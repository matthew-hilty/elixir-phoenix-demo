defmodule DemoWeb.Browser.PharmacyControllerTest do
  use DemoWeb.ConnCase

  import Demo.DataCase, only: [fixture: 1]
  import DemoWeb.Browser.ConnCase, only: [log_in_admin: 1]

  @invalid_attrs %{address: nil, email: nil, name: nil}
  @create_attrs %{ username: "some username",
                   pharmacy: %{
                     name: "some name",
                     email: "some email",
                     address: "some address",
                   },
                   credential: %{password: "some password"}
                 }

  describe "index" do
    setup [:log_in_admin]

    test "lists all pharmacies", %{conn: conn} do
      response = get conn, pharmacy_path(conn, :index)
      assert html_response(response, 200) =~ "Listing Pharmacies"
    end
  end

  describe "new pharmacy" do
    setup [:log_in_admin]

    test "renders form", %{conn: conn} do
      response = get conn, pharmacy_path(conn, :new)
      assert html_response(response, 200) =~ "New Pharmacy"
    end
  end

  describe "create pharmacy" do
    setup [:log_in_admin]

    test "redirects to show when data is valid", %{conn: conn} do
      response0 = post conn, pharmacy_path(conn, :create), agent: @create_attrs
      assert %{id: id} = redirected_params(response0)
      assert redirected_to(response0) == pharmacy_path(response0, :show, id)
      response1 = get conn, pharmacy_path(conn, :show, id)
      assert html_response(response1, 200) =~ "Show Pharmacy"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      response = post conn, pharmacy_path(conn, :create), agent: @invalid_attrs
      assert html_response(response, 400) =~ "New Pharmacy"
    end
  end

  describe "delete pharmacy" do
    setup [:log_in_admin, :create_pharmacy]

    test "deletes chosen pharmacy", %{conn: conn, pharmacy: pharmacy} do
      response0 = delete conn, pharmacy_path(conn, :delete, pharmacy)
      assert redirected_to(response0) == pharmacy_path(response0, :index)
      response1 = get conn, pharmacy_path(conn, :show, pharmacy)
      assert redirected_to(response1) == page_path(response1, :index)
      error = "Pharmacy ##{pharmacy.id} does not exist"
      assert get_flash(response1, :error) =~ error
    end
  end

  defp create_pharmacy(_) do
    pharmacy = fixture(:pharmacy)
    {:ok, pharmacy: pharmacy}
  end
end
