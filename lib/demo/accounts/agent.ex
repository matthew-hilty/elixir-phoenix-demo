defmodule Demo.Accounts.Agent do
  use Ecto.Schema

  import Ecto.Changeset

  alias Demo.Accounts.{Administrator,Courier,Credential,Pharmacy}

  schema "agents" do
    field :username, :string

    has_one :credential, Credential

    # NOTE: The subordinate domain concepts Administrator, Courier, and
    # Pharmacy are coupled to Agent for greater ease of use.
    # That is, the `has_one` macro, although no agent record
    # can actually claim to have one each of administrators, couriers, and
    # pharmacies, allows use of `&Ecto.Changeset.cast_assoc`, which
    # facilitates (1) database record insertion, (2) HTML form submission,
    # and (3) HTML form error management.

    has_one :administrator, Administrator
    has_one :courier, Courier
    has_one :pharmacy, Pharmacy

    # NOTE: Since Administrator et al. are already coupled to Agent,
    # the following virtual field adds little extra harm.
    # Its purpose is to facilitate pattern matching.
    field :account_type, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
