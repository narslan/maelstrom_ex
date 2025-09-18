defmodule MyConsumer do
  use GenServer
  alias AMQP.{Connection, Channel, Basic, Queue}

  ## API

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue, name: __MODULE__)
  end

  ## GenServer callbacks

  @impl true
  def init(queue) do
    {:ok, conn} = Connection.open()
    {:ok, chan} = Channel.open(conn)

    # Queue deklarieren (idempotent)
    {:ok, _} = Queue.declare(chan, queue, durable: false)

    # Basic.consume registriert den Consumer-Prozess bei RabbitMQ
    {:ok, _consumer_tag} = Basic.consume(chan, queue)

    {:ok, %{chan: chan, conn: conn, queue: queue}}
  end

  @impl true
  def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, state) do
    IO.puts(" [x] Received #{payload}")
    process_message(payload)
    Basic.ack(state.chan, tag)
    {:noreply, state}
  end

  # RabbitMQ bestätigt die Consumer-Registrierung
  @impl true
  def handle_info({:basic_consume_ok, %{consumer_tag: _}}, state) do
    {:noreply, state}
  end

  # Falls ein Consumer vom Server abgemeldet wird
  @impl true
  def handle_info({:basic_cancel, %{consumer_tag: _}}, state) do
    IO.puts(" [x] Consumer cancelled")
    {:stop, :normal, state}
  end

  # Bestätigung, dass Cancel erfolgreich war
  @impl true
  def handle_info({:basic_cancel_ok, %{consumer_tag: _}}, state) do
    {:noreply, state}
  end

  # Catch-all für alles andere
  @impl true
  def handle_info(msg, state) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{conn: conn}) do
    Connection.close(conn)
    :ok
  end

  ## Hilfsfunktionen

  defp process_message(payload) do
    # hier kannst du das Payload parsen (JSON, CSV, etc.)
    IO.inspect(payload, label: "Processing")
  end
end
