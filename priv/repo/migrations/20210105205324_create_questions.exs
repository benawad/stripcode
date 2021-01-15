defmodule OnlyCodes.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :codeBlocks, {:array, :text}, null: false
      add :path, :text, null: false
      add :lang, :text, null: false
      add :numLines, :integer, null: false

      add :correctGitHubRepoId, references(:github_repos, column: :githubRepoId, type: :string, on_delete: :delete_all), null: false
      add :answer0GitHubRepoId, references(:github_repos, column: :githubRepoId, type: :string, on_delete: :delete_all), null: false
      add :answer1GitHubRepoId, references(:github_repos, column: :githubRepoId, type: :string, on_delete: :delete_all), null: false
      add :answer2GitHubRepoId, references(:github_repos, column: :githubRepoId, type: :string, on_delete: :delete_all), null: false
      add :answer3GitHubRepoId, references(:github_repos, column: :githubRepoId, type: :string, on_delete: :delete_all), null: false
      add :answer4GitHubRepoId, references(:github_repos, column: :githubRepoId, type: :string, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:questions, [:lang])
  end
end
