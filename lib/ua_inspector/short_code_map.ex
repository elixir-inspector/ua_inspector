defmodule UAInspector.ShortCodeMap do
  @moduledoc """
  Basic short code map module providing minimal functions.
  """

  use Behaviour

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)

      @behaviour unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def init() do
        :ets.new(@ets_table, [ :set, :protected, :named_table ])
      end

      def list,   do: :ets.tab2list(@ets_table)
      def local,  do: @file_local
      def remote, do: @file_remote

      def to_long(short) do
        list
        |> Enum.find({ short, short }, fn ({ s, _ }) -> short == s end)
        |> elem(1)
      end

      def to_short(long) do
        list
        |> Enum.find({ long, long }, fn ({ _, l }) -> long == l end)
        |> elem(0)
      end
    end
  end

  @doc """
  Initializes (sets up) the short code map.
  """
  defcallback init() :: atom | :ets.tid

  @doc """
  Returns all database entries as a list.
  """
  defcallback list() :: list

  @doc """
  Loads a short code mapping.
  """
  defcallback load() :: no_return

  @doc """
  Returns the long representation for a short name.

  Unknown names are returned unmodified.
  """
  defcallback to_long(String.t) :: String.t

  @doc """
  Returns the short representation for a long name.

  Unknown names are returned unmodified.
  """
  defcallback to_short(String.t) :: String.t
end
