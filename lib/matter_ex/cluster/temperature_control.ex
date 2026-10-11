defmodule MatterEx.Cluster.TemperatureControl do
  @moduledoc """
  Matter Temperature Control cluster (0x0056).

  Controls a temperature setpoint using the TemperatureNumber and
  TemperatureStep features. Temperatures are in 0.01°C units (for example,
  2000 is 20.00°C).

  Matter requires an endpoint to choose exactly one of TemperatureNumber and
  TemperatureLevel. This built-in cluster implements TemperatureNumber with
  TemperatureStep; vendor-specific named temperature levels are not exposed.
  """

  use MatterEx.Cluster, id: 0x0056, name: :temperature_control

  attribute(0x0000, :temperature_setpoint, :int16, default: 2000)
  attribute(0x0001, :min_temperature, :int16, default: -5000)
  attribute(0x0002, :max_temperature, :int16, default: 12500)
  attribute(0x0003, :step, :int16, default: 50)
  attribute(0xFFFC, :feature_map, :uint32, default: 0x05)
  attribute(0xFFFD, :cluster_revision, :uint16, default: 1)

  command(0x00, :set_temperature, target_temperature: :int16)

  @impl MatterEx.Cluster
  def handle_command(:set_temperature, params, state) do
    target = params[:target_temperature]
    min_temperature = get_attribute(state, :min_temperature)
    max_temperature = get_attribute(state, :max_temperature)
    step = get_attribute(state, :step)

    if valid_target?(target, min_temperature, max_temperature, step) do
      {:ok, nil, set_attribute(state, :temperature_setpoint, target)}
    else
      {:error, :constraint_error}
    end
  end

  defp valid_target?(target, min_temperature, max_temperature, step) do
    is_integer(target) and is_integer(min_temperature) and is_integer(max_temperature) and
      is_integer(step) and step > 0 and target >= min_temperature and
      target <= max_temperature and rem(target - min_temperature, step) == 0
  end
end
