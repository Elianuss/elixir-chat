defmodule ElixirChatWeb.MessageComponent do
  use Phoenix.Component

  def classes(classes) do
    classes
    |> Enum.filter(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.join(" ")
  end

  def message(assigns) do
    ~H"""
      <div id={@id} class="flex">
        <div class={"break-all inline-block my-2 p-8 rounded-b-xl rounded-r-xl bg-base-purple-300/10 text-gray-800 max-w-[70%] #{if @is_self_message, do: "ml-auto !bg-base-purple-300/20 rounded-t-lg !rounded-l-lg !rounded-b-[0px]"}"}>
          <p><%= @content %></p>
        </div>
      </div>
    """
  end

end
