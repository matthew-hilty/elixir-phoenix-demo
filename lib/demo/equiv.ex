defmodule Demo.Equiv do
  alias Demo.Accounts.{Administrator,Agent,Courier,Pharmacy}
  alias Demo.Orders.Order
  alias Demo.OrderStates.OrderState
  alias Demo.Patients.Patient

  defimpl Equiv, for: Administrator do
    def equiv?(%Administrator{} = administrator0, %Administrator{} = administrator1) do
      administrator0.email == administrator1.email
        && administrator0.agent_id == administrator1.agent_id
    end
  end

  defimpl Equiv, for: Agent do
    def equiv?(%Agent{} = agent0, %Agent{} = agent1) do
      agent0.username == agent1.username
    end
  end

  defimpl Equiv, for: Courier do
    def equiv?(%Courier{} = courier0, %Courier{} = courier1) do
      courier0.address == courier1.address
        && courier0.agent_id == courier1.agent_id
        && courier0.email == courier1.email
        && courier0.name == courier1.name
    end
  end

  defimpl Equiv, for: Order do
    def equiv?(%Order{} = order0, %Order{} = order1) do
      order0.courier_id == order1.courier_id
        && order0.order_state_id == order1.order_state_id
        && order0.patient_id == order1.patient_id
        && order0.pharmacy_id == order1.pharmacy_id
        && order0.pickup_date == order1.pickup_date
        && order0.pickup_time == order1.pickup_time
    end
  end

  defimpl Equiv, for: OrderState do
    def equiv?(%OrderState{} = order_state0, %OrderState{} = order_state1) do
      order_state0.description == order_state1.description
    end
  end

  defimpl Equiv, for: Patient do
    def equiv?(%Patient{} = patient0, %Patient{} = patient1) do
      patient0.address == patient1.address
        && patient0.name == patient1.name
    end
  end

  defimpl Equiv, for: Pharmacy do
    def equiv?(%Pharmacy{} = pharmacy0, %Pharmacy{} = pharmacy1) do
      pharmacy0.address == pharmacy1.address
        && pharmacy0.agent_id == pharmacy1.agent_id
        && pharmacy0.email == pharmacy1.email
        && pharmacy0.name == pharmacy1.name
    end
  end
end
