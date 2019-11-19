defmodule Demo.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :pickup_date, :date
      add :pickup_time, :time
      add :patient_id, references(:patients, on_delete: :delete_all)
      add :pharmacy_id, references(:pharmacies, on_delete: :delete_all)
      add :courier_id, references(:couriers, on_delete: :delete_all)
      add :order_state_id, references(:order_states, on_delete: :delete_all)

      timestamps()
    end

    create index(:orders, [:patient_id])
    create index(:orders, [:pharmacy_id])
    create index(:orders, [:courier_id])
    create index(:orders, [:order_state_id])
    create unique_index(:orders, [:pickup_date, :patient_id, :pharmacy_id, :courier_id])
  end
end
