
ALTER TABLE departments 
    DROP CONSTRAINT IF EXISTS departments_type_id_fk,
    ADD CONSTRAINT departments_type_id_fk
        FOREIGN KEY (type_id)
        REFERENCES department_types(id),
    DROP CONSTRAINT IF EXISTS departments_level_id_fk,
    ADD CONSTRAINT departments_level_id_fk
        FOREIGN KEY (level_id)
        REFERENCES department_levels(id);
    
ALTER TABLE users 
    DROP CONSTRAINT IF EXISTS users_role_department_id_fk,
    ADD CONSTRAINT users_role_department_id_fk
    FOREIGN KEY (role_department_id)
    REFERENCES departments(id);
    
ALTER TABLE plants
    DROP CONSTRAINT IF EXISTS plants_department_id_fk,
    ADD CONSTRAINT plants_department_id_fk
    FOREIGN KEY (department_id)
    REFERENCES departments(id); 

ALTER TABLE tanks
    DROP CONSTRAINT IF EXISTS tanks_plant_id_fk,
    ADD CONSTRAINT tanks_plant_id_fk
    FOREIGN KEY (plant_id)
    REFERENCES plants(id); 
    
ALTER TABLE business_plans
    DROP CONSTRAINT IF EXISTS business_plans_plant_id_fk,
    ADD CONSTRAINT business_plans_plant_id_fk
    FOREIGN KEY (plant_id)
    REFERENCES plants(id); 
    
ALTER TABLE two_hour_mining_reports
    DROP CONSTRAINT IF EXISTS two_hour_mining_reports_plant_id_fk,
    ADD CONSTRAINT two_hour_mining_reports_plant_id_fk
    FOREIGN KEY (plant_id)
    REFERENCES plants(id); 

ALTER TABLE daily_mining_reports
    DROP CONSTRAINT IF EXISTS daily_mining_plant_id_fk,
    ADD CONSTRAINT daily_mining_plant_id_fk
    FOREIGN KEY (plant_id)
    REFERENCES plants(id); 
    
ALTER TABLE water_drop_reports
    DROP CONSTRAINT IF EXISTS water_drop_reports_plant_id_fk,
    ADD CONSTRAINT water_drop_reports_plant_id_fk
    FOREIGN KEY (plant_id)
    REFERENCES plants(id); 
    
ALTER TABLE tanks_reports
    DROP CONSTRAINT IF EXISTS tanks_reports_tank_id_fk,
    ADD CONSTRAINT tanks_reports_tank_id_fk
    FOREIGN KEY (tank_id)
    REFERENCES tanks(id); 

ALTER TABLE monthly_reports
    DROP CONSTRAINT IF EXISTS monthly_reports_plant_id_fk,
    ADD CONSTRAINT monthly_reports_plant_id_fk
    FOREIGN KEY (plant_id)
    REFERENCES plants(id); 
