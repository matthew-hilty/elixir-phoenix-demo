defmodule DemoWeb.Router do
  use DemoWeb, :router

  import Utilities, only: [nilify_error: 1]

  alias Guardian.Plug.LoadResource, as: Guardian_LoadResource
  alias Guardian.Plug.Pipeline, as: Guardian_Pipeline
  alias Guardian.Plug.VerifyHeader, as: Guardian_VerifyHeader
  alias Guardian.Plug.VerifySession, as: Guardian_VerifySession
  alias DemoWeb.Guardian
  alias DemoWeb.AuthErrorHandler
  alias DemoWeb.GuardianController

  pipeline :browser do
    plug :accepts, ["html"]
    plug ProperCase.Plug.SnakeCaseParams
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian_Pipeline, module: Guardian, error_handler: AuthErrorHandler
    plug Guardian_VerifySession
    plug :authenticate_agent
  end

  scope "/", DemoWeb.Browser do
    pipe_through :browser

    get "/", PageController, :index

    resources "/administrators", AdministratorController, except: [:edit, :update]
    resources "/couriers",       CourierController,       except: [:edit, :update]
    resources "/orders",         OrderController
    resources "/patients",       PatientController,       except: [:edit, :update]
    resources "/pharmacies",     PharmacyController,      except: [:edit, :update]

    get "/orders.csv", OrderController, :csv_index

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  pipeline :api do
    plug :accepts, ["json", "csv"]
    plug ProperCase.Plug.SnakeCaseParams
    plug Guardian_Pipeline,
      error_handler: DemoWeb.Api.SessionController,
      module: DemoWeb.Guardian
    plug Guardian_VerifyHeader, realm: "Token"
    plug Guardian_LoadResource, allow_blank: true
    plug :authenticate_agent
  end

  scope "/api", DemoWeb.Api, as: :api do
    pipe_through :api

    post   "/login",              SessionController,       :create

    get    "/administrators",     AdministratorController, :index
    get    "/administrators/:id", AdministratorController, :show
    post   "/administrators",     AdministratorController, :create

    get    "/couriers",           CourierController,       :index
    get    "/couriers/:id",       CourierController,       :show
    post   "/couriers",           CourierController,       :create

    delete "/orders/:id",         OrderController,         :cancel
    get    "/orders",             OrderController,         :index
    get    "/orders/:id",         OrderController,         :show
    post   "/orders",             OrderController,         :create
    post   "/orders/:id/cancel",  OrderController,         :cancel
    post   "/orders/:id/deliver", OrderController,         :deliver
    post   "/orders/:id/mark_undeliverable", OrderController, :mark_undeliverable

    get    "/patients",           PatientController,       :index
    get    "/patients/:id",       PatientController,       :show
    post   "/patients",           PatientController,       :create

    get    "/pharmacies",         PharmacyController,      :index
    get    "/pharmacies/:id",     PharmacyController,      :show
    post   "/pharmacies",         PharmacyController,      :create
  end

  defp authenticate_agent(conn, _) do
    assign(
      conn,
      :agent,
      GuardianController.identify_agent(conn) |> nilify_error())
  end
end
