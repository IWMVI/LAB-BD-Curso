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
            
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
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

	DROP TEMPORARY TABLE IF EXISTS results;
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

CALL get_cod_depto_turmas_prof(20021, 'INF01');

/* 03. Horários de Aula do Professor "Antunes" em 2002/1 */

DROP PROCEDURE IF EXISTS get_horarios_antunes;

DELIMITER //

CREATE PROCEDURE get_horarios_antunes(IN nome_prof VARCHAR(40))
BEGIN 
	DECLARE done INT DEFAULT FALSE;
	DECLARE dia_sem VARCHAR(40);
	DECLARE hora_inicio VARCHAR(40);
	DECLARE num_horas VARCHAR(40);
    DECLARE sigla_tur VARCHAR(20);
    DECLARE hora_formata VARCHAR(5);
	
	DECLARE cur CURSOR FOR
        SELECT 
            h.DiaSem,
            h.HoraInicio, 
            h.NumHoras,
            h.SiglaTur
        FROM Horario h
        JOIN ProfTurma p ON h.SiglaTur = p.SiglaTur
        JOIN Professor p1 ON p1.CodProf = p.CodProf
			AND p1.NomeProf = nome_prof;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN cur;

	DROP TEMPORARY TABLE IF EXISTS results;

	CREATE TEMPORARY TABLE IF NOT EXISTS results(
		result VARCHAR(255)
	);
	
	read_loop: LOOP
		FETCH cur INTO dia_sem, hora_inicio, num_horas, sigla_tur;
		
		IF done THEN
			LEAVE read_loop;
		END IF;
	
        SET hora_inicio = LPAD(hora_inicio, 4, '0');  -- Garantir que tenha 4 dígitos
        SET hora_formata = CONCAT(SUBSTRING(hora_inicio, 1, 2), ':', SUBSTRING(hora_inicio, 3, 2));  -- Formatar para HH:MM

        INSERT INTO results(result)
        VALUES(CONCAT('Dia da Semana: ', dia_sem, 
                      ' Horário de início: ', hora_formata, 
                      ' Número de horas: ', num_horas, 
                      ' Turma: ', sigla_tur));
                      
	END LOOP;
	
	CLOSE cur;

	SELECT *
	FROM results;
	
END
//
DELIMITER ;

CALL get_horarios_antunes('Antunes');

/* 04. Nomes dos Departamentos com Turmas na Sala 101 do Prédio 'Informática - aulas' em 2002/1 */

DROP PROCEDURE IF EXISTS get_departamentos_sala;

DELIMITER //

CREATE PROCEDURE get_departamentos_sala(IN num_sala INT, IN nome_pred VARCHAR(40))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nome_depto VARCHAR(40);
    DECLARE nome_predio VARCHAR(40);
    
    DECLARE cur CURSOR FOR
        SELECT DISTINCT 
            d.NomeDepto,
            p.NomePredio,
            h.NumSala
        FROM Depto d
        JOIN Horario h ON h.CodDepto = d.CodDepto
        JOIN Sala s ON h.NumSala = s.NumSala
            AND s.NumSala = num_sala
        JOIN Predio p ON p.CodPred = h.CodPred
            AND p.NomePredio = nome_pred;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS results;

    CREATE TEMPORARY TABLE results(
        result VARCHAR(255)
    );

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO nome_depto, nome_predio, num_sala;
    
        IF done THEN
            LEAVE read_loop;
        END IF;
    
        INSERT INTO results (result)
        VALUES (CONCAT('Departamento: ', nome_depto, ' Prédio: ', nome_predio, ' Sala: ', num_sala));
        
    END LOOP;
    
    CLOSE cur;

    SELECT DISTINCT *
    FROM results;
    
END
//
DELIMITER ;

CALL get_departamentos_sala(101, 'Informática');

/* 5. Obter os códigos dos professores com título denominado 'Doutor' que não ministraram aulas em 2002/1. */

DROP PROCEDURE IF EXISTS get_professores_doutor_sem_aulas;

DELIMITER //

CREATE PROCEDURE get_professores_doutor_sem_aulas(IN titulo VARCHAR(40), IN ano_sem INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cod_prof INT;

    DECLARE cur CURSOR FOR
        SELECT p.CodProf
        FROM Professor p
        JOIN Titulacao t ON p.CodTit = t.CodTit
        LEFT JOIN ProfTurma pt ON p.CodProf = pt.CodProf 
            AND pt.AnoSem = ano_sem  -- Verifica se o professor não está associado a esse ano
        WHERE t.NomeTit = titulo
        AND pt.CodProf IS NULL;  -- Seleciona apenas os professores que não ministraram aulas

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS results; 
    
    CREATE TEMPORARY TABLE results(
        result INT
    );
    
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO cod_prof;
        IF done THEN
            LEAVE read_loop;
        END IF;
       
        INSERT INTO results(result)
        VALUES (cod_prof);
      
    END LOOP;

    CLOSE cur;
   
    SELECT *
    FROM results;
  
END //

DELIMITER ;

CALL get_professores_doutor_sem_aulas('Doutor', 20021);

/* 6. Obter os identificadores das salas que tiveram turmas nas segundas e quartas-feiras em 2002/1 */
/* a) Nas segundas-feiras (dia da semana = 2), tiveram ao menos uma turma do departamento 'Informática' */
/* b) Nas quartas-feiras (dia da semana = 4), tiveram ao menos uma turma ministrada pelo professor denominado 'Antunes' */

DROP PROCEDURE IF EXISTS get_id_sala;

DELIMITER //
CREATE PROCEDURE get_id_sala(IN ano_sem INT, IN nome_prof VARCHAR(40), IN depto VARCHAR(40))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE num_sala_r VARCHAR(40);
    DECLARE cod_pred_r VARCHAR(40);
    DECLARE dia_sem_r INT;
    DECLARE qtd_r INT;
    DECLARE nome_prof_r VARCHAR(40);
    
    DECLARE cur CURSOR FOR
		SELECT DISTINCT
			s.NumSala,
            s.CodPred,
            h.DiaSem,
            p.NomeProf,
            COUNT(s.NumSala) as Quantidade
        FROM Sala s
        JOIN Horario h ON h.NumSala = s.NumSala
			AND h.CodPred = s.CodPred
		JOIN Depto d ON d.CodDepto = h.CodDepto
			AND d.NomeDepto = depto
		JOIN Professor p ON p.CodDepto = d.CodDepto
			AND p.NomeProf = nome_prof
		JOIN ProfTurma pt ON pt.CodProf = p.CodProf
			AND h.NumDisc = pt.NumDisc
		WHERE (h.DiaSem = 4 OR h.DiaSem = 2) 
			AND h.AnoSem = ano_sem
		GROUP BY s.NumSala, s.CodPred, s.NumSala, h.DiaSem, p.NomeProf
        HAVING Quantidade >= 1;
        
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
        
        OPEN cur;
        
        DROP TEMPORARY TABLE IF EXISTS results;
        
        CREATE TEMPORARY TABLE results(
			result VARCHAR(255)
        );
        
        read_loop: LOOP
			FETCH cur INTO num_sala_r, cod_pred_r, dia_sem_r, nome_prof_r, qtd_r;
            
            IF done THEN
				LEAVE read_loop;
			END IF;
            
            INSERT INTO results(result)
            VALUES (CONCAT('Número Sala: ', num_sala_r, ' Número Prédio: ', cod_pred_r, ' Dia Semana: ', dia_sem_r, ' Professor: ', nome_prof_r));
		
        END LOOP;
        
        SELECT *
        FROM results;
END
//
DELIMITER ;

CALL get_id_sala(20021, 'Antunes', 'Informática'); 

/* 7. Obter o dia da semana, a hora de início e o número de horas de cada turma ministrada por 'Antunes' em 2002/1,  
      na sala número 101 e prédio de código 43423 */

DELIMITER //
CREATE PROCEDURE get_aulas_antunes()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE dia_sem INT;
    DECLARE hora_inicio INT;
    DECLARE num_horas INT;

    DECLARE cur CURSOR FOR
    SELECT h.DiaSem, h.HoraInicio, h.NumHoras
    FROM Horario h
    JOIN ProfTurma pt ON h.AnoSem = pt.AnoSem 
		AND h.CodDepto = pt.CodDepto 
		AND h.NumDisc = pt.NumDisc 
        AND h.SiglaTur = pt.SiglaTur
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
END
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
    JOIN Disciplina disc ON pt.CodDepto = disc.CodDepto
		AND pt.NumDisc = disc.NumDisc
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
END
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
    JOIN Horario h1 ON pt1.AnoSem = h1.AnoSem 
		AND pt1.CodDepto = h1.CodDepto 
        AND pt1.NumDisc = h1.NumDisc 
        AND pt1.SiglaTur = h1.SiglaTur
    JOIN Horario h2 ON h1.AnoSem = h2.AnoSem 
		AND h1.DiaSem = h2.DiaSem 
        AND h1.HoraInicio = h2.HoraInicio 
		AND (h1.CodDepto <> h2.CodDepto 
			OR h1.NumDisc <> h2.NumDisc 
            OR h1.SiglaTur <> h2.SiglaTur)
    JOIN ProfTurma pt2 ON h2.AnoSem = pt2.AnoSem 
		AND h2.CodDepto = pt2.CodDepto 
		AND h2.NumDisc = pt2.NumDisc 
        AND h2.SiglaTur = pt2.SiglaTur
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
END
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
    JOIN PreRequisito pr ON d.NumDisc = pr.NumDisc 
		AND d.CodDepto = pr.CodDepto
    JOIN Disciplina dp ON pr.NumDiscPreReq = dp.NumDisc	
		AND pr.CodDeptoPreReq = dp.CodDepto;

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
END
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
        WHERE d.NumDisc = pr.NumDisc 
			AND d.CodDepto = pr.CodDepto
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
END
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
    JOIN PreRequisito pr ON d.NumDisc = pr.NumDisc 
		AND d.CodDepto = pr.CodDepto
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
END
//
DELIMITER ;
