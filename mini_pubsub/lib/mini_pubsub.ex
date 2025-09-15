defmodule MiniPubSub do
  @doc "Startet das PubSub-System (intern :pg)"
  def start_link(name \\ __MODULE__) do
    :pg.start_link(name)
  end

  @doc "Ein Prozess abonniert ein Topic"
  def subscribe(topic, name \\ __MODULE__) do
    :pg.join(name, topic, self())
  end

  @doc "Ein Prozess deabonniert ein Topic"
  def unsubscribe(topic, name \\ __MODULE__) do
    :pg.leave(name, topic, self())
  end

  @doc "Nachricht an alle Subscriber eines Topics senden"
  def broadcast(topic, message, name \\ __MODULE__) do
    for pid <- :pg.get_members(name, topic) do
      send(pid, {:pubsub, topic, message})
    end

    :ok
  end

  @doc "Alle Subscriber eines Topics abfragen"
  def subscribers(topic, name \\ __MODULE__) do
    :pg.get_members(name, topic)
  end
end
