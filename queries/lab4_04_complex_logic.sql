-- 4. Сложная логика (CASE) и модификация данных
-- Сценарий 1: Классификация предложений по цене за квадратный метр
-- Используем CASE для создания категорий 'Budget', 'Standard', 'Premium'

SELECT 
    o.id AS offer_id,
    a.title,
    o.price,
    ad.area_sqm,
    ROUND(o.price / ad.area_sqm, 2) AS price_per_sqm,
    CASE 
        WHEN (o.price / ad.area_sqm) < 1000 THEN 'Budget'
        WHEN (o.price / ad.area_sqm) BETWEEN 1000 AND 2000 THEN 'Standard'
        ELSE 'Premium'
    END AS price_category
FROM homeflip.offers o
JOIN homeflip.accommodations a ON o.accommodation_id = a.id
JOIN homeflip.accommodation_details ad ON a.id = ad.accommodation_id
WHERE o.status = 'active'
ORDER BY price_per_sqm DESC;

-- Сценарий 2: Массовое обновление (UPDATE с подзапросом/логикой)
-- Увеличить цену на 5% для всех предложений категории 'Premium' (из логики выше),
-- которые были созданы более месяца назад.

/*
UPDATE homeflip.offers
SET price = price * 1.05
WHERE id IN (
    SELECT o.id
    FROM homeflip.offers o
    JOIN homeflip.accommodations a ON o.accommodation_id = a.id
    JOIN homeflip.accommodation_details ad ON a.id = ad.accommodation_id
    WHERE (o.price / ad.area_sqm) > 2000 -- Условие Premium
      AND o.created_at < NOW() - INTERVAL '1 month'
      AND o.status = 'active'
);
*/
