defmodule DemoWeb.Api.OrderControllerTest do
  use DemoWeb.Api.ConnCase

  import Demo.DataCase, only: [json_equiv?: 2]
  import DemoWeb.Api.ConnCase,
    only: [ add_administrator: 1,
            add_courier: 1,
            add_order: 1,
            add_patient: 1,
            add_pharmacy: 1,
            log_in_admin: 1,
          ]

  alias Demo.OrderStates

  @base_attrs %{ "order_state" => "active",
                 "pickup_date" => "2010-04-17",
                 "pickup_time" => "14:00",
                }

  describe "index" do
    setup [:add_administrator, :log_in_admin, :add_order, :add_order]

    test "lists all orders", %{conn: conn, orders: orders} do
      response = get conn, api_order_path(conn, :index, order_state: "all", pickup_date: "all")
      json = json_response(response, 200)
      assert json_equiv?(json["orders"], orders)
    end
  end

  describe "show order" do
    setup [:add_administrator, :log_in_admin, :add_order]

    test "renders an order when the id is valid" , %{conn: conn, order: order} do
      response0 = get conn, api_order_path(conn, :show, order)
      json = json_response(response0, 200)
      assert json_equiv?(json["order"], order)
    end
  end

  describe "create order" do
    setup [ :add_administrator,
            :log_in_admin,
            :add_courier,
            :add_patient,
            :add_pharmacy,
            :add_order,
          ]

    test "creates and renders an order when the data is valid", %{conn: conn} = params do
      %{courier: courier, patient: patient, pharmacy: pharmacy} = params

      attrs =
        @base_attrs
        |> Enum.into(%{ "courier_id" => courier.id,
                        "patient_id" => patient.id,
                        "pharmacy_id" => pharmacy.id,
                      })

      response0 = post conn, api_order_path(conn, :create), order: attrs
      json = json_response(response0, :created)
      created = json["created"]["order"]
      created_id = created["id"]

      template =
        @base_attrs
        |> Enum.into(%{ "id" => created_id,
                        "courier" => courier,
                        "patient" => patient,
                        "pharmacy" => pharmacy,
                      })

      assert json_equiv?(created, template)

      response1 = get conn, api_order_path(conn, :show, created_id)
      json = json_response(response1, 200)
      assert json_equiv?(json["order"], template)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{}
      response = post conn, api_order_path(conn, :create), order: invalid_attrs
      json_response(response, 400)
    end
  end

  describe "cancel order" do
    setup [:add_administrator, :log_in_admin, :add_order]

    test "cancels an order" , %{conn: conn, order: order} do
      response0 = delete conn, api_order_path(conn, :cancel, order)
      json = json_response(response0, 200)
      assert json_equiv?(
        json["canceled"]["order"],
        %{order | order_state_id: OrderStates.canceled_id()})
    end
  end

  describe "deliver an order" do
    setup [:add_administrator, :log_in_admin, :add_order]

    test "delivers an order" , %{conn: conn, order: order} do
      response0 = post conn, api_order_path(conn, :deliver, order)
      json = json_response(response0, 200)
      assert json_equiv?(
        json["delivered"]["order"],
        %{order | order_state_id: OrderStates.delivered_id()})
    end
  end

  describe "mark an order undeliverable" do
    setup [:add_administrator, :log_in_admin, :add_order]

    test "marks an order undeliverable" , %{conn: conn, order: order} do
      response0 = post conn, api_order_path(conn, :mark_undeliverable, order)
      json = json_response(response0, 200)
      assert json_equiv?(
        json["undeliverable"]["order"],
        %{order | order_state_id: OrderStates.undeliverable_id()})
    end
  end
end
