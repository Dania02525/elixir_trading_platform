defmodule ElixirExchange.OrderFillerTest do
  use ExUnit.Case, async: true

  alias ElixirExchange.OrderFiller

  @limit_sell_order1 %{type: "limit", side: "sell", quantity: 100, unfilled_quantity: 100, status: "unfilled", price: 100}
  @limit_sell_order2 %{type: "limit", side: "sell", quantity: 100, unfilled_quantity: 100, status: "unfilled", price: 99}
  @limit_sell_order3 %{type: "limit", side: "sell", quantity: 100, unfilled_quantity: 100, status: "unfilled", price: 98}

  @limit_sell_order_set [@limit_sell_order3, @limit_sell_order2, @limit_sell_order1]

  @limit_sell_order4 %{type: "limit", side: "sell", quantity: 99, unfilled_quantity: 99, status: "unfilled", price: 97}
  @limit_sell_order5 %{type: "limit", side: "sell", quantity: 101, unfilled_quantity: 101, status: "unfilled", price: 97}
  @limit_sell_order6 %{type: "limit", side: "sell", quantity: 101, unfilled_quantity: 101, status: "unfilled", price: 96}
  @limit_sell_order7 %{type: "limit", side: "sell", quantity: 301, unfilled_quantity: 301, status: "unfilled", price: 95}

  @limit_buy_order1 %{type: "limit", side: "buy", quantity: 100, unfilled_quantity: 100, status: "unfilled", price: 97}
  @limit_buy_order2 %{type: "limit", side: "buy", quantity: 100, unfilled_quantity: 100, status: "unfilled", price: 96}
  @limit_buy_order3 %{type: "limit", side: "buy", quantity: 100, unfilled_quantity: 100, status: "unfilled", price: 95}

  @limit_buy_order_set [@limit_buy_order1, @limit_buy_order2, @limit_buy_order3]

  @limit_buy_order4 %{type: "limit", side: "buy", quantity: 99, unfilled_quantity: 99, status: "unfilled", price: 98}
  @limit_buy_order5 %{type: "limit", side: "buy", quantity: 101, unfilled_quantity: 101, status: "unfilled", price: 98}
  @limit_buy_order6 %{type: "limit", side: "buy", quantity: 101, unfilled_quantity: 101, status: "unfilled", price: 99}
  @limit_buy_order7 %{type: "limit", side: "buy", quantity: 301, unfilled_quantity: 301, status: "unfilled", price: 100}

  @market_sell_order1 %{type: "market", side: "sell", quantity: 99, unfilled_quantity: 99, status: "unfilled"}
  @market_sell_order2 %{type: "market", side: "sell", quantity: 101, unfilled_quantity: 101, status: "unfilled"}
  @market_sell_order3 %{type: "market", side: "sell", quantity: 301, unfilled_quantity: 301, status: "unfilled"}

  @market_buy_order1 %{type: "market", side: "buy", quantity: 99, unfilled_quantity: 99, status: "unfilled"}
  @market_buy_order2 %{type: "market", side: "buy", quantity: 101, unfilled_quantity: 101, status: "unfilled"}
  @market_buy_order3 %{type: "market", side: "buy", quantity: 301, unfilled_quantity: 301, status: "unfilled"}

  # market buy order tests

  test "fill market buy order fully from part of limit sell order" do
    [order, orders] = OrderFiller.fill_order(@market_buy_order1, @limit_sell_order_set)
    assert order.unfilled_quantity == 0
    assert order.status == "filled"
    assert List.first(orders).unfilled_quantity == 1
    assert List.first(orders).status == "partially_filled"
  end

  test "fill market buy order fully from whole plus part of limit sell order" do
    [order, orders] = OrderFiller.fill_order(@market_buy_order2, @limit_sell_order_set)
    assert order.unfilled_quantity == 0
    assert order.status == "filled"
    [o1 | t1] = orders
    [o2 | _t2] = t1
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 99
    assert o2.status == "partially_filled"
  end

  test "fill market buy order partially from whole limit sell orders and leave open" do
    [order, orders] = OrderFiller.fill_order(@market_buy_order3, @limit_sell_order_set)
    assert order.unfilled_quantity == 1
    assert order.status == "partially_filled"
    [o1 | t1] = orders
    [o2 | t2] = t1
    [o3 | _t3] = t2
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 0
    assert o2.status == "filled"
    assert o3.unfilled_quantity == 0
    assert o3.status == "filled"
  end

  # market sell order tests

  test "fill market sell order fully from part of limit buy order" do
    [order, orders] = OrderFiller.fill_order(@market_sell_order1, @limit_buy_order_set)
    assert order.unfilled_quantity == 0
    assert order.status == "filled"
    assert List.first(orders).unfilled_quantity == 1
    assert List.first(orders).status == "partially_filled"
  end

  test "fill market sell order fuly from whole plus part of limit buy order" do
    [order, orders] = OrderFiller.fill_order(@market_sell_order2, @limit_buy_order_set)
    assert order.unfilled_quantity == 0
    assert order.status == "filled"
    [o1 | t1] = orders
    [o2 | _t2] = t1
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 99
    assert o2.status == "partially_filled"
  end

  test "fill market sell order partially from whole limit buy orders and leave open" do
    [order, orders] = OrderFiller.fill_order(@market_sell_order3, @limit_buy_order_set)
    assert order.unfilled_quantity == 1
    assert order.status == "partially_filled"
    [o1 | t1] = orders
    [o2 | t2] = t1
    [o3 | _t3] = t2
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 0
    assert o2.status == "filled"
    assert o3.unfilled_quantity == 0
    assert o3.status == "filled"
  end

  # limit buy order tests

  test "fill limit buy order fully from part of limit sell order" do
    [order, orders] = OrderFiller.fill_order(@limit_buy_order4, @limit_sell_order_set)
    assert order.unfilled_quantity == 0
    assert order.status == "filled"
    assert List.first(orders).unfilled_quantity == 1
    assert List.first(orders).status == "partially_filled"
  end

  test "fill limit buy order partially from whole limit sell order" do
    [order, orders] = OrderFiller.fill_order(@limit_buy_order5, @limit_sell_order_set)
    assert order.unfilled_quantity == 1
    assert order.status == "partially_filled"
    [o1 | t1] = orders
    [o2 | _t2] = t1
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 100
    assert o2.status == "unfilled"
  end

  test "fill limit buy order fully from whole plus part of limit sell order" do
    [order, orders] = OrderFiller.fill_order(@limit_buy_order6, @limit_sell_order_set)
    assert order.unfilled_quantity == 0
    assert order.status == "filled"
    [o1 | t1] = orders
    [o2 | _t2] = t1
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 99
    assert o2.status == "partially_filled"
  end

  test "fill limit buy order partially from whole limit sell orders" do
    [order, orders] = OrderFiller.fill_order(@limit_buy_order7, @limit_sell_order_set)
    assert order.unfilled_quantity == 1
    assert order.status == "partially_filled"
    [o1 | t1] = orders
    [o2 | t2] = t1
    [o3 | _t3] = t2
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 0
    assert o2.status == "filled"
    assert o3.unfilled_quantity == 0
    assert o3.status == "filled"
  end

  # limit sell order tests

  test "fill limit sell order fully from part of limit buy order" do
    [order, orders] = OrderFiller.fill_order(@limit_sell_order4, @limit_buy_order_set)
    assert order.unfilled_quantity == 0
    assert order.status == "filled"
    assert List.first(orders).unfilled_quantity == 1
    assert List.first(orders).status == "partially_filled"
  end

  test "fill limit sell order partially from whole limit buy order" do
    [order, orders] = OrderFiller.fill_order(@limit_sell_order5, @limit_buy_order_set)
    assert order.unfilled_quantity == 1
    assert order.status == "partially_filled"
    [o1 | t1] = orders
    [o2 | _t2] = t1
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 100
    assert o2.status == "unfilled"
  end

  test "fill limit sell order fully from whole plus part of limit buy order" do
    [order, orders] = OrderFiller.fill_order(@limit_sell_order6, @limit_buy_order_set)
    assert order.unfilled_quantity == 0
    assert order.status == "filled"
    [o1 | t1] = orders
    [o2 | _t2] = t1
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 99
    assert o2.status == "partially_filled"
  end

  test "fill limit sell order partially from whole limit buy orders" do
    [order, orders] = OrderFiller.fill_order(@limit_sell_order7, @limit_buy_order_set)
    assert order.unfilled_quantity == 1
    assert order.status == "partially_filled"
    [o1 | t1] = orders
    [o2 | t2] = t1
    [o3 | _t3] = t2
    assert o1.unfilled_quantity == 0
    assert o1.status == "filled"
    assert o2.unfilled_quantity == 0
    assert o2.status == "filled"
    assert o3.unfilled_quantity == 0
    assert o3.status == "filled"
  end
end
