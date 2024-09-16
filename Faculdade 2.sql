CREATE DATABASE faculdade;

USE faculdade;

CREATE TABLE Predio (
    CodPred INT,
    NomePredio VARCHAR(40),
    PRIMARY KEY (CodPred)
);

CREATE TABLE Sala (
    CodPred INT,
    NumSala INT,
    DescricaoSala VARCHAR(40),
    CapacSala INT,
    PRIMARY KEY (NumSala , CodPred),
    FOREIGN KEY (CodPred)
        REFERENCES Predio (CodPred)
);

CREATE TABLE Depto (
    CodDepto CHAR(5),
    NomeDepto VARCHAR(40),
    PRIMARY KEY (CodDepto)
);

CREATE TABLE Titulacao (
    CodTit INT,
    NomeTit VARCHAR(40),
    PRIMARY KEY (CodTit)
);

CREATE TABLE Professor (
    CodProf INT,
    CodDepto CHAR(5),
    CodTit INT,
    NomeProf VARCHAR(40),
    PRIMARY KEY (CodProf),
    FOREIGN KEY (CodDepto)
        REFERENCES Depto (CodDepto),
    FOREIGN KEY (CodTit)
        REFERENCES Titulacao (CodTit)
);

CREATE TABLE Disciplina (
    CodDepto CHAR(5),
    NumDisc INT,
    NomeDisc VARCHAR(10),
    CreditoDisc INT,
    PRIMARY KEY (CodDepto , NumDisc),
    FOREIGN KEY (CodDepto)
        REFERENCES Depto (CodDepto)
);

CREATE TABLE PreReq (
    CodDeptoPreReq CHAR(5),
    NumDiscPreReq INT,
    CodDepto CHAR(5),
    NumDisc INT,
    PRIMARY KEY (CodDeptoPreReq , NumDiscPreReq , CodDepto , NumDisc),
    FOREIGN KEY (CodDepto , NumDisc)
        REFERENCES Disciplina (CodDepto , NumDisc),
    FOREIGN KEY (CodDeptoPreReq , NumDiscPreReq)
        REFERENCES Disciplina (CodDepto , NumDisc)
);

CREATE TABLE Turma (
    AnoSem INT,
    CodDepto CHAR(5),
    NumDisc INT,
    SiglaTur CHAR(2),
    CapacTur INT,
    PRIMARY KEY (AnoSem , CodDepto , NumDisc , SiglaTur),
    FOREIGN KEY (CodDepto , NumDisc)
        REFERENCES Disciplina (CodDepto , NumDisc)
);

CREATE TABLE ProfTurma (
    AnoSem INT,
    CodDepto CHAR(5),
    NumDisc INT,
    SiglaTur CHAR(2),
    CodProf INT,
    PRIMARY KEY (AnoSem , CodDepto , NumDisc , SiglaTur , CodProf),
    FOREIGN KEY (AnoSem , CodDepto , NumDisc , SiglaTur)
        REFERENCES Turma (AnoSem , CodDepto , NumDisc , SiglaTur),
    FOREIGN KEY (CodProf)
        REFERENCES Professor (CodProf)
);

CREATE TABLE Horario (
    AnoSem INT,
    CodDepto CHAR(5),
    NumDisc INT,
    SiglaTur CHAR(2),
    DiaSem INT,
    HoraInicio INT,
    NumSala INT,
    CodPred INT,
    NumHoras INT,
    PRIMARY KEY (AnoSem , CodDepto , NumDisc , SiglaTur , DiaSem , HoraInicio),
    FOREIGN KEY (AnoSem , CodDepto , NumDisc , SiglaTur)
        REFERENCES Turma (AnoSem , CodDepto , NumDisc , SiglaTur),
    FOREIGN KEY (NumSala , CodPred)
        REFERENCES Sala (NumSala , CodPred)
);

-- Criar Procedure, usando cursor explícito, para selecionar a quantidade de disciplinas agrupadas por departamento.

DELIMITER //

CREATE PROCEDURE ContDisc()
BEGIN
    -- Variáveis para armazenar os resultados do cursor
    DECLARE v_CodDepto CHAR(5);
    DECLARE v_DisciplinaCount INT;

    -- Declara o cursor para contar disciplinas por departamento
    DECLARE cur CURSOR FOR
        SELECT CodDepto, COUNT(*) AS DiscCont
        FROM Disciplina
        GROUP BY CodDepto;

    -- Declara um handler para quando não há mais linhas no cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_CodDepto = NULL;

    -- Abre o cursor
    OPEN cur;

    -- Loop para processar os dados do cursor
    read_loop: LOOP
        FETCH cur INTO v_CodDepto, v_DisciplinaCount;

        -- Sai do loop se não houver mais linhas
        IF v_CodDepto IS NULL THEN
            LEAVE read_loop;
        END IF;

        -- Exibe os resultados
        SELECT v_CodDepto AS Departamento, v_DisciplinaCount AS QuantidadeDisciplinas;

    END LOOP;

    -- Fecha o cursor
    CLOSE cur;
END //

DELIMITER ;
