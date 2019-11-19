defmodule Demo.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  import Utilities,
    only: [ map_error: 2,
            map_value: 2,
            modify_if: 3,
            prohibit_nil: 2,
          ]

  alias Demo.Repo
  alias Demo.Orders.Order
  alias Demo.OrderStates
  alias Demo.OrderStates.OrderState
  alias Ecto.Changeset

  @no_resource :no_resource
  @active_order_state_id 1

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders(%{})
      [%Order{}, ...]

      iex> list_orders(%{pickup_date: :all})
      [%Order{}, ...]

      iex> list_orders(%{pickup_date: %Date{year: _, month: _, day: _}})
      [%Order{}, ...]

      iex> list_orders(%{order_state_description: :all})
      [%Order{}, ...]

      iex> list_orders(%{order_state_description: "active"})
      [%Order{}, ...]

      iex> list_orders(%{patient_id: :all})
      [%Order{}, ...]

      iex> list_orders(%{patient_id: 1})
      [%Order{}, ...]

      iex> list_orders(%{courier_id: 1, pharmacy_id: 1})
      [%Order{}, ...]

      iex> list_orders(%{courier_id: 1, pickup_date: :all, pharmacy_id: 1})
      [%Order{}, ...]

  """
  def list_orders(params), do: Repo.all(create_query(params))

  @doc """
  Gets a single order.

  ## Examples

      iex> get_order(123)
      {:ok, %Order{}}

      iex> get_order(456)
      {:error, :no_resource}

  """
  def get_order(id) do
    Order
    |> Repo.get(id)
    |> Repo.preload([:patient, :pharmacy, :courier, :order_state])
    |> prohibit_nil(@no_resource)
    |> map_value(&set_order_state_description/1)
  end

  @doc """
  Creates an order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Changeset.put_change(:order_state_id, @active_order_state_id)
    |> Repo.insert()
    |> map_value(fn (order) ->
          Repo.preload(order, [:patient, :pharmacy, :courier, :order_state])
        end)
  end

  @doc """
  Updates an order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates an order's order_state.

  ## Examples

      iex> update_order_state(%Order{order_state_description: "active"}, "canceled")
      {:ok, %Order{order_state_description: "canceled"}}

      iex> update_order_state(order, "random_invalid_order_state_description")
      {:error, :invalid_order_state}

  """
  def update_order_state(%Order{} = order, order_state_description) do
    order
    |> Order.changeset(%{order_state_description: order_state_description})
    |> Repo.update()
    |> map_error(fn (_) -> :invalid_order_state end)
  end

  @doc """
  Deletes a Order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{source: %Order{}}

  """
  def change_order(%Order{} = order) do
    Order.changeset(order, %{})
  end

  @doc "Determines whether an order has a corresponding order state."
  def has_order_state?(%Order{} = order, order_state_description) do
    order.order_state_description == order_state_description
  end

  @doc "Determines whether an order is active."
  def is_active?(%Order{} = order) do
    order.order_state_id == OrderStates.active_id()
  end

  @doc "Determines whether an order is canceled."
  def is_canceled?(%Order{} = order) do
    order.order_state_id == OrderStates.canceled_id()
  end

  @doc "Determines whether an order is delivered."
  def is_delivered?(%Order{} = order) do
    order.order_state_id == OrderStates.delivered_id()
  end

  @doc "Determines whether an order is undeliverable."
  def is_undeliverable?(%Order{} = order) do
    order.order_state_id == OrderStates.undeliverable_id()
  end

  defp create_query(params) do
    query =
      from o in Order,
      inner_join: c in assoc(o, :courier),
      inner_join: os in assoc(o, :order_state),
      inner_join: p in assoc(o, :patient),
      inner_join: ph in assoc(o, :pharmacy),
      preload: [courier: c, order_state: os, patient: p, pharmacy: ph]
    query
    |> order_by([o], asc: o.id)
    |> modify_if(
          Map.has_key?(params, :courier_id) && params.courier_id != :all,
          fn (query) ->
            where(query, [o], o.courier_id == ^params.courier_id)
          end)
    |> modify_if(
          (Map.get(params, :order_state_description) in OrderState.order_states()),
          fn (query) ->
            where(query, [o, c, os, p, ph], os.description == ^params.order_state_description)
          end)
    |> modify_if(
          Map.has_key?(params, :patient_id) && params.patient_id != :all,
          fn (query) ->
            where(query, [o], o.patient_id == ^params.patient_id)
          end)
    |> modify_if(
          Map.has_key?(params, :pharmacy_id) && params.pharmacy_id != :all,
          fn (query) ->
            where(query, [o], o.pharmacy_id == ^params.pharmacy_id)
          end)
    |> modify_if(
          Map.has_key?(params, :pickup_date) && params.pickup_date != :all,
          fn (query) ->
            where(query, [o], o.pickup_date == ^params.pickup_date)
          end)
  end

  defp set_order_state_description(%{order_state: %OrderState{} = order_state} = order) do
    %{order | order_state_description: order_state.description}
  end
end
