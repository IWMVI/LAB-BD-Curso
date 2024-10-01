USE faculdade;

/*
    Criar trigger para registrar um LOG das atualizações das Tabela Professor. No Log deve existir:

           1-  código do usuário que fez a alteração;
           2-  chave primaria do registro alterado;
           3-  Tipo de alteração realizado (INSERT ou UPDATE ou DELETE);
           4-  Data e Hora da alteração.


Entregar a estrutura da Tabela de LOG ( pode ser chamada Tabela_Log_Professor ) ;

e o Código da(s) Trigger(s).
*/

    DELIMITER //

    CREATE TRIGGER trg_log_professor_insert
    AFTER INSERT ON Professor
    FOR EACH ROW
    BEGIN
        INSERT INTO Tabela_Log_Professor (CodUsuario, CodProf, TipoAlteracao, DataHoraAlteracao)
        VALUES (USER(), NEW.CodProf, 'INSERT', NOW());
    END //

    CREATE TRIGGER trg_log_professor_update
    AFTER UPDATE ON Professor
    FOR EACH ROW
    BEGIN
        INSERT INTO Tabela_Log_Professor (CodUsuario, CodProf, TipoAlteracao, DataHoraAlteracao)
        VALUES (USER(), NEW.CodProf, 'UPDATE', NOW());
    END //

    CREATE TRIGGER trg_log_professor_delete
    AFTER DELETE ON Professor
    FOR EACH ROW
    BEGIN
        INSERT INTO Tabela_Log_Professor (CodUsuario, CodProf, TipoAlteracao, DataHoraAlteracao)
        VALUES (USER(), OLD.CodProf, 'DELETE', NOW());
    END //

    DELIMITER ;
    