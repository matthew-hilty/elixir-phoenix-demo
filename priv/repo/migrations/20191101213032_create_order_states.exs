defmodule Demo.Repo.Migrations.CreateOrderStates do
  use Ecto.Migration

  def change do
    create table(:order_states) do
      add :description, :string

      timestamps()
    end

    create unique_index(:order_states, [:description])
  end
end
