-- 5. Удалить черновики объектов (которые не обновлялись более года)
DELETE FROM homeflip.accommodations
WHERE status_id = (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'draft')
  AND id IN (SELECT accommodation_id FROM homeflip.accommodation_details WHERE updated_at < CURRENT_DATE - INTERVAL '1 year');
