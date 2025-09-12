defmodule Gcounter.Main do
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
        nodes = get_in(data, ["body", "node_ids"])
        :ok = Node.Store.set_node_id(node_id)
        :ok = Node.Store.set_nodes(nodes)

        Network.reply(data, %{type: "init_ok"})

      "add" ->
        element = get_in(data, ["body", "element"])
        Gcounter.Store.add(element)
        Network.reply(data, %{type: "add_ok"})

      "read" ->
        Network.reply(data, %{type: "read_ok", value: Gcounter.Store.read()})

      "replicate" ->
        value = get_in(data, ["body", "value"])
        Gcounter.Store.merge(value)
        :no_reply
    end
  end
end
