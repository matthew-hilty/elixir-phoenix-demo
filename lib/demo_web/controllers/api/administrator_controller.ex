defmodule DemoWeb.Api.AdministratorController do
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

  def create(conn, %{"administrator" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("administrator", Map.take(params, ["email"]))
    case Accounts.create_administrator(params) do
      {@ok, agent} ->
        conn
        |> put_status(@created)
        |> render("create.json", administrator: agent.administrator)
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("ADCR-A")
    end
  end
  def create(conn, _), do: conn |> match_error("to create an administrator")

  def index(conn, _params) do
    conn
    |> render("index.json", administrators: Accounts.list_administrators())
  end

  def show(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, administrator} <- Accounts.get_administrator(id) do
      conn
      |> render("show.json", administrator: administrator)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("administrator ##{id}", "does not exist", @not_found)
      _ ->
        conn
        |> internal_error("ADSH-A-1")
    end
  end
  def show(conn, _), do: conn |> internal_error("ADSH-A-2")
end
