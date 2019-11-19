defmodule Demo.ToJson do
  alias Demo.Accounts.{Administrator,Agent,Courier,Pharmacy}
  alias Demo.Orders.Order
  alias Demo.OrderStates
  alias Demo.Patients.Patient

  defimpl ToJson, for: Administrator do
    def to_json(%Administrator{} = administrator) do
      administrator
      |> Utilities.to_json([:id, :username, :email])
    end
  end

  defimpl ToJson, for: Agent do
    def to_json(%Agent{} = agent) do
      agent
      |> Utilities.to_json([:username])
    end
  end

  defimpl ToJson, for: Courier do
    def to_json(%Courier{} = courier) do
      courier
      |> Utilities.to_json([:id, :name, :email])
    end
  end

  defimpl ToJson, for: Order do
    def to_json(%Order{order_state_id: id} = order) do
      fields = ~w(id patient pharmacy courier pickup_date pickup_time)a
      order
      |> Utilities.to_json(fields)
      |> Map.put("order_state", OrderStates.to_description(id))
    end
  end

  defimpl ToJson, for: Patient do
    def to_json(%Patient{} = patient) do
      patient
      |> Utilities.to_json([:id, :name, :address])
    end
  end

  defimpl ToJson, for: Pharmacy do
    def to_json(%Pharmacy{} = pharmacy) do
      pharmacy
      |> Utilities.to_json([:id, :name, :email])
    end
  end
end
