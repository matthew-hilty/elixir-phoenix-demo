defmodule DemoWeb.Browser.OrderControllerTest do
  use DemoWeb.ConnCase

  import Demo.DataCase, only: [fixture: 1]
  import DemoWeb.Browser.ConnCase, only: [log_in_admin: 1]

  @update_attrs %{pickup_date: "2011-05-18", pickup_time: "15:01"}
  @invalid_attrs %{pickup_date: nil, pickup_time: nil}
  @create_attrs %{ "order_state_description" => "active",
                   "pickup_date" => "2010-04-17",
                   "pickup_time" => "14:00",
                 }

  describe "index" do
    setup [:log_in_admin]

    test "lists all orders", %{conn: conn} do
      response = get conn, order_path(conn, :index)
      msg = Plug.HTML.html_escape("Listing Today's Active Orders")
      assert html_response(response, 200) =~ msg
    end
  end

  describe "new order" do
    setup [:log_in_admin]

    test "renders form", %{conn: conn} do
      response = get conn, order_path(conn, :new)
      assert html_response(response, 200) =~ "New Order"
    end
  end

  describe "create order" do
    setup [:log_in_admin, :create_courier, :create_patient, :create_pharmacy]

    test "redirects to show when data is valid", (%{conn: conn} = params) do
      %{courier: courier, patient: patient, pharmacy: pharmacy} = params
      attrs =
        %{ "courier_id" => courier.id,
           "patient_id" => patient.id,
           "pharmacy_id" => pharmacy.id,
         }
        |> Enum.into(@create_attrs)
      response0 = post conn, order_path(conn, :create), order: attrs
      assert %{id: id} = redirected_params(response0)
      assert redirected_to(response0) == order_path(response0, :show, id)
      response1 = get conn, order_path(conn, :show, id)
      assert html_response(response1, 200) =~ "Show Order"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      response = post conn, order_path(conn, :create), order: @invalid_attrs
      assert html_response(response, 400) =~ "New Order"
    end
  end

  describe "edit order" do
    setup [:log_in_admin, :create_order]

    test "renders form for editing chosen order", %{conn: conn, order: order} do
      response = get conn, order_path(conn, :edit, order)
      assert html_response(response, 200) =~ "Edit Order"
    end
  end

  describe "update order" do
    setup [:log_in_admin, :create_order]

    test "redirects when data is valid", %{conn: conn, order: order} do
      response0 = put conn, order_path(conn, :update, order), order: @update_attrs
      assert redirected_to(response0) == order_path(response0, :show, order)
      response1 = get conn, order_path(conn, :show, order)
      assert html_response(response1, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, order: order} do
      response = put conn, order_path(conn, :update, order), order: @invalid_attrs
      assert html_response(response, 400) =~ "Edit Order"
    end
  end

  describe "delete order" do
    setup [:log_in_admin, :create_order]

    test "deletes chosen order", %{conn: conn, order: order} do
      response0 = delete conn, order_path(conn, :delete, order)
      assert redirected_to(response0) == order_path(response0, :index)
      response1 = get conn, order_path(conn, :show, order)
      assert redirected_to(response1) == page_path(response1, :index)
      error = "Order ##{order.id} does not exist"
      assert get_flash(response1, :error) =~ error
    end
  end

  defp create_courier(_) do
    courier = fixture(:courier)
    {:ok, courier: courier}
  end

  defp create_order(_) do
    order = fixture(:order)
    {:ok, order: order}
  end

  defp create_patient(_) do
    patient = fixture(:patient)
    {:ok, patient: patient}
  end

  defp create_pharmacy(_) do
    pharmacy = fixture(:pharmacy)
    {:ok, pharmacy: pharmacy}
  end
end
