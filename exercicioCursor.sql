USE master
GO
DROP DATABASE IF EXISTS exercicioCursor
GO
CREATE DATABASE exercicioCursor
GO
USE exercicioCursor

CREATE TABLE curso (
	codigo	INT NOT NULL,
	nome	VARCHAR(70)	NOT NULL,
	duracao	INT	NOT NULL,

	PRIMARY KEY(codigo)
)
GO

CREATE TABLE disciplinas (
	codigo	CHAR(6) NOT NULL,
	nome	VARCHAR(70)	NOT NULL,
	carga_horaria	INT	NOT NULL,

	PRIMARY KEY(codigo)
)
GO

CREATE TABLE disciplina_curso (
	codigo_disciplina	CHAR(6) NOT NULL,
	codigo_curso	INT NOT NULL,

	PRIMARY KEY(codigo_disciplina, codigo_curso),
	FOREIGN KEY(codigo_disciplina) REFERENCES disciplinas(codigo),
	FOREIGN KEY(codigo_curso) REFERENCES curso(codigo)
)
GO

INSERT INTO disciplinas (codigo, nome, carga_horaria)
VALUES
('ALG001', 'Algoritmos', 80),
('ADM001', 'Administração', 80),
('LHW010', 'Laboratório de Hardware', 40),
('LPO001', 'Pesquisa Operacional', 80),
('FIS003', 'Física I', 80),
('FIS007', 'Físico Química', 80),
('CMX001', 'Comércio Exterior', 80),
('MKT002', 'Fundamentos de Marketing', 80),
('INF001', 'Informática', 40),
('ASI001', 'Sistemas de Informação', 80);
GO

INSERT INTO curso (codigo, nome, duracao)
VALUES
	(48, 'Análise e Desenvolvimento de Sistemas', 2880),
	(51, 'Logistica', 2880),
	(67, 'Polímeros', 2880),
	(73, 'Comércio Exterior', 2600),
	(94, 'Gestão Empresarial', 2600)
GO

INSERT INTO disciplina_curso (codigo_disciplina, codigo_curso)
VALUES
('ALG001', 48),
('ADM001', 48),
('ADM001', 51),
('ADM001', 73),
('ADM001', 94),
('LHW010', 48),
('LPO001', 51),
('FIS003', 67),
('FIS007', 67),
('CMX001', 51),
('CMX001', 73),
('MKT002', 51),
('MKT002', 94),
('INF001', 51),
('INF001', 73),
('ASI001', 48),
('ASI001', 94);
GO

SELECT * FROM curso
SELECT * FROM disciplinas
SELECT * FROM disciplina_curso
GO
/*
Criar uma UDF (Function) cuja entrada é o código do curso e, com um cursor, monte uma tabela de saída com as informações do curso que é parâmetro de entrada.
(Código_Disciplina | Nome_Disciplina | Carga_Horaria_Disciplina | Nome_Curso)
*/

CREATE FUNCTION obter_disciplinas_curso (@codigo_curso INT)
RETURNS @tabela_saida TABLE (
    codigo_disciplina CHAR(6),
    nome_disciplina VARCHAR(70),
    carga_horaria_disciplina INT,
    nome_curso VARCHAR(70)
)
AS
BEGIN
    DECLARE @codigo_disciplina CHAR(6)
    DECLARE @nome_disciplina VARCHAR(70)
    DECLARE @carga_horaria_disciplina INT
    DECLARE @nome_curso VARCHAR(70)

    DECLARE curso_cursor CURSOR FOR
    SELECT c.codigo, c.nome
    FROM curso c
    WHERE c.codigo = @codigo_curso

    OPEN curso_cursor

    FETCH NEXT FROM curso_cursor INTO @codigo_curso, @nome_curso

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE disciplina_cursor CURSOR FOR
        SELECT d.codigo, d.nome, d.carga_horaria
        FROM disciplinas d
        INNER JOIN disciplina_curso dc ON d.codigo = dc.codigo_disciplina
        WHERE dc.codigo_curso = @codigo_curso

        OPEN disciplina_cursor

        FETCH NEXT FROM disciplina_cursor INTO @codigo_disciplina, @nome_disciplina, @carga_horaria_disciplina

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO @tabela_saida (codigo_disciplina, nome_disciplina, carga_horaria_disciplina, nome_curso)
            VALUES (@codigo_disciplina, @nome_disciplina, @carga_horaria_disciplina, @nome_curso)

            FETCH NEXT FROM disciplina_cursor INTO @codigo_disciplina, @nome_disciplina, @carga_horaria_disciplina
        END

        CLOSE disciplina_cursor
        DEALLOCATE disciplina_cursor

        FETCH NEXT FROM curso_cursor INTO @codigo_curso, @nome_curso
    END

    CLOSE curso_cursor
    DEALLOCATE curso_cursor

    RETURN
END
GO

SELECT * FROM dbo.obter_disciplinas_curso(48)
