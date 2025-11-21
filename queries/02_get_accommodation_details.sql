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
WHERE a.id = 'b238574f-aa55-463d-9eda-7af979cd3b06'
GROUP BY a.id, u.id;
