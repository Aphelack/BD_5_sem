-- =============================================================================
-- Лабораторная работа №5: Триггеры и Хранимые процедуры
-- =============================================================================

-- 1. Хранимая функция: Расчет рейтинга пользователя
-- Функция вычисляет средний рейтинг всех объектов, принадлежащих пользователю.
-- Возвращает 0, если у пользователя нет объектов или отзывов.

CREATE OR REPLACE FUNCTION homeflip.calculate_user_rating(p_user_id uuid)
RETURNS numeric AS $$
DECLARE
    v_avg_rating numeric;
BEGIN
    SELECT AVG(r.rating)
    INTO v_avg_rating
    FROM homeflip.accommodations a
    JOIN homeflip.reviews_on_accommodations r ON a.id = r.accommodation_id
    WHERE a.owner_id = p_user_id;

    RETURN COALESCE(v_avg_rating, 0);
END;
$$ LANGUAGE plpgsql;

-- Пример вызова:
-- SELECT email, homeflip.calculate_user_rating(id) as rating FROM homeflip.users LIMIT 5;


-- 2. Хранимая процедура: Создание предложения обмена (Booking)
-- Процедура проверяет доступность дат и создает запись в exchange_offers.
-- Если даты заняты, выбрасывает исключение.

CREATE OR REPLACE PROCEDURE homeflip.create_exchange_offer(
    p_from_user_id uuid,
    p_target_accommodation_id uuid,
    p_start_date timestamptz,
    p_end_date timestamptz
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status_id uuid;
BEGIN
    -- Проверка валидности дат
    IF p_start_date >= p_end_date THEN
        RAISE EXCEPTION 'Start date must be before end date';
    END IF;

    -- Проверка на пересечение с существующими подтвержденными обменами
    -- (В реальном проекте это может дублировать EXCLUDE constraint, но здесь для примера логики)
    IF EXISTS (
        SELECT 1 FROM homeflip.exchange_offers eo
        JOIN homeflip.exchange_offer_statuses s ON eo.status_id = s.id
        WHERE eo.target_accommodation_id = p_target_accommodation_id
          AND s.code IN ('accepted', 'completed')
          AND (eo.start_date, eo.end_date) OVERLAPS (p_start_date, p_end_date)
    ) THEN
        RAISE EXCEPTION 'Accommodation is already booked for these dates';
    END IF;

    -- Получение ID статуса 'pending'
    SELECT id INTO v_status_id FROM homeflip.exchange_offer_statuses WHERE code = 'pending';

    -- Создание предложения
    INSERT INTO homeflip.exchange_offers (
        from_user_id, target_accommodation_id, start_date, end_date, status_id
    ) VALUES (
        p_from_user_id, p_target_accommodation_id, p_start_date, p_end_date, v_status_id
    );
    
    RAISE NOTICE 'Exchange offer created successfully for user %', p_from_user_id;
END;
$$;

-- Пример вызова:
-- CALL homeflip.create_exchange_offer(
--     (SELECT id FROM homeflip.users LIMIT 1), 
--     (SELECT id FROM homeflip.accommodations LIMIT 1), 
--     NOW() + INTERVAL '10 days', 
--     NOW() + INTERVAL '15 days'
-- );


-- 3. Триггер: Аудит изменений статуса жилья
-- Создадим таблицу для логов, если её нет (обычно это в миграциях, но здесь для полноты примера)
CREATE TABLE IF NOT EXISTS homeflip.accommodation_status_logs (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    accommodation_id uuid NOT NULL,
    old_status_id uuid,
    new_status_id uuid,
    changed_at timestamptz DEFAULT CURRENT_TIMESTAMP,
    changed_by text -- В реальной системе здесь был бы ID пользователя из сессии
);

-- Функция триггера
CREATE OR REPLACE FUNCTION homeflip.log_accommodation_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE' AND OLD.status_id IS DISTINCT FROM NEW.status_id) THEN
        INSERT INTO homeflip.accommodation_status_logs (
            accommodation_id, old_status_id, new_status_id, changed_by
        ) VALUES (
            NEW.id, OLD.status_id, NEW.status_id, current_user
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Привязка триггера
DROP TRIGGER IF EXISTS log_status_change ON homeflip.accommodations;
CREATE TRIGGER log_status_change
AFTER UPDATE ON homeflip.accommodations
FOR EACH ROW
EXECUTE FUNCTION homeflip.log_accommodation_status_change();

-- Пример проверки:
-- UPDATE homeflip.accommodations 
-- SET status_id = (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'archived') 
-- WHERE id = (SELECT id FROM homeflip.accommodations LIMIT 1);
-- SELECT * FROM homeflip.accommodation_status_logs;


-- 4. Триггер: Автоматическое вычисление цены (Пример BEFORE INSERT/UPDATE)
-- Допустим, у нас есть базовая цена за метр (которой нет в схеме, но представим) и мы хотим считать итоговую.
-- Или, более реально для текущей схемы: запретить менять description на слишком короткое.

CREATE OR REPLACE FUNCTION homeflip.check_description_length()
RETURNS TRIGGER AS $$
BEGIN
    IF LENGTH(NEW.description) < 20 THEN
        RAISE EXCEPTION 'Description is too short (min 20 chars). You provided % chars.', LENGTH(NEW.description);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_desc_len ON homeflip.accommodations;
CREATE TRIGGER check_desc_len
BEFORE INSERT OR UPDATE ON homeflip.accommodations
FOR EACH ROW
EXECUTE FUNCTION homeflip.check_description_length();
