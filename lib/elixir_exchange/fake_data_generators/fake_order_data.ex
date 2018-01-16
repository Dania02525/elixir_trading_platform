defmodule ElixirExchange.FakeOrderData do
  @midprice 0.0653

  def market_price do
    @midprice
  end

  def fake_orders do
    if Process.whereis(:fake_orders) do
      Agent.get(:fake_orders, fn state -> state end)
    else
      fake_orders = gen_fake_orders(100)
      my_orders = [
        build_fake_order(%{side: "buy", status: "open", type: "limit", user_id: "4jB48zNGHIIr25CG"}),
        build_fake_order(%{side: "buy", status: "open", type: "limit", user_id: "4jB48zNGHIIr25CG"}),
        build_fake_order(%{side: "sell", status: "open", type: "limit", user_id: "4jB48zNGHIIr25CG"})
      ]

      orders =
        Enum.reduce(my_orders, fake_orders, fn(o, acc)->
          Map.put(acc, o.id, o)
        end)

      Agent.start(fn -> orders end, name: :fake_orders)
      orders
    end
  end

  def gen_fake_orders(count) do
    Enum.reduce((1..count), %{}, fn(_n, acc)->
      attr = build_fake_order()
      Map.put(acc, attr.id, attr)
    end)
  end

  def build_fake_order(attr \\ %{}) do
    id = Map.get(attr, :id) || random_id()
    type = Map.get(attr, :type) || random_type()
    side = Map.get(attr, :side) || random_side()
    status = Map.get(attr, :status) || random_status()
    quantity = Map.get(attr, :quantity) || random_quantity()
    unfilled_quantity = Map.get(attr, :unfilled_quantity) || random_unfilled_quantity(quantity, status)
    price = Map.get(attr, :price) || random_price(type, side)
    user_id = Map.get(attr, :user_id) || random_user_id()
    created = Map.get(attr, :created) || random_created()

    %{
      id: id,
      pair: "xrb:xlm",
      type: type,
      side: side,
      status: status,
      quantity: quantity,
      unfilled_quantity: unfilled_quantity,
      price: price,
      user_id: user_id,
      created: created
    }
  end

  def random_id do
    :crypto.strong_rand_bytes(16) |> Base.url_encode64 |> binary_part(0, 16)
  end

  def random_type do
    case :rand.uniform(2) do
      1 -> "market"
      2 -> "limit"
    end
  end

  def random_side do
    case :rand.uniform(2) do
      1 -> "buy"
      2 -> "sell"
    end
  end

  def random_status do
    case :rand.uniform(4) do
      1 -> "open"
      2 -> "filled"
      3 -> "partially_filled"
      4 -> "canceled"
    end
  end

  def random_quantity do
    # 31.xx - 2030.xx
    :rand.uniform(2000) + 30 + ((:rand.uniform(10) - 1) / :rand.uniform(20))
  end

  def random_unfilled_quantity(quantity, status) do
    case status do
      "open" -> quantity
      "canceled" -> quantity
      "filled" -> 0
      "partially_filled" -> quantity * (:rand.uniform(99) / 100)
    end
  end

  def random_price(type, side) do
    case [type, side] do
      ["market", _] -> @midprice
      [_, "buy"] -> @midprice * (1 - (:rand.uniform(15) / 100))
      [_, "sell"] -> @midprice * (1 + (:rand.uniform(15) / 100))
    end
  end

  def random_user_id do
    :crypto.strong_rand_bytes(16) |> Base.url_encode64 |> binary_part(0, 16)
  end

  def random_created do
    :os.system_time() + :rand.uniform(20000)
  end
end
