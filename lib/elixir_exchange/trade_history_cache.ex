defmodule ElixirExchange.TradeHistoryCache do
  @update_interval 3000

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    update_interval()
    {:ok, init_trade_data()}
  end

  def init_trade_data do
    %{
      "xrb:xlm" => ElixirExchange.GraphData.gen_fake_history(75)
    }
  end

  def get_history(pair) do
    Map.get(GenServer.call(__MODULE__, :get_history), pair)
    |> Enum.map(fn(e)->
      Map.put(e, :date, DateTime.to_iso8601(e.date))
    end)
  end

  def handle_call(:get_history, _caller, state) do
    {:reply, state, state}
  end

  def handle_info(:update, state) do
    prev = Map.get(state, "xrb:xlm") |> List.first
    new_datapoint = ElixirExchange.GraphData.gen_forward_datapoint(prev)
    state = update_state(state, new_datapoint)
    broadcast_update_pairs(new_datapoint)
    update_interval()
    {:noreply, state}
  end

  defp broadcast_update_pairs(data) do
    ElixirExchangeWeb.Endpoint.broadcast("trading:xrb:xlm", "update", %{data: Map.put(data, :date, DateTime.to_iso8601(data.date))})
  end

  defp update_state(state, new_datapoint) do
    Map.put(state, "xrb:xlm", shift_history(state["xrb:xlm"], new_datapoint))
  end

  defp shift_history(history, new_datapoint) do
    history
    |> Enum.reverse
    |> List.delete_at(0)
    |> Enum.reverse

    [ new_datapoint | history ]
  end

  defp update_interval() do
    Process.send_after(self(), :update, @update_interval)
  end
end
