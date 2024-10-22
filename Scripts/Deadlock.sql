USE faculdade;

SET
    autocommit = 0;

/*  Criar um script descrevendo os passos para simular uma possível situação de DeadLock,
com os respectivos comandos das DISTINTAS sessões (1 e 2).

Tambem é necessario mostrar a mensagem de erro apresentada na Tela (screen shot). */
START TRANSACTION;

-- Atualizar a tabela 'Professor'
UPDATE Professor
SET
    NomeProf = 'João'
WHERE
    CodProf = 1;

-- Iniciar transação na sessão 2
START TRANSACTION;

UPDATE Turma
SET
    CapacTur = 35
WHERE
    AnoSem = 20241
    AND CodDepto = 'CS'
    AND NumDisc = 101
    AND SiglaTur = 'A1';

UPDATE Professor
SET
    NomeProf = 'Carlos'
WHERE
    CodProf = 1;

-- Deadlock
UPDATE Turma
SET
    CapacTur = 30
WHERE
    AnoSem = 20241
    AND CodDepto = 'CS'
    AND NumDisc = 101
    AND SiglaTur = 'A1';