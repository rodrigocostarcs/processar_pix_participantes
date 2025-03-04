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
