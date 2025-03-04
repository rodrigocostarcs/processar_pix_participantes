defmodule ProcessarPixParticipantes.ParticipantePixRepository do
  import Ecto.Query
  alias ProcessarPixParticipantes.Repo
  alias ProcessarPixParticipantes.ParticipantePix

  @doc """
  Insere ou atualiza um participante PIX baseado no ISPB
  """
  def upsert(attrs) do
    # Converte a string de data para NaiveDateTime
    inicio_operacao = parse_datetime(attrs["inicio_operacao"])

    # Prepara os atributos para inserção/atualização
    changeset_attrs = %{
      ispb: attrs["ispb"],
      nome: attrs["nome"],
      nome_reduzido: attrs["nome_reduzido"],
      modalidade_participacao: attrs["modalidade_participacao"],
      tipo_participacao: attrs["tipo_participacao"],
      inicio_operacao: inicio_operacao
    }

    # Busca o participante pelo ISPB
    case get_by_ispb(attrs["ispb"]) do
      nil ->
        # Não existe, então cria um novo
        IO.puts("Inserindo novo participante com ISPB: #{attrs["ispb"]}")

        %ParticipantePix{}
        |> ParticipantePix.changeset(changeset_attrs)
        |> Repo.insert()

      participante ->
        # Já existe, então atualiza
        IO.puts("Atualizando participante existente com ISPB: #{attrs["ispb"]}")

        # Verificar se há alterações antes de atualizar
        changes = ParticipantePix.changeset(participante, changeset_attrs)

        if changes.changes != %{} do
          # Tem alterações, atualiza
          IO.puts("Alterações detectadas, atualizando dados")
          Repo.update(changes)
        else
          # Sem alterações, retorna o participante existente
          IO.puts("Sem alterações, mantendo registro existente")
          {:ok, participante}
        end
    end
  end

  @doc """
  Busca um participante pelo ISPB
  """
  def get_by_ispb(ispb) when is_binary(ispb) do
    Repo.get_by(ParticipantePix, ispb: ispb)
  end

  def get_by_ispb(_), do: nil

  @doc """
  Busca todos os participantes
  """
  def list_all do
    Repo.all(ParticipantePix)
  end

  @doc """
  Parse de string de data para NaiveDateTime
  """
  defp parse_datetime(date_string) when is_binary(date_string) do
    case NaiveDateTime.from_iso8601(date_string) do
      {:ok, datetime} -> datetime
      {:error, _} -> nil
    end
  end

  defp parse_datetime(_), do: nil
end
