defmodule Rill.Consumer do
  defmodule Defaults do
    def poll_interval_milliseconds, do: 100
    def batch_size, do: 1000
    def position_update_interval, do: 100
  end

  defstruct global_position: 1, timer_ref: nil

  alias Rill.MessageStore.MessageData.Read
  alias Rill.Messaging.Handler

  def dispatch(%__MODULE__{} = state, handlers, %Read{} = message_data) do
    Enum.each(handlers, fn handler ->
      Handler.handle(handler, message_data)
    end)

    update_position(state, message_data)
  end

  def update_position(%__MODULE__{} = state, %Read{} = message_data) do
    Map.put(state, :global_position, message_data.global_position)
  end

  defmacro __using__(opts \\ []) do
    handlers = Keyword.fetch!(opts, :handlers)
    identifier = Keyword.get(opts, :identifier) || to_string(__CALLER__.module)
    stream_name = Keyword.fetch!(opts, :stream_name)

    poll_interval_milliseconds =
      Keyword.get(
        opts,
        :poll_interval_milliseconds,
        Defaults.poll_interval_milliseconds()
      )

    batch_size = Keyword.get(opts, :batch_size, Defaults.batch_size())

    quote location: :keep do
      use GenServer

      def init(state \\ %__MODULE__{}) do
        interval = unquote(poll_interval_milliseconds)
        GenServer.cast()
        {:ok, ref} = :timer.send_interval(interval, self(), {:fetch})
        state = Map.put(state, :timer_ref, ref)
        {:ok, state}
      end
    end
  end
end
