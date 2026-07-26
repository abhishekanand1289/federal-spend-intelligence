CREATE DATABASE gov_contracts;

USE gov_contracts;

CREATE TABLE agencies(
	agency_id INT auto_increment PRIMARY KEY,
    awarding_agency_name VARCHAR(255),
    awarding_sub_agency_name VARCHAR(255),
    funding_agency_name VARCHAR(255)
);


CREATE TABLE recipients (
    recipient_id INT AUTO_INCREMENT PRIMARY KEY,
    recipient_uei VARCHAR(50),
    recipient_name VARCHAR(255),
    recipient_city_name VARCHAR(100),
    recipient_state_name VARCHAR(100),
    recipient_country_name VARCHAR(100),
    veteran_owned_business VARCHAR(10),
    woman_owned_business VARCHAR(10),
    minority_owned_business VARCHAR(10),
    small_disadvantaged_business VARCHAR(10)
);

create table locations(
	location_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100),
    state_name VARCHAR(100),
    country_name VARCHAR(100),
    location_type VARCHAR(50)
);


create table contracts(
	contract_id INT AUTO_INCREMENT PRIMARY KEY,
	contract_award_unique_key VARCHAR(255),
    award_id_piid VARCHAR(100),
    federal_action_obligation DECIMAL(20,2),
    total_dollars_obligated DECIMAL(20,2),
    action_date DATE,
    action_date_fiscal_year INT,
    period_of_performance_start_date DATE,
    period_of_performance_current_end_date DATE,
    transaction_description TEXT,
    award_type VARCHAR(100),
    type_of_contract_pricing VARCHAR(100),
    extent_competed VARCHAR(100),
    number_of_offers_received INT,
    agency_id INT,
    recipient_id INT,
    recipient_location_id INT,
    performance_location_id INT,
    naics_code INT,
    naics_description VARCHAR(255),
    product_or_service_code VARCHAR(25),
    product_or_service_code_description VARCHAR(255),
    FOREIGN KEY (agency_id) REFERENCES agencies(agency_id),
    FOREIGN KEY (recipient_id) REFERENCES recipients(recipient_id),
    FOREIGN KEY (recipient_location_id) REFERENCES locations(location_id),
    FOREIGN KEY (performance_location_id) REFERENCES locations(location_id)
)

