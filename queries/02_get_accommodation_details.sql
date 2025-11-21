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
WHERE a.id = 'd4188f49-8574-473b-82af-bacee3031c8d'  -- Замените на нужный UUID объекта
GROUP BY a.id, u.id;
