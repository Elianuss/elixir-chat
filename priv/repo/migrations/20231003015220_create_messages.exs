defmodule ElixirChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :user_id, references(:users), null: false
      add :room_id, references(:rooms), null: false
      add :content, :string
      add :is_edited, :boolean

      timestamps()
    end
  end
end
