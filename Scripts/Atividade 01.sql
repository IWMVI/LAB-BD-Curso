USE faculdade;

/* 01. Obter os códigos dos diferentes departamentos que têm turmas no ano-semestre 2002/1: */
SELECT DISTINCT
	CodDepto
FROM
	Turma t
WHERE
	AnoSem = 20021;

/* 02. Obter os códigos dos professores que são do departamento de código 'INF01' e que ministraram ao menos uma turma em 2002/1: */
SELECT DISTINCT
	p.CodProf
FROM
	Professor p
	JOIN ProfTurma p2 ON p2.CodProf = p.CodProf
WHERE
	p.CodDepto = 'INF01'
	AND p2.AnoSem = 20021;

/*  03. Obter os horários de aula (dia da semana, hora inicial e número de horas ministradas) do professor "Antunes" em 20021: */
SELECT
	h.DiaSem,
	h.HoraInicio,
	h.NumHoras
FROM
	Professor p
	JOIN ProfTurma p2 ON p2.CodProf = p.CodProf
	JOIN Horario h ON h.AnoSem = p2.AnoSem
WHERE
	p.NomeProf = 'Antunes'
	AND h.AnoSem = 20021;

/* 04. Obter os nomes dos departamentos que têm turmas que, em 2002/1, têm aulas na sala 101 do prédio denominado 'Informática - aulas': */
SELECT DISTINCT
	d.NomeDepto
FROM
	Turma t
	JOIN Horario h ON t.AnoSem = h.AnoSem
	AND t.CodDepto = h.CodDepto
	AND t.NumDisc = h.NumDisc
	AND t.SiglaTur = h.SiglaTur
	JOIN Predio p ON p.CodPred = h.CodPred
	JOIN Depto d ON t.CodDepto = d.CodDepto
WHERE
	p.NomePredio = 'Informática'
	AND h.NumSala = 101
	AND h.AnoSem = 20021;

/* 05. Obter os códigos dos professores com título denominado 'Doutor' que não ministraram aulas em 2002/1: */
SELECT
	p.CodProf
FROM
	Professor p
	JOIN Titulacao t ON t.CodTit = p.CodTit
WHERE
	t.NomeTit = 'Doutor'
	AND p.CodProf NOT IN (
		SELECT
			p2.CodProf
		FROM
			ProfTurma p2
		WHERE
			p2.AnoSem = 20021
	);

/* 06. Obter os identificadores das salas (código do prédio e número da sala) que, em 2002/1:
A) Nas segundas-feiras (dia da semana = 2), tiveram ao menos uma turma do departamento 'Informática': */
SELECT DISTINCT
	h.CodPred,
	h.NumSala
FROM
	Horario h
	JOIN Turma t ON h.CodDepto = t.CodDepto
	AND h.AnoSem = t.AnoSem
	AND h.NumDisc = t.NumDisc
	AND h.SiglaTur = t.SiglaTur
WHERE
	h.DiaSem = 2
	AND h.AnoSem = 20021
	AND t.CodDepto = 'Informática - Aulas';

/* B) Nas quartas-feiras (dia da semana = 4), tiveram ao menos uma turma ministrada pelo professor denominado 'Antunes': */
SELECT DISTINCT
	h.CodPred AS "Código do Prédio",
	h.NumSala AS "Número da Sala"
FROM
	Horario h
	JOIN ProfTurma p ON p.CodDepto = h.CodDepto
	AND p.AnoSem = h.AnoSem
	AND p.NumDisc = h.NumDisc
	AND p.SiglaTur = h.SiglaTur
	JOIN Professor p2 ON p.CodProf = p2.CodProf
WHERE
	h.DiaSem = 4
	AND p2.NomeProf = 'Antunes';

/* 07. Obter o dia da semana, a hora de início e o número de horas de cada horário de cada turma ministrada por um professor de nome `Antunes',
em 2002/1, na sala número 101 do prédio de código 43423:*/
SELECT
	h.DiaSem AS "Dia da Semana",
	FORMAT (h.HoraInicio, 'HH:mm') AS "Hora de Início",
	h.NumHoras AS "Número de Horas"
FROM
	Horario h
	JOIN ProfTurma p ON p.NumDisc = h.NumDisc
	AND p.AnoSem = h.AnoSem
	AND p.CodDepto = h.CodDepto
	AND p.SiglaTur = h.SiglaTur
	JOIN Professor p2 ON p2.CodProf = p.CodProf
WHERE
	p2.NomeProf = 'Antunes'
	AND h.NumSala = 101
	AND h.CodPred = 43423
	AND h.AnoSem = 20021;

/* 08. Para cada professor que já ministrou aulas em disciplinas de outros departamentos, 
obter o código do professor, seu nome, o nome de seu departamento e o nome do departamento no qual 
ministrou disciplina: */
SELECT DISTINCT
	p.CodProf,
	p.NomeProf,
	p.CodDepto AS 'Depto Origem',
	d3.NomeDepto AS 'Depto Ministrado'
FROM
	Professor p
	JOIN ProfTurma p2 ON p2.CodProf = p.CodProf
	JOIN Depto d ON d.CodDepto = p2.CodDepto
	JOIN Disciplina d2 ON d2.CodDepto = d.CodDepto
	JOIN Depto d3 ON d2.CodDepto = d3.CodDepto
WHERE
	p.CodDepto <> d2.CodDepto;

/* 09. Obter o nome dos professores que possuem horários conflitantes 
(possuem turmas que tenham a mesma hora inicial, no mesmo dia da semana e no mesmo semestre). 
Além dos nomes, mostrar as chaves primárias das turmas em conflito: */
SELECT DISTINCT
	P.NomeProf,
	H1.AnoSem,
	H1.CodDepto,
	H1.NumDisc,
	H1.SiglaTur,
	H1.DiaSem,
	H1.HoraInicio,
	H2.CodDepto AS CodDeptoConflito,
	H2.NumDisc AS NumDiscConflito,
	H2.SiglaTur AS SiglaTurConflito
FROM
	Professor P
	JOIN ProfTurma PT1 ON P.CodProf = PT1.CodProf
	JOIN Horario H1 ON PT1.AnoSem = H1.AnoSem
	AND PT1.CodDepto = H1.CodDepto
	AND PT1.NumDisc = H1.NumDisc
	AND PT1.SiglaTur = H1.SiglaTur
	JOIN ProfTurma PT2 ON P.CodProf = PT2.CodProf
	JOIN Horario H2 ON PT2.AnoSem = H2.AnoSem
	AND PT2.CodDepto = H2.CodDepto
	AND PT2.NumDisc = H2.NumDisc
	AND PT2.SiglaTur = H2.SiglaTur
WHERE
	H1.AnoSem = H2.AnoSem
	AND H1.DiaSem = H2.DiaSem
	AND H1.HoraInicio = H2.HoraInicio
	AND (
		H1.CodDepto <> H2.CodDepto
		OR H1.NumDisc <> H2.NumDisc
		OR H1.SiglaTur <> H2.SiglaTur
	)
ORDER BY
	P.NomeProf,
	H1.AnoSem,
	H1.DiaSem,
	H1.HoraInicio;