-- =============================================================================
-- Пул простых SQL запросов
-- =============================================================================

-- 1. Получить все опубликованные объекты в конкретном городе (например, Moscow)
SELECT 
    a.id, 
    a.description, 
    addr.street_address, 
    c.name as city, 
    at.name as type, 
    ad.area_sqm, 
    ad.max_guests
FROM homeflip.accommodations a
JOIN homeflip.addresses addr ON a.address_id = addr.id
JOIN homeflip.cities c ON addr.city_id = c.id
JOIN homeflip.accommodation_details ad ON a.id = ad.accommodation_id
JOIN homeflip.accommodation_types at ON ad.type_id = at.id
JOIN homeflip.accommodation_statuses s ON a.status_id = s.id
WHERE c.name = 'Moscow' AND s.code = 'published';

-- 2. Получить полную информацию об объекте по ID (включая удобства)
SELECT 
    a.description,
    u.first_name || ' ' || u.last_name as owner_name,
    a.telegram,
    string_agg(am.short_name, ', ') as amenities
FROM homeflip.accommodations a
JOIN homeflip.users u ON a.owner_id = u.id
LEFT JOIN homeflip.accommodation_amenity aa ON a.id = aa.accommodation_id
LEFT JOIN homeflip.amenities am ON aa.amenity_id = am.id
WHERE a.description LIKE '%Moscow%' -- Используем LIKE для примера, лучше по ID
GROUP BY a.id, u.id;

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

-- 4. Обновить описание объекта
UPDATE homeflip.accommodations
SET description = 'Updated description: Cozy apartment near Red Square',
    status_id = (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'published')
WHERE owner_id = (SELECT id FROM homeflip.users WHERE email = 'ivan@example.com');

-- 5. Удалить черновики объектов (которые не обновлялись более года)
DELETE FROM homeflip.accommodations
WHERE status_id = (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'draft')
  AND id IN (SELECT accommodation_id FROM homeflip.accommodation_details WHERE updated_at < CURRENT_DATE - INTERVAL '1 year');

-- 6. Получить список пользователей с ролью 'admin'
SELECT u.email, u.first_name, u.last_name
FROM homeflip.users u
JOIN homeflip.roles r ON u.role_id = r.id
WHERE r.name = 'admin';

-- 7. Посчитать средний рейтинг жилья для каждого пользователя
SELECT 
    u.first_name, 
    u.last_name, 
    AVG(r.rating) as avg_rating
FROM homeflip.users u
JOIN homeflip.accommodations a ON u.id = a.owner_id
JOIN homeflip.reviews_on_accommodations r ON a.id = r.accommodation_id
GROUP BY u.id;
