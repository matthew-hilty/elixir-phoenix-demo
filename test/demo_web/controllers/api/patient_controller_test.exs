defmodule DemoWeb.Api.PatientControllerTest do
  use DemoWeb.Api.ConnCase

  import Demo.DataCase, only: [json_equiv?: 2]
  import DemoWeb.Api.ConnCase,
    only: [ add_administrator: 1,
            add_patient: 1,
            log_in_admin: 1,
          ]

  describe "index" do
    setup [:add_administrator, :log_in_admin, :add_patient, :add_patient]

    test "lists all patients", %{conn: conn, patients: patients} do
      response = get conn, api_patient_path(conn, :index)
      json = json_response(response, 200)
      assert json_equiv?(json["patients"], patients)
    end
  end

  describe "show patient" do
    setup [:add_administrator, :log_in_admin, :add_patient]

    test "renders a patient when the id is valid" , %{conn: conn, patient: patient} do
      response0 = get conn, api_patient_path(conn, :show, patient)
      json = json_response(response0, 200)
      assert json_equiv?(json["patient"], patient)
    end
  end

  describe "create patient" do
    setup [:add_administrator, :log_in_admin, :add_patient]

    test "creates and renders a patient when the data is valid" , %{conn: conn} do
      name = "some name"
      address = "some address"

      attrs = %{"name" => name, "address" => address}

      response0 = post conn, api_patient_path(conn, :create), patient: attrs
      json = json_response(response0, :created)
      created = json["created"]["patient"]
      created_id = created["id"]

      template = %{"id" => created_id} |> Enum.into(attrs)

      assert created == template

      response1 = get conn, api_patient_path(conn, :show, created_id)
      json = json_response(response1, 200)
      assert json["patient"] == template
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{}
      response = post conn, api_patient_path(conn, :create), patient: invalid_attrs
      json_response(response, 400)
    end
  end
end
