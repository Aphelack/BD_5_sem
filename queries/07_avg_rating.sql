-- 7. Посчитать средний рейтинг жилья для каждого пользователя
SELECT 
    u.first_name, 
    u.last_name, 
    AVG(r.rating) as avg_rating
FROM homeflip.users u
JOIN homeflip.accommodations a ON u.id = a.owner_id
JOIN homeflip.reviews_on_accommodations r ON a.id = r.accommodation_id
GROUP BY u.id;
