-- Criar Procedure com cursor para selecionar a quantidade de professores que têm turmas no 1º Semestre de 2020 agrupados por nome de titulação
-- cujo nome do departamento seja diferente de Logística.

USE Faculdade;

DROP PROCEDURE IF EXISTS QtdProfTurma;

DELIMITER //
CREATE PROCEDURE QtdProfTurma()

BEGIN
    DECLARE titulacao VARCHAR(40);
    DECLARE qtd INT;
    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR

    SELECT
        Titulacao.NomeTit,
        COUNT(Professor.CodProf) AS Qtd
    FROM
        Professor
    JOIN
        ProfTurma ON Professor.CodProf = ProfTurma.CodProf
    JOIN
        Turma ON ProfTurma.AnoSem = Turma.AnoSem AND ProfTurma.CodDepto = Turma.CodDepto AND ProfTurma.NumDisc = Turma.NumDisc
    JOIN
        Depto ON Professor.CodDepto = Depto.CodDepto
    JOIN
        Titulacao ON Professor.CodTit = Titulacao.CodTit
    WHERE
        Turma.AnoSem = 20201
        AND Depto.NomeDepto != 'Logística'
    GROUP BY
        Titulacao.NomeTit;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

        OPEN cur;

        read_loop: LOOP
            FETCH cur INTO titulacao, qtd;
            IF done THEN
                LEAVE read_loop;
            END IF;
            SELECT titulacao, qtd;
        END LOOP;

        IF done = 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nenhum professor encontrado';
        END IF;

        CLOSE cur;
    END //
    DELIMITER ;

CALL QtdProfTurma();
