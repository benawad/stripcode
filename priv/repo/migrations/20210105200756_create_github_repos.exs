defmodule OnlyCodes.Repo.Migrations.CreateGithubRepos do
  use Ecto.Migration

  def change do
    create table(:github_repos) do
      add :stargazerCount, :integer, null: false
      add :description, :text, null: false
      add :githubRepoId, :string, null: false
      add :ownerAndName, :text, null: false
      add :lang, :string, null: false

      timestamps()
    end

    create index(:github_repos, [:lang])
    create unique_index(:github_repos, [:githubRepoId])
  end
end
