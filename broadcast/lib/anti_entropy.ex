defmodule AntiEntropy do
  use GenServer
  @interval 500

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{started: false}}
  end

  @impl true
  def handle_cast(:start, state) do
    schedule_tick()
    {:noreply, %{state | started: true}}
  end

  @impl true
  def handle_info(:tick, %{started: true} = state) do
    {:ok, messages} = MessageStore.get_messages()
    neighbors = MessageStore.get_neighbors()

    Enum.each(neighbors, fn neighbor ->
      msg_id = MessageStore.next_msg_id()
      body = %{"type" => "anti_entropy", "messages" => messages, "msg_id" => msg_id}
      Network.send_message(neighbor, body)
    end)

    schedule_tick()
    {:noreply, state}
  end

  def handle_info(:tick, state), do: {:noreply, state}

  defp schedule_tick(), do: Process.send_after(self(), :tick, @interval)
end
