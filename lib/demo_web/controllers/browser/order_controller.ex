defmodule DemoWeb.Browser.OrderController do
  use DemoWeb, :controller

  import DemoWeb.Browser.ControllerUtilities,
    only: [ authentication_error: 2,
            authorization_error: 2,
            changeset_error: 2,
            id_type_validation_error: 1,
            internal_error: 2,
            match_error: 2,
            resource_error: 3,
            send_attachment: 4,
            validation_error: 2,
          ]
  import DemoWeb.ControllerUtilities, only: [validate_id_type: 1]
  import DemoWeb.GuardianController, only: [authenticate_agent: 1]
  import DemoWeb.OrderUtilities,
    only: [ normalize_validate_creation: 2,
            normalize_validate_index: 2,
            normalize_validate_update: 3,
          ]
  import Utilities, only: [accumulate_errors: 1]
  import DemoWeb.Utilities, only: [to_changeset: 2]

  alias Demo.Accounts
  alias Demo.Accounts.{Administrator,Courier,Pharmacy}
  alias Demo.Orders
  alias Demo.Orders.Order
  alias DemoWeb.OrderView

  @error :error
  @no_resource :no_resource
  @index :index
  @info :info
  @invalid_parameter :invalid_parameter
  @normalized_params :normalized_params
  @not_authenticated :not_authenticated
  @not_authorized :not_authorized
  @ok :ok
  @show :show

  def create(conn, %{"order" => params}) do
    with {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         {@ok, _} <- authorize_admin_or_pharmacy(account),
         validated_params <- normalize_validate_creation(params, account),
         {@ok, normalized_params} <- accumulate_errors(validated_params),
         {@ok, order} <- Orders.create_order(normalized_params) do
      conn
      |> put_flash(@info, "Order created successfully.")
      |> redirect(to: order_path(conn, @show, order))
    else
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must log in to create an order")
      {@error, @not_authorized} ->
        conn
        |> authorization_error("Not authorized to create an order")
      {@error, %{errors: errors, valid_results: valid_results}} ->
        changeset =
          errors
          |> OrderView.format_upsert_errors()
          |> to_changeset(valid_results)
        conn
        |> changeset_error(%{view: "new.html", changeset: changeset})
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(%{view: "new.html", changeset: changeset})
      _ ->
        conn
        |> internal_error("ORCR-B")
    end
  end
  def create(conn, _), do: conn |> match_error("to create an order")

  def csv_index(conn, params) do
    with {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         validated_params <- normalize_validate_index(params, account),
         {@ok, normalized_params} <- accumulate_errors(validated_params),
         orders <- Orders.list_orders(normalized_params),
         csv <- OrderView.to_csv(orders) do
      conn
      |> send_attachment("text/csv", "orders.csv", csv)
    else
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must log in to view orders")
      {@error, %{errors: errors, valid_results: _}} ->
        conn
        |> validation_error(OrderView.format_index_errors(errors))
      _ ->
        conn
        |> internal_error("ORINCSV-B")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         {@ok, order} <- Orders.get_order(id),
         {@ok, _} <- authorize(account, order),
         {@ok, _} <- Orders.delete_order(order) do
      conn
      |> put_flash(@info, "Order ##{id} canceled successfully.")
      |> redirect(to: order_path(conn, @index))
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must log in to cancel order ##{id}")
      {@error, @no_resource} ->
        conn
        |> resource_error("order ##{id}", "does not exist")
      {@error, @not_authorized} ->
        conn
        |> authorization_error("Not authorized to cancel order ##{id}")
      {@error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(@error, "Failure to cancel order ##{id}")
        |> redirect(to: order_path(conn, @show, id))
      _ ->
        conn
        |> internal_error("ORSH-B-1")
    end
  end
  def delete(conn, _), do: conn |> internal_error("ORSH-B-2")

  def edit(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, agent} <- authenticate_agent(conn),
         {@ok, order} <- Orders.get_order(id),
         account <- Accounts.specify_agent(agent),
         {@ok, _} <- authorize(account, order) do
      conn
      |> render("edit.html", order_id: id, changeset: Orders.change_order(order))
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must log in to update order ##{id}")
      {@error, @no_resource} ->
        conn
        |> resource_error("order ##{id}", "does not exist")
      {@error, @not_authorized} ->
        conn
        |> authorization_error("Not authorized to update order ##{id}")
      _ ->
        conn
        |> internal_error("ORED-B-1")
    end
  end
  def edit(conn, _), do: conn |> internal_error("ORED-B-2")

  def index(conn, params) do
    with {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         validated_params <- normalize_validate_index(params, account),
         {@ok, normalized_params} <- accumulate_errors(validated_params),
         orders <- Orders.list_orders(normalized_params) do
      conn
      |> assign(@normalized_params, normalized_params)
      |> render("index.html", orders: orders)
    else
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must log in to view orders")
      {@error, %{errors: errors, valid_results: _}} ->
        conn
        |> validation_error(OrderView.format_index_errors(errors))
      _ ->
        conn
        |> internal_error("ORIN-B")
    end
  end

  def new(conn, _params) do
    with {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         {@ok, _} <- authorize_admin_or_pharmacy(account) do
      conn
      |> render("new.html", changeset: Orders.change_order(%Order{}))
    else
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must log in to create an order")
      {@error, @not_authorized} ->
        conn
        |> authorization_error("Not authorized to create an order")
      _ ->
        conn
        |> internal_error("ORNE-B")
    end
  end

  def show(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, agent} <- authenticate_agent(conn),
         account <- Accounts.specify_agent(agent),
         {@ok, order} <- Orders.get_order(id),
         {@ok, _} <- authorize(account, order) do
      conn
      |> render("show.html", order: order)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must log in to view order ##{id}")
      {@error, @no_resource} ->
        conn
        |> resource_error("order ##{id}", "does not exist")
      {@error, @not_authorized} ->
        conn
        |> authorization_error("Not authorized to view order ##{id}")
      _ ->
        conn
        |> internal_error("ORSH-B-1")
    end
  end
  def show(conn, _), do: conn |> internal_error("ORSH-B-2")

  def update(conn, %{"id" => id, "order" => params}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, agent} <- authenticate_agent(conn),
         {@ok, order} <- Orders.get_order(id),
         account <- Accounts.specify_agent(agent),
         {@ok, _} <- authorize(account, order),
         validated_params <- normalize_validate_update(order, params, account),
         {@ok, normalized_params} <- accumulate_errors(validated_params) do
      {@ok, new_order} = Orders.update_order(order, normalized_params)
      conn
      |> put_flash(@info, "Order ##{id} updated successfully.")
      |> redirect(to: order_path(conn, @show, new_order))
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @not_authenticated} ->
        conn
        |> authentication_error("Must log in to update order ##{id}")
      {@error, @no_resource} ->
        conn
        |> resource_error("order ##{id}", "does not exist")
      {@error, @not_authorized} ->
        conn
        |> authorization_error("Not authorized to update order ##{id}")
      {@error, %{errors: errors, valid_results: valid_results}} ->
        changeset =
          errors
          |> OrderView.format_upsert_errors()
          |> to_changeset(valid_results)
        conn
        |> changeset_error(%{
              view: "edit.html",
              changeset: changeset,
              order_id: id,
            })
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(%{
              view: "edit.html",
              changeset: changeset,
              order_id: id,
            })
      _ ->
        conn
        |> internal_error("ORCR-B")
    end
  end
  def update(conn, _), do: conn |> match_error("to update an order")

  defp authorize(account, order) do
    authorized? = case account do
      %Administrator{} -> true
      %Courier{} -> account.id == order.courier_id
      %Pharmacy{} -> account.id == order.pharmacy_id
    end
    if authorized? do
      {@ok, account}
    else
      {@error, @not_authorized}
    end
  end

  defp authorize_admin_or_pharmacy(account) do
    authorized? = case account do
      %Administrator{} -> true
      %Pharmacy{} -> true
      _ -> false
    end
    if authorized? do
      {@ok, account}
    else
      {@error, @not_authorized}
    end
  end
end
