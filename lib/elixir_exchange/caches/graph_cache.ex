defmodule ElixirExchange.GraphCache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(_) do
    :ets.new(:graph_cache, [:set, :public, :named_table])
    init_cache()
    {:ok, []}
  end

  def get_history(pair) do
    {_key, val} = List.first(:ets.lookup(:graph_cache, pair))
    val
  end

  def push_datapoint(pair, datapoint) do
    history =
      get_history(pair)
      |> Enum.reverse
      |> List.delete_at(0)
      |> Enum.reverse

    :ets.insert(:graph_cache, {pair, [ datapoint | history]})
  end

  defp init_cache do
    Application.fetch_env!(:elixir_exchange, :pairs)
    |> Enum.each(fn(pair)->
      :ets.insert(:graph_cache, {pair, ElixirExchange.GraphData.query_history(pair)})
    end)
  end
end
