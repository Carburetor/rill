defmodule Rill.MessageStore do
  alias Rill.Messaging.Message.Transform

  @type read_option(
          {:position, non_neg_integer()}
          | {:batch_size, pos_integer()}
        )
  @doc """
  Returned enumerable must be a stream from the given position until the end
  of the stream
  """
  @callback read(
              session :: term(),
              stream_name :: String.t(),
              opts :: [read_option()]
            ) :: Enumerable.t()

  @type write_option(
          {:expected_version, Rill.MessageStore.ExpectedVersion.t()}
          | {:reply_stream_name, String.t() | nil}
        )
  @callback write(
              session :: term(),
              message :: struct(),
              stream_name :: String.t(),
              opts :: [write_option()]
            ) :: non_neg_integer()
  @callback write_initial(
              session :: term(),
              message :: struct(),
              stream_name :: String.t()
            ) :: non_neg_integer()

  # @spec write(
  #         session :: term(),
  #         database :: module(),
  #         messages :: struct() | [struct()],
  #         stream_name :: String.t(),
  #         opts :: [write_option()]
  #       ) :: non_neg_integer()
  # def write(session, database, message, stream_name)
  #     when not is_list(message) do
  #   write(session, database, message, stream_name, [])
  # end

  # def write(session, database, message, stream_name, opts)
  #     when not is_list(message) do
  #   write(session, database, [message], stream_name, opts)
  # end

  # def write(session, database, messages, stream_name) when is_list(messages) do
  #   write(session, database, messages, stream_name, [])
  # end

  # def write(session, database, messages, stream_name, opts)
  #     when is_list(messages) do
  #   message_data = Transform.write(message)
  #   expected_version = Keyword.get(opts, :expected_version)
  #   expected_version = ExpectedVersion.canonize(expected_version)
  #   # TODO:

  #   database.put(session, message_data, stream_name)
  # end
end
