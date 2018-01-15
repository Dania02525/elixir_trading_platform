defmodule ElixirExchange.OrderCache do
  def start_link() do
    pid = :ets.new(:order_cache, [:set, :public, :named_table])
    {:ok, pid}
  end

  def get_orders(pair) do

  end

  def new_order(pair, order) do

  end

  def delete_order(pair, order_id) do

  end
end
