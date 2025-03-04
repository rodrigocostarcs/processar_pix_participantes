# ProcessarPixParticipantes

Este projeto consulta a API do Brasil API **https://brasilapi.com.br/docs** para obter a lista de participantes do sistema PIX, armazena os dados em uma fila SQS, e depois processa as mensagens da fila para persistir os dados no banco de dados MySQL.

## Visão Geral do Sistema

O sistema funciona com os seguintes componentes:

1. **Consulta à API**: Um worker para''

 consulta a API do Brasil API para obter participantes do PIX
2. **Armazenamento em SQS**: Os dados são enviados para uma fila FIFO do Amazon SQS
3. **Processamento da Fila**: Um segundo worker consome as mensagens da fila SQS
4. **Persistência**: Os dados são inseridos ou atualizados no banco de dados MySQL

## Requisitos

- Erlang/OTP 24+
- Elixir 1.14+
- MySQL 8.0+
- Acesso a AWS (para SQS)
- API Brasil

## Configuração do Ambiente MySQL no Ubuntu

### Atualize os pacotes:
```bash
sudo apt update
```

### Instale o MySQL Server:
```bash
sudo apt install mysql-server
```

### Inicie e habilite o MySQL:
```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Acesse o MySQL:
```bash
mysql -u root -p
```

### Crie o banco de dados

```
CREATE DATABASE pix;
```

### Crie a tabela para armazenar os participantes:
```sql
CREATE TABLE participantes_pix (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- ID único para cada registro
    ispb VARCHAR(8) NOT NULL,           -- Código do banco
    nome VARCHAR(255) NOT NULL,         -- Nome completo do banco
    nome_reduzido VARCHAR(255) NOT NULL, -- Nome reduzido do banco
    modalidade_participacao VARCHAR(10), -- Modalidade de participação
    tipo_participacao VARCHAR(10),      -- Tipo de participação
    inicio_operacao DATETIME,           -- Data e hora do início da operação
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Data de inserção
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Data de atualização
);
```

## Instalação do Elixir e Erlang no Ubuntu

### Atualize os pacotes:
```bash
sudo apt update
```

### Instale Erlang e Elixir:
```bash
sudo apt install erlang elixir
```

### Verifique a versão:
```bash
elixir --version
```

### Instale as ferramentas do Phoenix Framework:
```bash
mix archive.install hex phx_new 1.7.0
```

## Configuração do Projeto

### Clone o repositório e acesse a pasta do projeto:
```bash
cd processar_pix_participantes
```

### Instale as dependências:
```bash
mix deps.get
```

### Configure o arquivo `config/dev.exs` com as credenciais:

```elixir
# Configuração do banco de dados
config :processar_pix_participantes, ProcessarPixParticipantes.Repo,
  username: "root",
  password: "senha",
  hostname: "localhost",
  database: "pix",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configuração da AWS
config :ex_aws,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  region: "us-east-1" #definir a sua region conforme a aws

# Configuração da fila SQS
config :processar_pix_participantes, :aws_sqs_queue_url, 
  System.get_env("AWS_SQS_QUEUE_URL")

# Configuração da API Brasil
config :processar_pix_participantes, :api_brasil_url, 
  "https://brasilapi.com.br/api/pix/v1/participants"
```

## Funcionamento dos Workers

### Worker de Consulta à API

Este worker executa a cada 2 minutos (120.000 ms) e realiza:
- Consulta à API do Brasil para obter participantes do PIX
- Envio de cada participante como mensagem para a fila SQS

### Worker de Processamento da Fila

Este worker executa a cada 5 minutos (300.000 ms) e realiza:
- Consumo das mensagens da fila SQS
- Verificação se o participante já existe no banco
- Inserção de novos participantes ou atualização dos existentes
- Remoção das mensagens processadas da fila

## Modelo de Dados

O modelo `ParticipantePix` representa cada instituição participante do sistema PIX, com os campos:
- `ispb`: Identificador único da instituição no sistema bancário
- `nome`: Nome completo da instituição
- `nome_reduzido`: Nome reduzido da instituição
- `modalidade_participacao`: Tipo de participação no PIX (ex: PDCT)
- `tipo_participacao`: Forma de participação (ex: DRCT, IDRT)
- `inicio_operacao`: Data e hora de início das operações no PIX

## Execução do Projeto

### Configure as variáveis de ambiente:
```bash
export AWS_ACCESS_KEY_ID="sua_chave_aws"
export AWS_SECRET_ACCESS_KEY="sua_senha_aws"
export AWS_SQS_QUEUE_URL="https://sqs.us-east-1.amazonaws.com/123456789012/sua-fila.fifo"
```

### Execute o projeto:
```bash
mix phx.server
```

Ou para modo interativo:
```bash
iex -S mix phx.server
```

## Monitoramento e Logs

O sistema gera logs detalhados para facilitar o monitoramento:
- Registros de consultas bem-sucedidas à API
- Informações sobre envio de mensagens para a fila SQS
- Detalhes sobre processamento de mensagens
- Registros de inserções e atualizações no banco de dados

## Troubleshooting

### Problema ao enviar mensagens para SQS
Se encontrar erros relacionados a `String.Chars` ao enviar mensagens, verifique se está usando o formato correto para a chamada do método `send_message`.

### Mensagens não sendo processadas
Verifique se o formato de resposta do SQS está correto no método `receive_messages`. A estrutura deve corresponder ao padrão esperado pelo ExAws.

### Erros de deduplicação
Para filas FIFO, certifique-se que está fornecendo um `message_deduplication_id` ou habilite a deduplicação baseada em conteúdo na configuração da fila.
