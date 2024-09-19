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

CALL get_cod_depto_turmas_prof(20021, "INF01");

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
			DISTINCT
			d.NomeDepto
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

	OPEN cur;

	CREATE TEMPORARY TABLE IF NOT EXISTS results(
		NomeDepto VARCHAR(40)
	);

	read_loop: LOOP
		FETCH cur INTO nome_depto;
		IF done THEN
			LEAVE read_loop;
		END IF;
	
		INSERT INTO results (NomeDepto)
		VALUES (nome_depto);
		
	END LOOP;
	
	CLOSE cur;

	SELECT *
	FROM results;
	
END
//
DELIMITER ;

CALL get_departamentos_sala();































