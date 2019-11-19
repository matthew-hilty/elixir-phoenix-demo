defmodule Demo.Accounts.Administrator do
  use Ecto.Schema

  import Ecto.Changeset

  alias Demo.Accounts.Agent

  schema "administrators" do
    field :email, :string
    belongs_to :agent, Agent
    field :username, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(administrator, attrs) do
    administrator
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
