defmodule Demo.Repo.Migrations.CreateCouriers do
  use Ecto.Migration

  def change do
    create table(:couriers) do
      add :name, :string
      add :address, :string
      add :email, :string
      add :agent_id, references(:agents, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:couriers, [:name])
    create unique_index(:couriers, [:address])
    create unique_index(:couriers, [:email])
    create index(:couriers, [:agent_id])
  end
end
