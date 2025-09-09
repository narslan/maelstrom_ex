defmodule Broadcast do
  @moduledoc false
  def main(_args) do
    IO.stream(:stdio, :line)
    |> Stream.transform(1, fn line, counter ->
      data = decode_json_line(line)

      case process(data, counter) do
        :no_reply ->
          {[], counter}

        reply ->
          encoded = encode_json_line(reply)
          {[encoded], counter + 1}
      end
    end)
    |> Stream.each(&IO.puts/1)
    |> Stream.run()
  end

  defp decode_json_line(line) do
    IO.write(:stderr, "Received #{line}")

    case JSON.decode(line) do
      {:ok, data} ->
        data

      {:error, reason} ->
        %{"error" => reason, "input" => line}
    end
  end

  defp process(data, counter) do
    case data["body"]["type"] do
      "init" ->
        new_node_id = data["body"]["node_id"]
        :ok = MessageStore.set_node_id(new_node_id)
        reply(data, %{type: :init_ok}, counter)

      "echo" ->
        reply(data, %{type: :echo_ok, echo: data["body"]["echo"]}, counter)

      "broadcast" ->
        m = data["body"]["message"]

        unless MessageStore.message_exists?(m) do
          :ok = MessageStore.add_message(data["body"]["message"])

          MessageStore.get_neighbors()
          |> Enum.each(fn neighbor ->
            send_message(neighbor, %{type: :broadcast, message: m})
          end)
        end

        if data["body"]["msg_id"] do
          reply(data, %{type: :broadcast_ok}, counter)
        else
          :no_reply
        end

      "read" ->
        {:ok, msgs} = MessageStore.get_messages()

        reply(data, %{type: :read_ok, messages: msgs}, counter)

      "topology" ->
        :ok = MessageStore.set_neighbors(data["body"]["topology"])
        reply(data, %{type: :topology_ok}, counter)
    end
  end

  defp reply(data, reply_body, counter) do
    body =
      reply_body
      |> Map.put(:in_reply_to, data["body"]["msg_id"])
      |> Map.put(:msg_id, counter)

    %{
      "src" => MessageStore.get_node_id(),
      "dest" => data["src"],
      "body" => body
    }
  end

  defp send_message(dest, body) do
    msg = %{
      "src" => MessageStore.get_node_id(),
      "dest" => dest,
      "body" => body
    }

    IO.puts(encode_json_line(msg))
  end

  defp encode_json_line(data) do
    JSON.encode!(data)
  end
end
