-- 8. Создать пользовательскую функцию.
-- 9. Создать триггер.   

-- 8. Cоздаем пользовательскую функцию, которая на введеную дату по введеному региону добычи
-- возвращает суточную добычу и исполнение бизнес-плана

CREATE OR REPLACE FUNCTION day_result (idate DATE, region_id INTEGER)
RETURNS REAL[] AS
$$
DECLARE
    fact REAL;
    plan REAL;
BEGIN
    fact = (
        SELECT SUM(oil) 
            FROM daily_mining_reports dmr
                JOIN plants p ON dmr.plant_id=p.id
                JOIN departments d ON p.department_id=d.id
            WHERE dmr.cdate=idate AND d.type_id=1 AND d.parent_id=region_id
        );
      plan = (
        SELECT SUM(oil_mining) 
            FROM business_plans bp
                JOIN plants p ON bp.plant_id=p.id
                JOIN departments d ON p.department_id=d.id
            WHERE bp.cdate='2022-05-03' AND d.type_id=1 AND d.parent_id=4
        );
      RETURN ARRAY[fact,plan,fact-plan];
END
$$
LANGUAGE PLPGSQL;

SELECT day_result ('2022-05-05',4);


-- 9. При вставке данных в двухчасовой отчет по добыче проверить наличие данных за предыдущее время,
-- не давать создавать новую строку с текущим временем

CREATE OR REPLACE FUNCTION insert_two_hours ()
RETURNS TRIGGER AS 
$$
DECLARE
    is_found BOOLEAN;
    arr_times CTIMES[];
    prev_time CTIMES;
BEGIN
    arr_times = enum_range(null,(NEW.ctime::CTIMES));
    prev_time = arr_times[array_upper(arr_times,1)-1];
    IF EXISTS (SELECT * FROM two_hour_mining_reports t
                 WHERE t.cdate=NEW.cdate AND t.plant_id=NEW.plant_id AND t.ctime=NEW.ctime)
    THEN 
        RAISE EXCEPTION 'На % данные уже существуют. Выполните update',NEW.ctime;
    END IF;
    IF NEW.CTIME = '02:00'::CTIMES THEN
        RETURN NEW;
    END IF;
    IF NOT EXISTS (SELECT * FROM two_hour_mining_reports t
                        WHERE t.cdate=NEW.cdate AND t.plant_id=NEW.plant_id AND t.ctime=prev_time)
    THEN
        RAISE EXCEPTION 'Вы не ввели данные за %',prev_time;
    END IF;
    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_two_hour_mining_prev_data 
    BEFORE INSERT ON two_hour_mining_reports
    FOR EACH ROW 
    EXECUTE FUNCTION insert_two_hours();
                 
INSERT INTO two_hour_mining_reports (cdate,ctime,plant_id,liquid,oil) 
    VALUES ('2022-05-29','00:00',184,10,5);
    
    