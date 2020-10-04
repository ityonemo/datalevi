defmodule DataleviWeb.PageLive do
  use DataleviWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    rel_directory = Map.get(params, "path", "/")

    abs_directory = Path.join(Datalevi.directory, rel_directory)

    files = abs_directory
    |> File.ls!()
    |> Enum.sort()
    |> Enum.flat_map(&name_to_info(rel_directory, &1, abs_directory))

    # register for notifications on filesystem changes
    FileSystem.subscribe(Datalevi.FileSystem)

    {:ok, assign(socket,
      files: files,
      rel_directory: rel_directory,
      abs_directory: abs_directory,
      parent_dir: Path.dirname(rel_directory)),
      temporary_assigns: [files: []]}
  end

  defp name_to_info(rel_directory, filename, abs_directory) do
    abs_path = Path.join(abs_directory, filename)
    case stat_to_info(rel_directory, filename, abs_path) do
      :error -> []
      info -> [info]
    end
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

  defp stat_to_info(rel_directory, filename, abs_path) do
    case File.stat(abs_path) do
      {:ok, stat} ->
        %{target: Path.join(rel_directory, filename)}
        |> modify_directory(stat, filename)
        |> add_stat(stat)
      _error -> :error
    end
  end

  @impl true
  def handle_info({:file_event, _, {abs_path, what}}, socket!) do
    %{abs_directory: abs_directory, rel_directory: rel_directory} = socket!.assigns
    # NB that relative path is synonymous to filename in the
    # success case.
    rel_path = Path.relative_to(abs_path, abs_directory)

    socket! = cond do
      rel_path =~ "/" ->
        socket!
      :created in what ->
        case stat_to_info(rel_directory, rel_path, abs_path) do
          :error ->
            socket!
          info ->
            info |> IO.inspect(label: "79")
            push_event(socket!, "created", %{file: info})
        end

      :deleted in what ->
        push_event(socket!, "deleted", %{file: rel_path})

      :modified in what ->
        case stat_to_info(rel_directory, rel_path, abs_path) do
          :error ->
            socket!
          info ->
            push_event(socket!, "modified", %{file: info})
        end
      true ->
        socket!
    end

    {:noreply, socket!}
  end

end
