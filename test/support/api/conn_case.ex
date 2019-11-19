defmodule DemoWeb.Api.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  import Demo.DataCase, only: [fixture: 1, get_password: 1]
  import DemoWeb.Router.Helpers, only: [api_session_path: 2]
  import Phoenix.ConnTest, only: [build_conn: 0, post: 3]
  import Plug.Conn, only: [put_req_header: 3]

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import DemoWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint DemoWeb.Endpoint
    end
  end

  @endpoint DemoWeb.Endpoint

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Demo.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Demo.Repo, {:shared, self()})
    end
    {:ok, conn: build_conn()}
  end

  def add_administrator(context) do
    administrators = Map.get(context, :administrators) || []
    administrator = fixture(:administrator)
    { :ok,
      administrator: administrator,
      administrators: [administrator | administrators],
    }
  end

  def add_courier(context) do
    couriers = Map.get(context, :couriers) || []
    courier = fixture(:courier)
    { :ok,
      courier: courier,
      couriers: [courier | couriers],
    }
  end

  def add_order(context) do
    orders = Map.get(context, :orders) || []
    order = fixture(:order)
    { :ok,
      order: order,
      orders: [order | orders],
    }
  end

  def add_patient(context) do
    patients = Map.get(context, :patients) || []
    patient = fixture(:patient)
    { :ok,
      patient: patient,
      patients: [patient | patients],
    }
  end

  def add_pharmacy(context) do
    pharmacies = Map.get(context, :pharmacies) || []
    pharmacy = fixture(:pharmacy)
    { :ok,
      pharmacy: pharmacy,
      pharmacies: [pharmacy | pharmacies],
    }
  end

  def log_in_admin(%{administrators: [administrator | _]}) do
    credential = %{ "username" => administrator.username,
                    "password" => get_password(administrator),
                  }
    { :ok,
      conn: get_authenticated_connection(credential),
      logged_in_admin: administrator,
    }
  end

  defp get_authenticated_connection(credential) do
    conn0 = build_conn()
    response =
      conn0
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json")
      |> post(api_session_path(conn0, :create), credential)
    token = Poison.Parser.parse!(response.resp_body)["session"]["token"]
    put_req_header(build_conn(), "authorization", "token: #{token}")
  end
end
