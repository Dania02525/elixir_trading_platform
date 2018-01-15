defmodule ElixirExchangeWeb.TradingView do
  use Phoenix.Channel
  require Logger

  def join("trading:" <> pair, _message, socket) do
    if Enum.member?(Application.fetch_env!(:elixir_exchange, :pairs), pair) do
      socket = assign(socket, :pair, pair)
      send(self(), {:after_join, pair})
      {:ok, socket}
    else
      {:error, %{reason: "#{pair} is not a valid trading pair"}}
    end
  end


  def handle_info({:after_join, pair}, socket) do
    push socket, "init", %{status: "connected", data: ElixirExchange.GraphData.cached_history(pair)}
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end
end
