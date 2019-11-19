defmodule DemoWeb.Api.PatientView do
  use DemoWeb, :view

  def render("create.json", %{patient: patient}) do
    %{created: %{patient: ToJson.to_json(patient)}}
  end

  def render("index.json", %{patients: patients}) do
    %{ count: length(patients),
       patients: ToJson.to_json(patients),
     }
  end

  def render("show.json", %{patient: patient}) do
    %{patient: ToJson.to_json(patient)}
  end
end
