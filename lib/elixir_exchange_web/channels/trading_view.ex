defmodule ElixirExchangeWeb.TradingView do
  use Phoenix.Channel
  require Logger

  @update_frequency 5000

  def join("trading:" <> pair, _message, socket) do
    socket = assign(socket, :pair, pair)
    send(self(), {:after_join, pair})
    {:ok, socket}
  end

  def handle_info({:after_join, pair}, socket) do
    push socket, "init", %{status: "connected", data: ElixirExchange.GraphData.init(pair)}
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end
end
