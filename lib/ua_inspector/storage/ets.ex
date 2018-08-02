defmodule UAInspector.Storage.ETS do
  @moduledoc """
  ETS Interaction for storage servers.
  """

  @doc """
  Creates a new named storage table.
  """
  @spec create(module) :: :ets.tid()
  def create(name) do
    :ets.new(name, [:protected, :ordered_set, read_concurrency: true])
  end

  @doc """
  Deletes a storage table if it exists.
  """
  @spec delete(:ets.tid()) :: :ok
  def delete(tid) do
    true =
      case :ets.info(tid) do
        :undefined -> true
        _ -> :ets.delete(tid)
      end

    :ok
  end
end
