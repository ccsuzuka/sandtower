SELECT
    C.relname, A.attname 字段,
    concat_ws (
        '',
        T.typname,
        SUBSTRING (
            format_type (A.atttypid, A.atttypmod)
            FROM
                '\(.*\)'
        )
    ) AS 类型,
        case when s.pk is not null then '是'
                               else '否'
    end as 主键,
    case A.attnotnull when 'f' then '是'
                      when 't' then '否'
    end as 空,
    d.description 注释
FROM pg_attribute A
INNER JOIN pg_class C on A .attrelid = C .oid
INNER JOIN pg_type T on A .atttypid = T .oid
LEFT JOIN (SELECT conrelid, unnest(conkey) as pk
                        FROM pg_constraint
                        WHERE contype = 'p') S ON S.conrelid = C .oid
                                   AND A.attnum = S.pk
LEFT JOIN pg_description d on d.objoid = A.attrelid AND d.objsubid = A.attnum
LEFT JOIN pg_namespace n on n.oid = c.relnamespace     
WHERE A.attnum > 0 
AND n.nspname = 'public' 
and c.relname not like 'idx%' 
and c.relname not like 'pk%'
and c.relname not like 'unq%'
and c.relname not like 'shed%'
ORDER BY 
    C .relname, A .attnum
