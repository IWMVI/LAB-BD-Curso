USE faculdade;

/*
    Criar trigger para registrar um LOG das atualizações das Tabela Professor. No Log deve existir:

        1-  código do usuário que fez a alteração;
        2-  chave primaria do registro alterado;
        3-  Tipo de alteração realizado (INSERT ou UPDATE ou DELETE);
        4-  Data e Hora da alteração.


Entregar a estrutura da Tabela de LOG ( pode ser chamada Tabela_Log_Professor ) ;

e o Código da(s) Trigger(s).
*/

CREATE TEMPORARY TABLE
    Tabela_Log_Professor (
        CodLog INT AUTO_INCREMENT,
        CodProf INT,
        CodDepto CHAR(5),
        CodTit INT,
        NomeProf VARCHAR(40),
        CodUsuario INT,
        TipoAlteracao VARCHAR(10),
        DataHoraAlteracao DATETIME,
        PRIMARY KEY (CodLog)
    );

DELIMITER //

CREATE TRIGGER
    Log_Professor_Insert
AFTER INSERT
ON Professor
FOR EACH ROW
BEGIN
    INSERT INTO Tabela_Log_Professor (CodProf, CodDepto, CodTit, NomeProf, CodUsuario, TipoAlteracao, DataHoraAlteracao)
    VALUES (NEW.CodProf, NEW.CodDepto, NEW.CodTit, NEW.NomeProf, 1, 'INSERT', NOW());
END;
//

CREATE TRIGGER
    Log_Professor_Update
AFTER UPDATE
ON Professor
FOR EACH ROW
BEGIN
    INSERT INTO Tabela_Log_Professor (CodProf, CodDepto, CodTit, NomeProf, CodUsuario, TipoAlteracao, DataHoraAlteracao)
    VALUES (NEW.CodProf, NEW.CodDepto, NEW.CodTit, NEW.NomeProf, 1, 'UPDATE', NOW());
END;
//

CREATE TRIGGER
    Log_Professor_Delete
AFTER DELETE
ON Professor
FOR EACH ROW
BEGIN
    INSERT INTO Tabela_Log_Professor (CodProf, CodDepto, CodTit, NomeProf, CodUsuario, TipoAlteracao, DataHoraAlteracao)
    VALUES (OLD.CodProf, OLD.CodDepto, OLD.CodTit, OLD.NomeProf, 1, 'DELETE', NOW());
END;
//

DELIMITER ;

-- Visualizações dos registros do LOG após a execução dos comandos abaixo:

INSERT INTO
    Professor (CodProf, CodDepto, CodTit, NomeProf)
VALUES
    (100, 'INF01', 1, 'PROFESSOR 1'),
    (200, 'ADM01', 1, 'PROFESSOR 2'),
    (300, 'MAT01', 1, 'PROFESSOR 3');

UPDATE
    Professor
SET
    NomeProf = 'PROFESSOR 1 ALTERADO'
WHERE
    CodProf = 100;

DELETE FROM
    Professor
WHERE
    CodProf = 200;

SELECT
    *
FROM
    Tabela_Log_Professor;


-- Experado:

-- CodLog | CodProf | CodDepto | CodTit | NomeProf              | CodUsuario | TipoAlteracao    | DataHoraAlteracao
-- 1      | 1       | DEPTO    | 1      | PROFESSOR 1           | 1          | INSERT           | 2021-11-01 00:00:00
-- 2      | 2       | DEPTO    | 1      | PROFESSOR 2           | 1          | INSERT           | 2021-11-01 00:00:00
-- 3      | 3       | DEPTO    | 1      | PROFESSOR 3           | 1          | INSERT           | 2021-11-01 00:00:00
-- 4      | 1       | DEPTO    | 1      | PROFESSOR 1 ALTERADO  | 1          | UPDATE           | 2021-11-01 00:00:00
-- 5      | 2       | DEPTO    | 1      | PROFESSOR 2           | 1          | DELETE           | 2021-11-01 00:00:00
