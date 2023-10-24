defmodule ElixirChatWeb.ChatLive.Room do
  use ElixirChatWeb, :live_component
  import ElixirChatWeb.MessageComponent
  alias ElixirChatWeb.ChatLive.Form

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
    }
  end

  def render(assigns) do
    ~H"""
      <div class="flex w-full h-full bg-base-white bg-gradient-to-t from-base-gray-100/40 from-0% via-base-white via-40% to-base-gray-100/40 to-100% relative">

        <%!-- Empty State --%>
        <div :if={is_nil(@active_room)}>
          No Room
        </div>

        <div
          :if={!is_nil(@active_room)}
          class="flex flex-col w-full h-full items-start justify-between">
          <div class="px-8 pt-12 pb-4 flex items-center justify-start bg-base-white w-full">
            <h2 class="text-xl"><b><%= if @active_room, do: @active_room.name, else: 'Group #001' %></b></h2>
          </div>

          <div
            id="messages"
            phx-update="stream"
            class="custom-scrollbar dark-scroll w-full h-[90%] flex flex-col px-8 py-4 overflow-y-auto"
          >
            <.message id={dom_id} is_self_message={@current_user.id == message.user_id} content={message.content} :for={{dom_id, message} <- @messages}/>
          </div>

          <%!-- Message Form --%>
          <.live_component id={"message-form-for-user-id-#{@current_user.id}"} module={Form} room_id={@active_room.id} user_id={@current_user.id} />
        </div>
      </div>
    """
  end

end
