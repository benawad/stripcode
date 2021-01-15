defmodule OnlyCodes.GitHubRepo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "github_repos" do
    field :githubRepoId, :string
    field :description, :string
    field :ownerAndName, :string
    field :stargazerCount, :integer
    field :lang, :string

    has_many :correctAnswerForQuestions, OnlyCodes.Question, foreign_key: :correctGitHubRepoId
    has_many :answer0ForQuestions, OnlyCodes.Question, foreign_key: :answer0GitHubRepoId
    has_many :answer1ForQuestions, OnlyCodes.Question, foreign_key: :answer1GitHubRepoId
    has_many :answer2ForQuestions, OnlyCodes.Question, foreign_key: :answer2GitHubRepoId
    has_many :answer3ForQuestions, OnlyCodes.Question, foreign_key: :answer3GitHubRepoId
    has_many :answer4ForQuestions, OnlyCodes.Question, foreign_key: :answer4GitHubRepoId

    has_many :guessedChoices, OnlyCodes.Choice, foreign_key: :guessedGitHubRepoId

    timestamps()
  end

  @doc false
  def changeset(git_hub_repo, attrs) do
    git_hub_repo
    |> cast(attrs, [:stargazerCount, :description, :githubRepoId, :ownerAndName, :lang])
    |> validate_required([:stargazerCount, :description, :githubRepoId, :ownerAndName, :lang])
    |> unique_constraint(:githubRepoId)
  end
end
