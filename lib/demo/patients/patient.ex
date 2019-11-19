defmodule Demo.Patients.Patient do
  use Ecto.Schema

  import Ecto.Changeset

  alias Demo.Orders.Order

  schema "patients" do
    field :address, :string
    field :name, :string
    has_many :orders, Order

    timestamps()
  end

  @doc false
  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [:name, :address])
    |> validate_required([:name, :address])
    |> unique_constraint(:name)
    |> unique_constraint(:address)
  end
end
