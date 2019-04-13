defmodule UAInspector.Storage.ETS do
  @moduledoc false

  @doc """
  Creates a new named storage data table.
  """
  @spec create_data(atom) :: :ets.tid()
  def create_data(name) do
    :ets.new(name, [:protected, :ordered_set, read_concurrency: true])
  end

  @doc """
  Creates a new named storage lookup table.
  """
  @spec create_lookup(atom) :: atom
  def create_lookup(name) do
    case :ets.info(name) do
      :undefined ->
        :ets.new(name, [:named_table, :protected, :set, read_concurrency: true])

      _ ->
        name
    end
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

  @doc """
  Tries to retrieve a data table tid from a lookup table.
  """
  @spec fetch_data(atom, atom) :: :ets.tid() | nil
  def fetch_data(lookup_name, data_name) do
    case :ets.info(lookup_name) do
      :undefined ->
        nil

      _ ->
        case :ets.lookup(lookup_name, data_name) do
          [{^data_name, ets_tid}] -> ets_tid
          _ -> nil
        end
    end
  end

  @doc """
  Saves a list of data entries to a storage table without an additional index.
  """
  @spec store_data_entries(list, :ets.tid()) :: :ok
  def store_data_entries([entry | entries], ets_tid) do
    true = :ets.insert(ets_tid, entry)

    store_data_entries(entries, ets_tid)
  end

  def store_data_entries([], _ets_tid), do: :ok

  @doc """
  Saves a list of data entries to a storage table with incrementing index.
  """
  @spec store_data_entries(list, :ets.tid(), non_neg_integer) :: non_neg_integer
  def store_data_entries([entry | entries], ets_tid, index) do
    true = :ets.insert(ets_tid, {index, entry})

    store_data_entries(entries, ets_tid, index + 1)
  end

  def store_data_entries([], _ets_tid, index), do: index

  @doc """
  Updates the data table tid in a lookup table.
  """
  @spec update_data(atom, atom, :ets.tid()) :: :ok
  def update_data(lookup_name, data_name, data_tid) do
    true = :ets.insert(lookup_name, {data_name, data_tid})

    :ok
  end
end
