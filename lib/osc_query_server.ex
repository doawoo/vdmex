defmodule Vdmex.OSCQueryServer do
  use WebSockex

  def start_link(options) do
    hostname = Keyword.get(options, :hostname, "localhost")
    modules = Keyword.get(options, :modules, %{})

    client =
      Tesla.client([
        {Tesla.Middleware.BaseUrl, "http://#{hostname}:2345/"},
        Tesla.Middleware.JSON
      ])

    modules =
      Tesla.get!(client, "/").body |> find_valid_interfaces(modules)

    {:ok, server_pid} =
      WebSockex.start_link("ws://#{hostname}:2345", __MODULE__, %{})

    Enum.each(modules, fn {interface_name, module_name, paths, definition} ->
      IO.puts("Found valid VDMX module: #{interface_name}")
      Enum.each(paths, fn p -> Process.send_after(server_pid, {:connect_path, p}, 100) end)

      {:ok, pid} =
        GenServer.start_link(module_name, interface_name: interface_name, definition: definition)

      IO.puts("Registering #{interface_name} with PID: #{inspect(pid)}")
    end)

    {:ok, server_pid}
  end

  def handle_frame({type, msg}, state) do
    case type do
      :text ->
        IO.puts("Received OSCQuery Message: #{msg}")

      :binary ->
        data = OSCx.decode(msg)

        Registry.dispatch(Vdmex.Registry, :osc_message, fn entries ->
          for {pid, _} <- entries, do: send(pid, {self(), data})
        end)
    end

    {:ok, state}
  end

  def handle_info({:connect_path, path}, state) do
    IO.puts("\tConnecting to path: #{path}")
    message = %{"COMMAND" => "LISTEN", "DATA" => path}
    {:reply, {:text, Jason.encode!(message)}, state}
  end

  defp find_valid_interfaces(query_result, modules) do
    # This just filters the OSCQuery result to find valid interfaces that define an _ex_id 
    # text field, which maps to a valid module in the modules map.
    query_result["CONTENTS"]["OSCQUERY"]["CONTENTS"]
    |> Enum.filter(fn {_k, v} -> Map.has_key?(v["CONTENTS"], "_ex_id") end)
    |> Enum.map(fn {interface_name, def} ->
      id_string = def["CONTENTS"]["_ex_id"]["VALUE"] |> List.first()
      full_paths = Enum.map(def["CONTENTS"], fn {_k, v} -> v["FULL_PATH"] end)

      if Map.has_key?(modules, id_string) do
        {interface_name, Map.get(modules, id_string), full_paths, def["CONTENTS"]}
      else
        nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end
end
