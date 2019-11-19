defmodule DemoWeb.Api.OrderController do
  use DemoWeb, :controller

  import DemoWeb.Api.ControllerUtilities,
    only: [ authentication_error: 2,
            authorization_error: 2,
            changeset_error: 2,
            id_type_validation_error: 1,
            internal_error: 2,
            match_error: 2,
            resource_error: 3,
            resource_error: 4,
            send_attachment: 4,
            validation_error: 2,
          ]
  import DemoWeb.ControllerUtilities, only: [validate_id_type: 1]
  import DemoWeb.GuardianController, only: [authenticate_agent: 1]
  import DemoWeb.OrderUtilities,
    only: [ normalize_validate_creation: 2,
            normalize_validate_index: 2,
          ]
  import Utilities, only: [accumulate_errors: 1]

  alias Demo.Accounts
  alias Demo.Accounts.{Administrator,Courier,Pharmacy}
  alias Demo.Orders
  alias Demo.OrderStates.OrderState
  alias DemoWeb.OrderView

  @already_canceled :already_canceled
  @already_delivered :already_delivered
  @already_has_order_state :already_has_order_state
  @created :created
  @error :error
  @invalid_parameter :invalid_parameter
  @no_resource :no_resource
  @not_authenticated :not_authenticated
  @not_authorized :not_authorized
  @not_found :not_found
  @ok :ok

  @canceled OrderState.canceled()
  @delivered OrderState.delivered()
  @undeliverable OrderState.undeliverable()

  def cancel(conn, params) do
    conn
    |> update_order_state(params, @canceled, "cancel.json")
  end

  def create(conn, %{"order" => params}) do
    with {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         validated_params <- normalize_validate_creation(params, account),
         {@ok, normalized_params} <- accumulate_errors(validated_params),
         {@ok, order} <- Orders.create_order(normalized_params) do
      conn
      |> put_status(@created)
      |> render("create.json", order: order)
    else
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must provide credentials to create an order")
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      {@error, %{errors: errors, valid_results: _}} ->
        conn
        |> validation_error(OrderView.format_upsert_errors(errors))
      _ ->
        conn
        |> internal_error("ORCR-A")
    end
  end
  def create(conn, _) do
    conn
    |> match_error("to create an order")
  end

  def deliver(conn, params) do
    conn
    |> update_order_state(params, @delivered, "deliver.json")
  end

  def index(conn, params) do
    with {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         validated_params <- normalize_validate_index(params, account),
         {@ok, normalized_params} <- accumulate_errors(validated_params),
         orders <- Orders.list_orders(normalized_params) do
      conn
      |> filetype_specific_index(orders, normalized_params)
    else
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must provide credentials to view orders")
      {@error, %{errors: errors, valid_results: _}} ->
        conn
        |> validation_error(OrderView.format_index_errors(errors))
      _ ->
        conn
        |> internal_error("ORIN-A")
    end
  end

  def mark_undeliverable(conn, params) do
    conn
    |> update_order_state(params, @undeliverable, "mark_undeliverable.json")
  end

  def show(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, _} <- authenticate_agent(conn),
         {@ok, order} <- Orders.get_order(id) do
      conn
      |> render("show.json", order: order)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must provide credentials to view an order")
      {@error, @no_resource} ->
        conn
        |> resource_error("order ##{id}", "does not exist", @not_found)
      _ ->
        conn
        |> internal_error("ORSH-A-1")
    end
  end
  def show(conn, _), do: conn |> internal_error("ORSH-A-2")

  defp accepts_csv_filetype?(%Plug.Conn{} = conn) do
    conn
    |> get_acceptable_filetypes()
    |> Enum.any?(&(String.contains?(&1, "text/csv")))
  end

  defp authorize_update(account, order) do
    case account do
      (%Administrator{} = administrator) ->
        {@ok, administrator}
      (%Courier{} = courier) ->
        if order.courier_id == courier.id do
          {@ok, courier}
        else
          {@error, @not_authorized}
        end
      (%Pharmacy{} = pharmacy) ->
        if order.pharmacy_id == pharmacy.id do
          {@ok, pharmacy}
        else
          {@error, @not_authorized}
        end
      _ ->
        {@error, @not_authorized}
    end
  end

  defp check_elibility(order, order_state) do
    cond do
      Orders.has_order_state?(order, order_state) ->
        {@error, @already_has_order_state}
      Orders.is_canceled?(order) ->
        {@error, @already_canceled}
      Orders.is_delivered?(order) ->
        {@error, @already_delivered}
      true ->
        {@ok, {order, order_state}}
    end
  end

  defp csv_index(conn, orders) do
    conn
    |> send_attachment(
          "text/csv",
          "orders.csv",
          OrderView.to_csv(orders))
  end

  defp filetype_specific_index(conn, orders, normalized_params) do
    if accepts_csv_filetype?(conn) do
      conn
      |> csv_index(orders)
    else
      conn
      |> json_index(orders, normalized_params)
    end
  end

  defp get_acceptable_filetypes(conn) do
    conn
    |> get_req_header("accept")
    |> Enum.flat_map(fn (header) ->
          header
          |> String.split(";")
          |> List.first()
          |> String.split(",")
        end)
  end

  defp json_index(conn, orders, normalized_params) do
    conn
    |> render(
          "index.json",
          orders: orders,
          query_params: normalized_params)
  end

  defp update_order_state(conn, %{"id" => id}, order_state, view) do
    resource = "order ##{id}"
    with {@ok, _} <- validate_id_type(id),
         {@ok, agent} <- authenticate_agent(conn),
         {@ok, order} <- Orders.get_order(id),
         {@ok, _} <- authorize_update(Accounts.specify_agent(agent), order),
         {@ok, _} <- check_elibility(order, order_state),
         {@ok, new_order} <- Orders.update_order_state(order, order_state) do
      conn
      |> render(view, order: new_order)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must provide credentials to update an order")
      {@error, @not_authorized} ->
        conn
        |> authorization_error("Not authorized to update orders.")
      {@error, @already_canceled} ->
        msg = "cannot be #{order_state} because it has already been canceled"
        conn
        |> resource_error(resource, msg)
      {@error, @already_delivered} ->
        msg = "cannot be #{order_state} because it has already been delivered"
        conn
        |> resource_error(resource, msg)
      {@error, @already_has_order_state} ->
        conn
        |> resource_error(resource, "is already #{order_state}")
      {@error, @no_resource} ->
        conn
        |> resource_error(resource, "does not exist", @not_found)
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("ORUP-A-1")
    end
  end
  defp update_order_state(conn, _, _, _), do: conn |> internal_error("ORUP-A-2")
end
