# Automated IS 456 Structural Compliance Database 🏗️📊

## Overview
This project bridges Civil Engineering with Data Automation. It is a relational MySQL database designed to store Reinforced Cement Concrete (RCC) structural member data and automatically audit the designs against IS 456 minimum standards.

## Key Features
* **Automated Parameter Calculation:** Utilizes MySQL Triggers to dynamically calculate the effective depth ($d$) of a beam. It features custom logic to adjust the centroid and spacer bar dimensions if site congestion requires a two-layer reinforcement setup.
* **IS 456 Code Integration:** A reference table stores nominal cover minimums based on exposure conditions (e.g., Moderate Exposure = 30mm).
* **Automated Auditing:** Whenever a new beam is inserted into the database, a Trigger automatically compares the provided clear cover against the IS 456 reference table and logs a 'PASS' or 'FAIL' status in a dedicated audit table without any manual input.

## Technologies Used
* Relational Database Design (RDBMS)
* MySQL (DDL, DML, Triggers, Stored Procedures)
