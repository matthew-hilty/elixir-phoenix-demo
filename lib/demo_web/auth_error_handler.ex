defmodule DemoWeb.AuthErrorHandler do
  use DemoWeb, :controller

  def auth_error(%Plug.Conn{} = conn, {_type, _reason}, _opts) do
    note = "(Consider resetting Guardian's 'ttl' value in 'config.ex'.)"
    msg = "Expired credentials #{note}"
    conn
    |> DemoWeb.Guardian.Plug.sign_out()
    |> clear_session()
    |> put_flash(:warning, msg)
    |> redirect(to: session_path(conn, :create))
  end
end
