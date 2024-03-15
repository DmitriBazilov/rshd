CREATE OR REPLACE FUNCTION schemas_table(t text)
RETURNS VOID AS
$$
    DECLARE
        schema_tab CURSOR FOR (
            SELECT tab.relname, space.nspname FROM pg_class tab
                JOIN pg_namespace space on tab.relnamespace = space.oid
            WHERE tab.relname = t
            ORDER BY space.nspname
            );
        table_count int;
        schema text;
    BEGIN
        SELECT COUNT(DISTINCT nspname) INTO table_count FROM pg_class tab JOIN pg_namespace space on tab.relnamespace = space.oid WHERE relname = t;

        IF table_count < 1 THEN
            RAISE EXCEPTION 'Таблица "%" не найдена!', t;
        ELSE
            RAISE NOTICE ' ';
            RAISE NOTICE 'Выберите схему, с которой вы хотите получить данные: ';

            FOR col in schema_tab
            LOOP
                RAISE NOTICE '%', col.nspname;
            END LOOP;
            RAISE NOTICE ' ';
            END IF;
    END
$$ LANGUAGE plpgsql;