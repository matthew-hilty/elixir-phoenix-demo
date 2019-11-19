defmodule Demo.OrderStates do
  @moduledoc """
  The OrderStates context.
  """

  import Ecto.Query, warn: false
  import Utilities, only: [prohibit_nil: 2]

  alias Demo.Repo
  alias Demo.OrderStates.OrderState

  @active OrderState.active()
  @canceled OrderState.canceled()
  @delivered OrderState.delivered()
  @no_resource :no_resource
  @undeliverable OrderState.undeliverable()

  @doc """
  Returns the list of order_states.

  ## Examples

      iex> list_order_states()
      [%OrderState{}, ...]

  """
  def list_order_states do
    Repo.all(OrderState)
  end

  @doc """
  Gets a single order_state.

  ## Examples

      iex> get_order_state(123)
      {:ok, %OrderState{}}

      iex> get_order_state(456)
      {:error, :no_resource}

  """
  def get_order_state(id) do
    OrderState
    |> Repo.get(id)
    |> prohibit_nil(@no_resource)
  end

  @doc """
  Creates a order_state.

  ## Examples

      iex> create_order_state(%{field: value})
      {:ok, %OrderState{}}

      iex> create_order_state(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order_state(attrs \\ %{}) do
    %OrderState{}
    |> OrderState.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order_state changes.

  ## Examples

      iex> change_order_state(order_state)
      %Ecto.Changeset{source: %OrderState{}}

  """
  def change_order_state(%OrderState{} = order_state) do
    OrderState.changeset(order_state, %{})
  end

  @doc false
  def active_id(), do: get_order_state_id(@active)

  @doc false
  def canceled_id(), do: get_order_state_id(@canceled)

  @doc false
  def delivered_id(), do: get_order_state_id(@delivered)

  @doc false
  def to_description(value) when is_integer(value) do
    order_state =
      list_order_states()
      |> Enum.find(fn (%{id: id}) -> id == value end)
    if is_nil(order_state) do
      raise "Description cannot be determined for the value #{value}"
    else
      order_state.description
    end
  end

  @doc false
  def undeliverable_id(), do: get_order_state_id(@undeliverable)

  defp get_order_state_id(description) do
    OrderState
    |> Repo.get_by!(description: description)
    |> Map.get(:id)
  end
end
