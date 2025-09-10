defmodule Broadcast.Application do
  use Application

  def start(_, _) do
    children = [
      MessageStore,
      AntiEntropy
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
