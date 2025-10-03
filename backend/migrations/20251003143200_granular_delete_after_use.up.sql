-- Add up migration script here
-- Convert delete_after_use from boolean to jsonb to support granular deletion options
-- The jsonb structure will be: {"args": true, "logs": true, "results": true}
-- For backward compatibility, existing boolean true values will be converted to all three enabled
-- Existing boolean false or null values will remain as null

-- For script table
ALTER TABLE script ADD COLUMN delete_after_use_new jsonb;
UPDATE script SET delete_after_use_new = '{"args": true, "logs": true, "results": true}'::jsonb WHERE delete_after_use = true;
ALTER TABLE script DROP COLUMN delete_after_use;
ALTER TABLE script RENAME COLUMN delete_after_use_new TO delete_after_use;
