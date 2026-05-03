#!/bin/bash
set -e

# Wait for SQL Server to be ready
echo "Testing SQL Server connection..."

# Simple connectivity test
docker exec sqlserver bash -c 'sleep 2 && /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "BigData2026!" -Q "SELECT 1"' && echo "✓ Connection successful" || echo "✗ Connection failed"
