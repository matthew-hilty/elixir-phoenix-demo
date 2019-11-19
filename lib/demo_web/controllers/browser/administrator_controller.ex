defmodule DemoWeb.Browser.AdministratorController do
  use DemoWeb, :controller

  import DemoWeb.Browser.ControllerUtilities,
    only: [ id_type_validation_error: 1,
            internal_error: 2,
            match_error: 2,
            resource_error: 3,
          ]
  import DemoWeb.ControllerUtilities, only: [validate_id_type: 1]

  alias Demo.Accounts
  alias Demo.Accounts.Agent

  plug :pipeline_require_administrator

  @error :error
  @ignore :ignore
  @index :index
  @info :info
  @invalid_parameter :invalid_parameter
  @new :new
  @no_resource :no_resource
  @ok :ok
  @request_path :request_path
  @show :show

  def create(conn, %{"agent" => agent_params}) do
    case Accounts.create_administrator(agent_params) do
      {@ok, %Agent{administrator: administrator}} ->
        conn
        |> put_flash(@info, "Administrator created successfully.")
        |> redirect(to: administrator_path(conn, @show, administrator))
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> render("new.html", changeset: changeset)
      _ ->
        conn
        |> internal_error("ADCR-B")
    end
  end
  def create(conn, _), do: conn |> match_error("to create an administrator")

  def delete(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, administrator} <- Accounts.get_administrator(id),
         {@ok, _} = Accounts.delete_administrator(administrator) do
      conn
      |> put_flash(@info, "Administrator deleted successfully.")
      |> redirect(to: administrator_path(conn, @index))
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("administrator ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("ADDE-B-1")
    end
  end
  def delete(conn, _), do: conn |> internal_error("ADDE-B-2")

  def index(conn, _params) do
    conn
    |> render("index.html", administrators: Accounts.list_administrators())
  end

  def new(conn, _params) do
    conn
    |> render("new.html", changeset: Accounts.change_administrator())
  end

  def show(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, administrator} <- Accounts.get_administrator(id) do
      conn
      |> render("show.html", administrator: administrator)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("administrator ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("ADSH-B-1")
    end
  end
  def show(conn, _), do: conn |> internal_error("ADSH-B-2")

  defp pipeline_require_administrator(conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(@error, "You must be logged in as an administrator to manage administrators.")
      |> put_session(@request_path, @ignore)
      |> redirect(to: session_path(conn, @new))
      |> halt()
    end
  end
end
