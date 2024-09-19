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
        
        INSERT INTO results(RESULT) VALUES(depto);
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
	
		INSERT INTO results(RESULT) VALUES(CONCAT('O professor de código ', cod_prof_r, ' no ano ', ano_sem_r, ' ministrou ', qtd_r, ' aulas.'));
		
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