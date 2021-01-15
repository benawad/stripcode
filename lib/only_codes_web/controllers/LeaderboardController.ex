defmodule OnlyCodesWeb.LeaderboardController do
  use OnlyCodesWeb, :controller
  alias OnlyCodes.{Repo, User}
  import Ecto.Query

  def format_num(n) do
    n
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3, 3, [])
    |> Enum.join(",")
    |> String.reverse()
  end

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    users =
      Repo.all(
        from all_users in User,
          order_by: [desc: all_users.points],
          limit: 50
      )

    conn
    |> put_resp_header("cache-control", "public, max-age=10")
    |> render("leaderboard.html",
      noHeaderBorder: true,
      page_title: "Leaderboard",
      users:
        users
        |> Enum.map(fn x ->
          %{
            points:
              if(x.points < 0, do: "-" <> format_num(-x.points), else: format_num(x.points)),
            username: x.username,
            topLang: "python",
            avatarUrl: x.avatarUrl
          }
        end)
    )
  end
end
