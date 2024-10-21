USE faculdade;

/* 1- Obter os nomes dos departamentos que têm turmas que, em 2023/1, têm aulas na sala 203 do prédio denominado 'Informática - aulas'.
-- Resolver usando theta-join e junção natural. */
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
    AND s.`NumSala` = 203
    AND p.`NomePredio` = 'Informática - aulas';

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
    AND s.`NumSala` = 203
    AND p.`NomePredio` = 'Informática - aulas';