defmodule Node.Store do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    state = %{
      all_nodes: [],
      neighbors: [],
      node_id: nil,
      next_msg_id: 1
    }

    {:ok, state}
  end

  # --- Topology / Nodes ---

  @impl true
  def handle_call({:set_nodes, nodes}, _from, state) do
    neighbors = compute_neighbors(state.node_id, nodes)
    {:reply, :ok, %{state | all_nodes: nodes, neighbors: neighbors}}
  end

  def handle_call(:get_all_nodes, _from, state) do
    {:reply, state.all_nodes, state}
  end

  def handle_call(:get_neighbors, _from, state) do
    {:reply, state.neighbors, state}
  end

  def handle_call({:set_node_id, node_id}, _from, state) do
    neighbors = compute_neighbors(node_id, state.all_nodes)
    {:reply, :ok, %{state | node_id: node_id, neighbors: neighbors}}
  end

  def handle_call(:get_node_id, _from, state) do
    {:reply, state.node_id, state}
  end

  # --- Msg IDs ---

  def handle_call(:next_msg_id, _from, state) do
    id = state.next_msg_id
    new_state = %{state | next_msg_id: id + 1}
    {:reply, id, new_state}
  end

  # --- API ---
  def set_node_id(id), do: GenServer.call(__MODULE__, {:set_node_id, id})
  def get_node_id(), do: GenServer.call(__MODULE__, :get_node_id)

  def set_nodes(nodes), do: GenServer.call(__MODULE__, {:set_nodes, nodes})
  def get_all_nodes(), do: GenServer.call(__MODULE__, :get_all_nodes)
  def get_neighbors(), do: GenServer.call(__MODULE__, :get_neighbors)

  def next_msg_id(), do: GenServer.call(__MODULE__, :next_msg_id)

  # --- Topology Calculation ---

  defp compute_neighbors(node_id, nodes) do
    if node_id == nil do
      []
    else
      Enum.filter(nodes, &(&1 != node_id))
    end
  end
end
