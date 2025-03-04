defmodule ProcessarPixParticipantes.BrasilAPIClient do
  @moduledoc """
  Cliente para buscar participantes do PIX na BrasilAPI.
  """

  @api_url Application.compile_env(:processar_pix_participantes, :api_brasil_url)

  def fetch_participants do
    case HTTPoison.get(@api_url, [], recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, participants} -> {:ok, participants}
          {:error, error} -> {:error, {:json_decode_error, error}}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, {:http_error, status_code}}

      {:error, error} ->
        {:error, {:http_request_error, error}}
    end
  end
end
