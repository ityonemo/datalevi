defmodule DataleviWeb.FileDownloadController do
  use DataleviWeb, :controller

  def show(conn, params = %{"path" => path}) do
    full_path = Path.join(Datalevi.directory, path)

    # PERHAPS THERE IS A BETTER WAY TO DO THIS?
    unless String.starts_with?(full_path, Datalevi.directory) do
      ## REPLACE THIS WITH A 404
      raise "hell"
    end

    send_download(conn, {:file, full_path})
  end
end
