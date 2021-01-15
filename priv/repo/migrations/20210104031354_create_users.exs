defmodule OnlyCodes.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :points, :integer, null: false, default: 0
      add :username, :string, null: false
      add :githubId, :string, null: false
      add :avatarUrl, :text
      add :currentLang, :string, default: "python"
      add :other, :map, default: %{}

      timestamps()
    end

    create index(:users, [:points])
    create unique_index(:users, [:githubId])
    create unique_index(:users, [:username])
  end
end
