defmodule Demo.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Demo.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Demo.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Demo.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Demo.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  alias Demo.Accounts
  alias Demo.Accounts.{Administrator,Courier,Pharmacy}
  alias Demo.{Orders,Patients}

  @administrator :administrator
  @courier :courier
  @ok :ok
  @order :order
  @patient :patient
  @pharmacy :pharmacy

  @order_attrs %{ "order_state_description" => "active",
                  "pickup_date" => "2010-04-17",
                  "pickup_time" => "14:00",
                }

  def fixture(@administrator) do
    fixture(@administrator, get_username())
  end

  def fixture(@courier) do
    fixture(@courier, get_username())
  end

  def fixture(@order) do
    fixture(@order, %{})
  end

  def fixture(@patient) do
    fixture(@patient, get_username())
  end

  def fixture(@pharmacy) do
    fixture(@pharmacy, get_username())
  end

  def fixture(@administrator, username) do
    {@ok, %_{administrator: administrator} = agent} =
      Accounts.create_administrator(
        get_account("administrator", username))
    %{administrator | agent: agent}
  end

  def fixture(@courier, username) do
    {@ok, %_{courier: courier} = agent} =
      Accounts.create_courier(
        get_account("courier", username))
    %{courier | agent: agent}
  end

  def fixture(@order, account_details) do
    courier_username = Map.get(account_details, @courier) || get_username()
    pharmacy_username = Map.get(account_details, @pharmacy) || get_username()

    courier = fixture(@courier, courier_username)
    patient = fixture(@patient)
    pharmacy = fixture(@pharmacy, pharmacy_username)

    {@ok, order} =
      %{ "patient_id" => patient.id,
         "courier_id" => courier.id,
         "pharmacy_id" => pharmacy.id,
       }
      |> Enum.into(@order_attrs)
      |> Orders.create_order()
    order
  end

  def fixture(@patient, name) do
    attrs = %{"name" => name, "address" => name <> "_address"}
    {@ok, patient} = Patients.create_patient(attrs)
    patient
  end

  def fixture(@pharmacy, username) do
    {@ok, %_{pharmacy: pharmacy} = agent} =
      Accounts.create_pharmacy(
        get_account("pharmacy", username))
    %{pharmacy | agent: agent}
  end

  def get_password(%Administrator{} = account), do: account.username
  def get_password(%Courier{} = account),       do: account.username
  def get_password(%Pharmacy{} = account),      do: account.username

  def json_equiv?(json, list) when is_list(list) do
    json_list = list |> Enum.map(&ToJson.to_json/1)
    Utilities.same_members?(json, json_list)
  end
  def json_equiv?(json, value) do
    json == ToJson.to_json(value)
  end

  defp get_username() do
    :rand.uniform(1000000000) |> to_string()
  end

  defp get_account(account_type, username) do
    %{ "username"   => username,
       account_type => %{ "name" => username,
                          "email" => username <> "@example.com",
                          "address" => username <> "_address",
                        },
       "credential" => %{"password" => username},
     }
  end
end
