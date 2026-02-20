# Hospital Management Database Schema

A normalized relational database schema (1NF-3NF) designed for a hospital management system. Implemented in MySQL, this schema handles entities including patient records, appointments, emergency services, laboratory results, and dynamic pricing.

## Architecture and Design
* **Normalization:** Structured to prevent data anomalies and minimize redundancy.
* **Referential Integrity:** Enforced using foreign key constraints (`ON DELETE CASCADE`, `ON DELETE RESTRICT`, `SET NULL`) across 18 interconnected tables.
* **Performance Optimization:** Applied `INDEX` on high-traffic columns such as patient IDs, doctor IDs, and appointment dates.
* **Data Integrity:** Utilized strict data types (`ENUM`, `DECIMAL(10,2)`, `CHAR`) to optimize storage and maintain standard data formats.

* <img width="1065" height="1087" alt="image" src="https://github.com/user-attachments/assets/fc3cbc69-6dd6-4e40-9d58-d109f0f0cde0" />


## Core Entities
The schema consists of 18 tables. The primary entities include:
* `hastalar` & `doktorlar`
* `randevular` & `poliklinikler`
* `tahlil_sonuclari` & `recete_ogeleri`
* `fiyat_listesi` (Dynamic Pricing)

## Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/pakayca/hospital-management-database.git

2. Execute the schema.sql file in your MySQL environment to generate the database structure.
