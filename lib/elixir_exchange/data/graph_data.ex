defmodule ElixirExchange.GraphData do
  require Logger

  def query_history(pair) do
    # query the trade history for this pair
    Logger.debug "> caching trade history"
    ElixirExchange.FakeGraphData.gen_fake_history(150)
  end

  # this should be done each minute
  def store_latest_trade_data do
    Logger.debug "> storing trade datapoint"
    # calculate latest trade data from orders
    Application.fetch_env!(:elixir_exchange, :pairs)
    |> Enum.each(fn(pair)->
      prev = List.first(ElixirExchange.GraphCache.get_history(pair))
      new_data = ElixirExchange.FakeGraphData.gen_forward_datapoint(prev)
      ElixirExchange.GraphCache.push_datapoint(pair, new_data)
      broadcast_new_datapoint(pair, new_data)
    end)
  end

  def cached_history(pair) do
    ElixirExchange.GraphCache.get_history(pair)
  end

  defp broadcast_new_datapoint(pair, data) do
    Logger.debug "> broadcasting trade datapoint"
    ElixirExchangeWeb.Endpoint.broadcast("trading:#{pair}", "update", %{data: data})
  end
end
