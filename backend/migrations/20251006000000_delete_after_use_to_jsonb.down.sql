-- Add down migration script here
-- Convert delete_after_use from jsonb back to boolean
-- If any of the sub-options is true, the boolean will be true

ALTER TABLE script
  ALTER COLUMN delete_after_use TYPE boolean
  USING CASE
    WHEN delete_after_use IS NOT NULL AND (
      (delete_after_use->>'args')::boolean = true OR
      (delete_after_use->>'logs')::boolean = true OR
      (delete_after_use->>'results')::boolean = true
    ) THEN true
    ELSE NULL
  END;
