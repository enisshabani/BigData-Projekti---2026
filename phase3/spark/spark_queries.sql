-- Query 1: adapted from the Phase 2 XPath logic for CO2 values.
SELECT country_name, year, co2_per_capita
FROM executive_summary
WHERE year = 2024
ORDER BY co2_per_capita DESC;

-- Query 2: adapted from the Phase 2 XQuery logic for renewable energy leaders.
SELECT country_name, year, renewable_share
FROM executive_summary
WHERE renewable_share >= 50
ORDER BY renewable_share DESC;