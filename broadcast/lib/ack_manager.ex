defmodule AckManager do
  use GenServer

  @retry_interval 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def track(msg_id, neighbor, message) do
    GenServer.cast(__MODULE__, {:track, msg_id, neighbor, message})
  end

  def ack(msg_id) do
    GenServer.cast(__MODULE__, {:ack, msg_id})
  end

  @impl true
  def init(state) do
    schedule_retry()
    {:ok, state}
  end

  @impl true
  def handle_cast({:track, msg_id, neighbor, message}, state) do
    new_state = Map.put(state, msg_id, {neighbor, message})
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:ack, msg_id}, state) do
    new_state = Map.delete(state, msg_id)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:retry, state) do
    Enum.each(state, fn {msg_id, {neighbor, message}} ->
      IO.puts(:stderr, "Retrying #{inspect(message)} to #{neighbor}")
      Network.send_message(neighbor, Map.put(message, :msg_id, msg_id))
    end)

    schedule_retry()
    {:noreply, state}
  end

  defp schedule_retry() do
    Process.send_after(self(), :retry, @retry_interval)
  end
end
