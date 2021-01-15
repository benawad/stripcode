defmodule OnlyCodesWeb.Router do
  use OnlyCodesWeb, :router
  require Ueberauth

  def auth_or_redirect(conn, _opts) do
    session = get_session(conn)

    case session do
      %{"current_user" => %{userId: _, version: 1}} -> conn
      _ -> redirect(conn, to: "/auth/github") |> halt()
    end
  end

  def check_if_ben(conn, _opts) do
    session = get_session(conn)

    case session do
      %{"current_user" => %{isBen: true}} -> conn
      _ -> redirect(conn, external: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    end
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OnlyCodesWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug :auth_or_redirect
  end

  pipeline :is_the_one_and_only_benawad do
    plug :check_if_ben
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", OnlyCodesWeb do
    pipe_through :browser

    get "/github", LoginController, :request
    get "/github/callback", LoginController, :callback
  end

  scope "/ranked", OnlyCodesWeb do
    pipe_through :browser
    pipe_through :auth

    live "/", RankedLive, :index
    # live "/no-timer", RankedLive, :index
  end

  scope "/", OnlyCodesWeb do
    pipe_through :browser

    get "/", LandingPageController, :index
    get "/leaderboard", LeaderboardController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", OnlyCodesWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through :browser
    pipe_through :is_the_one_and_only_benawad

    live_dashboard "/dashboard", metrics: OnlyCodesWeb.Telemetry, ecto_repos: [OnlyCodes.Repo]
  end
end
