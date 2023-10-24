defmodule ElixirChatWeb.SearchBarComponent do
  use Phoenix.Component

  def search_bar(assigns) do
    ~H"""
      <div class="flex flex-row items-center justify-between w-full pb-4 border-b border-b-base-purple-100 px-8">
        <div class="flex flex-row gap-x-1">
          <i class="material-icons text-base-white !text-[26px]">more_vert</i>
          <i class="material-icons text-base-white !text-[26px]">search</i>
        </div>
        <i class="material-icons text-base-white !text-[26px]">edit</i>
      </div>
    """
  end
end
