defmodule Demo.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :password_digest, :string
      add :agent_id, references(:agents, on_delete: :delete_all)

      timestamps()
    end

    create index(:credentials, [:agent_id])
  end
end
