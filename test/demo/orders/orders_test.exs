defmodule Demo.OrdersTest do
  use Demo.DataCase

  alias Demo.Accounts
  alias Demo.Accounts.Agent
  alias Demo.Orders
  alias Demo.Patients

  describe "orders" do
    alias Demo.Orders.Order

    @valid_attrs %{ order_state_description: "active",
                    pickup_date: ~D[2010-04-17],
                    pickup_time: ~T[14:00:00.000000],
                  }
    @update_attrs %{pickup_date: ~D[2011-05-18], pickup_time: ~T[15:01:01.000000]}
    @invalid_attrs %{pickup_date: nil, pickup_time: nil}

    def random_name() do
      :rand.uniform(10000000000000) |> to_string()
    end

    def pharmacy_fixture() do
      attrs = %{ username: random_name(),
                 pharmacy: %{
                   address: "some address",
                   email: "some email",
                   name: "some name",
                 },
                 credential: %{password: "some password"}
               }
      {:ok, %Agent{pharmacy: pharmacy} = agent} =
        attrs
        |> Enum.into(attrs)
        |> Accounts.create_pharmacy()
      %{pharmacy | agent: agent}
    end

    def courier_fixture() do
      attrs = %{ username: random_name(),
                 courier: %{
                   address: "some address",
                   email: "some email",
                   name: "some name",
                 },
                 credential: %{password: "some password"}
               }
      {:ok, %Agent{courier: courier} = agent} =
        attrs
        |> Enum.into(attrs)
        |> Accounts.create_courier()
      %{courier | agent: agent}
    end

    def patient_fixture() do
      attrs = %{address: "some address", name: "some name"}
      {:ok, patient} =
        attrs
        |> Enum.into(attrs)
        |> Patients.create_patient()
      patient
    end

    def order_fixture(attrs \\ %{}) do
      pharmacy = pharmacy_fixture()
      courier = courier_fixture()
      patient = patient_fixture()
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{patient_id: patient.id, pharmacy_id: pharmacy.id, courier_id: courier.id})
        |> Orders.create_order()
      order
    end

    test "list_orders/1 returns all orders" do
      order = order_fixture()
      assert(Equiv.equiv?(Orders.list_orders(%{}), [order]))
    end

    test "get_order/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order(order.id) |> elem(1) == order
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, order} = Orders.update_order(order, @update_attrs)
      assert %Order{} = order
      assert order.pickup_date == ~D[2011-05-18]
      assert order.pickup_time == ~T[15:01:01.000000]
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order(order.id) |> elem(1)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert {:error, :no_resource} = Orders.get_order(order.id)
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end
end
