defmodule ProcessarPixParticipantes.Repo do
  use Ecto.Repo,
    otp_app: :processar_pix_participantes,
    adapter: Ecto.Adapters.MyXQL
end
