--     5. Создать два сложных (многотабличных) запроса с использованием подзапросов.
--     6. Создать два сложных запроса с использованием объединения JOIN и без использования подзапросов.
--     7. Создать два представления, в основе которых лежат сложные запросы.  

-- Делаем 6 сложных запросов

-- 1. Иерархия подразделений
CREATE OR REPLACE VIEW departments_hierarchy AS (
    WITH RECURSIVE deps_rec(id,name,parent_id,level_id,type_id,full_path)  AS (
        SELECT d0.*,name::VARCHAR(200) AS full_path FROM departments d0 WHERE parent_id=0
        UNION
        SELECT d1.*,(deps_rec.full_path||' -> '||d1.name)::VARCHAR(200) FROM departments d1 JOIN deps_rec ON deps_rec.id=d1.parent_id
    )
    SELECT  
            dl.id as dep_level_id,dl.name as dep_level,
            d.id,d.name,d.full_path,
            dt.id as dep_type_id,dt.name as dep_type
        FROM deps_rec d
        LEFT JOIN department_levels dl
            ON d.level_id=dl.id
        LEFT JOIN department_types dt
            ON d.type_id=dt.id
);
SELECT * FROM departments_hierarchy;

-- 2. Вывести суточную сводку объектов добычи с группировкой по регионам и цехам добычи за 2 мая 2022г.
WITH regions AS (
    SELECT * FROM departments WHERE level_id=2
), deps as (
    SELECT  r.id as region_id,r.name as region_name,
            d.id as dep_id,d.name as dep_name
        FROM departments d
        JOIN regions r ON d.parent_id=r.id
    WHERE d.level_id=3 AND d.type_id=1
), mining_plants AS (
    SELECT d.*,p.id as plant_id,p.name as plant_name
        FROM deps d JOIN plants p ON d.dep_id=p.department_id
)
SELECT *
    FROM mining_plants mp
    LEFT JOIN daily_mining_reports dmr
        ON mp.plant_id=dmr.plant_id
    WHERE dmr.cdate='2022-05-02'
    ORDER BY region_id,dep_id;



-- 3.Для каждого резервуара цехов подготовки нефти проверить наличие двухчасовок за 2 мая 2022г
WITH
tanks_full AS (
    SELECT d.id as dep_id,d.name as dep_name,p.id as plant_id,p.name as plants_name,t.id as tank_id,t.name as tank_name 
    FROM departments d
        JOIN plants p ON d.id=p.department_id
        JOIN tanks t on p.id=t.plant_id
    WHERE d.type_id=2
    )
SELECT  
            tanks_full.*, 
            array_agg(ctime) OVER(PARTITION BY tanks_full.tank_id) AS times_array,
            count(ctime) OVER(PARTITION BY tanks_full.tank_id) AS times_count
        FROM tanks_full
            LEFT JOIN tanks_reports tr
            ON tanks_full.tank_id=tr.tank_id
        WHERE tr.cdate='2022-05-02' OR tr.cdate IS null
    
-- 4.Показать объекты с неисполнением бизнес-плана по добыче нефтиза май

CREATE Or REPLACE VIEW BP_exec AS ( 
SELECT bp.plant_id, p.name as plant_name, bp.cdate, bp.oil_mining as oil_plan, coalesce(dmr.oil,0) as oil_fact, coalesce(dmr.oil,0) - bp.oil_mining AS diff,dh.*
    FROM business_plans bp
    LEFT JOIN daily_mining_reports dmr
        ON bp.plant_id=dmr.plant_id AND bp.cdate=dmr.cdate
    JOIN plants p
        ON p.id=bp.plant_id
    JOIN departments_hierarchy dh
        ON dh.id=p.department_id
    WHERE  coalesce(dmr.oil,0) < bp.oil_mining
    ORDER BY bp.plant_id,bp.cdate
);
SELECT * FROM BP_exec WHERE EXTRACT(MONTH FROM cdate)=5;    

--5. Показать id объектов, которые есть в отчете по закачке воды, но нет в ежедневном отчете по добыче и закачке
-- (т.е. показать закачку по цехам, не являющимися добывающими) за май

SELECT * FROM water_drop_reports wdp
    WHERE wdp.plant_id NOT IN (
        SELECT DISTINCT plant_id
            FROM daily_mining_reports
        WHERE EXTRACT(MONTH FROM cdate)=5
        GROUP BY plant_id
    )
    ORDER BY cdate;
    
--6. Показать доступы пользователей объекта УПСВ-6
SELECT id,email,role_is_write FROM users 
    WHERE users.role_department_id =
    (SELECT id FROM departments
        WHERE id=(
            SELECT department_id FROM plants
                WHERE name='УПСВ-6'
        )
    );
