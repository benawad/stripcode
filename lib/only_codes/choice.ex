defmodule OnlyCodes.Choice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "choices" do
    field :pointsEarned, :integer, null: false

    belongs_to :user, OnlyCodes.User, foreign_key: :userId
    belongs_to :githubRepo, OnlyCodes.GitHubRepo, foreign_key: :guessedGitHubRepoId
    belongs_to :question, OnlyCodes.Question, foreign_key: :questionId

    timestamps()
  end

  @doc false
  def changeset(choice, attrs) do
    choice
    |> cast(attrs, [:pointsEarned, :guessedGitHubRepoId, :userId, :questionId])
    |> validate_required([:pointsEarned, :guessedGitHubRepoId, :userId, :questionId])
    |> unique_constraint(:already_answered, name: :verify_answered_only_once)
  end
end
