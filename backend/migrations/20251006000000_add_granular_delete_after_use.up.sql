-- Change delete_after_use from boolean to jsonb to allow granular control
-- Old: delete_after_use: true deletes everything
-- New: delete_after_use: { args: true, logs: true, results: true } allows per-component control

ALTER TABLE script DROP COLUMN IF EXISTS delete_after_use;
ALTER TABLE script ADD COLUMN delete_after_use JSONB;
