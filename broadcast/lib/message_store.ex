defmodule MessageStore do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(args) do
    {:ok, args}
  end

  @impl true
  def handle_call({:add_message, msg}, _from, state) do
    {:reply, :ok, [msg | state]}
  end

  def handle_call(:get_messages, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def add_message(msg) do
    GenServer.call(__MODULE__, {:add_message, msg}, 10_000)
  end

  def get_messages() do
    GenServer.call(__MODULE__, :get_messages, 10_000)
  end
end
