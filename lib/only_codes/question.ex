defmodule OnlyCodes.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :codeBlocks, {:array, :string}
    field :numLines, :integer
    field :path, :string
    field :lang, :string

    belongs_to :correctGitHubRepo, OnlyCodes.GitHubRepo,
      foreign_key: :correctGitHubRepoId,
      references: :githubRepoId,
      type: :string

    belongs_to :answer0GitHubRepo, OnlyCodes.GitHubRepo,
      foreign_key: :answer0GitHubRepoId,
      references: :githubRepoId,
      type: :string

    belongs_to :answer1GitHubRepo, OnlyCodes.GitHubRepo,
      foreign_key: :answer1GitHubRepoId,
      references: :githubRepoId,
      type: :string

    belongs_to :answer2GitHubRepo, OnlyCodes.GitHubRepo,
      foreign_key: :answer2GitHubRepoId,
      references: :githubRepoId,
      type: :string

    belongs_to :answer3GitHubRepo, OnlyCodes.GitHubRepo,
      foreign_key: :answer3GitHubRepoId,
      references: :githubRepoId,
      type: :string

    belongs_to :answer4GitHubRepo, OnlyCodes.GitHubRepo,
      foreign_key: :answer4GitHubRepoId,
      references: :githubRepoId,
      type: :string

    has_many :guessedChoices, OnlyCodes.Choice, foreign_key: :questionId

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:codeBlocks, :path, :numLines, :lang])
    |> validate_required([:codeBlocks, :path, :numLines, :lang])
  end
end
