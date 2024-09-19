USE faculdade;

DELIMITER //

-- Criar Procedure, usando cursor explícito, para selecionar a quantidade de disciplinas agrupadas por departamento.

CREATE PROCEDURE ContDisc()
BEGIN
    -- Variáveis para armazenar os resultados do cursor
    DECLARE v_CodDepto CHAR(5);
    DECLARE v_DisciplinaCount INT;

    -- Declara o cursor para contar disciplinas por departamento
    DECLARE cur CURSOR FOR
        SELECT
            CodDepto,
            COUNT(*) AS DiscCont
        FROM
            Disciplina
        GROUP BY
            CodDepto;

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
        SELECT
            v_CodDepto AS Departamento,
            v_DisciplinaCount AS QuantidadeDisciplinas;
    END LOOP;

    -- Fecha o cursor
    CLOSE cur;
END //

-- Restaura o delimitador padrão
DELIMITER ;

SELECT * FROM Predio