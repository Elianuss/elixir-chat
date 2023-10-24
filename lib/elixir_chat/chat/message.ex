defmodule ElixirChat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElixirChat.Chat.Room
  alias ElixirChat.Accounts.User

  schema "messages" do
    field :content, :string
    belongs_to :room, Room
    belongs_to :user, User

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :user_id, :room_id])
    |> validate_required([:content, :user_id, :room_id])
  end

end
