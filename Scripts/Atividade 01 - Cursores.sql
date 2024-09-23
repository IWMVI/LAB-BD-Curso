USE faculdade;

/* 1. Obter os códigos dos diferentes departamentos que têm turmas no ano-semestre 2002/1 */

DELIMITER //

CREATE PROCEDURE get_cod_depto_turmas(IN ano_sem_pass INT)
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE depto VARCHAR(20);
    
    DECLARE cursor_depto CURSOR FOR
		SELECT
			DISTINCT CodDepto
		FROM
			Turma
		WHERE
			AnoSem = ano_sem_pass;
		    DECLARE CONTINUE HANDLER FOR NOT FOUND SET
			done = TRUE;
    
    OPEN cursor_depto;
	
    DROP TABLE IF EXISTS results;

   CREATE TEMPORARY TABLE results(
		RESULT VARCHAR(255)
	);
    
    read_loop: LOOP
		FETCH cursor_depto INTO depto;
        
        IF done THEN
			LEAVE read_loop;
		END IF;
        
        INSERT INTO results(RESULT) 
        VALUES(depto);
	END LOOP;
    
    SELECT * 
    FROM results;
    
    CLOSE cursor_depto;
END 
// 
DELIMITER ;

CALL get_cod_depto_turmas(20021);

/* 02. Obter os códigos dos professores que são do departamento de código 'INF01' e que ministraram ao menos uma turma em 2002/1. */

DELIMITER //

CREATE PROCEDURE get_cod_depto_turmas_prof(IN ano_sem_pass INT, IN cod_prof_depto VARCHAR(20))
BEGIN 
	DECLARE done INT DEFAULT FALSE;
	DECLARE cod_prof_r VARCHAR(20);
	DECLARE ano_sem_r INT;
	DECLARE qtd_r INT;

    DECLARE cursor_depto CURSOR FOR
        SELECT 
            pt.CodProf, pt.AnoSem, COUNT(pt.AnoSem) AS QTD 
        FROM ProfTurma pt
        JOIN Professor p ON pt.CodProf = p.CodProf
        WHERE p.CodDepto = cod_prof_depto
        GROUP BY pt.CodProf, pt.AnoSem;
	DECLARE CONTINUE handler FOR NOT FOUND SET done = TRUE;

	OPEN cursor_depto;

	DROP TABLE IF EXISTS results;
	CREATE TEMPORARY TABLE results (
		RESULT VARCHAR(255)
	);

	read_loop: LOOP
		FETCH cursor_depto INTO cod_prof_r, ano_sem_r, qtd_r;
	
		IF done THEN
			LEAVE read_loop;
		END IF;
	
		INSERT INTO results(RESULT) 
		VALUES(CONCAT('O professor de código ', cod_prof_r, ' no ano ', ano_sem_r, ' ministrou ', qtd_r, ' aulas.'));
		
	END LOOP;
	
	SELECT * FROM results;
	
	CLOSE cursor_depto;
END
//
DELIMITER ;

SELECT *
FROM profturma;

SELECT
	CodProf,
	AnoSem AS QTD
FROM
	profturma p
WHERE
	p.CodDepto = 'INF01'
	AND p.AnoSem = 20021;

CALL get_cod_depto_turmas_prof(20021, 'INF01');

/* 03. 1. Horários de Aula do Professor "Antunes" em 2002/1 */

DELIMITER //

CREATE PROCEDURE get_horarios_antunes()
BEGIN 
	DECLARE done INT DEFAULT FALSE;
	DECLARE dia_sem INT;
	DECLARE hora_inicio INT;
	DECLARE num_horas INT;
	
	DECLARE cur CURSOR FOR
        SELECT 
            h.DiaSem,
            h.HoraInicio, 
            h.NumHoras
        FROM Horario h
        JOIN Turma t ON h.AnoSem = t.AnoSem 
            AND h.CodDepto = t.CodDepto 
            AND h.NumDisc = t.NumDisc 
            AND h.SiglaTur = t.SiglaTur
        JOIN ProfTurma p ON t.AnoSem = p.AnoSem 
            AND t.CodDepto = p.CodDepto
            AND t.NumDisc = p.NumDisc
            AND t.SiglaTur = p.SiglaTur
        JOIN Professor p1 ON p1.CodProf = p.CodProf
        WHERE p1.NomeProf = 'Antunes' AND h.AnoSem = 20021;
	
	DECLARE CONTINUE handler FOR NOT FOUND SET done = TRUE;

	OPEN cur;

	CREATE TEMPORARY TABLE IF NOT EXISTS results(
		dia_semana INT,
		hora_inicial INT,
		numero_horas INT
	);
	
	read_loop: LOOP
		FETCH cur INTO dia_sem, hora_inicio, num_horas;
		
		IF done THEN
			LEAVE read_loop;
		END IF;
	
		INSERT INTO results(dia_semana, hora_inicial, numero_horas)
		VALUES(dia_sem, hora_inicio, num_horas);
	
	END LOOP;
	
	CLOSE cur;

	SELECT *
	FROM results;
	
END
//
DELIMITER ;

CALL get_horarios_antunes();

/* 04. Nomes dos Departamentos com Turmas na Sala 101 do Prédio 'Informática - aulas' em 2002/1 */

DELIMITER //

CREATE PROCEDURE get_departamentos_sala()
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE nome_depto VARCHAR(40);

	DECLARE cur CURSOR FOR
		SELECT 
			DISTINCT d.NomeDepto
		FROM Depto d
		JOIN Turma t ON d.CodDepto = t.CodDepto
		JOIN Horario h ON t.AnoSem = h.AnoSem 
			AND t.CodDepto = h.CodDepto 
			AND t.NumDisc = h.NumDisc 
			AND t.SiglaTur = h.SiglaTur
		JOIN Sala s ON h.NumSala = s.NumSala
			AND h.CodPred = s.CodPred
		JOIN Predio p ON s.CodPred = p.CodPred
		WHERE t.AnoSem = 20021
			AND s.NumSala = 101
			AND p.NomePredio = 'Informática';

	DECLARE CONTINUE handler FOR NOT FOUND SET done = TRUE;

	DROP TEMPORARY TABLE IF EXISTS results;

	CREATE TEMPORARY TABLE results(
		NomeDepto VARCHAR(40)
	);

	OPEN cur;

	read_loop: LOOP
		FETCH cur INTO nome_depto;
	
		IF done THEN
			LEAVE read_loop;
		END IF;
	
		INSERT INTO results (NomeDepto)
		VALUES (nome_depto);
		
	END LOOP;
	
	CLOSE cur;

	SELECT DISTINCT *
	FROM results;
	
END
//
DELIMITER ;

CALL get_departamentos_sala();

SELECT * FROM depto d 

/* 5. Obter os códigos dos professores com título denominado 'Doutor' que não ministraram aulas em 2002/1. */

DELIMITER //
CREATE PROCEDURE get_professores_doutor_sem_aulas()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cod_prof INT;

    DECLARE cur CURSOR FOR
    SELECT p.CodProf
    FROM Professor p
    JOIN Titulacao t ON p.CodTit = t.CodTit
    WHERE t.NomeTit = 'Doutor'
    AND p.CodProf NOT IN (
        SELECT pt.CodProf
        FROM ProfTurma pt
        WHERE pt.AnoSem = 20021
    );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO cod_prof;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT cod_prof;
    END LOOP;

    CLOSE cur;
END //
//
DELIMITER ;

/* 6. Obter os identificadores das salas que tiveram turmas nas segundas e quartas-feiras em 2002/1 */
/* a) Nas segundas-feiras (dia da semana = 2), tiveram ao menos uma turma do departamento 'Informática' */

DELIMITER //
CREATE PROCEDURE get_salas_segunda()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cod_pred INT;
    DECLARE num_sala INT;

    DECLARE cur CURSOR FOR
    SELECT h.CodPred, h.NumSala
    FROM Horario h
    JOIN Turma t ON h.AnoSem = t.AnoSem AND h.CodDepto = t.CodDepto AND h.NumDisc = t.NumDisc AND h.SiglaTur = t.SiglaTur
    WHERE h.DiaSem = 2 AND h.AnoSem = 20021 AND t.CodDepto = 'INF01';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO cod_pred, num_sala;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT cod_pred, num_sala;
    END LOOP;

    CLOSE cur;
END //
//
DELIMITER ;

/* b) Nas quartas-feiras (dia da semana = 4), tiveram ao menos uma turma ministrada pelo professor denominado 'Antunes' */

DELIMITER //
CREATE PROCEDURE get_salas_quarta()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cod_pred INT;
    DECLARE num_sala INT;

    DECLARE cur CURSOR FOR
    SELECT h.CodPred, h.NumSala
    FROM Horario h
    JOIN ProfTurma pt ON h.AnoSem = pt.AnoSem AND h.CodDepto = pt.CodDepto AND h.NumDisc = pt.NumDisc AND h.SiglaTur = pt.SiglaTur
    JOIN Professor p ON pt.CodProf = p.CodProf
    WHERE h.DiaSem = 4 AND h.AnoSem = 20021 AND p.NomeProf = 'Antunes';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO cod_pred, num_sala;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT cod_pred, num_sala;
    END LOOP;

    CLOSE cur;
END //
//
DELIMITER ;

/* 7. Obter o dia da semana, a hora de início e o número de horas de cada turma ministrada por 'Antunes' em 2002/1,  
      na sala número 101 e prédio de código 43423 */

DELIMITER //
CREATE PROCEDURE get_horarios_antunes()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE dia_sem INT;
    DECLARE hora_inicio INT;
    DECLARE num_horas INT;

    DECLARE cur CURSOR FOR
    SELECT h.DiaSem, h.HoraInicio, h.NumHoras
    FROM Horario h
    JOIN ProfTurma pt ON h.AnoSem = pt.AnoSem AND h.CodDepto = pt.CodDepto AND h.NumDisc = pt.NumDisc AND h.SiglaTur = pt.SiglaTur
    JOIN Professor p ON pt.CodProf = p.CodProf
    WHERE p.NomeProf = 'Antunes'
    AND h.AnoSem = 20021
    AND h.NumSala = 101
    AND h.CodPred = 43423;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO dia_sem, hora_inicio, num_horas;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT dia_sem, hora_inicio, num_horas;
    END LOOP;

    CLOSE cur;
END //
//
DELIMITER ;

/* 8. Para cada professor que já ministrou disciplinas de outros departamentos */

DELIMITER //
CREATE PROCEDURE get_professores_outros_deptos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cod_prof INT;
    DECLARE nome_prof VARCHAR(40);
    DECLARE dept_origem VARCHAR(40);
    DECLARE dept_ministrado VARCHAR(40);

    DECLARE cur CURSOR FOR
    SELECT DISTINCT p.CodProf, p.NomeProf, d1.NomeDepto AS DeptOrigem, d2.NomeDepto AS DeptMinistrado
    FROM Professor p
    JOIN Depto d1 ON p.CodDepto = d1.CodDepto
    JOIN ProfTurma pt ON p.CodProf = pt.CodProf
    JOIN Disciplina disc ON pt.CodDepto = disc.CodDepto AND pt.NumDisc = disc.NumDisc
    JOIN Depto d2 ON disc.CodDepto = d2.CodDepto
    WHERE p.CodDepto != disc.CodDepto;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO cod_prof, nome_prof, dept_origem, dept_ministrado;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT cod_prof, nome_prof, dept_origem, dept_ministrado;
    END LOOP;

    CLOSE cur;
END //
//
DELIMITER ;

/* 9. Obter o nome dos professores que possuem horários conflitantes (mesma hora inicial, dia da semana e semestre) e as chaves primárias das turmas
      em conflito */

DELIMITER //
CREATE PROCEDURE get_horarios_conflitantes()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nome_prof VARCHAR(40);
    DECLARE ano_sem INT;
    DECLARE cod_depto VARCHAR(10);
    DECLARE num_disc VARCHAR(10);
    DECLARE sigla_tur VARCHAR(10);

    DECLARE cur CURSOR FOR
    SELECT DISTINCT p.NomeProf, pt1.AnoSem, pt1.CodDepto, pt1.NumDisc, pt1.SiglaTur
    FROM Professor p
    JOIN ProfTurma pt1 ON p.CodProf = pt1.CodProf
    JOIN Horario h1 ON pt1.AnoSem = h1.AnoSem AND pt1.CodDepto = h1.CodDepto AND pt1.NumDisc = h1.NumDisc AND pt1.SiglaTur = h1.SiglaTur
    JOIN Horario h2 ON h1.AnoSem = h2.AnoSem AND h1.DiaSem = h2.DiaSem AND h1.HoraInicio = h2.HoraInicio 
    AND (h1.CodDepto <> h2.CodDepto OR h1.NumDisc <> h2.NumDisc OR h1.SiglaTur <> h2.SiglaTur)
    JOIN ProfTurma pt2 ON h2.AnoSem = pt2.AnoSem AND h2.CodDepto = pt2.CodDepto AND h2.NumDisc = pt2.NumDisc AND h2.SiglaTur = pt2.SiglaTur
    WHERE pt1.CodProf = pt2.CodProf;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO nome_prof, ano_sem, cod_depto, num_disc, sigla_tur;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT nome_prof, ano_sem, cod_depto, num_disc, sigla_tur;
    END LOOP;

    CLOSE cur;
END //
//
DELIMITER ;

/* 10. Para cada disciplina que possui pré-requisito, obter o nome da disciplina seguido do nome da disciplina que é seu pré-requisito */

DELIMITER //
CREATE PROCEDURE get_disciplinas_com_prerequisitos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nome_disciplina VARCHAR(40);
    DECLARE nome_prerequisito VARCHAR(40);

    DECLARE cur CURSOR FOR
    SELECT d.NomeDisciplina, dp.NomeDisciplina AS NomePreRequisito
    FROM Disciplina d
    JOIN PreRequisito pr ON d.NumDisc = pr.NumDisc AND d.CodDepto = pr.CodDepto
    JOIN Disciplina dp ON pr.NumDiscPreReq = dp.NumDisc AND pr.CodDeptoPreReq = dp.CodDepto;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO nome_disciplina, nome_prerequisito;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT nome_disciplina, nome_prerequisito;
    END LOOP;

    CLOSE cur;
END //
//
DELIMITER ;

 /* 11. Obter os nomes das disciplinas que não têm pré-requisito */

DELIMITER //
CREATE PROCEDURE get_disciplinas_sem_prerequisitos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nome_disciplina VARCHAR(40);

    DECLARE cur CURSOR FOR
    SELECT d.NomeDisciplina
    FROM Disciplina d
    WHERE NOT EXISTS (
        SELECT 1 
        FROM PreRequisito pr
        WHERE d.NumDisc = pr.NumDisc AND d.CodDepto = pr.CodDepto
    );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO nome_disciplina;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT nome_disciplina;
    END LOOP;

    CLOSE cur;
END //
//
DELIMITER ;

/* 12. Obter o nome de cada disciplina que possui ao menos dois pré-requisitos */

DELIMITER //
CREATE PROCEDURE get_disciplinas_com_2_prerequisitos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nome_disciplina VARCHAR(40);

    DECLARE cur CURSOR FOR
    SELECT d.NomeDisciplina
    FROM Disciplina d
    JOIN PreRequisito pr ON d.NumDisc = pr.NumDisc AND d.CodDepto = pr.CodDepto
    GROUP BY d.NomeDisciplina
    HAVING COUNT(pr.NumDiscPreReq) >= 2;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO nome_disciplina;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT nome_disciplina;
    END LOOP;

    CLOSE cur;
END //
//
DELIMITER ;

CALL get_departamentos_2002();

CALL get_professores_depto_INF01();

CALL get_horarios_antunes();

CALL get_departamentos_sala();

CALL get_professores_titulo_doutor();

CALL get_salas_informática_antunes();

CALL get_horarios_antunes_sala_101();

CALL get_professores_outros_dept();

CALL get_professores_horarios_conflitantes();

CALL get_disciplinas_com_pre_requisitos();

CALL get_disciplinas_sem_pre_requisitos();

CALL get_disciplinas_com_dois_pre_requisitos();
