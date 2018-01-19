defmodule ElixirExchange.OrderSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children =
      Enum.map(Application.fetch_env!(:elixir_exchange, :pairs), fn(pair)->
        sell_process = String.to_atom("sell_#{pair}")
        buy_process = String.to_atom("buy_#{pair}")
        [
          worker(ElixirExchange.OrderServer, [pair, "sell"], [id: sell_process]),
          worker(ElixirExchange.OrderServer, [pair, "buy"], [id: buy_process])
        ]
      end)
      |> List.flatten()

    supervise(children, strategy: :one_for_one)
  end
end
