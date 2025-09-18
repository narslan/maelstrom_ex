defmodule Publisher do
  alias AMQP.{Connection, Channel, Basic}

  def send_with_timestamp(queue, payload) do
    {:ok, conn} = Connection.open()
    {:ok, chan} = Channel.open(conn)

    # Queue deklarieren
    {:ok, _} = AMQP.Queue.declare(chan, queue)

    ts = System.system_time(:second)

    # Nachricht publizieren mit timestamp
    :ok =
      Basic.publish(
        chan,
        # exchange
        "",
        # routing_key
        queue,
        # body
        payload,
        timestamp: ts
      )

    Connection.close(conn)
  end
end
