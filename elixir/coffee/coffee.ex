defmodule Coffee do
  def start_link do
    {:ok, spawn_link(__MODULE__, init, [])}
  end

  def init do
    Process.register self, __MODULE__
    HW.reboot()
    HW.display "Make Your Selection", []
    selection
  end

  # TODO: not enough yet.
  def selection do
    receive do
      {:selection, type, price} ->
        HW.display("Please pay:", price)
      {:pay, coin} ->
        HW.return_change(Coin)
        :selection
      _ ->
        :selection
    end
  end
end
