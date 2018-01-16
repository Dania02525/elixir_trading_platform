defmodule ElixirExchange.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(ElixirExchange.Repo, []),
      # Start the endpoint when the application starts
      supervisor(ElixirExchangeWeb.Endpoint, []),

      worker(ElixirExchange.GraphCache, []),
      worker(ElixirExchange.OrderCache, []),
      worker(ElixirExchange.Cron, [[
        %{
          module: ElixirExchange.GraphData,
          function: :store_latest_trade_data,
          params: [],
          interval: 3000
        }
      ]]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirExchange.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ElixirExchangeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
