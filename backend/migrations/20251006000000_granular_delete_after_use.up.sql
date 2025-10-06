-- Add up migration script here
-- Change delete_after_use from BOOLEAN to JSONB for granular control
-- The JSONB structure: {"args": true, "logs": true, "results": true}
-- For backward compatibility:
--   - null/false: no deletion
--   - true (boolean): delete all (args, logs, results)
--   - JSONB object: granular control

-- For script table
ALTER TABLE script ALTER COLUMN delete_after_use TYPE JSONB USING
  CASE
    WHEN delete_after_use IS NULL THEN NULL
    WHEN delete_after_use = true THEN '{"args": true, "logs": true, "results": true}'::jsonb
    WHEN delete_after_use = false THEN NULL
  END;
