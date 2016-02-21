defmodule Ping do
  @moduledoc """
  Example described with Elixir.

  iex(1)> c "ping.ex"
  [Ping]
  iex(2)> GenServer.start(Ping, [], [name: :ping])
  {:ok, #PID<0.65.0>}
  30
  35
  40
  iex(3)> GenServer.call(:ping, :pause)
  :paused
  iex(4)> GenServer.call(:ping, :start)
  :started
  55
  """
  use GenServer

  @timeout 5000

  def init(_) do
    {:ok, :null, @timeout}
  end

  def handle_call(:start, _from, state), do: {:reply, :started, state, @timeout}
  def handle_call(:pause, _from, state), do: {:reply, :paused, state}

  def handle_info(:timeout, state) do
    {_hour, _min, sec} = :erlang.time
    IO.puts("#{sec}")
    {:noreply, state, @timeout}
  end
end
