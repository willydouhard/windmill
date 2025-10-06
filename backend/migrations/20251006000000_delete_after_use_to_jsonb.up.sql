-- Add up migration script here
-- Convert delete_after_use from boolean to jsonb to support granular deletion options
-- For backward compatibility, true becomes {"args": true, "logs": true, "results": true}
-- and false/null stays as null

-- For script table
ALTER TABLE script
  ALTER COLUMN delete_after_use TYPE jsonb
  USING CASE
    WHEN delete_after_use = true THEN '{"args": true, "logs": true, "results": true}'::jsonb
    ELSE NULL
  END;

-- Note: FlowModule.delete_after_use is stored in the flow.value JSONB column,
-- so no schema migration is needed. The Rust types and worker logic will handle
-- the conversion during serialization/deserialization.
