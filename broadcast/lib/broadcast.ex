defmodule Broadcast do
  @moduledoc false
  def main(_args) do
    IO.stream(:stdio, :line)
    |> Stream.transform(1, fn line, counter ->
      data = Network.decode_json_line(line)

      case process(data, counter) do
        :no_reply ->
          {[], counter}

        reply ->
          encoded = Network.encode_json_line(reply)
          {[encoded], counter + 1}
      end
    end)
    |> Stream.each(&IO.puts/1)
    |> Stream.run()
  end

  defp process(data, counter) do
    case data["body"]["type"] do
      "init" ->
        new_node_id = data["body"]["node_id"]
        :ok = MessageStore.set_node_id(new_node_id)
        Network.reply(data, %{type: :init_ok}, counter)

      "echo" ->
        Network.reply(data, %{type: :echo_ok, echo: data["body"]["echo"]}, counter)

      "broadcast" ->
        m = data["body"]["message"]

        unless MessageStore.message_exists?(m) do
          :ok = MessageStore.add_message(data["body"]["message"])

          MessageStore.get_neighbors()
          |> Enum.each(fn neighbor ->
            Network.send_message(neighbor, %{type: :broadcast, message: m})
          end)
        end

        if data["body"]["msg_id"] do
          Network.reply(data, %{type: :broadcast_ok}, counter)
        else
          :no_reply
        end

      "read" ->
        {:ok, msgs} = MessageStore.get_messages()

        Network.reply(data, %{type: :read_ok, messages: msgs}, counter)

      "topology" ->
        :ok = MessageStore.set_neighbors(data["body"]["topology"])
        Network.reply(data, %{type: :topology_ok}, counter)
    end
  end
end
