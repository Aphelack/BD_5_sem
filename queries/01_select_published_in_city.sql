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
WHERE c.name = 'Saint Petersburg' AND s.code = 'published';
