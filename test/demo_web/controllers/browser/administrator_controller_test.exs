defmodule DemoWeb.Browser.AdministratorControllerTest do
  use DemoWeb.Browser.ConnCase

  import Demo.DataCase, only: [fixture: 1]
  import DemoWeb.Browser.ConnCase, only: [log_in_admin: 1]

  @invalid_attrs %{email: nil}
  @create_attrs %{ username: "some username",
                   administrator: %{
                     email: "some email",
                   },
                   credential: %{password: "some password"}
                 }

  describe "index" do
    setup [:log_in_admin]

    test "lists all administrators", %{conn: conn} do
      response = get conn, administrator_path(conn, :index)
      assert html_response(response, 200) =~ "Listing Administrators"
    end
  end

  describe "new administrator" do
    setup [:log_in_admin]

    test "renders form", %{conn: conn} do
      response = get conn, administrator_path(conn, :new)
      assert html_response(response, 200) =~ "New Administrator"
    end
  end

  describe "create administrator" do
    setup [:log_in_admin]

    test "redirects to show when data is valid", %{conn: conn} do
      response0 = post conn, administrator_path(conn, :create), agent: @create_attrs
      assert %{id: id} = redirected_params(response0)
      assert redirected_to(response0) == administrator_path(response0, :show, id)
      response1 = get conn, administrator_path(conn, :show, id)
      assert html_response(response1, 200) =~ "Show Administrator"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      response = post conn, administrator_path(conn, :create), agent: @invalid_attrs
      assert html_response(response, 400) =~ "New Administrator"
    end
  end

  describe "delete administrator" do
    setup [:log_in_admin, :create_administrator]

    test "deletes chosen administrator", %{conn: conn, administrator: administrator} do
      response0 = delete conn, administrator_path(conn, :delete, administrator)
      assert redirected_to(response0) == administrator_path(response0, :index)
      response1 = get conn, administrator_path(conn, :show, administrator)
      assert redirected_to(response1) == page_path(response1, :index)
      error = "Administrator ##{administrator.id} does not exist"
      assert get_flash(response1, :error) =~ error
    end
  end

  defp create_administrator(_) do
    administrator = fixture(:administrator)
    {:ok, administrator: administrator}
  end
end
