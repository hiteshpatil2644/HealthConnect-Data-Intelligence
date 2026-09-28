USE dev_HealthConnect_refined;
GO

/* =========================================================
   STEP 37
   VERIFY REFINED DATA MODEL
   ========================================================= */


/* =========================================================
   PART 1 — REFINED TABLES + COLUMNS
   ========================================================= */

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'refined_dw'
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;
GO


/* =========================================================
   PART 2 — FOREIGN KEY RELATIONSHIPS
   ========================================================= */

SELECT
    fk.name AS Foreign_Key_Name,
    OBJECT_SCHEMA_NAME(fkc.parent_object_id) AS Child_Schema,
    OBJECT_NAME(fkc.parent_object_id) AS Child_Table,
    COL_NAME(
        fkc.parent_object_id,
        fkc.parent_column_id
    ) AS Child_Column,
    OBJECT_SCHEMA_NAME(fkc.referenced_object_id) AS Parent_Schema,
    OBJECT_NAME(fkc.referenced_object_id) AS Parent_Table,
    COL_NAME(
        fkc.referenced_object_id,
        fkc.referenced_column_id
    ) AS Parent_Column
FROM sys.foreign_key_columns AS fkc
INNER JOIN sys.foreign_keys AS fk
    ON fkc.constraint_object_id = fk.object_id
WHERE OBJECT_SCHEMA_NAME(fkc.parent_object_id) = 'refined_dw'
ORDER BY
    Child_Table,
    Foreign_Key_Name;
GO


/* =========================================================
   PART 3 — REFINED TABLE ROW COUNTS
   ========================================================= */

SELECT
    'refined_patients' AS Table_Name,
    COUNT(*) AS Row_Count
FROM refined_dw.refined_patients

UNION ALL

SELECT
    'refined_providers',
    COUNT(*)
FROM refined_dw.refined_providers

UNION ALL

SELECT
    'refined_payers',
    COUNT(*)
FROM refined_dw.refined_payers

UNION ALL

SELECT
    'refined_encounters',
    COUNT(*)
FROM refined_dw.refined_encounters

UNION ALL

SELECT
    'refined_diagnoses',
    COUNT(*)
FROM refined_dw.refined_diagnoses

UNION ALL

SELECT
    'refined_procedures',
    COUNT(*)
FROM refined_dw.refined_procedures

UNION ALL

SELECT
    'refined_medications',
    COUNT(*)
FROM refined_dw.refined_medications

UNION ALL

SELECT
    'refined_claims',
    COUNT(*)
FROM refined_dw.refined_claims;
GO