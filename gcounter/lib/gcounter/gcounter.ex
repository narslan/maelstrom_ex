defmodule Gcounter.Store do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    state = MapSet.new()

    {:ok, state}
  end

  @impl true
  def handle_cast({:merge, values}, state) do
    state = MapSet.union(state, MapSet.new(values))

    {:noreply, state}
  end

  def handle_cast({:add, msg}, state) do
    state = MapSet.put(state, msg)
    {:noreply, state}
  end

  @impl true
  def handle_call(:read, _from, state) do
    {:reply, MapSet.to_list(state), state}
  end

  def add(msg) do
    GenServer.cast(__MODULE__, {:add, msg})
  end

  def read() do
    GenServer.call(__MODULE__, :read)
  end

  def merge(values) do
    GenServer.cast(__MODULE__, {:merge, values})
  end
end
