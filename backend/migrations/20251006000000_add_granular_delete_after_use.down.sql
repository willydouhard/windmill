-- Revert granular delete_after_use back to boolean

ALTER TABLE script DROP COLUMN IF EXISTS delete_after_use;
ALTER TABLE script ADD COLUMN delete_after_use BOOLEAN;
