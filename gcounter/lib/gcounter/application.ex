defmodule Gcounter.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Node.Store,
      Gcounter.Store,
      Replicate
    ]

    opts = [strategy: :one_for_one, name: Gcounter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
