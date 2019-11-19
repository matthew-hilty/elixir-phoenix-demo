defmodule DemoWeb.Browser.PharmacyController do
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
    case Accounts.create_pharmacy(agent_params) do
      {@ok, %Agent{pharmacy: pharmacy}} ->
        conn
        |> put_flash(@info, "Pharmacy created successfully.")
        |> redirect(to: pharmacy_path(conn, @show, pharmacy))
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> render("new.html", changeset: changeset)
      _ ->
        conn
        |> internal_error("PHCR-B")
    end
  end
  def create(conn, _) do
    conn
    |> match_error("to create a pharmacy")
  end

  def delete(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, pharmacy} <- Accounts.get_pharmacy(id),
         {@ok, _} = Accounts.delete_pharmacy(pharmacy) do
      conn
      |> put_flash(@info, "Pharmacy deleted successfully.")
      |> redirect(to: pharmacy_path(conn, @index))
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("pharmacy ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("PHDE-B-1")
    end
  end
  def delete(conn, _), do: conn |> internal_error("PHDE-B-2")

  def index(conn, _params) do
    conn
    |> render("index.html", pharmacies: Accounts.list_pharmacies())
  end

  def new(conn, _params) do
    conn
    |> render("new.html", changeset: Accounts.change_pharmacy())
  end

  def show(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, pharmacy} <- Accounts.get_pharmacy(id) do
      conn
      |> render("show.html", pharmacy: pharmacy)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("pharmacy ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("PHSH-B-1")
    end
  end
  def show(conn, _), do: conn |> internal_error("PHSH-B-2")

  defp pipeline_require_administrator(conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(@error, "You must be logged in as an administrator to manage pharmacies.")
      |> put_session(@request_path, @ignore)
      |> redirect(to: session_path(conn, @new))
      |> halt()
    end
  end
end
