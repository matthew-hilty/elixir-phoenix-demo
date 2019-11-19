defmodule DemoWeb.Api.CourierControllerTest do
  use DemoWeb.Api.ConnCase

  import Demo.DataCase, only: [json_equiv?: 2]
  import DemoWeb.Api.ConnCase,
    only: [ add_administrator: 1,
            add_courier: 1,
            log_in_admin: 1,
          ]

  describe "index" do
    setup [:add_administrator, :log_in_admin, :add_courier, :add_courier]

    test "lists all couriers", %{conn: conn, couriers: couriers} do
      response = get conn, api_courier_path(conn, :index)
      json = json_response(response, 200)
      assert json_equiv?(json["couriers"], couriers)
    end
  end

  describe "show courier" do
    setup [:add_administrator, :log_in_admin, :add_courier]

    test "renders a courier when the id is valid" , %{conn: conn, courier: courier} do
      response0 = get conn, api_courier_path(conn, :show, courier)
      json = json_response(response0, 200)
      assert json_equiv?(json["courier"], courier)
    end
  end

  describe "create courier" do
    setup [:add_administrator, :log_in_admin, :add_courier]

    test "creates and renders a courier when the data is valid" , %{conn: conn} do
      name = "some name"
      email = "some email"

      attrs = %{ "name" => name,
                 "username" => "some username",
                 "email" => email,
                 "address" => "some address",
                 "password" => "some password",
               }

      response0 = post conn, api_courier_path(conn, :create), courier: attrs
      json = json_response(response0, :created)
      created = json["created"]["courier"]
      created_id = created["id"]

      template = %{ "id" => created_id,
                    "name" => name,
                    "email" => email,
                  }

      assert created == template

      response1 = get conn, api_courier_path(conn, :show, created_id)
      json = json_response(response1, 200)
      assert json["courier"] == template
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{}
      response = post conn, api_courier_path(conn, :create), courier: invalid_attrs
      json_response(response, 400)
    end
  end
end
