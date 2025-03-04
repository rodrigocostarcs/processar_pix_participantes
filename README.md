# ProcessarPixParticipantes - Guia de Configuração e Execução

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

### Execute os comandos dos arquivos `comandos.sql` para configurar o banco de dados.

---

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

---

## Configuração do Projeto

### Clone o repositório e acesse a pasta do projeto:
```bash
cd processar_pix_participantes
```

### Instale as dependências:
```bash
mix deps.get
```

### Configure o arquivo `config/dev.exs` com as credenciais do banco de dados:
```elixir
username: "root",
password: "senha",
hostname: "localhost",
database: "banco",
stacktrace: true,
show_sensitive_data_on_connection_error: true,
pool_size: 10
```

---

## Execução do Projeto

### Execute o servidor Phoenix:
```bash
mix phx.server
```

A API estará disponível em: [http://127.0.0.1:4000](http://127.0.0.1:4000)

---