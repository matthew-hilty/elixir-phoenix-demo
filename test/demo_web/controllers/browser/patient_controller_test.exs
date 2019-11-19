defmodule DemoWeb.Browser.PatientControllerTest do
  use DemoWeb.ConnCase

  import Demo.DataCase, only: [fixture: 1]
  import DemoWeb.Browser.ConnCase, only: [log_in_admin: 1]

  @invalid_attrs %{address: nil, name: nil}
  @create_attrs %{name: "some name", address: "some address"}

  describe "index" do
    setup [:log_in_admin]

    test "lists all patients", %{conn: conn} do
      response = get conn, patient_path(conn, :index)
      assert html_response(response, 200) =~ "Listing Patients"
    end
  end

  describe "new patient" do
    setup [:log_in_admin]

    test "renders form", %{conn: conn} do
      response = get conn, patient_path(conn, :new)
      assert html_response(response, 200) =~ "New Patient"
    end
  end

  describe "create patient" do
    setup [:log_in_admin]

    test "redirects to show when data is valid", %{conn: conn} do
      response0 = post conn, patient_path(conn, :create), patient: @create_attrs
      assert %{id: id} = redirected_params(response0)
      assert redirected_to(response0) == patient_path(response0, :show, id)
      response1 = get conn, patient_path(conn, :show, id)
      assert html_response(response1, 200) =~ "Show Patient"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      response = post conn, patient_path(conn, :create), patient: @invalid_attrs
      assert html_response(response, 400) =~ "New Patient"
    end
  end

  describe "delete patient" do
    setup [:log_in_admin, :create_patient]

    test "deletes chosen patient", %{conn: conn, patient: patient} do
      response0 = delete conn, patient_path(conn, :delete, patient)
      assert redirected_to(response0) == patient_path(response0, :index)
      response1 = get conn, patient_path(conn, :show, patient)
      assert redirected_to(response1) == page_path(response1, :index)
      error = "Patient ##{patient.id} does not exist"
      assert get_flash(response1, :error) =~ error
    end
  end

  defp create_patient(_) do
    patient = fixture(:patient)
    {:ok, patient: patient}
  end
end
