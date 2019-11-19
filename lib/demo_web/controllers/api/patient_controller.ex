defmodule DemoWeb.Api.PatientController do
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

  alias Demo.Patients

  plug :pipeline_require_administrator

  @created :created
  @error :error
  @invalid_parameter :invalid_parameter
  @no_resource :no_resource
  @not_found :not_found
  @ok :ok

  def create(conn, %{"patient" => params}) do
    case Patients.create_patient(params) do
      {@ok, patient} ->
        conn
        |> put_status(@created)
        |> render("create.json", patient: patient)
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("PACR-A")
    end
  end
  def create(conn, _) do
    conn
    |> match_error("to create a patient")
  end

  def index(conn, _params) do
    conn
    |> render("index.json", patients: Patients.list_patients())
  end

  def show(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, patient} <- Patients.get_patient(id) do
      conn
      |> render("show.json", patient: patient)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("patient ##{id}", "does not exist", @not_found)
      _ ->
        conn
        |> internal_error("PASH-A-1")
    end
  end
  def show(conn, _), do: conn |> internal_error("PASH-A-2")
end
