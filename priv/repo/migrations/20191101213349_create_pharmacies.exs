defmodule Demo.Repo.Migrations.CreatePharmacies do
  use Ecto.Migration

  def change do
    create table(:pharmacies) do
      add :name, :string
      add :address, :string
      add :email, :string
      add :agent_id, references(:agents, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:pharmacies, [:name])
    create unique_index(:pharmacies, [:address])
    create unique_index(:pharmacies, [:email])
    create index(:pharmacies, [:agent_id])
  end
end
