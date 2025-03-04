defmodule ProcessarPixParticipantes.SQSClient do
  @moduledoc """
  Módulo para interagir com a fila SQS.
  """

  alias ExAws.SQS

  @queue_url Application.compile_env(:processar_pix_participantes, :aws_sqs_queue_url)

  # Enviar mensagem para a fila
  def send_message(message) do
    if is_nil(@queue_url) do
      IO.puts("Erro: Configuração AWS_SQS_QUEUE_URL não está definida no config.exs.")
      {:error, :missing_queue_url}
    else
      message_json = Jason.encode!(message)

      # Gerar um ID de deduplificação único baseado no conteúdo da mensagem
      deduplication_id = :crypto.hash(:md5, message_json) |> Base.encode16()

      try do
        response =
          ExAws.SQS.send_message(
            @queue_url,
            message_json,
            message_group_id: "default",
            message_deduplication_id: deduplication_id
          )
          |> ExAws.request()

        case response do
          {:ok, result} ->
            {:ok, result}

          {:error, reason} ->
            IO.inspect(reason, label: "Erro ao enviar mensagem para SQS")
            {:error, reason}
        end
      rescue
        error ->
          IO.inspect(error, label: "Exceção ao enviar mensagem para SQS")
          {:error, error}
      end
    end
  end

  # Buscar mensagens da fila com opções mais específicas
  def receive_messages do
    # Opções corrigidas com átomos
    options = [
      max_number_of_messages: 10,
      # Espera até 20 segundos por novas mensagens
      wait_time_seconds: 20,
      message_attribute_names: [:all],
      attribute_names: [:all]
    ]

    case ExAws.SQS.receive_message(@queue_url, options) |> ExAws.request() do
      {:ok, %{body: %{messages: messages}}} when is_list(messages) ->
        IO.puts("Número de mensagens recebidas: #{length(messages)}")

        Enum.each(messages, fn msg ->
          # Decodificar o corpo da mensagem
          decoded_body = Jason.decode!(msg.body)
          IO.inspect(decoded_body, label: "Conteúdo da Mensagem")
          IO.inspect(msg.message_id, label: "ID da Mensagem")
        end)

        messages

      {:ok, response} ->
        IO.puts("Resposta inesperada: #{inspect(response)}")
        []

      {:ok, _} ->
        IO.puts("Nenhuma mensagem na fila SQS.")
        []

      {:error, reason} ->
        IO.inspect(reason, label: "Erro ao buscar mensagens do SQS")
        []
    end
  end

  # Método para deletar mensagem após processamento
  def delete_message(receipt_handle) do
    case ExAws.SQS.delete_message(@queue_url, receipt_handle) |> ExAws.request() do
      {:ok, _} ->
        IO.puts("Mensagem deletada com sucesso")
        :ok

      {:error, reason} ->
        IO.inspect(reason, label: "Erro ao deletar mensagem")
        {:error, reason}
    end
  end
end
