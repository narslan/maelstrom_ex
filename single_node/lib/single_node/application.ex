defmodule SingleNode.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Transactor,
      Node.Store
    ]

    opts = [strategy: :one_for_one, name: SingleNode.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
