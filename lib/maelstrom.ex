defmodule Maelstrom.EchoCli do
  @moduledoc false
  def main(_args) do
    IO.stream(:stdio, :line)
    |> Stream.transform({nil, 1}, fn line, {node_id, counter} ->
      data = decode_json_line(line)
      {reply, new_node_id} = process(data, node_id, counter)
      encoded = encode_json_line(reply)
      {[encoded], {new_node_id, counter + 1}}
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

  defp process(data, node_id, counter) do
    case data["body"]["type"] do
      "init" ->
        new_node_id = data["body"]["node_id"]
        reply = reply(new_node_id, data, %{type: :init_ok}, counter)
        {reply, new_node_id}

      "echo" ->
        reply = reply(node_id, data, %{type: :echo_ok, echo: data["body"]["echo"]}, counter)
        {reply, node_id}
    end
  end

  defp reply(node_id, data, reply_body, counter) do
    body =
      reply_body
      |> Map.put(:in_reply_to, data["body"]["msg_id"])
      |> Map.put(:msg_id, counter)

    %{
      "src" => node_id,
      "dest" => data["src"],
      "body" => body
    }
  end

  defp encode_json_line(data) do
    JSON.encode!(data)
  end
end
