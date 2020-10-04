defmodule DataleviWeb.FileController do
  use DataleviWeb, :controller

  def show(conn, %{"path" => path}) do
    full_path = Path.join(Datalevi.directory, path)
    send_download(conn, {:file, full_path})
  end

  def delete(conn, %{"file" => path}) do
    Datalevi.directory
    |> Path.join(path)
    |> File.rm()
    |> case do
      :ok -> send_resp(conn, 200, "ok")
      {:error, reason} -> send_resp(conn, 400,
        Jason.encode!(%{"error" => inspect reason}))
    end
  end
end
