defmodule PetalComponents.SlideOver do
  use Phoenix.Component

  import PetalComponents.Class

  alias Phoenix.LiveView.JS

  # prop origin, :string, options: ["left", "top", "bottom", "right"]
  # prop title, :string
  # prop max_width, :string
  # slot default
  def slide_over(assigns) do
    assigns =
      assigns
      |> assign_new(:origin, fn -> "right" end)
      |> assign_new(:max_width, fn -> "md" end)
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(
          class
          max_width
          title
          origin
        )a)
      end)

    ~H"""
    <div {@extra_assigns} id="slide-over" phx-remove={hide_slide_over(@origin)}>
      <div
        id="modal-overlay"
        class="fixed inset-0 z-50 transition-opacity bg-gray-900 dark:bg-gray-900 bg-opacity-30 dark:bg-opacity-70"
        aria-hidden="true"
      >
      </div>

      <div
        class={build_class([
          "fixed inset-0 z-50 flex overflow-hidden transform",
          get_margin_classes(@origin),
          @class,
          ])}
        role="dialog"
        aria-modal="true"
      >
        <div
          id="modal-content"
          class={get_classes(@max_width, @origin, @class)}
          phx-click-away={hide_slide_over(@origin)}
          phx-window-keydown={hide_slide_over(@origin)}
          phx-key="escape"
        >

          <!-- Header -->
          <div class="px-5 py-3 border-b border-gray-100 dark:border-gray-600">
            <div class="flex items-center justify-between">
              <div class="font-semibold text-gray-800 dark:text-gray-200">
                <%= @title %>
              </div>

              <button type="button" phx-click={hide_slide_over(@origin)} class="text-gray-400 hover:text-gray-500">
                <div class="sr-only">Close</div>
                <svg class="w-4 h-4 fill-current">
                  <path d="M7.95 6.536l4.242-4.243a1 1 0 111.415 1.414L9.364 7.95l4.243 4.242a1 1 0 11-1.415 1.415L7.95 9.364l-4.243 4.243a1 1 0 01-1.414-1.415L6.536 7.95 2.293 3.707a1 1 0 011.414-1.414L7.95 6.536z" />
                </svg>
              </button>
            </div>
          </div>

          <!-- Content -->
          <div class="p-5">
            <%= render_slot(@inner_block) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # The live view that calls <.slide_over> will need to handle the "close_slide_over" event. eg:
  # def handle_event("close_slide_over", _, socket) do
  #   {:noreply, push_patch(socket, to: Routes.moderate_users_path(socket, :index))}
  # end
  def hide_slide_over(js \\ %JS{}, origin) do
    origin_class =
      case origin do
        x when x in ["left", "right"] -> "translate-x-0"
        x when x in ["top", "bottom"] -> "translate-y-0"
      end

    destination_class =
      case origin do
        "left" -> "-translate-x-full"
        "right" -> "translate-x-full"
        "top" -> "-translate-y-full"
        "bottom" -> "translate-y-full"
      end

    js
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.hide(
      transition: {
        "ease-in duration-200",
        "opacity-100",
        "opacity-0"
      },
      to: "#modal-overlay"
    )
    |> JS.hide(
      transition: {
        "ease-in duration-200",
        origin_class,
        destination_class
      },
      to: "#modal-content"
    )
    |> JS.push("close_slide_over")
  end

  defp get_classes(max_width, origin, class) do
    base_classes = "w-full max-h-full overflow-auto bg-white shadow-lg dark:bg-gray-800"

    slide_over_classes =
      case origin do
        "left" -> "transition translate-x-0"
        "right" -> "transition translate-x-0 absolute right-0 inset-y-0"
        "top" -> "transition translate-y-0 absolute inset-x-0"
        "bottom" -> "transition translate-y-0 absolute inset-x-0 bottom-0"
      end

    max_width_class =
      case origin do
        x when x in ["left", "right"] ->
          case max_width do
            "sm" -> "max-w-sm"
            "md" -> "max-w-xl"
            "lg" -> "max-w-3xl"
            "xl" -> "max-w-5xl"
            "2xl" -> "max-w-7xl"
            "full" -> "max-w-full"
          end

        x when x in ["top", "bottom"] ->
          ""
      end

    custom_classes = class

    build_class([slide_over_classes, max_width_class, base_classes, custom_classes])
  end

  defp get_margin_classes(margin) do
    case margin do
      "left" -> "mr-10"
      "right" -> "ml-10"
      "top" -> "mb-10"
      "bottom" -> "mt-10"
    end
  end
end
