USE gov_contracts;

SELECT * FROM contracts
LIMIT 30;

## KPIS
SELECT COUNT(*) AS total_contracts,
ROUND(SUM(total_dollars_obligated)/1000000000, 2) AS total_obligated_billions,
COUNT(DISTINCT r.recipient_uei) AS unique_recipients,
COUNT(DISTINCT a.awarding_agency_name) AS unique_agencies
FROM contracts c
JOIN agencies a ON c.agency_id = a.agency_id
JOIN recipients r ON c.recipient_id = r.recipient_id;


## SPENDING BY AGENCY
SELECT a.awarding_agency_name, COUNT(c.contract_id) AS total_contracts,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total_obligated_billions
FROM contracts c
JOIN  agencies a ON c.agency_id = a.agency_id
GROUP BY a.awarding_agency_name
ORDER BY total_obligated_billions DESC;


## AVG. CONTRACT VALUE BY AGENCY
SELECT a.awarding_agency_name AS Agency,
COUNT(c.contract_id) AS total_contracts,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total_obligated_billions,
ROUND(AVG(federal_action_obligation)/1000000,2) AS avg_contract_millions
FROM contracts c
JOIN agencies a ON c.agency_id = a.agency_id
GROUP BY a.awarding_agency_name;


## COMPETED VS NOT COMPETED BY AGENCY
SELECT a.awarding_agency_name AS agency,
COUNT(contract_id) AS total_contracts,
CASE
WHEN extent_competed IN('FULL AND OPEN COMPETITION AFTER EXCLUSION OF SOURCES', 
'FULL AND OPEN COMPETITION', 'COMPETED UNDER SAP', 'FOLLOW ON TO COMPETED ACTION') 
THEN 'COMPETED'
WHEN extent_competed IN ('NOT COMPETED UNDER SAP', 'NOT COMPETED', 'NOT AVAILABLE FOR COMPETITION')
THEN 'NOT COMPETED'
ELSE 'UNKNOWN'
END AS competition_status,
ROUND(SUM(federal_action_obligation)/1000000000,2) AS obligated_billions
FROM contracts c
JOIN agencies a ON c.agency_id = a.agency_id
WHERE c.extent_competed IS NOT NULL
GROUP BY a.awarding_agency_name, competition_status
ORDER BY a.awarding_agency_name, obligated_billions DESC;


## RECIPIENT TOTAL & AVG. CONTRACT VALUE
SELECT r.recipient_name, COUNT(c.contract_id) AS total_contracts,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total_billions,
ROUND(AVG(federal_action_obligation)/1000000,2) AS average_millions_contract
FROM contracts c
JOIN recipients r ON c.recipient_id = r.recipient_id
GROUP BY r.recipient_name
ORDER BY total_billions DESC;


SELECT * FROM contracts LIMIT 5;

SET SESSION wait_timeout = 600;
SET SESSION interactive_timeout = 600;
SET SESSION net_read_timeout = 600;
SET SESSION net_write_timeout = 600;

CREATE INDEX idx_performance_location 
ON contracts(performance_location_id);


ALTER TABLE contracts
ADD COLUMN performance_state VARCHAR(100);

UPDATE contracts c
JOIN locations l ON c.performance_location_id = l.location_id
SET c.performance_state = l.state_name
WHERE l.location_type = 'performance';

SELECT * FROM contracts LIMIT 10;


## TOTAL CONTRACT VALUES BY TOP 15 STATE
SELECT performance_state,
ROUND(SUM(federal_action_obligation)/1000000000,2) AS total_billions
FROM contracts 
WHERE performance_state IS NOT NULL
GROUP BY performance_state
ORDER BY total_billions DESC
LIMIT 15;


## TOTAL CONTRACT VALUES OF TOP 20 INDUSTRIES
SELECT naics_code,
naics_description,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total_billions
FROM contracts
GROUP BY naics_code, naics_description
ORDER BY total_billions DESC
LIMIT 20;

## MONTHLY SPENDING FROM FEB TO JUNE 2026
SELECT DATE_FORMAT(action_date, '%Y-%m') AS month,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total_billions
FROM contracts
GROUP BY month
ORDER BY month;

## OVERALL COMPETED VS NOT COMPETED
SELECT COUNT(contract_id) AS total_contracts, 
CASE
WHEN extent_competed IN('FULL AND OPEN COMPETITION AFTER EXCLUSION OF SOURCES', 
'FULL AND OPEN COMPETITION', 'COMPETED UNDER SAP', 'FOLLOW ON TO COMPETED ACTION') 
THEN 'COMPETED'
WHEN extent_competed IN ('NOT COMPETED UNDER SAP', 'NOT COMPETED', 'NOT AVAILABLE FOR COMPETITION')
THEN 'NOT COMPETED'
ELSE 'UNKNOWN'
END AS competition_status,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total_billions
FROM contracts
WHERE extent_competed IS NOT NULL
GROUP BY competition_status
ORDER BY total_billions DESC;

## TOP 10 NON-COMPETED
SELECT r.recipient_name,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total_billions
FROM contracts c
JOIN recipients r ON c.recipient_id = r.recipient_id
WHERE extent_competed IN ('NOT COMPETED UNDER SAP', 'NOT COMPETED', 'NOT AVAILABLE FOR COMPETITION')
GROUP BY r.recipient_name
ORDER BY total_billions DESC
LIMIT 10;

SELECT 
    ROUND(SUM(federal_action_obligation) / 1000000000, 4) AS billions
FROM contracts c
JOIN recipients r ON c.recipient_id = r.recipient_id
WHERE r.recipient_name = 'LOCKHEED MARTIN CORPORATION'
AND extent_competed IN (
    'NOT COMPETED',
    'NOT COMPETED UNDER SAP',
    'NOT AVAILABLE FOR COMPETITION'
);


SELECT 
r.recipient_name,
COUNT(c.contract_id) AS total_contracts,
ROUND(SUM(c.federal_action_obligation) / 1000000000, 2) AS obligated_billions,
ROUND(SUM(c.federal_action_obligation) * 100 / 
        (SELECT SUM(federal_action_obligation) FROM contracts), 2) AS pct_of_total
FROM contracts c
JOIN recipients r ON c.recipient_id = r.recipient_id
GROUP BY r.recipient_name
ORDER BY obligated_billions DESC
LIMIT 10;


SELECT l.state_name,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total_billions
FROM contracts c
JOIN locations l ON c.performance_location_id = l.location_id
WHERE l.state_name IS NOT NULL
GROUP BY l.state_name
ORDER BY total_billions DESC
LIMIT 10;

DESCRIBE contracts;

SELECT a.awarding_agency_name,
c.performance_state,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total
FROM contracts c
JOIN agencies a ON c.agency_id = a.agency_id
WHERE c.performance_state IS NOT NULL
GROUP BY a.awarding_agency_name, c.performance_state
ORDER BY total DESC
LIMIT 10;

SELECT DISTINCT(extent_competed) FROM contracts;

SELECT naics_description,
    CASE 
        WHEN extent_competed IN (
            'FULL AND OPEN COMPETITION',
            'FULL AND OPEN COMPETITION AFTER EXCLUSION OF SOURCES',
            'COMPETED UNDER SAP',
            'FOLLOW ON TO COMPETED ACTION') THEN 'Competed'
        WHEN extent_competed IN (
            'NOT COMPETED UNDER SAP',
            'NOT COMPETED',
            'NOT AVAILABLE FOR COMPETITION') THEN 'Not Competed'
        ELSE 'Unknown'
    END AS competition_status,
    ROUND(SUM(federal_action_obligation) / 1000000000, 2) AS obligated_billions
FROM contracts
WHERE naics_description IS NOT NULL
AND extent_competed IS NOT NULL
GROUP BY naics_description, competition_status
ORDER BY obligated_billions DESC
LIMIT 10;


SELECT c.performance_state,
COUNT(c.contract_id),
a.awarding_agency_name,
ROUND(SUM(c.federal_action_obligation)/1000000000, 2) AS total
FROM contracts c
JOIN agencies a ON c.agency_id = a.agency_id
WHERE performance_state IS NOT NULL
GROUP BY c.performance_state, a.awarding_agency_name
ORDER BY c.performance_state, total DESC;

SELECT performance_state,
ROUND(SUM(federal_action_obligation) / 1000000000, 2) AS obligated_billions,
ROUND(SUM(federal_action_obligation) * 100 / 
        (SELECT SUM(federal_action_obligation) 
         FROM contracts 
         WHERE performance_state IS NOT NULL), 1) AS percent
FROM contracts
WHERE performance_state IS NOT NULL
GROUP BY performance_state
ORDER BY obligated_billions DESC
LIMIT 3;

## TOP3 vs other states
SELECT
CASE
	WHEN performance_state IN ('TEXAS', 'VIRGINIA', 'CALIFORNIA') THEN 'TOP 3'
    ELSE 'OTHER STATES'
END AS states,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total,
ROUND(SUM(federal_action_obligation) * 100 / 
			(SELECT SUM(federal_action_obligation) FROM contracts
					WHERE performance_state IS NOT NULL), 1) as percent 
FROM contracts
WHERE performance_state IS NOT NULL
GROUP BY states;


SELECT a.awarding_agency_name,
CASE
	WHEN c.performance_state IN ('TEXAS', 'VIRGINIA', 'CALIFORNIA') THEN 'TOP 3'
    ELSE 'OTHER STATES'
END AS states,
ROUND(SUM(c.federal_action_obligation)/1000000000, 2) AS total,
ROUND(SUM(c.federal_action_obligation) * 100 / 
			SUM(SUM(c.federal_action_obligation)) OVER 
            (PARTITION BY a.awarding_agency_name), 1) AS percent
FROM contracts c
JOIN agencies a ON c.agency_id = a.agency_id
WHERE performance_state IS NOT NULL
GROUP BY awarding_agency_name, states
ORDER BY awarding_agency_name, total DESC;

SELECT a.awarding_agency_name,
c.performance_state,
ROUND(SUM(c.federal_action_obligation)/1000000000, 2) AS total,
ROUND(SUM(federal_action_obligation) * 100/
			SUM(SUM(c.federal_action_obligation)) OVER
            (PARTITION BY a.awarding_agency_name), 1) AS percent
FROM contracts c
JOIN agencies a ON c.agency_id = a.agency_id
WHERE a.awarding_agency_name = 'Department of Homeland Security' AND
		c.performance_state IN('TEXAS', 'CALIFORNIA')
GROUP BY c.performance_state;


SELECT a.awarding_agency_name,
c.performance_state,
ROUND(SUM(c.federal_action_obligation)/1000000000, 2) AS total,
ROUND(SUM(federal_action_obligation) * 100/
			SUM(SUM(c.federal_action_obligation)) OVER
            (PARTITION BY a.awarding_agency_name), 1) AS percent
FROM contracts c
JOIN agencies a ON c.agency_id = a.agency_id
WHERE a.awarding_agency_name = 'Department of Veterans Affairs' AND
		c.performance_state = 'VIRGINIA'
GROUP BY c.performance_state;


SELECT
CASE 
	WHEN performance_state IN ('TEXAS','VIRGINIA','CALIFORNIA','FLORIDA') 
	THEN 'Top 4 States'
	ELSE 'Other 46 States'
END AS state_group,
ROUND(SUM(federal_action_obligation) / 1000000000, 2) AS obligated_billions,
ROUND(SUM(federal_action_obligation) * 100 /
        (SELECT SUM(federal_action_obligation) FROM contracts 
         WHERE performance_state IS NOT NULL), 1) AS pct_of_total
FROM contracts
WHERE performance_state IS NOT NULL
GROUP BY state_group;


## Agency vs Industry
SELECT a.awarding_agency_name,
c.naics_description,
ROUND(SUM(federal_action_obligation)/1000000000, 2) AS total
FROM contracts c
JOIN agencies a ON c.agency_id = a.agency_id
WHERE c.naics_description IS NOT NULL
GROUP BY a.awarding_agency_name, c.naics_description
ORDER BY total DESC
LIMIT 20;


SELECT DISTINCT(extent_competed) FROM contracts;


SELECT 
naics_description,
CASE
	WHEN extent_competed IN ('FULL AND OPEN COMPETITION',
            'FULL AND OPEN COMPETITION AFTER EXCLUSION OF SOURCES',
            'COMPETED UNDER SAP',
            'FOLLOW ON TO COMPETED ACTION') THEN 'COMPETED'
	WHEN extent_competed IN ('NOT COMPETED UNDER SAP', 
    'NOT COMPETED', 'NOT AVAILABLE FOR COMPETITION') THEN 'NOT COMPETED'
    ELSE 'UNKNOWN'
END AS competition_status,
ROUND(SUM(federal_action_obligation)/1000000000, 2) as total
FROM contracts
WHERE naics_description IS NOT NULL
GROUP BY naics_description, competition_status
ORDER BY total DESC;


SELECT 
    naics_description,
    recipient_name,
    total,
    percent
FROM (
    SELECT
        c.naics_description,
        r.recipient_name,
        ROUND(SUM(c.federal_action_obligation) / 1000000000, 2) AS total,
        ROUND(SUM(c.federal_action_obligation) * 100 /
            SUM(SUM(c.federal_action_obligation)) OVER 
            (PARTITION BY c.naics_description), 1) AS percent,
        ROW_NUMBER() OVER (PARTITION BY c.naics_description 
            ORDER BY SUM(c.federal_action_obligation) DESC) AS rn
    FROM contracts c
    JOIN recipients r ON c.recipient_id = r.recipient_id
    WHERE c.naics_description IS NOT NULL
    GROUP BY c.naics_description, r.recipient_name
) ranked
WHERE rn = 1
ORDER BY total DESC
LIMIT 30;

SELECT DISTINCT extent_competed, 
COUNT(*) as cnt
FROM contracts
WHERE naics_description = 'GUIDED MISSILE AND SPACE VEHICLE MANUFACTURING'
GROUP BY extent_competed;







