-- Add down migration script here
-- Revert delete_after_use from JSONB back to BOOLEAN
-- Any JSONB value with any field set to true will become true, otherwise false

-- For script table
ALTER TABLE script ALTER COLUMN delete_after_use TYPE BOOLEAN USING
  CASE
    WHEN delete_after_use IS NULL THEN NULL
    WHEN jsonb_typeof(delete_after_use) = 'object' THEN
      COALESCE(
        (delete_after_use->>'args')::boolean OR
        (delete_after_use->>'logs')::boolean OR
        (delete_after_use->>'results')::boolean,
        false
      )
    ELSE false
  END;
