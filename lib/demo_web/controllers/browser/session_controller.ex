defmodule DemoWeb.Browser.SessionController do
  use DemoWeb, :controller

  import DemoWeb.Browser.ControllerUtilities,
    only: [ internal_error: 2,
            match_error: 2,
          ]

  alias Demo.Accounts
  alias Demo.Sessions

  @doc """
    Callback required by Guardian
  """
  def auth_error(conn, {_type, _reason}, _opts) do
    note = "(Consider resetting Guardian's 'ttl' value in 'config.ex'.)"
    msg = "Expired credentials #{note}"
    conn
    |> put_status(:forbidden)
    |> json(%{errors: %{request: [msg]}})
  end
  def auth_error(conn, _, _), do: conn |> internal_error("SEAE-B")

  def new(conn, _params) do
    conn
    |> assign(:changeset, Accounts.change_agent())
    |> render("new.html")
  end

  def create(conn, %{"agent" => params}) do
    changeset = Sessions.session_changeset(params)
    if changeset.valid? do
      %{"username" => username, "credential" => %{"password" => password}} = params
      case Sessions.get_agent_by_username_and_password(username, password) do
        {:ok, agent} ->
          conn
          |> log_in(agent.id)
          |> redirect_after_login()
        {:error, :unauthenticated} ->
          conn
          |> authentication_error()
          |> redirect(to: session_path(conn, :new))
      end
    else
      conn
      |> assign(:changeset, %{changeset | action: :show_errors})
      |> render("new.html")
    end
  end
  def create(conn, _) do
    conn
    |> authentication_error()
    |> match_error("to create a session")
  end

  def delete(conn, _) do
    conn
    |> logout()
    |> redirect(to: page_path(conn, :index))
  end

  defp authentication_error(conn) do
    conn
    |> clear_session()
    |> put_flash(:error, "Invalid username/password combination")
  end

  defp get_redirect_path(conn) do
    case get_session(conn, :request_path) do
      nil -> page_path(conn, :index)
      :ignore -> page_path(conn, :index)
      request_path -> request_path
    end
  end

  defp log_in(conn, agent_id) do
    conn
    |> put_flash(:info, "Welcome back!")
    |> DemoWeb.Guardian.Plug.sign_in(%{agent_id: agent_id})
  end

  defp logout(conn) do
    conn
    |> DemoWeb.Guardian.Plug.sign_out()
    |> configure_session(drop: true)
  end

  defp redirect_after_login(conn) do
    conn
    |> delete_session(:request_path)
    |> redirect(to: get_redirect_path(conn))
  end
end
