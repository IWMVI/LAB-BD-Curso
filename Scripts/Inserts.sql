USE Faculdade;

-- Prédio
INSERT INTO
	Predio (CodPred, NomePredio)
VALUES
	(43423, 'Informática'),
	(10111, 'Administração');

-- Sala
INSERT INTO
	Sala (CodPred, NumSala, DescricaoSala, CapacSala)
VALUES
	(43423, 101, 'Sala de aula', 30),
	(43423, 102, 'Laboratório', 25),
	(10111, 201, 'Auditório', 100);

-- Departamento
INSERT INTO
	Depto (CodDepto, NomeDepto)
VALUES
	('INF01', 'Informática'),
	('ADM01', 'Administração'),
	('MAT01', 'Matemática');

UPDATE `Depto`
SET
	`NomeDepto` = 'Informática - aulas'
WHERE
	`CodDepto` = 'INF01';

-- Titulação
INSERT INTO
	Titulacao (CodTit, NomeTit)
VALUES
	(1, 'Mestre'),
	(2, 'Doutor'),
	(3, 'Especialista');

-- Professor
INSERT INTO
	Professor (CodProf, CodDepto, CodTit, NomeProf)
VALUES
	(1001, 'INF01', 2, 'Antunes'),
	(1002, 'INF01', 1, 'Paulo'),
	(1003, 'ADM01', 2, 'Fernanda'),
	(1004, 'MAT01', 3, 'Marcos');

-- Disciplina
INSERT INTO
	Disciplina (CodDepto, NumDisc, NomeDisc, CreditoDisc)
VALUES
	('INF01', 101, 'Algoritmos', 4),
	('INF01', 102, 'BD', 4),
	('ADM01', 201, 'Gestão', 2),
	('MAT01', 301, 'Cálculo I', 4);

-- PreReq
INSERT INTO
	PreReq (CodDeptoPreReq, NumDiscPreReq, CodDepto, NumDisc)
VALUES
	('INF01', 101, 'INF01', 102),
	('MAT01', 301, 'INF01', 101);

-- Turma
INSERT INTO
	Turma (AnoSem, CodDepto, NumDisc, SiglaTur, CapacTur)
VALUES
	(20021, 'INF01', 101, 'A1', 30),
	(20021, 'INF01', 102, 'A2', 25),
	(20021, 'ADM01', 201, 'B1', 50),
	(20021, 'MAT01', 301, 'C1', 40);

-- Turma
INSERT INTO
	ProfTurma (AnoSem, CodDepto, NumDisc, SiglaTur, CodProf)
VALUES
	(20021, 'INF01', 101, 'A1', 1001),
	(20021, 'INF01', 102, 'A2', 1002),
	(20021, 'ADM01', 201, 'B1', 1003),
	(20021, 'MAT01', 301, 'C1', 1004);

-- Horário
INSERT INTO
	Horario (AnoSem, CodDepto, NumDisc, SiglaTur, DiaSem, HoraInicio, NumSala, CodPred, NumHoras)
VALUES
	(20021, 'INF01', 101, 'A1', 2, 800, 101, 43423, 2),
	(20021, 'INF01', 101, 'A1', 4, 800, 101, 43423, 2),
	(20021, 'INF01', 102, 'A2', 2, 1000, 102, 43423, 2),
	(20021, 'ADM01', 201, 'B1', 3, 900, 201, 10111, 3),
	(20021, 'MAT01', 301, 'C1', 5, 1300, 101, 43423, 4);

INSERT INTO
	Turma (AnoSem, CodDepto, NumDisc, SiglaTur, CapacTur)
VALUES
	(202301, 'INF01', 101, 'A1', 30),
	(202301, 'INF01', 102, 'A2', 25);

INSERT INTO
	ProfTurma (AnoSem, CodDepto, NumDisc, SiglaTur, CodProf)
VALUES
	(202301, 'INF01', 101, 'A1', 1001),
	(202301, 'INF01', 102, 'A2', 1002);

INSERT INTO
	Predio (CodPred, NomePredio)
VALUES
	(50000, 'Informática - aulas');

INSERT INTO
	Sala (CodPred, NumSala, DescricaoSala, CapacSala)
VALUES
	(50000, 203, 'Laboratório de Programação', 35);

INSERT INTO
	Horario (AnoSem, CodDepto, NumDisc, SiglaTur, DiaSem, HoraInicio, NumSala, CodPred, NumHoras)
VALUES
	(202301, 'INF01', 101, 'A1', 2, 800, 203, 50000, 2), -- Aula na sala 203 do prédio 'Informática - aulas'
	(202301, 'INF01', 102, 'A2', 3, 1000, 203, 50000, 2);