defmodule ElixirExchange.FormatHelpers do
  def collapse_orders(orders) do
    Enum.reduce(orders, %{}, fn(o, acc)->
      existing = Map.get(acc, o.price)
      if existing do
        order = %{
          price: o.price,
          quantity: existing.quantity + o.unfilled_quantity
        }
        Map.put(acc, o.price, order)
      else
        order = %{
            price: o.price,
            quantity: o.unfilled_quantity
          }
        Map.put(acc, o.price, order)
      end
    end)
    |> Enum.map(fn {_k, v}->
      v
    end)
  end
end
