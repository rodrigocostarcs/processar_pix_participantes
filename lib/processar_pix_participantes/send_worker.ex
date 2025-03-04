defmodule ProcessarPixParticipantes.SendWorker do
  use GenServer

  alias ProcessarPixParticipantes.BrasilAPIClient
  alias ProcessarPixParticipantes.SQSClient

  # 1 minuto
  @interval 1000_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_work()
    {:ok, []}
  end

  @impl true
  def handle_info(:fetch_and_send, state) do
    case BrasilAPIClient.fetch_participants() do
      {:ok, participants} ->
        Enum.each(participants, &SQSClient.send_message(&1))

      {:error, reason} ->
        IO.inspect(reason, label: "Erro ao buscar dados")
    end

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :fetch_and_send, @interval)
  end
end
