defmodule Demo.Repo.Migrations.CreateAdministrators do
  use Ecto.Migration

  def change do
    create table(:administrators) do
      add :email, :string
      add :agent_id, references(:agents, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:administrators, [:email])
    create index(:administrators, [:agent_id])
  end
end
