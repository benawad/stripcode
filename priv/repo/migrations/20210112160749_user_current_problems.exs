defmodule OnlyCodes.Repo.Migrations.UserCurrentProblems do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :currentProblems, :map, default: %{}
    end
  end
end
