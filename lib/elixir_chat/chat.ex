defmodule ElixirChat.Chat do
  import Ecto.Query, warn: false
  alias Expo.Message
  alias ElixirChat.Chat.Room
  alias ElixirChat.Repo
  alias ElixirChat.Chat.Message

  @topic_rooms "room:id"

  # Get all Rooms
  def list_all_rooms() do
    Repo.all(Room)
  end

  def get_room_by_id(id) do
    Repo.get(Room, id)
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> publish_message_created()
  end

  def get_all_messages_by_room_id(room_id) do
    query = from(
      m in Message,
      where: m.room_id == ^room_id,
      select: m
    )

    Repo.all(query)
  end

  def publish_message_created({:ok, message} = result) do
    Phoenix.PubSub.broadcast(ElixirChat.PubSub, @topic_rooms, %{message: message})
    result
  end

  def publish_message_created(result), do: result

end
