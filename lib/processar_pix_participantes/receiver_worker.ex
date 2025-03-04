defmodule ProcessarPixParticipantes.ReceiverWorker do
  use GenServer

  alias ProcessarPixParticipantes.SQSClient
  alias ProcessarPixParticipantes.ParticipantePixRepository

  # 5 minutos
  @interval 20_00

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_work()
    {:ok, []}
  end

  @impl true
  def handle_info(:process_messages, state) do
    try do
      # Busca mensagens
      messages = SQSClient.receive_messages()

      # Processamento das mensagens
      Enum.each(messages, fn msg ->
        try do
          # Decodificar o corpo da mensagem
          decoded_body = Jason.decode!(msg.body)

          # Salvar no banco de dados
          case ParticipantePixRepository.upsert(decoded_body) do
            {:ok, _participante} ->
              # Deletar mensagem apenas se salvou com sucesso
              SQSClient.delete_message(msg.receipt_handle)
              IO.puts("Participante salvo com sucesso: #{decoded_body["ispb"]}")

            {:error, changeset} ->
              IO.inspect(changeset.errors, label: "Erro ao salvar participante")
          end
        rescue
          error ->
            IO.inspect(error, label: "Erro ao processar mensagem individual")
        end
      end)
    rescue
      error ->
        IO.inspect(error, label: "Erro ao processar mensagens")
    end

    # Agendar próxima execução
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :process_messages, @interval)
  end
end
