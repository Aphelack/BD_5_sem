-- 2. Представление (View) с использованием JOINs
-- Представление, показывающее полную информацию об обменах:
-- Кто (Имя), К кому (Имя владельца), Где (Город), Статус, Даты

CREATE OR REPLACE VIEW homeflip.exchange_details_view AS
SELECT 
    eo.id AS offer_id,
    -- Информация об инициаторе
    u_from.first_name || ' ' || u_from.last_name AS initiator_name,
    u_from.email AS initiator_email,
    -- Информация о владельце жилья
    u_owner.first_name || ' ' || u_owner.last_name AS owner_name,
    u_owner.email AS owner_email,
    -- Информация о жилье
    c.name AS city,
    a.description AS accommodation_desc,
    -- Детали обмена
    eo.start_date,
    eo.end_date,
    eos.name AS status,
    eos.code AS status_code
FROM homeflip.exchange_offers eo
-- INNER JOIN с инициатором
JOIN homeflip.users u_from ON eo.from_user_id = u_from.id
-- INNER JOIN с жильем
JOIN homeflip.accommodations a ON eo.target_accommodation_id = a.id
-- INNER JOIN с владельцем (через жилье)
JOIN homeflip.users u_owner ON a.owner_id = u_owner.id
-- INNER JOIN с адресом и городом
JOIN homeflip.addresses addr ON a.address_id = addr.id
JOIN homeflip.cities c ON addr.city_id = c.id
-- INNER JOIN со статусом
JOIN homeflip.exchange_offer_statuses eos ON eo.status_id = eos.id;

-- Пример использования
SELECT * FROM homeflip.exchange_details_view WHERE status_code = 'pending';
