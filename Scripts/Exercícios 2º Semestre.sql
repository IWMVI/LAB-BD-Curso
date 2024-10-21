USE faculdade;

/* 1- Obter os nomes dos docentes cuja titulação tem código diferente de 8. */
-- Usando theta-join
SELECT DISTINCT
    p.`NomeProf`
FROM
    `Professor` p
    JOIN `Titulacao` t ON t.`CodTit` = p.`CodTit`
WHERE
    p.`CodTit` <> 8;

-- Usando Natural Join
SELECT DISTINCT
    p.`NomeProf`
FROM
    `Professor` p
    NATURAL JOIN `Titulacao` t
WHERE
    p.`CodTit` <> 8;

-- 2- Obter os nomes dos departamentos que têm turmas que, em 2023/1, 
-- têm aulas na sala 204 do prédio denominado 'Polímeros'.
-- Usando theta-join
SELECT DISTINCT
    d.`NomeDepto`
FROM
    `Depto` d
    JOIN `Turma` t ON d.`CodDepto` = t.`CodDepto`
    JOIN `Horario` h ON t.`CodDepto` = h.`CodDepto`
    AND t.`NumDisc` = h.`NumDisc`
    JOIN `Sala` s ON h.`NumSala` = s.`NumSala`
    AND h.`CodPred` = s.`CodPred`
    JOIN `Predio` p ON s.`CodPred` = p.`CodPred`
WHERE
    h.`AnoSem` = 202301
    AND s.`NumSala` = 204
    AND p.`NomePredio` = 'Polímeros';

-- Usando Natural Join
SELECT DISTINCT
    d.`NomeDepto`
FROM
    `Depto` d
    NATURAL JOIN `Turma` t
    NATURAL JOIN `Horario` h
    NATURAL JOIN `Sala` s
    NATURAL JOIN `Predio` p
WHERE
    h.`AnoSem` = 202301
    AND s.`NumSala` = 204
    AND p.`NomePredio` = 'Polímeros';

/*  03 - Obter o nome dos professores que possuem horários conflitantes
(Possuem turmas que tenham a mesma hora inicial, no mesmo dia da semana
e no mesmo semeste)*/
-- Usando theta-join
SELECT DISTINCT
    p.`NomeProf`
FROM
    `Professor` p
    JOIN `ProfTurma` pt ON p.`CodProf` = pt.`CodProf`
    JOIN `Horario` h ON h.`AnoSem` = pt.`AnoSem`
    AND pt.`CodDepto` = h.`CodDepto`
    AND pt.`NumDisc` = h.`NumDisc`
    JOIN `Horario` h2 ON h.`AnoSem` = h2.`AnoSem`
    AND h.`DiaSem` = h2.`DiaSem`
    AND h.`HoraInicio` = h2.`HoraInicio`
    AND h.`CodDepto` = h2.`CodDepto`
    AND h.`NumDisc` = h2.`NumDisc`
WHERE
    h.`CodDepto` <> h2.`CodDepto`
    OR h.`NumDisc` <> h2.`NumDisc`;

-- Usando Natural Join
SELECT DISTINCT
    p.`NomeProf`
FROM
    `Professor` p
    NATURAL JOIN `ProfTurma` pt
    NATURAL JOIN `Horario` h
    NATURAL JOIN `Horario` h2
WHERE
    h.`CodDepto` <> h2.`CodDepto`
    OR h.`NumDisc` <> h2.`NumDisc`;

/*  Para cada disciplina que possui pré-requisito, obter o nome da disciplina
seguido do nome da disciplina que é seu pré-requisito
(Usar junções explícitas - quando possível usar junção natural*/
SELECT
    d1.NomeDisc AS Disciplina,
    d2.NomeDisc AS PreRequisito
FROM
    Disciplina d1
    JOIN PreReq pr ON d1.CodDepto = pr.CodDepto
    AND d1.NumDisc = pr.NumDisc
    JOIN Disciplina d2 ON pr.CodDeptoPreReq = d2.CodDepto
    AND pr.NumDiscPreReq = d2.NumDisc;

/*  05 - Para cada disciplina, mesmo aquelas que não possuem pré-requisito,
obter o nome da disciplina seguido da disciplina que é seu pré-requisito
(Usar junções explícitas - quando possível usar junção natural)*/
SELECT
    d1.`NomeDisc` AS Disciplina,
    COALESCE(d2.`NomeDisc`, 'Sem pré-requisito') AS PreRequisito
FROM
    `Disciplina` d1
    LEFT JOIN `PreReq` pr ON d1.`CodDepto` = pr.`CodDepto`
    AND d1.`NumDisc` = pr.`NumDisc`
    LEFT JOIN `Disciplina` d2 ON pr.`CodDepto`
    AND pr.`NumDiscPreReq` = d2.`CodDepto`
    AND d2.`NumDisc`;

/*  06 - Para cada disciplina que tem um pré-requisito que a sua vez também tem um pré-requisito, 
obter o nome da disciplina seguido do nome do pré-requisito de seu pré-requisito. */
SELECT
    d1.`NomeDisc` AS Disciplina,
    d2.`NomeDisc` AS PreRequisito,
    d3.`NomeDisc` AS PreRequisitoDoPreRequisito
FROM
    `Disciplina` d1
    JOIN `PreReq` pr1 ON d1.`CodDepto` = pr1.`CodDepto`
    AND d1.`NumDisc` = pr1.`NumDisc`
    JOIN `Disciplina` d2 ON pr1.`CodDeptoPreReq` = d2.`CodDepto`
    AND pr1.`NumDiscPreReq` = d2.`NumDisc`
    JOIN `PreReq` pr2 ON d2.`CodDepto` = pr2.`CodDepto`
    AND d2.`NumDisc` = pr2.`NumDisc`
    JOIN `Disciplina` d3 ON pr2.`CodDeptoPreReq` = d3.`CodDepto`
    AND pr2.`NumDiscPreReq` = d3.`NumDisc`;

/* 07 - Obter uma tabela com três colunas: nome da disciplina, nome do pré-requisito e o nível de pré-requisito. 
Limitar a consulta para três níveis.*/
-- Nível 1
SELECT
    d1.`NomeDisc` AS Disciplina,
    d2.`NomeDisc` AS PreRequisito,
    1 AS Nivel
FROM
    `Disciplina` d1
    JOIN `PreReq` pr ON d1.`CodDepto` = pr.`CodDepto`
    AND d1.`NumDisc` = pr.`NumDisc`
    JOIN `Disciplina` d2 ON pr.`CodDeptoPreReq` = d2.`CodDepto`
    AND pr.`NumDiscPreReq` = d2.`NumDisc`
UNION
-- Nível 2 
SELECT
    d1.`NomeDisc` AS Disciplina,
    d3.`NomeDisc` AS PreRequisito,
    2 AS Nivel
FROM
    `Disciplina` d1
    JOIN `PreReq` pr ON d1.`CodDepto` = pr.`CodDepto`
    AND d1.`NumDisc` = pr.`NumDisc`
    JOIN `Disciplina` d2 ON pr.`CodDeptoPreReq` = d2.`CodDepto`
    AND pr.`NumDiscPreReq` = d2.`NumDisc`
    JOIN `PreReq` pr2 ON d2.`CodDepto` = pr2.`CodDepto`
    AND d2.`NumDisc` = pr2.`NumDisc`
    JOIN `Disciplina` d3 ON pr2.`CodDeptoPreReq` = d3.`CodDepto`
    AND pr2.`NumDiscPreReq` = d3.`NumDisc`
UNION
-- Nível 3
SELECT
    d1.`NomeDisc` AS Disciplina,
    d4.`NomeDisc` AS PreRequisito,
    3 AS Nivel
FROM
    `Disciplina` d1
    JOIN `PreReq` pr ON d1.`CodDepto` = pr.`CodDepto`
    AND d1.`NumDisc` = pr.`NumDisc`
    JOIN `Disciplina` d2 ON pr.`CodDeptoPreReq` = d2.`CodDepto`
    AND pr.`NumDiscPreReq` = d2.`NumDisc`
    JOIN `PreReq` pr2 ON d2.`CodDepto` = pr2.`CodDepto`
    AND d2.`NumDisc` = pr2.`NumDisc`
    JOIN `Disciplina` d3 ON pr2.`CodDeptoPreReq` = d3.`CodDepto`
    AND pr2.`NumDiscPreReq` = d3.`NumDisc`
    JOIN `PreReq` pr3 ON d3.`CodDepto` = pr3.`CodDepto`
    AND d3.`NumDisc` = pr3.`NumDisc`
    JOIN `Disciplina` d4 ON pr3.`CodDeptoPreReq` = d4.`CodDepto`
    AND pr3.`NumDiscPreReq` = d4.`NumDisc`;

/*  08 - Obter os códigos dos professores com código de título vazio que não ministraram aulas em 2023/2 (resolver com junção natural).
 */
SELECT DISTINCT
    p.`CodProf`
FROM
    `Professor` p
    NATURAL JOIN `ProfTurma` pt
WHERE
    p.`CodTit` IS NULL
    AND pt.`AnoSem` <> 202302;