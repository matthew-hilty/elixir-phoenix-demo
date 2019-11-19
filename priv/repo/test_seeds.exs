alias Demo.OrderStates

[{:ok, _active}, {:ok, _canceled}, {:ok, _delivered}, {:ok, _undeliverable}] =
  Enum.map(
    ~w(active canceled delivered undeliverable)s,
    fn (description) ->
      OrderStates.create_order_state(%{description: description})
    end)
