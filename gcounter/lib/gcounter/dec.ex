defmodule Gcounter.Store.Dec do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    state = %{}

    {:ok, state}
  end

  @impl true
  def handle_cast({:merge, values}, state) do
    state =
      Map.merge(state, values, fn _k, v1, v2 ->
        max(v1, v2)
      end)

    {:noreply, state}
  end

  def handle_cast({:add, delta}, state) do
    node_id = Node.Store.get_node_id()
    state = Map.update(state, node_id, 0, fn existing_value -> existing_value + delta end)
    {:noreply, state}
  end

  @impl true
  def handle_call(:read, _from, state) do
    sum = Map.values(state) |> Enum.sum()
    {:reply, sum, state}
  end

  def add(delta) do
    GenServer.cast(__MODULE__, {:add, delta})
  end

  def read() do
    GenServer.call(__MODULE__, :read)
  end

  def merge(values) do
    GenServer.cast(__MODULE__, {:merge, values})
  end
end
