defmodule ProcessarPixParticipantes.ParticipantePix do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "participantes_pix" do
    field :ispb, :string
    field :nome, :string
    field :nome_reduzido, :string
    field :modalidade_participacao, :string
    field :tipo_participacao, :string
    field :inicio_operacao, :naive_datetime

    timestamps(
      type: :naive_datetime,
      inserted_at: :created_at,
      updated_at: :updated_at
    )
  end

  @doc """
  Cria um changeset para validação dos dados do participante PIX
  """
  def changeset(participante, attrs) do
    participante
    |> cast(attrs, [
      :ispb,
      :nome,
      :nome_reduzido,
      :modalidade_participacao,
      :tipo_participacao,
      :inicio_operacao
    ])
    |> validate_required([
      :ispb,
      :nome,
      :nome_reduzido
    ])
    |> validate_length(:ispb, max: 8)
    |> unique_constraint(:ispb)
  end
end
