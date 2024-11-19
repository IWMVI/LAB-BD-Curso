USE faculdade;

-- Baseado no modelo final de dados criado em aula. Resolver as seguintes questões usando SQL:
-- Para a criação dos comandos abaixo, utilizar CURSOR dentro de STORED PROCEDURE.
-- Obter os identificadores de todas turmas de disciplinas do departamento denominado `Informática'
-- que não têm aula na sala de número 102 do prédio de código 43421.

DELIMITER //
CREATE PROCEDURE GetTurmasSemAulaSala102()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE anoSem INT;
    DECLARE codDepto CHAR(5);
    DECLARE numDisc INT;
    DECLARE siglaTur CHAR(2);
    DECLARE cur CURSOR FOR
        SELECT t.AnoSem, t.CodDepto, t.NumDisc, t.SiglaTur
        FROM Turma t
        JOIN Depto d ON t.CodDepto = d.CodDepto
        WHERE d.NomeDepto LIKE '%Informática%'
        AND NOT EXISTS (
            SELECT 1
            FROM Horario h
            WHERE h.AnoSem = t.AnoSem
            AND h.CodDepto = t.CodDepto
            AND h.NumDisc = t.NumDisc
            AND h.SiglaTur = t.SiglaTur
            AND h.NumSala = 102
            AND h.CodPred = 43421
        );
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO anoSem, codDepto, numDisc, siglaTur;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT anoSem, codDepto, numDisc, siglaTur;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;

call GetTurmasSemAulaSala102();

-- 2.    Obter o número de salas que foram usadas no ano-semestre 20021 por turmas do departamento denominado `Informática'.

DELIMITER //

CREATE PROCEDURE GetNumSalasUsadas()
BEGIN
    DECLARE numSalas INT;

    SELECT COUNT(DISTINCT h.NumSala, h.CodPred) INTO numSalas
    FROM Horario h
    JOIN Turma t ON h.AnoSem = t.AnoSem AND h.CodDepto = t.CodDepto AND h.NumDisc = t.NumDisc AND h.SiglaTur = t.SiglaTur
    JOIN Depto d ON t.CodDepto = d.CodDepto
    WHERE h.AnoSem = 20021 AND d.NomeDepto LIKE '%Informática%';

    SELECT numSalas;
END //

DELIMITER ;

CALL GetNumSalasUsadas();

-- 3.    Obter os nomes das disciplinas do departamento denominado `Informática' que têm o maior número de créditos dentre as disciplinas deste departamento.


DELIMITER //

CREATE PROCEDURE GetMaxCreditosDisciplinas()
BEGIN
    DECLARE maxCreditos INT;

    SELECT MAX(CreditoDisc) INTO maxCreditos
    FROM Disciplina d
    JOIN Depto depto ON d.CodDepto = depto.CodDepto
    WHERE depto.NomeDepto = 'Informática';

    SELECT d.NomeDisc
    FROM Disciplina d
    JOIN Depto depto ON d.CodDepto = depto.CodDepto
    WHERE depto.NomeDepto = 'Informática' AND d.CreditoDisc = maxCreditos;
END //

DELIMITER ;

CALL GetMaxCreditosDisciplinas();

-- 4.   Para cada departamento, obter seu nome e os créditos totais oferecidos no ano-semestre 20022.
--  O número de créditos oferecidos é calculado através do produto de número de créditos da disciplina pelo número de 
-- turmas oferecidas no semestre.
-- A - (desprezando departamentos sem turmas)
-- B- (incluindo departamentos sem turmas)
-- A - (desprezando departamentos sem turmas)


DELIMITER //

CREATE PROCEDURE GetCreditosTotaisDesprezando()
BEGIN
    SELECT d.NomeDepto, SUM(di.CreditoDisc * (
        SELECT COUNT(*)
        FROM Turma t
        WHERE t.CodDepto = di.CodDepto AND t.NumDisc = di.NumDisc AND t.AnoSem = 20022
    )) AS CreditosTotais
    FROM Depto d
    JOIN Disciplina di ON d.CodDepto = di.CodDepto
    GROUP BY d.NomeDepto;
END //

DELIMITER ;

CALL GetCreditosTotaisDesprezando();

-- B- (incluindo departamentos sem turmas)

DELIMITER //

CREATE PROCEDURE GetCreditosTotaisIncluindo()
BEGIN
    SELECT d.NomeDepto, IFNULL(SUM(di.CreditoDisc * (
        SELECT COUNT(*)
        FROM Turma t
        WHERE t.CodDepto = di.CodDepto AND t.NumDisc = di.NumDisc AND t.AnoSem = 20022
    )), 0) AS CreditosTotais
    FROM Depto d
    LEFT JOIN Disciplina di ON d.CodDepto = di.CodDepto
    GROUP BY d.NomeDepto;
END //

DELIMITER ;

CALL GetCreditosTotaisIncluindo();