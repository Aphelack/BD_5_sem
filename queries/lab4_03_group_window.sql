-- 3. Группировка и Оконные функции
-- Для каждого города вывести:
-- 1. Количество объектов
-- 2. Среднюю площадь
-- 3. Ранг города по количеству объектов (DENSE_RANK)

SELECT 
    c.name AS city_name,
    COUNT(a.id) AS accommodations_count,
    ROUND(AVG(ad.area_sqm), 2) AS avg_area,
    DENSE_RANK() OVER (ORDER BY COUNT(a.id) DESC) AS city_rank
FROM homeflip.cities c
LEFT JOIN homeflip.addresses addr ON c.id = addr.city_id
LEFT JOIN homeflip.accommodations a ON addr.id = a.address_id
LEFT JOIN homeflip.accommodation_details ad ON a.id = ad.accommodation_id
GROUP BY c.id, c.name
HAVING COUNT(a.id) > 0 -- Показать только города, где есть жилье
ORDER BY city_rank;
