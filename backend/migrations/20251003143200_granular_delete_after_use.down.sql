-- Add down migration script here
-- Convert back to boolean - if any of args, logs, or results is true, set delete_after_use to true

-- For script table
ALTER TABLE script ADD COLUMN delete_after_use_new boolean;
UPDATE script SET delete_after_use_new = true
WHERE delete_after_use IS NOT NULL
AND (
    (delete_after_use->>'args')::boolean = true
    OR (delete_after_use->>'logs')::boolean = true
    OR (delete_after_use->>'results')::boolean = true
);
ALTER TABLE script DROP COLUMN delete_after_use;
ALTER TABLE script RENAME COLUMN delete_after_use_new TO delete_after_use;
