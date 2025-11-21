-- 1. Сложная выборка с несколькими условиями и вложенным запросом
-- Найти пользователей, которые имеют подтвержденное жилье (status='published')
-- И при этом имеют хотя бы один завершенный обмен (status='completed')
-- И средний рейтинг их объектов выше 4.0

SELECT 
    u.id,
    u.first_name,
    u.last_name,
    u.email
FROM homeflip.users u
WHERE 
    -- Условие 1: Есть опубликованное жилье
    EXISTS (
        SELECT 1 
        FROM homeflip.accommodations a 
        JOIN homeflip.accommodation_statuses s ON a.status_id = s.id
        WHERE a.owner_id = u.id AND s.code = 'published'
    )
    AND
    -- Условие 2: Есть завершенный обмен (как инициатор или как владелец)
    (
        EXISTS (
            SELECT 1 
            FROM homeflip.exchange_offers eo 
            JOIN homeflip.exchange_offer_statuses eos ON eo.status_id = eos.id
            WHERE eo.from_user_id = u.id AND eos.code = 'completed'
        )
        OR
        EXISTS (
            SELECT 1 
            FROM homeflip.exchange_offers eo 
            JOIN homeflip.accommodations a ON eo.target_accommodation_id = a.id
            JOIN homeflip.exchange_offer_statuses eos ON eo.status_id = eos.id
            WHERE a.owner_id = u.id AND eos.code = 'completed'
        )
    )
    AND
    -- Условие 3: Средний рейтинг выше 4.0
    (
        SELECT AVG(r.rating)
        FROM homeflip.reviews_on_accommodations r
        JOIN homeflip.accommodations a ON r.accommodation_id = a.id
        WHERE a.owner_id = u.id
    ) > 4.0;
