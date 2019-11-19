defmodule Demo.AccountsTest do
  use Demo.DataCase

  alias Demo.Accounts
  alias Demo.Accounts.{Administrator,Agent,Courier,Pharmacy}

  describe "administrators" do
    alias Demo.Accounts.Administrator

    @valid_attrs %{ username: "some username",
                    administrator: %{
                      email: "some email",
                    },
                    credential: %{password: "some password"}
                  }

    @invalid_attrs %{email: nil}

    def administrator_fixture(attrs \\ %{}) do
      {:ok, %Agent{administrator: administrator} = agent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_administrator()
      %{administrator | agent: agent}
    end

    test "list_administrators/0 returns all administrators" do
      administrator = administrator_fixture()
      assert(Equiv.equiv?(Accounts.list_administrators(), [administrator]))
    end

    test "get_administrator/1 returns the administrator with given id" do
      administrator0 = administrator_fixture()
      {:ok, administrator1} = Accounts.get_administrator(administrator0.id)
      assert(Equiv.equiv?(administrator0, administrator1))
    end

    test "create_administrator/1 with valid data creates a administrator" do
      assert {:ok, %Agent{administrator: administrator}} =
        Accounts.create_administrator(@valid_attrs)
      assert administrator.email == "some email"
    end

    test "create_administrator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_administrator(@invalid_attrs)
    end

    test "delete_administrator/1 deletes the administrator" do
      administrator = administrator_fixture()
      assert {:ok, %Administrator{}} = Accounts.delete_administrator(administrator)
      assert {:error, :no_resource} = Accounts.get_administrator(administrator.id)
    end

    test "change_administrator/0 returns a administrator changeset" do
      assert %Ecto.Changeset{} = Accounts.change_administrator()
    end
  end

  describe "pharmacies" do
    alias Demo.Accounts.Pharmacy

    @valid_attrs %{ username: "some username",
                    pharmacy: %{
                      address: "some address",
                      email: "some email",
                      name: "some name",
                    },
                    credential: %{password: "some password"}
                  }
    @invalid_attrs %{address: nil, email: nil, name: nil}

    def pharmacy_fixture(attrs \\ %{}) do
      {:ok, %Agent{pharmacy: pharmacy} = agent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_pharmacy()
      %{pharmacy | agent: agent}
    end

    test "list_pharmacies/0 returns all pharmacies" do
      pharmacy = pharmacy_fixture()
      assert(Equiv.equiv?(Accounts.list_pharmacies(), [pharmacy]))
    end

    test "get_pharmacy/1 returns the pharmacy with given id" do
      pharmacy0 = pharmacy_fixture()
      {:ok, pharmacy1} = Accounts.get_pharmacy(pharmacy0.id)
      assert(Equiv.equiv?(pharmacy0, pharmacy1))
    end

    test "create_pharmacy/1 with valid data creates a pharmacy" do
      assert {:ok, %Agent{pharmacy: pharmacy}} = Accounts.create_pharmacy(@valid_attrs)
      assert pharmacy.address == "some address"
      assert pharmacy.email == "some email"
      assert pharmacy.name == "some name"
    end

    test "create_pharmacy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_pharmacy(@invalid_attrs)
    end

    test "delete_pharmacy/1 deletes the pharmacy" do
      pharmacy = pharmacy_fixture()
      assert {:ok, %Pharmacy{}} = Accounts.delete_pharmacy(pharmacy)
      assert {:error, :no_resource} = Accounts.get_pharmacy(pharmacy.id)
    end

    test "change_pharmacy/0 returns a pharmacy changeset" do
      assert %Ecto.Changeset{} = Accounts.change_pharmacy()
    end
  end

  describe "couriers" do
    alias Demo.Accounts.Courier

    @valid_attrs %{ username: "some username",
                    courier: %{
                      address: "some address",
                      email: "some email",
                      name: "some name",
                    },
                    credential: %{password: "some password"}
                  }
    @invalid_attrs %{address: nil, email: nil, name: nil}

    def courier_fixture(attrs \\ %{}) do
      {:ok, %Agent{courier: courier} = agent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_courier()
      %{courier | agent: agent}
    end

    test "list_couriers/0 returns all couriers" do
      courier = courier_fixture()
      assert(Equiv.equiv?(Accounts.list_couriers(), [courier]))
    end

    test "get_courier/1 returns the courier with given id" do
      courier0 = courier_fixture()
      {:ok, courier1} = Accounts.get_courier(courier0.id)
      assert(Equiv.equiv?(courier0, courier1))
    end

    test "create_courier/1 with valid data creates a courier" do
      assert {:ok, %Agent{courier: courier}} = Accounts.create_courier(@valid_attrs)
      assert courier.address == "some address"
      assert courier.email == "some email"
      assert courier.name == "some name"
    end

    test "create_courier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_courier(@invalid_attrs)
    end

    test "delete_courier/1 deletes the courier" do
      courier = courier_fixture()
      assert {:ok, %Courier{}} = Accounts.delete_courier(courier)
      assert {:error, :no_resource} = Accounts.get_courier(courier.id)
    end

    test "change_courier/0 returns a courier changeset" do
      assert %Ecto.Changeset{} = Accounts.change_courier()
    end
  end
end
