defmodule Demo.Repo.Migrations.CreatePatients do
  use Ecto.Migration

  def change do
    create table(:patients) do
      add :name, :string
      add :address, :string

      timestamps()
    end

    create unique_index(:patients, [:name])
    create unique_index(:patients, [:address])
  end
end
