defmodule Demo.Orders.Order do
  use Ecto.Schema

  import Ecto.Changeset

  alias Demo.Accounts.{Courier,Pharmacy}
  alias Demo.OrderStates
  alias Demo.OrderStates.OrderState
  alias Demo.Patients.Patient

  @active OrderState.active()
  @canceled OrderState.canceled()
  @delivered OrderState.delivered()
  @undeliverable OrderState.undeliverable()

  @required_params ~w(pickup_date pickup_time patient_id pharmacy_id courier_id)a
  @order_state_descriptions ~w(active canceled delivered undeliverable)s

  schema "orders" do
    field :pickup_date, :date
    field :pickup_time, :time
    belongs_to :patient, Patient
    belongs_to :pharmacy, Pharmacy
    belongs_to :courier, Courier
    belongs_to :order_state, OrderState
    field :order_state_description, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, @required_params ++ [:order_state_description])
    |> validate_required(@required_params)
    |> validate_number(:courier_id, greater_than: 0)
    |> validate_number(:patient_id, greater_than: 0)
    |> validate_number(:pharmacy_id, greater_than: 0)
    |> validate_order_state_description()
    |> set_order_state_id()
    |> unique_constraint(
        :pickup_date,
        name: :orders_pickup_date_patient_id_pharmacy_id_courier_id_index,
        message: "An order with this pickup date, this patient, this pharmacy, and this courier already exists.")
    |> foreign_key_constraint(:patient_id)
    |> foreign_key_constraint(:pharmacy_id)
    |> foreign_key_constraint(:courier_id)
    |> foreign_key_constraint(:order_state_id)
  end

  defp validate_order_state_description(changeset) do
    validate_change(changeset, :order_state_description, fn (:order_state_description, description) ->
        if description in @order_state_descriptions do
          []
        else
          [order_state_description: "Must be one of 'active', 'canceled', 'delivered', or 'undeliverable'"]
        end
      end)
  end

  defp set_order_state_id(changeset) do
    case get_change(changeset, :order_state_description) do
      @active ->
        put_change(changeset, :order_state_id, OrderStates.active_id())
      @canceled ->
        put_change(changeset, :order_state_id, OrderStates.canceled_id())
      @delivered ->
        put_change(changeset, :order_state_id, OrderStates.delivered_id())
      @undeliverable ->
        put_change(changeset, :order_state_id, OrderStates.undeliverable_id())
      _ -> changeset
    end
  end
end
