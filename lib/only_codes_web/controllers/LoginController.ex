defmodule OnlyCodesWeb.LoginController do
  use OnlyCodesWeb, :controller
  plug(Ueberauth)
  import Ecto.Query, warn: false

  def request(conn, _params) do
    redirect(conn, to: "/")
  end

  def callback(
        %{assigns: %{ueberauth_auth: auth}} = conn,
        _params
      ) do
    %{extra: %{raw_info: %{user: user}}} = auth

    try do
      db_user = Auth.find_or_create(user)

      conn
      |> put_session(:current_user, %{
        userId: db_user.id,
        version: 1,
        isBen:
          db_user.githubId ==
            Application.get_env(:only_codes, :ben_github_id)
      })
      |> configure_session(renew: true)
      |> redirect(to: "/ranked")
    rescue
      e in RuntimeError ->
        conn
        |> put_flash(:error, e.message)
        |> redirect(to: "/")
    end
  end
end
