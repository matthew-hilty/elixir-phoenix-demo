defmodule Demo.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :username, :string

      timestamps()
    end

    create unique_index(:agents, [:username])
  end
end
