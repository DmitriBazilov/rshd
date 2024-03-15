\prompt 'Введите название таблицы: \n' table_name

\set tmp_table_name '\'' :table_name '\''

SELECT schemas_table(:tmp_table_name::text);

\prompt 'Введите название схемы: \n' schema_name

SET myvars.table_name TO :'table_name';
SET myvars.schema_name TO :'schema_name';

DO
$$
    DECLARE
        r record;
        relid       oid;
        d_ord_pos   integer;
        d_col_name  text;
        d_col_type  text;
        d_col_cons  oid ARRAY;
        table_to_find name := current_setting('myvars.table_name')::text;
        schema_to_find name := current_setting('myvars.schema_name')::text;
        var_oid oid;
    BEGIN

        raise NOTICE '% % %', format('%*s', -5, 'NO.'), format('%*s', -20, 'Имя Столбца'), format('%*s', -20, 'Атрибуты');
        raise NOTICE '% % %', format('%*s', -5, '---'), format('%*s', -20, '-----------'), format('%*s', -20, '--------');
        for relid, d_ord_pos, d_col_name, d_col_type in select pc.oid, attnum, attname, format_type(atttypid, atttypmod)
                 from pg_attribute
                          join pg_catalog.pg_type pt on pg_attribute.atttypid = pt.oid
                          join pg_catalog.pg_class pc on pg_attribute.attrelid = pc.oid
                          join pg_catalog.pg_namespace pn on pc.relnamespace = pn.oid                  
                    where attnum > 0
                        and attrelid = table_to_find
                        and pn.nspname = schema_to_find

        loop
            raise NOTICE '% % %', format('%*s', -5, d_ord_pos), format('%*s', -20, d_col_name), format('%*s', -20, concat('Type: ', d_col_type));
            for d_col_cons in select array_agg(oid) from pg_catalog.pg_constraint
                where relid = conrelid
                    and conkey[1] = d_ord_pos
                    and contype = 'f'
            loop
                if d_col_cons IS NOT NULL THEN
                    foreach var_oid in array d_col_cons loop
                        raise NOTICE '% %', format('|%33s', 'Constr:'), format('%s', pg_get_constraintdef(var_oid));
                    end loop;
                END IF;
            end loop;
        end loop;

    END
$$;