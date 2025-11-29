-- 1) Топ-5 пользователей по количеству опубликованных объектов
-- (COUNT + JOIN + GROUP BY + ORDER BY)
SELECT u.id AS user_id, u.email, COUNT(a.id) AS published_accommodations
FROM homeflip.users u
LEFT JOIN homeflip.accommodations a ON a.owner_id = u.id
LEFT JOIN homeflip.accommodation_statuses s ON a.status_id = s.id
WHERE s.code = 'published'
GROUP BY u.id, u.email
ORDER BY published_accommodations DESC
LIMIT 5;

-- 2) Средний рейтинг и количество отзывов для каждого объекта
-- (LEFT JOIN + AGGREGATION + COALESCE)
SELECT a.id AS accommodation_id,
       a.description,
       COALESCE(AVG(r.rating), 0) AS avg_rating,
       COUNT(r.id) AS reviews_count
FROM homeflip.accommodations a
LEFT JOIN homeflip.reviews_on_accommodations r ON r.accommodation_id = a.id
GROUP BY a.id, a.description
ORDER BY avg_rating DESC NULLS LAST;

-- 3) Найти пользователей, у которых нет ни одного размещенного объекта
-- (LEFT JOIN + WHERE IS NULL)
SELECT u.id, u.email
FROM homeflip.users u
LEFT JOIN homeflip.accommodations a ON a.owner_id = u.id
WHERE a.id IS NULL;

-- 4) Найти все объекты, у которых есть опубликованные периоды размещения в будущем (EXISTS)
-- (EXISTS + correlated subquery)
SELECT a.id, a.description
FROM homeflip.accommodations a
WHERE EXISTS (
    SELECT 1
    FROM homeflip.accommodation_posted_periods p
    WHERE p.accommodation_id = a.id
      AND p.start_date > CURRENT_DATE
);

-- 5) Ранжирование объектов по средней площади внутри каждого города (WINDOW + PARTITION)
-- (JOIN через addresses -> cities, оконная функция DENSE_RANK)
SELECT 
    a.id AS accommodation_id,
    c.name AS city_name,
    ad.area_sqm,
    DENSE_RANK() OVER (PARTITION BY c.id ORDER BY ad.area_sqm DESC) AS rank_in_city
FROM homeflip.accommodations a
JOIN homeflip.addresses addr ON a.address_id = addr.id
JOIN homeflip.cities c ON addr.city_id = c.id
LEFT JOIN homeflip.accommodation_details ad ON a.id = ad.accommodation_id
WHERE ad.area_sqm IS NOT NULL
ORDER BY c.name, rank_in_city;

-- 6) Использование LAG: сравнить рейтинг каждого отзыва с предыдущим для того же объекта
-- (LAG() OVER (PARTITION BY ... ORDER BY id) — используем id как опорный порядок)
SELECT id AS review_id,
       accommodation_id,
       rating,
       LAG(rating) OVER (PARTITION BY accommodation_id ORDER BY id) AS previous_rating
FROM homeflip.reviews_on_accommodations
ORDER BY accommodation_id, id;

-- 7) Найти города, где средняя площадь жилья больше 70 кв.м (GROUP BY + HAVING)
SELECT c.id AS city_id, c.name AS city_name, AVG(ad.area_sqm)::numeric(10,2) AS avg_area
FROM homeflip.cities c
JOIN homeflip.addresses addr ON addr.city_id = c.id
JOIN homeflip.accommodations a ON a.address_id = addr.id
JOIN homeflip.accommodation_details ad ON ad.accommodation_id = a.id
GROUP BY c.id, c.name
HAVING AVG(ad.area_sqm) > 70
ORDER BY avg_area DESC;

-- 8) UNION / EXCEPT примеры
-- Список всех городов в двух наборах (RU + US), затем города, которые есть в RU но нет в US (EXCEPT)
SELECT name, 'RU' AS source FROM homeflip.cities WHERE country_id = (SELECT id FROM homeflip.countries WHERE iso_code = 'RU')
UNION
SELECT name, 'US' AS source FROM homeflip.cities WHERE country_id = (SELECT id FROM homeflip.countries WHERE iso_code = 'US');

-- Города в России, которых нет в США
SELECT name FROM homeflip.cities WHERE country_id = (SELECT id FROM homeflip.countries WHERE iso_code = 'RU')
EXCEPT
SELECT name FROM homeflip.cities WHERE country_id = (SELECT id FROM homeflip.countries WHERE iso_code = 'US');

-- 9) Correlated subquery: объекты, у которых количество отзывов выше среднего по городу
SELECT a.id, a.description, addr.city_id, review_count
FROM (
    SELECT a2.id, COUNT(r2.id) AS review_count
    FROM homeflip.accommodations a2
    LEFT JOIN homeflip.reviews_on_accommodations r2 ON r2.accommodation_id = a2.id
    GROUP BY a2.id
) AS counts
JOIN homeflip.accommodations a ON a.id = counts.id
JOIN homeflip.addresses addr ON a.address_id = addr.id
WHERE counts.review_count > (
    SELECT AVG(cnt) FROM (
        SELECT COUNT(r3.id) AS cnt
        FROM homeflip.accommodations a3
        JOIN homeflip.addresses addr3 ON a3.address_id = addr3.id
        LEFT JOIN homeflip.reviews_on_accommodations r3 ON r3.accommodation_id = a3.id
        WHERE addr3.city_id = addr.city_id
        GROUP BY a3.id
    ) sub
)
ORDER BY counts.review_count DESC;

-- 10) INSERT ... SELECT: добавить заглушечные фотографии для объектов, у которых ещё нет фото
INSERT INTO homeflip.accommodation_photos (accommodation_id, url, is_primary)
SELECT a.id, 'https://example.com/placeholder.jpg', true
FROM homeflip.accommodations a
WHERE NOT EXISTS (
    SELECT 1 FROM homeflip.accommodation_photos p WHERE p.accommodation_id = a.id
);

-- 11) EXPLAIN: показать план выполнения для одного сложного запроса (пример)
EXPLAIN
SELECT a.id, a.description, COALESCE(AVG(r.rating),0) AS avg_rating
FROM homeflip.accommodations a
LEFT JOIN homeflip.reviews_on_accommodations r ON r.accommodation_id = a.id
GROUP BY a.id, a.description
ORDER BY avg_rating DESC
LIMIT 10;


select a.id, COUNT(eo.id) from accommodations a
join exchange_offers eo on eo.target_accommodation_id = a.id
group by a.id, eo.id
