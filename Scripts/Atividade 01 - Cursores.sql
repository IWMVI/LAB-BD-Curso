USE faculdade;

/* 01. Obter os códigos dos diferentes departamentos que têm turmas no ano-semestre 2002/1:
Caso não haja resultados exibir uma mensagem de erro de acordo com o que é pedido no enunciado. */

DELIMITER //
CREATE PROCEDURE Departamentos20021()
BEGIN
    DECLARE contador INT;
    SELECT COUNT(*)
    INTO contador
    FROM
        Depto d
        JOIN Disciplina di ON d.CodDepto = di.CodDepto
        JOIN Turma t ON di.CodDepto = t.CodDepto
    WHERE
        t.AnoSem = 20021;
    IF contador = 0 THEN
        SELECT 'Não há departamentos com turmas em 2002/1';
    ELSE
        SELECT DISTINCT
            d.CodDepto
        FROM
            Depto d
            JOIN Disciplina di ON d.CodDepto = di.CodDepto
            JOIN Turma t ON di.CodDepto = t.CodDepto
        WHERE
            t.AnoSem = 20021;
    END IF;
END//
DELIMITER ;

CALL Departamentos20021();

/* 02. Obter os códigos dos professores que são do departamento de código 'INF01' e que ministraram ao menos uma turma em 2002/1: 
Caso não haja resultados exibir uma mensagem de erro de acordo com o que é pedido no enunciado.*/

DELIMITER //
CREATE PROCEDURE ProfessoresINF01()
BEGIN
    DECLARE contador INT;
    SELECT COUNT(*)
    INTO contador
    FROM
        Professor p
        JOIN ProfTurma pt ON p.CodProf = pt.CodProf
    WHERE
        p.CodDepto = 'INF01'
        AND pt.AnoSem = 20021;
    IF contador = 0 THEN
        SELECT 'Não há professores do departamento INF01 com turmas em 2002/1';
    ELSE
        SELECT DISTINCT
            p.CodProf
        FROM
            Professor p
            JOIN ProfTurma pt ON p.CodProf = pt.CodProf
        WHERE
            p.CodDepto = 'INF01'
            AND pt.AnoSem = 20021;
    END IF;
END//
DELIMITER ;

CALL ProfessoresINF01();

/*  03. Obter os horários de aula (dia da semana, hora inicial e número de horas ministradas) do professor "Antunes" em 20021: 
Caso não haja resultados exibir uma mensagem de erro de acordo com o que é pedido no enunciado.*/

DELIMITER //
CREATE PROCEDURE HorariosAntunes()
BEGIN
    DECLARE contador INT;
    SELECT COUNT(*)
    INTO contador
    FROM
        Professor p
        JOIN ProfTurma pt ON p.CodProf = pt.CodProf
        JOIN Horario h ON pt.AnoSem = h.AnoSem
        AND pt.CodDepto = h.CodDepto
        AND pt.NumDisc = h.NumDisc
        AND pt.SiglaTur = h.SiglaTur
    WHERE
        p.NomeProf = 'Antunes'
        AND h.AnoSem = 20021;
    IF contador = 0 THEN
        SELECT 'Não há horários para o professor Antunes em 2002/1';
    ELSE
        SELECT
            h.DiaSem,
            h.HoraInicio,
            h.NumHoras
        FROM
            Professor p
            JOIN ProfTurma pt ON p.CodProf = pt.CodProf
            JOIN Horario h ON pt.AnoSem = h.AnoSem
            AND pt.CodDepto = h.CodDepto
            AND pt.NumDisc = h.NumDisc
            AND pt.SiglaTur = h.SiglaTur
        WHERE
            p.NomeProf = 'Antunes'
            AND h.AnoSem = 20021;
    END IF;
END//
DELIMITER ;

CALL HorariosAntunes();

/* 04. Obter os nomes dos departamentos que têm turmas que, em 2002/1, têm aulas na sala 101 do prédio denominado 'Informática - aulas': 
Caso não haja resultados exibir uma mensagem de erro de acordo com o que é pedido no enunciado.*/

DELIMITER //
CREATE PROCEDURE DepartamentosSala101()
BEGIN
    DECLARE contador INT;
    SELECT COUNT(*)
    INTO contador
    FROM
        Depto d
        JOIN Disciplina di ON d.CodDepto = di.CodDepto
        JOIN Turma t ON di.CodDepto = t.CodDepto
        JOIN Horario h ON t.AnoSem = h.AnoSem
        AND t.CodDepto = h.CodDepto
        AND t.NumDisc = h.NumDisc
        AND t.SiglaTur = h.SiglaTur
        JOIN Sala s ON h.NumSala = s.NumSala
        AND h.CodPred = s.CodPred
        JOIN Predio p ON s.CodPred = p.CodPred
    WHERE
        h.AnoSem = 20021
        AND s.NumSala = 101
        AND p.NomePredio = 'Informática - aulas';
    IF contador = 0 THEN
        SELECT 'Não há departamentos com aulas na sala 101 do prédio Informática - aulas em 2002/1';
    ELSE
        SELECT DISTINCT
            d.NomeDepto
        FROM
            Depto d
            JOIN Disciplina di ON d.CodDepto = di.CodDepto
            JOIN Turma t ON di.CodDepto = t.CodDepto
            JOIN Horario h ON t.AnoSem = h.AnoSem
            AND t.CodDepto = h.CodDepto
            AND t.NumDisc = h.NumDisc
            AND t.SiglaTur = h.SiglaTur
            JOIN Sala s ON h.NumSala = s.NumSala
            AND h.CodPred = s.CodPred
            JOIN Predio p ON s.CodPred = p.CodPred
        WHERE
            h.AnoSem = 20021
            AND s.NumSala = 101
            AND p.NomePredio = 'Informática - aulas';
    END IF;
END//
DELIMITER ;

CALL DepartamentosSala101();

/* 05. Obter os códigos dos professores com título denominado 'Doutor' que não ministraram aulas em 2002/1:
Caso não haja resultados exibir uma mensagem de erro de acordo com o que é pedido no enunciado. */

DELIMITER //
CREATE PROCEDURE ProfessoresDoutoresSemAula()
BEGIN
    DECLARE contador INT;
    SELECT COUNT(*)
    INTO contador
    FROM
        Professor
    WHERE
        CodTit = 1
        AND CodProf NOT IN (
            SELECT CodProf
            FROM
                ProfTurma
            WHERE
                AnoSem = 20021
        );
    IF contador = 0 THEN
        SELECT 'Não há professores doutores com aulas em 2002/1';
    ELSE
        SELECT CodProf
        FROM
            Professor
        WHERE
            CodTit = 1
            AND CodProf NOT IN (
                SELECT CodProf
                FROM
                    ProfTurma
                WHERE
                    AnoSem = 20021
            );
    END IF;
END//
DELIMITER ;

CALL ProfessoresDoutoresSemAula();

/* 06. Obter os identificadores das salas (código do prédio e número da sala) que, em 2002/1:
A) Nas segundas-feiras (dia da semana = 2), tiveram ao menos uma turma do departamento 'Informática': 
B) Nas quartas-feiras (dia da semana = 4), tiveram ao menos uma turma ministrada pelo professor denominado 'Antunes': 
Caso não haja resultados exibir uma mensagem de erro de acordo com o que é pedido no enunciado.*/
DELIMITER //
CREATE PROCEDURE Salas20021()
BEGIN
    DECLARE contador INT;
    SELECT COUNT(*)
    INTO contador
    FROM
        Sala s
        JOIN Horario h ON s.NumSala = h.NumSala
        AND s.CodPred = h.CodPred
        JOIN Turma t ON h.AnoSem = t.AnoSem
        AND h.CodDepto = t.CodDepto
        AND h.NumDisc = t.NumDisc
        JOIN Depto d ON t.CodDepto = d.CodDepto
    WHERE
        h.AnoSem = 20021
        AND h.DiaSem = 2
        AND d.NomeDepto = 'Informática';
    IF contador = 0 THEN
        SELECT 'Não há salas com aulas de Informática nas segundas-feiras em 2002/1';
    ELSE
        SELECT DISTINCT
            s.CodPred,
            s.NumSala
        FROM
            Sala s
            JOIN Horario h ON s.NumSala = h.NumSala
            AND s.CodPred = h.CodPred
            JOIN Turma t ON h.AnoSem = t.AnoSem
            AND h.CodDepto = t.CodDepto
            AND h.NumDisc = t.NumDisc
            JOIN Depto d ON t.CodDepto = d.CodDepto
        WHERE
            h.AnoSem = 20021
            AND h.DiaSem = 2
            AND d.NomeDepto = 'Informática';
    END IF;
    SELECT COUNT(*)
    INTO contador
    FROM
        Sala s
        JOIN Horario h ON s.NumSala = h.NumSala
        AND s.CodPred = h.CodPred
        JOIN ProfTurma pt ON h.AnoSem = pt.AnoSem
        AND h.CodDepto = pt.CodDepto
        AND h.NumDisc = pt.NumDisc
        AND h.SiglaTur = pt.SiglaTur
        JOIN Professor p ON pt.CodProf = p.CodProf
    WHERE
        h.AnoSem = 20021
        AND h.DiaSem = 4
        AND p.NomeProf = 'Antunes';
    IF contador = 0 THEN
        SELECT 'Não há salas com aulas do professor Antunes nas quartas-feiras em 2002/1';
    ELSE
        SELECT DISTINCT
            s.CodPred,
            s.NumSala
        FROM
            Sala s
            JOIN Horario h ON s.NumSala = h.NumSala
            AND s.CodPred = h.CodPred
            JOIN ProfTurma pt ON h.AnoSem = pt.AnoSem
            AND h.CodDepto = pt.CodDepto
            AND h.NumDisc = pt.NumDisc
            AND h.SiglaTur = pt.SiglaTur
            JOIN Professor p ON pt.CodProf = p.CodProf
        WHERE
            h.AnoSem = 20021
            AND h.DiaSem = 4
            AND p.NomeProf = 'Antunes';
    END IF;
END//
DELIMITER ;

CALL Salas20021();

/* 07. Obter o dia da semana, a hora de início e o número de horas de cada horário de cada turma ministrada por um professor de nome `Antunes',
em 2002/1, na sala número 101 do prédio de código 43423:
Caso não haja resultados exibir uma mensagem de erro de acordo com o que é pedido no enunciado.*/

DELIMITER //
CREATE PROCEDURE HorariosAntunesSala101()
BEGIN
    DECLARE contador INT;
    SELECT COUNT(*)
    INTO contador
    FROM
        Horario h
        JOIN ProfTurma pt ON h.AnoSem = pt.AnoSem
        AND h.CodDepto = pt.CodDepto
        AND h.NumDisc = pt.NumDisc
        AND h.SiglaTur = pt.SiglaTur
        JOIN Professor p ON pt.CodProf = p.CodProf
        JOIN Sala s ON h.NumSala = s.NumSala
        AND h.CodPred = s.CodPred
    WHERE
        h.AnoSem = 20021
        AND p.NomeProf = 'Antunes'
        AND s.NumSala = 101
        AND s.CodPred = 43423;
    IF contador = 0 THEN
        SELECT 'Não há horários para o professor Antunes na sala 101 do prédio 43423 em 2002/1';
    ELSE
        SELECT
            h.DiaSem,
            h.HoraInicio,
            h.NumHoras
        FROM
            Horario h
            JOIN ProfTurma pt ON h.AnoSem = pt.AnoSem
            AND h.CodDepto = pt.CodDepto
            AND h.NumDisc = pt.NumDisc
            AND h.SiglaTur = pt.SiglaTur
            JOIN Professor p ON pt.CodProf = p.CodProf
            JOIN Sala s ON h.NumSala = s.NumSala
            AND h.CodPred = s.CodPred
        WHERE
            h.AnoSem = 20021
            AND p.NomeProf = 'Antunes'
            AND s.NumSala = 101
            AND s.CodPred = 43423;
    END IF;
END//
DELIMITER ;

CALL HorariosAntunesSala101();

/* 08. Para cada professor que já ministrou aulas em disciplinas de outros departamentos, 
obter o código do professor, seu nome, o nome de seu departamento e o nome do departamento no qual 
ministrou disciplina: 
Caso não haja resultados exibir uma mensagem de erro de acordo com o que é pedido no enunciado.*/

DELIMITER //
CREATE PROCEDURE ProfessoresOutrosDeptos()
BEGIN
    DECLARE contador INT;
    SELECT COUNT(*)
    INTO contador
    FROM
        Professor p
        JOIN ProfTurma pt ON p.CodProf = pt.CodProf
        JOIN Disciplina d ON pt.CodDepto = d.CodDepto
    WHERE
        p.CodDepto <> d.CodDepto;
    IF contador = 0 THEN
        SELECT 'Não há professores que ministraram disciplinas de outros departamentos';
    ELSE
        SELECT DISTINCT
            p.CodProf,
            p.NomeProf,
            d.NomeDepto AS NomeDeptoProf,
            d.NomeDepto AS NomeDeptoDisc
        FROM
            Professor p
            JOIN ProfTurma pt ON p.CodProf = pt.CodProf
            JOIN Disciplina d ON pt.CodDepto = d.CodDepto
        WHERE
            p.CodDepto <> d.CodDepto;
    END IF;
END//
DELIMITER ;

CALL ProfessoresOutrosDeptos();

/* 09. Obter o nome dos professores que possuem horários conflitantes 
(possuem turmas que tenham a mesma hora inicial, no mesmo dia da semana e no mesmo semestre). 
Além dos nomes, mostrar as chaves primárias das turmas em conflito:
Caso não haja resultados exibir uma mensagem de erro de acordo com o que é pedido no enunciado. */

DROP PROCEDURE IF EXISTS ProfessoresConflitos;

DELIMITER //
CREATE PROCEDURE ProfessoresConflitos()
BEGIN
    DECLARE contador INT;
    
    SELECT COUNT(*)
    INTO contador
    FROM
        Horario h1
        JOIN Horario h2 ON h1.AnoSem = h2.AnoSem
        AND h1.DiaSem = h2.DiaSem
        AND h1.HoraInicio = h2.HoraInicio
        AND h1.NumSala = h2.NumSala
        AND h1.CodPred = h2.CodPred
        AND h1.CodDepto = h2.CodDepto
        AND h1.NumDisc = h2.NumDisc
        AND h1.SiglaTur = h2.SiglaTur
    WHERE
        h1.HoraInicio = h2.HoraInicio
        AND h1.CodDepto = h2.CodDepto;
    
    IF contador = 0 THEN
        SELECT 'Não há professores com horários conflitantes' AS Mensagem;
    ELSE
        SELECT
            p1.NomeProf AS NomeProfessor1,
            p2.NomeProf AS NomeProfessor2,
            h1.AnoSem,
            h1.CodDepto,
            h1.NumDisc,
            h1.SiglaTur
        FROM
            Horario h1
            JOIN Horario h2 ON h1.AnoSem = h2.AnoSem
            AND h1.DiaSem = h2.DiaSem
            AND h1.HoraInicio = h2.HoraInicio
            AND h1.NumSala = h2.NumSala
            AND h1.CodPred = h2.CodPred
            AND h1.CodDepto = h2.CodDepto
            AND h1.NumDisc = h2.NumDisc
            AND h1.SiglaTur = h2.SiglaTur
            JOIN ProfTurma pt1 ON h1.AnoSem = pt1.AnoSem
            AND h1.CodDepto = pt1.CodDepto
            AND h1.NumDisc = pt1.NumDisc
            AND h1.SiglaTur = pt1.SiglaTur
            JOIN ProfTurma pt2 ON h2.AnoSem = pt2.AnoSem
            AND h2.CodDepto = pt2.CodDepto
            AND h2.NumDisc = pt2.NumDisc
            AND h2.SiglaTur = pt2.SiglaTur
            JOIN Professor p1 ON pt1.CodProf = p1.CodProf
            JOIN Professor p2 ON pt2.CodProf = p2.CodProf
        WHERE
            pt1.CodProf <> pt2.CodProf;
    END IF;
END//
DELIMITER ;

CALL ProfessoresConflitos();
