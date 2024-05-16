defmodule UAInspector.Util.Fragment do
  @moduledoc false

  alias UAInspector.Util

  @desktop Util.Regex.build_regex("Desktop(?: (x(?:32|64)|WOW64))?;")

  @doc """
  Tests if a user agents contains a desktop fragment.
  """
  @spec desktop?(String.t()) :: boolean
  def desktop?(ua), do: Regex.match?(@desktop, ua)
end
