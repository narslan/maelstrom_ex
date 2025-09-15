defmodule MiniPubSubTest do
  use ExUnit.Case

  test "broadcast delivers to subscribers" do
    # Testprozess subscribed sich
    MiniPubSub.subscribe()

    # Nachricht verschicken
    MiniPubSub.broadcast("Ping!")

    # Nachricht abholen
    assert_receive {:got_msg, _from, "Ping!"}
  end

  test "multiple subscribers get the message" do
    parent = self()

    # Starte zweiten Subscriber-Prozess
    spawn(fn ->
      MiniPubSub.subscribe()
      send(parent, :ready)

      receive do
        msg -> send(parent, {:child_got, msg})
      end
    end)

    # Warte bis child subscribed ist
    assert_receive :ready

    # Parent subscribed auch
    MiniPubSub.subscribe()
    MiniPubSub.broadcast("Hello!")

    # beide sollten bekommen
    assert_receive {:got_msg, _, "Hello!"}
    assert_receive {:child_got, {:got_msg, _, "Hello!"}}
  end
end
