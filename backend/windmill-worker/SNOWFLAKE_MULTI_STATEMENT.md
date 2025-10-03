# Snowflake Multi-Statement Session Reuse

## Overview

Snowflake scripts now support session state persistence across multiple statements within a single script execution. This enables the use of:
- Temporary tables
- Session variables
- Transaction blocks (when needed)
- Other session-scoped objects

## How It Works

When a Snowflake script contains multiple statements (separated by semicolons), the executor:

1. **Detects multiple statements** using `parse_sql_blocks()`
2. **Processes parameters** - Interpolates all parameters into the SQL since Snowflake's multi-statement API doesn't support variable binding
3. **Submits as single request** - Concatenates all statements and submits them to Snowflake's multi-statement API endpoint with `MULTI_STATEMENT_COUNT` parameter
4. **Maintains session state** - All statements execute in the same Snowflake session, preserving temp tables, variables, etc.
5. **Retrieves results** - Fetches results for each statement using their individual statement handles

## Example Usage

### Temporary Tables

```sql
-- Create a temporary table
CREATE TEMPORARY TABLE temp_results AS
SELECT id, name, amount
FROM transactions
WHERE date >= CURRENT_DATE() - 7;

-- Use the temporary table in subsequent queries
SELECT name, SUM(amount) as total
FROM temp_results
GROUP BY name
ORDER BY total DESC;
```

### Session Variables

```sql
-- Set session variables
SET max_amount = 1000;
SET date_threshold = DATEADD(day, -30, CURRENT_DATE());

-- Use variables in queries
SELECT *
FROM orders
WHERE amount < $max_amount
  AND order_date >= $date_threshold;
```

### Complex Multi-Step Processing

```sql
-- Step 1: Create temp table with filtered data
CREATE TEMPORARY TABLE filtered_orders AS
SELECT order_id, customer_id, order_date, amount
FROM orders
WHERE status = 'completed'
  AND order_date >= DATEADD(month, -3, CURRENT_DATE());

-- Step 2: Enrich with customer data
CREATE TEMPORARY TABLE enriched_orders AS
SELECT
    o.order_id,
    o.order_date,
    o.amount,
    c.customer_name,
    c.customer_tier
FROM filtered_orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- Step 3: Final aggregation and return results
SELECT
    customer_tier,
    COUNT(*) as order_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount
FROM enriched_orders
GROUP BY customer_tier
ORDER BY total_amount DESC;
```

## Implementation Details

### Single Statement (Original Behavior)
- Uses parameter bindings via Snowflake API's `bindings` field
- Executes as a single API call
- Supports all Snowflake data types

### Multiple Statements (New Behavior)
- Parameters are interpolated directly into SQL (no bindings support in multi-statement API)
- All statements concatenated with semicolons
- Single API POST request with `MULTI_STATEMENT_COUNT`
- Results retrieved via GET requests to individual statement handles
- Session state preserved across all statements

### Limitations

1. **No Parameter Binding**: Snowflake's multi-statement API doesn't support the `bindings` parameter, so parameters are interpolated into the SQL text
2. **10,000 Row Limit**: Standard limit applies unless S3 streaming is configured
3. **Sequential Execution**: Statements execute in order; if one fails, subsequent statements are not executed

## API Reference

The implementation uses Snowflake's SQL API:
- **POST** `https://{account}.snowflakecomputing.com/api/v2/statements/`
  - Body includes `statement` (concatenated SQL) and `parameters.MULTI_STATEMENT_COUNT`
- **GET** `https://{account}.snowflakecomputing.com/api/v2/statements/{statementHandle}`
  - Retrieves results for individual statements

## Benefits

1. **Simplified ETL**: No need to split complex transformations into multiple scripts
2. **Better Performance**: Reduces overhead of multiple script executions
3. **Cleaner Code**: Related operations can stay in one script
4. **Session Context**: Leverage Snowflake's session features fully
