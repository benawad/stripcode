defmodule OnlyCodes.Repo.Migrations.CreateChoices do
  use Ecto.Migration

  def change do
    create table(:choices) do
      add :pointsEarned, :integer, null: false

      add :guessedGitHubRepoId, references(:github_repos, on_delete: :delete_all), null: false
      add :userId, references(:users, on_delete: :delete_all), null: false
      add :questionId, references(:questions, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:choices, [:userId, :questionId], name: :verify_answered_only_once)

  end
end
