-- 6. Получить список пользователей с ролью 'admin'
SELECT u.email, u.first_name, u.last_name
FROM homeflip.users u
JOIN homeflip.roles r ON u.role_id = r.id
WHERE r.name = 'admin';
