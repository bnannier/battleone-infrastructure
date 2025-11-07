-- Create datadog monitoring user
CREATE USER datadog WITH PASSWORD 'secure_datadog_monitor_2023';

-- Grant necessary permissions for monitoring
GRANT pg_monitor TO datadog;
GRANT SELECT ON pg_stat_database TO datadog;
GRANT SELECT ON pg_stat_user_tables TO datadog;
GRANT SELECT ON pg_stat_user_indexes TO datadog;
GRANT SELECT ON pg_statio_user_tables TO datadog;
GRANT SELECT ON pg_statio_user_indexes TO datadog;

-- For collecting custom metrics
GRANT CONNECT ON DATABASE battleone TO datadog;

-- Additional permissions for comprehensive monitoring
GRANT SELECT ON information_schema.tables TO datadog;
GRANT SELECT ON information_schema.columns TO datadog;