defmodule DemoWeb.Api.PharmacyControllerTest do
  use DemoWeb.Api.ConnCase

  import Demo.DataCase, only: [json_equiv?: 2]
  import DemoWeb.Api.ConnCase,
    only: [ add_administrator: 1,
            add_pharmacy: 1,
            log_in_admin: 1,
          ]

  describe "index" do
    setup [:add_administrator, :log_in_admin, :add_pharmacy, :add_pharmacy]

    test "lists all pharmacies", %{conn: conn, pharmacies: pharmacies} do
      response = get conn, api_pharmacy_path(conn, :index)
      json = json_response(response, 200)
      assert json_equiv?(json["pharmacies"], pharmacies)
    end
  end

  describe "show pharmacy" do
    setup [:add_administrator, :log_in_admin, :add_pharmacy]

    test "renders a pharmacy when the id is valid" , %{conn: conn, pharmacy: pharmacy} do
      response0 = get conn, api_pharmacy_path(conn, :show, pharmacy)
      json = json_response(response0, 200)
      assert json_equiv?(json["pharmacy"], pharmacy)
    end
  end

  describe "create pharmacy" do
    setup [:add_administrator, :log_in_admin, :add_pharmacy]

    test "creates and renders a pharmacy when the data is valid" , %{conn: conn} do
      name = "some name"
      email = "some email"

      attrs = %{ "name" => name,
                 "username" => "some username",
                 "email" => email,
                 "address" => "some address",
                 "password" => "some password",
               }

      response0 = post conn, api_pharmacy_path(conn, :create), pharmacy: attrs
      json = json_response(response0, :created)
      created = json["created"]["pharmacy"]
      created_id = created["id"]

      template = %{ "id" => created_id,
                    "name" => name,
                    "email" => email,
                  }

      assert created == template

      response1 = get conn, api_pharmacy_path(conn, :show, created_id)
      json = json_response(response1, 200)
      assert json["pharmacy"] == template
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{}
      response = post conn, api_pharmacy_path(conn, :create), pharmacy: invalid_attrs
      json_response(response, 400)
    end
  end
end
