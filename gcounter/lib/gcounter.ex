defmodule Gcounter do
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
    "init" ->
      node_id = get_in(data, ["body", "node_id"])
      :ok = MessageStore.set_node_id(node_id)
      Network.reply(data, %{type: "init_ok"})
  end
end
