defmodule ElixirExchangeWeb.TradingView do
  use Phoenix.Channel
  require Logger
  import ElixirExchange.FormatHelpers

  def join("trading:" <> pair, _message, socket) do
    if Enum.member?(Application.fetch_env!(:elixir_exchange, :pairs), pair) do
      send(self(), {:after_join, pair})
      {:ok, socket}
    else
      {:error, %{reason: "#{pair} is not a valid trading pair"}}
    end
  end

  def handle_info({:after_join, pair}, socket) do
    push socket, "init", %{
      status: "connected",
      market_price: ElixirExchange.OrderData.market_price(pair),
      graph_data: ElixirExchange.GraphData.cached_history(pair),
      order_data: %{
        buys: collapse_orders(ElixirExchange.OrderServer.buy_orders(pair)),
        sells: collapse_orders(ElixirExchange.OrderServer.sell_orders(pair)),
        my_orders: my_orders(socket, pair)
      }
    }
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  defp my_orders(socket, pair) do
    if socket.assigns[:current_user] do
      ElixirExchange.OrderData.orders_by_user(pair, socket.assigns[:current_user])
    else
      []
    end
  end
end
