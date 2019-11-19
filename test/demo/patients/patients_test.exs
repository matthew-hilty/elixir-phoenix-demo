defmodule Demo.PatientsTest do
  use Demo.DataCase

  alias Demo.Patients

  describe "patients" do
    alias Demo.Patients.Patient

    @valid_attrs %{address: "some address", name: "some name"}
    @update_attrs %{address: "some updated address", name: "some updated name"}
    @invalid_attrs %{address: nil, name: nil}

    def patient_fixture(attrs \\ %{}) do
      {:ok, patient} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Patients.create_patient()
      patient
    end

    test "list_patients/0 returns all patients" do
      patient = patient_fixture()
      assert(Equiv.equiv?(Patients.list_patients(), [patient]))
    end

    test "get_patient/1 returns the patient with given id" do
      patient = patient_fixture()
      assert Patients.get_patient(patient.id) |> elem(1) == patient
    end

    test "create_patient/1 with valid data creates a patient" do
      assert {:ok, %Patient{} = patient} = Patients.create_patient(@valid_attrs)
      assert patient.address == "some address"
      assert patient.name == "some name"
    end

    test "create_patient/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Patients.create_patient(@invalid_attrs)
    end

    test "update_patient/2 with valid data updates the patient" do
      patient = patient_fixture()
      assert {:ok, patient} = Patients.update_patient(patient, @update_attrs)
      assert %Patient{} = patient
      assert patient.address == "some updated address"
      assert patient.name == "some updated name"
    end

    test "update_patient/2 with invalid data returns error changeset" do
      patient = patient_fixture()
      assert {:error, %Ecto.Changeset{}} = Patients.update_patient(patient, @invalid_attrs)
      assert patient == Patients.get_patient(patient.id) |> elem(1)
    end

    test "delete_patient/1 deletes the patient" do
      patient = patient_fixture()
      assert {:ok, %Patient{}} = Patients.delete_patient(patient)
      assert {:error, :no_resource} = Patients.get_patient(patient.id)
    end

    test "change_patient/1 returns a patient changeset" do
      patient = patient_fixture()
      assert %Ecto.Changeset{} = Patients.change_patient(patient)
    end
  end
end
