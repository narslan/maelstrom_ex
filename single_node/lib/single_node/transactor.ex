defmodule Transactor do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:transact, ops}, _from, state) do
    {txn_acc, new_state} =
      Enum.reduce(ops, {[], state}, fn
        ["r", k, _v], {acc, st} ->
          value = Map.get(st, k, [])
          {[["r", k, value] | acc], st}

        ["append", k, v] = op, {acc, st} ->
          new_list = Map.get(st, k, []) ++ [v]
          {[op | acc], Map.put(st, k, new_list)}
      end)

    txn2 = Enum.reverse(txn_acc)
    {:reply, txn2, new_state}
  end

  def transact(transactions) do
    GenServer.call(__MODULE__, {:transact, transactions})
  end
end
