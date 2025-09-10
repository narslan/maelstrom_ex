defmodule Broadcast do
  @moduledoc false
  def main(_args) do
    IO.stream(:stdio, :line)
    |> Stream.each(&handle_line/1)
    |> Stream.run()
  end

  defp handle_line(line) do
    data = Network.decode_json_line(line)

    case process(data) do
      :no_reply ->
        :ok

      reply ->
        IO.puts(Network.encode_json_line(reply))
        :ok
    end
  end

  defp process(data) do
    case data["body"]["type"] do
      "init" ->
        node_id = get_in(data, ["body", "node_id"])
        :ok = MessageStore.set_node_id(node_id)
        GenServer.cast(AntiEntropy, :start)
        Network.reply(data, %{type: "init_ok"})

      "broadcast" ->
        m = get_in(data, ["body", "message"])

        unless MessageStore.message_exists?(m) do
          :ok = MessageStore.add_message(m)

          Task.start(fn ->
            neighbors = MessageStore.get_neighbors()

            fanout = max(2, div(length(neighbors), 4))
            targets = Enum.take_random(neighbors, fanout)

            Enum.each(targets, fn neighbor ->
              if neighbor != data["src"] do
                msg_id = MessageStore.next_msg_id()
                body = %{"type" => "broadcast", "message" => m, "msg_id" => msg_id}
                Network.send_message(neighbor, body)
              end
            end)
          end)
        end

        if get_in(data, ["body", "msg_id"]) do
          Network.reply(data, %{type: "broadcast_ok"})
        else
          :no_reply
        end

      "read" ->
        {:ok, msgs} = MessageStore.get_messages()
        Network.reply(data, %{type: :read_ok, messages: msgs})

      "anti_entropy" ->
        incoming = data["body"]["messages"]

        Enum.each(incoming, fn m ->
          unless MessageStore.message_exists?(m) do
            :ok = MessageStore.add_message(m)
          end
        end)

        :no_reply

      "topology" ->
        nodes = Map.keys(get_in(data, ["body", "topology"]))
        :ok = MessageStore.set_nodes(nodes)
        Network.reply(data, %{type: "topology_ok"})

      "broadcast_ok" ->
        :no_reply
    end
  end
end
