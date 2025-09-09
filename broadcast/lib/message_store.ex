defmodule MessageStore do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    state = %{messages: [], neighbors: [], node_id: nil, next_msg_id: 1}
    {:ok, state}
  end

  @impl true
  def handle_call({:add_message, msg}, _from, state) do
    {:reply, :ok, %{state | messages: [msg | state.messages]}}
  end

  def handle_call({:exists_message, msg}, _from, state) do
    {:reply, msg in state.messages, state}
  end

  def handle_call(:get_messages, _from, state) do
    {:reply, {:ok, state.messages}, state}
  end

  def handle_call(:get_neighbors, _from, state) do
    {:reply, state.neighbors, state}
  end

  def handle_call({:set_neighbors, topology}, _from, state) do
    neighbors = Map.fetch!(topology, state.node_id)
    {:reply, :ok, %{state | neighbors: neighbors}}
  end

  def handle_call({:set_node_id, node_id}, _from, state) do
    {:reply, :ok, %{state | node_id: node_id}}
  end

  def handle_call(:get_node_id, _from, state) do
    {:reply, state.node_id, state}
  end

  def handle_call(:next_msg_id, _from, state) do
    id = state.next_msg_id
    new_state = %{state | next_msg_id: id + 1}
    {:reply, id, new_state}
  end

  def add_message(msg) do
    GenServer.call(__MODULE__, {:add_message, msg}, 10_000)
  end

  def message_exists?(msg) do
    GenServer.call(__MODULE__, {:exists_message, msg}, 10_000)
  end

  def get_messages() do
    GenServer.call(__MODULE__, :get_messages, 10_000)
  end

  def set_node_id(id) do
    GenServer.call(__MODULE__, {:set_node_id, id}, 10_000)
  end

  def get_node_id() do
    GenServer.call(__MODULE__, :get_node_id, 10_000)
  end

  def set_neighbors(topology) do
    GenServer.call(__MODULE__, {:set_neighbors, topology}, 10_000)
  end

  def get_neighbors() do
    GenServer.call(__MODULE__, :get_neighbors, 10_000)
  end

  def next_msg_id() do
    GenServer.call(__MODULE__, :next_msg_id)
  end
end
