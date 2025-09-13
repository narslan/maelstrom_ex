defmodule SingleNode.Main do
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

      "txn" ->
        txn = get_in(data, ["body", "txn"])

        IO.write(
          :stderr,
          "Txn: #{inspect(txn)}\n"
        )

        txn2 = Transactor.transact(txn)
        Network.reply(data, %{type: "txn_ok", txn: txn2})

      "no_reply" ->
        :no_reply
    end
  end
end
