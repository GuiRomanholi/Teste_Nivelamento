-- 1. criação das tabelas
CREATE TABLE operadoras (
    id SERIAL CONSTRAINT operadoras_id_pk PRIMARY KEY,
    registro_ans VARCHAR(20) CONSTRAINT operadoras_registro_ans_unique UNIQUE NOT NULL,
    cnpj VARCHAR(20) CONSTRAINT operadoras_cnpj_unique UNIQUE NOT NULL,
    razao_social VARCHAR(255) CONSTRAINT operadoras_razao_social_nn NOT NULL,
    nome_fantasia VARCHAR(255),
    modalidade VARCHAR(50) CONSTRAINT operadoras_modalidade_nn NOT NULL,
    logradouro VARCHAR(255) CONSTRAINT operadoras_logradouro_nn NOT NULL,
    numero VARCHAR(20) CONSTRAINT operadoras_numero_nn NOT NULL,
    complemento VARCHAR(255),
    bairro VARCHAR(100) CONSTRAINT operadoras_bairro_nn NOT NULL,
    cidade VARCHAR(100) CONSTRAINT operadoras_cidade_nn NOT NULL,
    uf CHAR(2) CONSTRAINT operadoras_uf_nn NOT NULL CHECK (LENGTH(uf) = 2),
    cep VARCHAR(10) CONSTRAINT operadoras_cep_nn NOT NULL,
    ddd VARCHAR(3),
    telefone VARCHAR(15),
    fax VARCHAR(15),
    endereco_eletronico VARCHAR(255),
    representante VARCHAR(255) CONSTRAINT operadoras_representante_nn NOT NULL,
    cargo_representante VARCHAR(255) CONSTRAINT operadoras_cargo_representante_nn NOT NULL,
    regiao_comercializacao INTEGER,
    data_registro DATE CONSTRAINT operadoras_data_registro_nn NOT NULL
);


CREATE TABLE demonstracoes_contabeis (
    id SERIAL CONSTRAINT demonstracoes_contabeis_id_pk PRIMARY KEY,
    registro_ans VARCHAR(20) CONSTRAINT demonstracoes_contabeis_registro_ans_nn NOT NULL,
    ano INT CONSTRAINT demonstracoes_contabeis_ano_check CHECK (ano >= 2000),
    trimestre INT CONSTRAINT demonstracoes_contabeis_trimestre_check CHECK (trimestre BETWEEN 1 AND 4),
    receita_total NUMERIC(15,2) CONSTRAINT demonstracoes_contabeis_receita_check CHECK (receita_total >= 0),
    despesas_total NUMERIC(15,2) CONSTRAINT demonstracoes_contabeis_despesas_check CHECK (despesas_total >= 0),
    despesas_eventos_saude NUMERIC(15,2) CONSTRAINT demonstracoes_contabeis_despesas_eventos_check CHECK (despesas_eventos_saude >= 0),
    FOREIGN KEY (registro_ans) REFERENCES operadoras(registro_ans) ON DELETE CASCADE
);

-- 2. importação dos dados
LOAD DATA INFILE '/caminho/para/operadoras_ativas.csv'
INTO TABLE operadoras
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(registro_ans, cnpj, razao_social, nome_fantasia, modalidade, logradouro, numero, complemento,
bairro, cidade, uf, cep, ddd, telefone, fax, endereco_eletronico, representante, cargo_representante, 
regiao_comercializacao, @data_registro)
SET data_registro = STR_TO_DATE(@data_registro, '%Y-%m-%d');

LOAD DATA INFILE '/caminho/para/demonstracoes_contabeis.csv'
INTO TABLE demonstracoes_contabeis
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(registro_ans, ano, trimestre, receita_total, despesas_total, despesas_eventos_saude);


-- Top 10 operadoras com maiores despesas em eventos/sinistros no último trimestre
SELECT operadoras.razao_social, SUM(despesas_eventos_saude) AS total_despesas
FROM demonstracoes_contabeis
JOIN operadoras ON demonstracoes_contabeis.registro_ans = operadoras.registro_ans
WHERE ano = EXTRACT(YEAR FROM CURRENT_DATE) 
AND trimestre = (CASE 
                    WHEN EXTRACT(MONTH FROM CURRENT_DATE) IN (1,2,3) THEN 1
                    WHEN EXTRACT(MONTH FROM CURRENT_DATE) IN (4,5,6) THEN 2
                    WHEN EXTRACT(MONTH FROM CURRENT_DATE) IN (7,8,9) THEN 3
                    ELSE 4 
                 END)
GROUP BY operadoras.razao_social
ORDER BY total_despesas DESC
LIMIT 10;

-- Top 10 operadoras com maiores despesas em eventos/sinistros no último ano
SELECT operadoras.razao_social, SUM(despesas_eventos_saude) AS total_despesas
FROM demonstracoes_contabeis
JOIN operadoras ON demonstracoes_contabeis.registro_ans = operadoras.registro_ans
WHERE ano = EXTRACT(YEAR FROM CURRENT_DATE) - 1
GROUP BY operadoras.razao_social
ORDER BY total_despesas DESC
LIMIT 10;
