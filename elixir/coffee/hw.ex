defmodule HW do
  def display(str, arg) do
    IO.puts "Display: #{str} #{arg}"
  end

  def return_change(payment) do
    IO.puts "Machine:Returned ~w in change #{payment}"
  end

  def drop_cup() do
    IO.puts "Machine:Dropped Cup.~n"
  end

  def prepare(type) do
    IO.puts "Machine:Preparing #{type}."
  end

  def reboot() do
    IO.puts "Machine:Rebooted Hardware~n"
  end
end
