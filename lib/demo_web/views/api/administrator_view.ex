defmodule DemoWeb.Api.AdministratorView do
  use DemoWeb, :view

  def render("create.json", %{administrator: administrator}) do
    %{created: %{administrator: ToJson.to_json(administrator)}}
  end

  def render("index.json", %{administrators: administrators}) do
    %{ count: length(administrators),
       administrators: ToJson.to_json(administrators),
     }
  end

  def render("show.json", %{administrator: administrator}) do
    %{administrator: ToJson.to_json(administrator)}
  end
end
