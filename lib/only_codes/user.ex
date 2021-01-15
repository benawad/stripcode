defmodule OnlyCodes.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :points, :integer
    field :avatarUrl, :string
    field :githubId, :string
    field :username, :string
    field :currentLang, :string
    field :currentProblems, :map

    has_many :guessedChoices, OnlyCodes.Choice, foreign_key: :userId

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :githubId, :avatarUrl])
    |> validate_required([:username, :githubId, :avatarUrl])
    |> unique_constraint(:username)
    |> unique_constraint(:githubId)
  end
end
