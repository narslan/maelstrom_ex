defmodule Replicate do
  use GenServer
  @interval 500

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_tick()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:tick, state) do
    neighbors = Node.Store.get_neighbors()

    # call einmal
    snapshot = Gcounter.Store.read()

    IO.write(
      :stderr,
      "[REPL] tick sending snapshot (size=#{length(snapshot)}) to #{length(neighbors)} neighbors\n"
    )

    Enum.each(neighbors, fn neighbor ->
      msg_id = Node.Store.next_msg_id()

      body = %{
        "type" => "replicate",
        "value" => snapshot,
        "msg_id" => msg_id
      }

      Network.send_message(neighbor, body)
    end)

    schedule_tick()
    {:noreply, state}
  end

  defp schedule_tick(), do: Process.send_after(self(), :tick, @interval)
end
