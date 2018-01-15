defmodule ElixirExchange.Cron do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(state) do
    Enum.map(state, fn(cron)->
      schedule_cron(cron)
    end)
    {:ok, state}
  end

  def handle_info({:run_cron, cron}, state) do
    execute_cron(cron)
    schedule_cron(cron)
    {:noreply, state}
  end

  defp execute_cron(cron) do
    apply(cron.module, cron.function, cron.params)
  end

  defp schedule_cron(cron) do
    Process.send_after(self(), {:run_cron, cron}, cron.interval)
  end
end
