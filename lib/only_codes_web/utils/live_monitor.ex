defmodule LiveMonitor do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def monitor(pid) do
    GenServer.call(__MODULE__, {:monitor, pid})
  end

  def get_count() do
    GenServer.call(__MODULE__, {:count})
  end

  def init(_) do
    # schedule_work()
    {:ok, %{count: 0}}
  end

  def handle_call({:count}, _, state) do
    {:reply, state.count, state}
  end

  def handle_call({:monitor, pid}, _, state) do
    Process.monitor(pid)
    {:reply, :ok, %{count: state.count + 1}}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    {:noreply, %{count: state.count - 1}}
  end

  def handle_info(:work, state) do
    OnlyCodesWeb.Endpoint.broadcast("numActiveUsers", "interval", state.count)
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    # 1 minute
    Process.send_after(self(), :work, 60 * 1000)
  end
end
