defmodule DemoWeb.Api.SessionView do
  use DemoWeb, :view

  def render("create.json", %{agent: agent, jwt: jwt}) do
    %{session: %{user: ToJson.to_json(agent), token: jwt}}
  end
end
