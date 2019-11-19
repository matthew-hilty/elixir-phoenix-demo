defmodule DemoWeb.Api.AdministratorControllerTest do
  use DemoWeb.Api.ConnCase

  import Demo.DataCase, only: [json_equiv?: 2]
  import DemoWeb.Api.ConnCase,
    only: [ add_administrator: 1,
            log_in_admin: 1,
          ]

  describe "index" do
    setup [:add_administrator, :add_administrator, :add_administrator, :log_in_admin]

    test "lists all administrators", %{conn: conn, administrators: administrators} do
      response = get conn, api_administrator_path(conn, :index)
      json = json_response(response, 200)
      assert json_equiv?(json["administrators"], administrators)
    end
  end

  describe "show administrator" do
    setup [:add_administrator, :log_in_admin]

    test "renders an administrator when the id is valid" , %{conn: conn, administrator: administrator} do
      response0 = get conn, api_administrator_path(conn, :show, administrator)
      json = json_response(response0, 200)
      assert json_equiv?(json["administrator"], administrator)
    end
  end

  describe "create administrator" do
    setup [:add_administrator, :log_in_admin]

    test "creates and renders an administrator when the data is valid" , %{conn: conn} do
      username = "some username"
      email = "some email"
      attrs = %{username: username, email: email, password: "some password"}

      response0 = post conn, api_administrator_path(conn, :create), administrator: attrs
      json = json_response(response0, :created)
      created = json["created"]["administrator"]
      created_id = created["id"]
      template = %{"id" => created_id, "username" => username, "email" => email}
      assert created == template

      response1 = get conn, api_administrator_path(conn, :show, created_id)
      json = json_response(response1, 200)
      assert json["administrator"] == template
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{}
      response = post conn, api_administrator_path(conn, :create), administrator: invalid_attrs
      json_response(response, 400)
    end
  end
end
