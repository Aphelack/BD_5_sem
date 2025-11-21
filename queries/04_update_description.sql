-- 4. Обновить описание объекта
UPDATE homeflip.accommodations
SET description = 'Updated description: Cozy apartment near Red Square',
    status_id = (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'published')
WHERE owner_id = (SELECT id FROM homeflip.users WHERE email = 'ivan@example.com');
