defmodule DemoWeb.Browser.PatientController do
  use DemoWeb, :controller

  import DemoWeb.Browser.ControllerUtilities,
    only: [ id_type_validation_error: 1,
            internal_error: 2,
            match_error: 2,
            resource_error: 3,
          ]
  import DemoWeb.ControllerUtilities, only: [validate_id_type: 1]

  alias Demo.Patients
  alias Demo.Patients.Patient

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

  def create(conn, %{"patient" => patient_params}) do
    case Patients.create_patient(patient_params) do
      {@ok, patient} ->
        conn
        |> put_flash(@info, "Patient created successfully.")
        |> redirect(to: patient_path(conn, @show, patient))
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> render("new.html", changeset: changeset)
      _ ->
        conn
        |> internal_error("PACR-B")
    end
  end
  def create(conn, _) do
    conn
    |> match_error("to create a patient")
  end

  def delete(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, patient} <- Patients.get_patient(id),
         {@ok, _patient} = Patients.delete_patient(patient) do
      conn
      |> put_flash(@info, "Patient deleted successfully.")
      |> redirect(to: patient_path(conn, @index))
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("patient ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("PADE-B-1")
    end
  end
  def delete(conn, _), do: conn |> internal_error("PADE-B-2")

  def index(conn, _params) do
    conn
    |> render("index.html", patients: Patients.list_patients())
  end

  def new(conn, _params) do
    conn
    |> render("new.html", changeset: Patients.change_patient(%Patient{}))
  end

  def show(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, patient} <- Patients.get_patient(id) do
      conn
      |> render("show.html", patient: patient)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("patient ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("PASH-B-1")
    end
  end
  def show(conn, _), do: conn |> internal_error("PASH-B-2")

  defp pipeline_require_administrator(conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(@error, "You must be logged in as an administrator to manage patients.")
      |> put_session(@request_path, @ignore)
      |> redirect(to: session_path(conn, @new))
      |> halt()
    end
  end
end
