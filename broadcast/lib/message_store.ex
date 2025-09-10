defmodule MessageStore do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    state = %{
      messages: MapSet.new(),
      all_nodes: [],
      neighbors: [],
      node_id: nil,
      next_msg_id: 1
    }

    {:ok, state}
  end

  # --- Messages ---

  @impl true
  def handle_call({:add_message, msg}, _from, state) do
    {:reply, :ok, %{state | messages: MapSet.put(state.messages, msg)}}
  end

  def handle_call({:exists_message, msg}, _from, state) do
    {:reply, MapSet.member?(state.messages, msg), state}
  end

  def handle_call(:get_messages, _from, state) do
    {:reply, {:ok, MapSet.to_list(state.messages)}, state}
  end

  # --- Topology / Nodes ---

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

  def add_message(msg), do: GenServer.call(__MODULE__, {:add_message, msg})
  def message_exists?(msg), do: GenServer.call(__MODULE__, {:exists_message, msg})
  def get_messages(), do: GenServer.call(__MODULE__, :get_messages)

  def set_node_id(id), do: GenServer.call(__MODULE__, {:set_node_id, id})
  def get_node_id(), do: GenServer.call(__MODULE__, :get_node_id)

  def set_nodes(nodes), do: GenServer.call(__MODULE__, {:set_nodes, nodes})
  def get_all_nodes(), do: GenServer.call(__MODULE__, :get_all_nodes)
  def get_neighbors(), do: GenServer.call(__MODULE__, :get_neighbors)

  def next_msg_id(), do: GenServer.call(__MODULE__, :next_msg_id)

  # --- Topology Calculation ---
  defp compute_neighbors(nil, _nodes), do: []

  defp compute_neighbors(node_id, nodes) do
    size = length(nodes)

    cond do
      size < 10 ->
        Enum.filter(nodes, &(&1 != node_id))

      true ->
        index = Enum.find_index(nodes, &(&1 == node_id))

        left = Enum.at(nodes, rem(index - 1 + size, size))
        right = Enum.at(nodes, rem(index + 1, size))

        shortcuts =
          Stream.iterate(1, &(&1 * 2))
          |> Enum.take_while(&(&1 < size))
          |> Enum.map(fn step -> Enum.at(nodes, rem(index + step, size)) end)

        Enum.uniq([left, right | shortcuts])
    end
  end
end
