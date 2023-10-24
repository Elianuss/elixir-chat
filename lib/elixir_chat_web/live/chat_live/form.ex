defmodule ElixirChatWeb.ChatLive.Form do
  alias ElixirChat.Chat
  alias ElixirChat.Chat.Message
  use ElixirChatWeb, :live_component

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(%{
        changeset: Message.changeset(%Message{}, %{})
      })
    }
  end

  def handle_event("update", %{"content" => content} = _params, socket) do
    {:noreply,
      socket
      |> assign(:changeset, Message.changeset(%Message{content: content}, %{}))
    }
  end

  def handle_event("save", %{"content" => content} = _params, socket) do
    Chat.create_message(%{
      content: content,
      room_id: socket.assigns.room_id,
      user_id: socket.assigns.user_id,
    })

    {:noreply,
      socket
      |> assign(:changeset, Message.changeset(%Message{}, %{}))
    }
  end

  def render(assigns) do
    ~H"""
      <div class="full-w-inputs block w-full h-[10%] max-h-[100px]">
        <.form id="message-form" class="flex items-center justify-start bg-base-white w-full bg-base-white px-8 py-6 gap-x-3 h-full nth-child(1):bg-red-400"
          for={@changeset}
          phx-submit="save"
          phx-change="update"
          phx-target={@myself}
          phx-hook="ScrollDown"
        >
          <.input name="content" value="" field={{@changeset, :content}} style="margin: 0px" />
          <.button class="button-appearance-none">
            <i class="material-icons text-base-purple-100 !text-[32px] hover:brightness-150 transition-all ease-in-out duration-150">send</i>
          </.button>
        </.form>
      </div>
    """
  end

end
