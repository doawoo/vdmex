defmodule Vdmex.Modules.BasicCounter do
  @moduledoc """
  A basic counter controller that increments a value each time it receives a "CLOCK" OSC message
  from the matching control surface. The counter value is sent back to the control surface as an OSC message.

  When the control plane sends a "CLOCK" OSC message, the counter increments 
  by 1 to the max value, then loops back to the min value.
  """
  use GenServer

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, [])
  end

  def init(options) do
    {:ok, _} = Registry.register(Vdmex.Registry, :osc_message, [])

    interface_name = Keyword.get(options, :interface_name)
    interface_def = Keyword.get(options, :definition)

    min = interface_def["COUNTER"]["RANGE"] |> List.first() |> Map.get("MIN")
    max = interface_def["COUNTER"]["RANGE"] |> List.first() |> Map.get("MAX")

    {:ok, %{interface_name: interface_name, min: min, max: max, current_value: min}}
  end

  def handle_info({from, message}, state) do
    if message.address == "/OSCQUERY/#{state.interface_name}/CLOCK" do
      new_value = if state.current_value + 1 > state.max do
        state.min
      else
        state.current_value + 1
      end
      addr = "/OSCQUERY/#{state.interface_name}/COUNTER"
      message = OSCx.Message.new(address: addr, arguments: [new_value * 1.0]) |> OSCx.encode()
      WebSockex.send_frame(from, {:binary, message})
      {:noreply, %{state | current_value: new_value}}
    else
      {:noreply, state}
    end
  end
end
