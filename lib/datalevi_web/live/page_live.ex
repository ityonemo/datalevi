defmodule DataleviWeb.PageLive do
  use DataleviWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    rel_directory = Map.get(params, "path", "/")

    abs_directory = Path.join(Datalevi.directory, rel_directory)

    files = abs_directory
    |> File.ls!()
    |> Enum.sort()
    |> Enum.map(&name_to_info(abs_directory, rel_directory, &1))

    {:ok, assign(socket,
      files: files,
      directory: rel_directory,
      parent_dir: Path.dirname(rel_directory))}
  end

  defp name_to_info(abs_directory, rel_directory, basename) do
    filename = Path.join(abs_directory, basename)
    stat = File.stat!(filename)

    %{target: Path.join(rel_directory, basename)}
    |> modify_directory(stat, basename)
    |> add_stat(stat)
  end

  defp modify_directory(info, %{type: :directory}, base) do
    Map.merge(info, %{name: base, dir: true})
  end
  defp modify_directory(info, stat, base) do
    Map.merge(info, %{name: base, dir: false, size: stat.size})
  end

  defp add_stat(info, %{access: :read_write}) do
    Map.merge(info, %{read: "✔️", write: "✔️"})
  end
  defp add_stat(info, %{access: :read}) do
    Map.merge(info, %{read: "✔️", write: "❌"})
  end
  defp add_stat(info, %{access: :write}) do
    Map.merge(info, %{read: "❌", write: "✔️"})
  end
  defp add_stat(info, %{access: :none}) do
    Map.merge(info, %{read: "❌", write: "❌"})
  end

end
