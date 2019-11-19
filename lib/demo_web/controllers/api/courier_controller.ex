defmodule DemoWeb.Api.CourierController do
  use DemoWeb, :controller

  import DemoWeb.Api.ControllerUtilities,
    only: [ changeset_error: 2,
            id_type_validation_error: 1,
            internal_error: 2,
            match_error: 2,
            pipeline_require_administrator: 2,
            resource_error: 4
          ]
  import DemoWeb.ControllerUtilities, only: [validate_id_type: 1]

  alias Demo.Accounts

  plug :pipeline_require_administrator

  @created :created
  @error :error
  @invalid_parameter :invalid_parameter
  @no_resource :no_resource
  @not_found :not_found
  @ok :ok

  def create(conn, %{"courier" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("courier", Map.take(params, ["name", "email", "address"]))
    case Accounts.create_courier(params) do
      {@ok, agent} ->
        conn
        |> put_status(@created)
        |> render("create.json", courier: agent.courier)
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("COCR-A")
    end
  end
  def create(conn, _) do
    conn
    |> match_error("to create a courier")
  end

  def index(conn, _params) do
    conn
    |> render("index.json", couriers: Accounts.list_couriers())
  end

  def show(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, courier} <- Accounts.get_courier(id) do
      conn
      |> render("show.json", courier: courier)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("courier ##{id}", "does not exist", @not_found)
      _ ->
        conn
        |> internal_error("COSH-A-1")
    end
  end
  def show(conn, _), do: conn |> internal_error("COSH-A-2")
end
