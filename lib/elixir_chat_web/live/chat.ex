defmodule ElixirChatWeb.ChatMain do
  alias ElixirChat.Chat
  alias ElixirChatWeb.ChatLive.Room
  alias ElixirChatWeb.ChatLive.Sidebar
  alias ElixirChatWeb.Presence
  alias ElixirChat.Chat
  use ElixirChatWeb, :live_view

  @topic_users "users:chat_list"
  @topic_rooms "room:id"

  on_mount {ElixirChatWeb.UserAuth, :ensure_authenticated}

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Phoenix.PubSub.subscribe(ElixirChat.PubSub, @topic_users)

      {:ok, _} = Presence.track(self(), @topic_users, current_user.id, %{
        user_id: current_user.id,
        username: current_user.email |> String.split("@") |> hd(),
        status: :online
      })
    end

    presences = Presence.list(@topic_users)

    {:ok,
      socket
      |> assign_active_room()
      |> assign_messages()
      |> assign(%{
        presences: simple_presence_map(presences),
        diff: nil,
        current_user: current_user
      })
    }
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ElixirChat.PubSub, @topic_rooms)
    {:noreply,
      socket
      |> stream(:messages, [], reset: true)
      |> assign_active_room(id)
      |> assign_messages(id)
    }
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  def handle_info(%{message: message}, socket) do
    {:noreply,
      socket
      |> insert_new_message(message)
      |> push_event("scrollToBottom", %{})
    }
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    {:noreply, socket
      |> remove_presences(diff.leaves)
      |> add_presences(diff.joins)
    }
  end

  defp assign_active_room(socket, id) do
    assign(socket, :room, Chat.get_room_by_id(id))
  end

  defp assign_active_room(socket) do
    assign(socket, :room, nil)
  end

  defp assign_messages(socket, active_room_id) do
    messages = case active_room_id do
      nil -> []
      _ -> Chat.get_all_messages_by_room_id(active_room_id)
    end
    socket
    |> stream(:messages, messages)
    |> push_event("scrollToBottom", %{})
  end

  defp assign_messages(socket), do: stream(socket, :messages, [])

  defp insert_new_message(socket, message) do
    stream_insert(socket, :messages, message)
  end

  defp remove_presences(socket, leaves) do
    user_ids = Enum.map(leaves, fn {user_id, _} -> user_id end)
    presences = Map.drop(socket.assigns.presences, user_ids)
    assign(socket, :presences, presences)
  end

  defp add_presences(socket, joins) do
    presences = Map.merge(socket.assigns.presences, simple_presence_map(joins))
    assign(socket, :presences, presences)
  end

  def simple_presence_map(presences) do
    Enum.into(presences, %{}, fn {user_id, %{metas: [meta | _]}} -> { user_id, meta } end)
  end

  def render(assigns) do
    ~H"""
      <div class="w-full h-full flex">

        <%!-- <pre><%= inspect(@streams, pretty: true) %></pre> --%>

        <%!-- Sidebar --%>
        <.live_component module={Sidebar} presences={@presences} active_room={@room} current_user={@current_user} id={"sidebar-of-user-#{@current_user.id}"}/>

        <%!-- Room --%>
        <.live_component module={Room} active_room={@room} messages={@streams.messages} current_user={@current_user} id={"room-for-user-#{@current_user.id}"} />
      </div>
    """
  end

end
