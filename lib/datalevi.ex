defmodule Datalevi do
  @moduledoc """
  important global information about the Datalevi system
  """

  def root_configured?, do: Application.get_env(:datalevi, :root_configured?, false)

  def directory, do: Application.get_env(:datalevi, :directory)
end
