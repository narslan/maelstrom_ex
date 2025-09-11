defmodule Network do
  def reply(data, reply_body) do
    body =
      reply_body
      |> Map.put(:in_reply_to, data["body"]["msg_id"])
      |> Map.put(:msg_id, Node.Store.next_msg_id())

    %{
      "src" => Node.Store.get_node_id(),
      "dest" => data["src"],
      "body" => body
    }
  end

  def send_message(dest, body) do
    msg = %{
      "src" => Node.Store.get_node_id(),
      "dest" => dest,
      "body" => body
    }

    IO.puts(encode_json_line(msg))
  end

  def encode_json_line(data) do
    JSON.encode!(data)
  end

  def decode_json_line(line) do
    IO.write(:stderr, "Received #{line}")

    case JSON.decode(line) do
      {:ok, data} ->
        data

      {:error, reason} ->
        %{"error" => reason, "input" => line}
    end
  end
end
