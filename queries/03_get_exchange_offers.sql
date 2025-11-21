-- 3. Найти все предложения обмена для пользователя (входящие)
SELECT 
    eo.id,
    u.first_name as from_user,
    eo.start_date,
    eo.end_date,
    s.name as status
FROM homeflip.exchange_offers eo
JOIN homeflip.accommodations a ON eo.target_accommodation_id = a.id
JOIN homeflip.users u ON eo.from_user_id = u.id
JOIN homeflip.exchange_offer_statuses s ON eo.status_id = s.id
WHERE a.owner_id = (SELECT id FROM homeflip.users WHERE email = 'ivan@example.com');
