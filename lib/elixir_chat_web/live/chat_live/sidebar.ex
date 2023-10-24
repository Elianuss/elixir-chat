defmodule ElixirChatWeb.ChatLive.Sidebar do
  use ElixirChatWeb, :live_component
  import ElixirChatWeb.SearchBarComponent
  alias ElixirChat.Accounts
  alias ElixirChat.Chat

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign_rooms(assigns.active_room)
      |> assign_people(assigns.presences, assigns.current_user)
    }
  end

  def assign_rooms(socket, active_room) do
    assign(socket, :rooms, format_room_list(Chat.list_all_rooms(), active_room))
  end

  def assign_people(socket, presences, current_user) do
    user_list = Accounts.list_all_users_without_the_id(current_user.id)
    assign(socket, %{current_user: current_user, people: format_people_list(presences, user_list)})
  end

  defp format_room_list(room_list, active_room) do
    Enum.map(room_list, fn room ->

      assign_active = fn room ->
        if !is_nil(active_room) && room.id == active_room.id,
        do: Map.put_new(room, :active, true),
        else: Map.put_new(room, :active, false)
      end

      Map.from_struct(room)
      |> assign_active.()
    end)
  end

  defp format_people_list(presences, user_list) do
    Enum.map(user_list, fn user ->

      assign_status = fn user ->
        current_presence_user = Map.get(presences, Integer.to_string(user.id), %{})
        if Kernel.map_size(current_presence_user) == 0,
        do: Map.put_new(user, :status, :offline),
        else: Map.put_new(user, :status, :online)
      end

      Map.from_struct(user)
      |> assign_status.()
    end)
  end

  def classes(classes) do
    classes
    |> Enum.filter(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.join(" ")
  end

  def render(assigns) do
    ~H"""
      <div
        class="py-12 flex flex-col items-start justify-start min-w-[370px] bg-gradient-to-t from-base-purple-300 via-base-purple-100 via-30% to-base-purple-200 to-90% gap-y-8">

        <%!-- Hidden for now --%>
        <div class="hidden">
          <ul class="relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
            <%= if @current_user do %>
            <li class="text-[0.8125rem] leading-6 text-zinc-900">
              <%= @current_user.email %>
            </li>
            <li>
              <.link href={~p"/users/settings"}
                class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700">
                Settings
              </.link>
            </li>
            <li>
              <.link href={~p"/users/log_out"} method="delete"
                class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700">
                Log out
              </.link>
            </li>
            <% else %>
            <li>
              <.link href={~p"/users/register"}
                class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700">
                Register
              </.link>
            </li>
            <li>
              <.link href={~p"/users/log_in"}
                class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700">
                Log in
              </.link>
            </li>
            <% end %>
          </ul>
          <h1>Chat List</h1>
          <h2>Current User ID: <%= @current_user.id %></h2>
        </div>

        <%!-- Search Bar --%>
        <.search_bar />

        <div class="custom-scrollbar w-full flex flex-col gap-y-8 overflow-hidden hover:overflow-y-auto transition-all ease-in-out duration-200">

          <%!-- Chat List --%>
          <div class="flex flex-col items-start justify-start w-full gap-y-4">
            <h3 class="font-bold text-base-gray-200 px-8">ROOMS</h3>
            <div class="flex flex-col items-start justify-start w-full">

              <%!-- Chat Room Item --%>
              <.link patch={~p"/chat/#{room.id}"} class={["flex flex-row items-start justify-start gap-x-2 w-full px-8 py-4 relative cursor-pointer transition-all ease-in-out duration-300 hover:bg-black/5", classes("!bg-black/10": room.active)]} :for={room <- @rooms}>
                <div class="w-[6px] h-full absolute left-0 top-0 bg-base-white/30" :if={room.active} />
                <i class="material-icons text-base-white !text-[42px]">group_work</i>
                <div class="flex flex-col text-base-gray-100 w-full">
                  <div class="flex flex-row gap-x-1 items-center justify-start gap-x-1">
                    <div
                      class="flex items-center justify-center rounded-full bg-yellow-400 h-[20px] w-[20px] text-base-purple-200 text-sm">
                      4</div>
                    <h4 class="text-base-white"><b><%= room.name %></b></h4>
                  </div>
                  <p class="text-sm whitespace-nowrap	overflow-hidden text-ellipsis w-[90%]"><b
                      class="text-base-white">John</b>, Serious business around here...</p>
                  <p class="text-xs"><b>3 Out 2023</b></p>
                </div>
              </.link>

            </div>
          </div>

          <%!-- People List --%>
          <div class="flex flex-col items-start justify-start w-full gap-y-4">
            <h3 class="font-bold text-base-gray-200 px-8">PEOPLE</h3>
            <div class="flex flex-col gap-y-4 items-start justify-start w-full">

              <%!-- People Item --%>
              <div class="flex flex-row items-start justify-start gap-x-2 w-full px-8 cursor-pointer" :for={user <- @people}>
                <i class="material-icons text-base-white !text-[42px]">person</i>
                <div class="flex flex-col text-base-gray-100 w-full">
                  <div class="flex flex-row gap-x-1 items-center justify-start gap-x-2">
                    <div class="w-2 h-2 bg-green-400 rounded-full" :if={user.status == :online} />
                    <div class="w-2 h-2 bg-base-gray-200 rounded-full" :if={user.status == :offline} />
                    <h4 class="text-base-white"><b><%= user.email |> String.split("@") |> hd() %></b></h4>
                  </div>
                  <p class="text-sm whitespace-nowrap	overflow-hidden text-ellipsis w-[95%]">Serious business around
                    here...</p>
                  <p class="text-xs"><b>3 Out 2023</b></p>
                </div>
              </div>

            </div>
          </div>

        </div>

      </div>
    """
  end
end
