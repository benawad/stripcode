defmodule Auth do
  import Ecto.Query, warn: false
  alias OnlyCodes.{Repo, User}

  def find_or_create(user) do
    githubId = Integer.to_string(user["id"])

    db_user = Repo.get_by(User, githubId: githubId)

    cond do
      db_user ->
        db_user
        |> User.changeset(%{
          avatarUrl: user["avatar_url"]
        })
        |> Repo.update!()

      true ->
        %User{}
        |> User.changeset(%{
          username: user["login"],
          githubId: githubId,
          avatarUrl: user["avatar_url"]
        })
        |> Repo.insert!()
    end
  end
end
