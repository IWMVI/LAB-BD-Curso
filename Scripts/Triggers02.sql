USE Faculdade;

-- CRIAR PROCEDURE QUE:
-- Liste os códigos dos professores com título denominado 'Doutor' que não ministraram aulas em 2019/1.
-- Caso nao existam professores dar uma mensagem de erro usando um dos métodos para o tratamento de Exceções.

DROP PROCEDURE IF EXISTS sp_professores_doutores_sem_aula_2019_1;

DELIMITER // 
CREATE PROCEDURE sp_professores_doutores_sem_aula_2019_1 () BEGIN DECLARE qtd INT;

SELECT
    COUNT(*) INTO qtd
FROM
    Professor p
    JOIN Titulacao t ON t.CodTit = p.CodTit
    LEFT JOIN ProfTurma pt ON pt.CodProf = p.CodProf
WHERE
    t.NomeTit = 'Doutor'
    AND pt.AnoSem = 20191;

IF qtd = 0 THEN SIGNAL SQLSTATE '45000'
SET
    MESSAGE_TEXT = 'Não existem professores doutores sem aula em 2019/1.';
ELSE
SELECT
    p.CodProf
FROM
    Professor p
    JOIN Titulacao t ON t.CodTit = p.CodTit
    LEFT JOIN ProfTurma pt ON pt.CodProf = p.CodProf
WHERE
    t.NomeTit = 'Doutor'
    AND pt.AnoSem = 20191;

END IF;

END 
// DELIMITER;

CALL sp_professores_doutores_sem_aula_2019_1 ();