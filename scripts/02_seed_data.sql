-- =============================================================================
-- Заполнение тестовыми данными
-- =============================================================================

-- 1. Справочники
INSERT INTO homeflip.countries (name, iso_code) VALUES
('Russia', 'RU'),
('Belarus', 'BY'),
('Kazakhstan', 'KZ');

INSERT INTO homeflip.cities (name, country_id, region) VALUES
('Moscow', (SELECT id FROM homeflip.countries WHERE iso_code = 'RU'), 'Moscow Region'),
('Saint Petersburg', (SELECT id FROM homeflip.countries WHERE iso_code = 'RU'), 'Leningrad Region'),
('Minsk', (SELECT id FROM homeflip.countries WHERE iso_code = 'BY'), 'Minsk Region'),
('Almaty', (SELECT id FROM homeflip.countries WHERE iso_code = 'KZ'), 'Almaty Region');

INSERT INTO homeflip.accommodation_types (name, description) VALUES
('Apartment', 'Standard city apartment'),
('House', 'Detached house with garden'),
('Loft', 'Industrial style apartment'),
('Cottage', 'Small house in the countryside');

INSERT INTO homeflip.accommodation_statuses (code, name, description) VALUES
('draft', 'Draft', 'Accommodation is being edited'),
('published', 'Published', 'Visible to everyone'),
('archived', 'Archived', 'No longer available');

INSERT INTO homeflip.exchange_offer_statuses (code, name, description) VALUES
('pending', 'Pending', 'Waiting for owner response'),
('accepted', 'Accepted', 'Exchange agreed'),
('rejected', 'Rejected', 'Exchange declined'),
('completed', 'Completed', 'Exchange finished');

INSERT INTO homeflip.amenities (short_name) VALUES
('Wi-Fi'), ('Kitchen'), ('Washing Machine'), ('Air Conditioning'), ('Parking'), ('Pool');

-- 2. Роли и Привилегии
INSERT INTO homeflip.roles (name, description) VALUES
('admin', 'System administrator with full access'),
('user', 'Regular user who can exchange homes'),
('guest', 'Unregistered user');

INSERT INTO homeflip.privileges (name, description) VALUES
('view_all', 'Can view all accommodations'),
('manage_users', 'Can ban/unban users'),
('create_accommodation', 'Can post new accommodation'),
('edit_own_accommodation', 'Can edit own accommodation');

-- Связь ролей и привилегий
INSERT INTO homeflip.role_privileges (role_id, privilege_id)
SELECT r.id, p.id FROM homeflip.roles r, homeflip.privileges p
WHERE r.name = 'admin'; -- Admin gets all privileges

INSERT INTO homeflip.role_privileges (role_id, privilege_id)
SELECT r.id, p.id FROM homeflip.roles r, homeflip.privileges p
WHERE r.name = 'user' AND p.name IN ('view_all', 'create_accommodation', 'edit_own_accommodation');

-- 3. Пользователи
INSERT INTO homeflip.users (yandex_id, email, first_name, last_name, phone_number, role_id) VALUES
('ya_123', 'admin@homeflip.com', 'Admin', 'User', '+79001234567', (SELECT id FROM homeflip.roles WHERE name = 'admin')),
('ya_456', 'ivan@example.com', 'Ivan', 'Ivanov', '+79007654321', (SELECT id FROM homeflip.roles WHERE name = 'user')),
('ya_789', 'petr@example.com', 'Petr', 'Petrov', '+79009876543', (SELECT id FROM homeflip.roles WHERE name = 'user')),
('ya_101', 'anna@example.com', 'Anna', 'Sidorova', '+375291234567', (SELECT id FROM homeflip.roles WHERE name = 'user'));

-- 4. Адреса и Объекты
-- Адрес для Ивана
WITH new_address AS (
    INSERT INTO homeflip.addresses (street_address, city_id, postal_code)
    VALUES ('Lenina st, 10, apt 5', (SELECT id FROM homeflip.cities WHERE name = 'Moscow'), '101000')
    RETURNING id
)
INSERT INTO homeflip.accommodations (owner_id, address_id, status_id, description, telegram)
SELECT 
    (SELECT id FROM homeflip.users WHERE email = 'ivan@example.com'),
    id,
    (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'published'),
    'Cozy apartment in the center of Moscow',
    '@ivan_msk'
FROM new_address;

-- Адрес для Петра
WITH new_address AS (
    INSERT INTO homeflip.addresses (street_address, city_id, postal_code)
    VALUES ('Nevsky pr, 20, apt 15', (SELECT id FROM homeflip.cities WHERE name = 'Saint Petersburg'), '190000')
    RETURNING id
)
INSERT INTO homeflip.accommodations (owner_id, address_id, status_id, description, telegram)
SELECT 
    (SELECT id FROM homeflip.users WHERE email = 'petr@example.com'),
    id,
    (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'published'),
    'Spacious loft near Hermitage',
    '@petr_spb'
FROM new_address;

-- Адрес для Анны
WITH new_address AS (
    INSERT INTO homeflip.addresses (street_address, city_id, postal_code)
    VALUES ('Nezavisimosti pr, 50', (SELECT id FROM homeflip.cities WHERE name = 'Minsk'), '220000')
    RETURNING id
)
INSERT INTO homeflip.accommodations (owner_id, address_id, status_id, description, telegram)
SELECT 
    (SELECT id FROM homeflip.users WHERE email = 'anna@example.com'),
    id,
    (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'published'),
    'Modern house in Minsk',
    '@anna_minsk'
FROM new_address;

-- 5. Детали объектов
INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests)
SELECT 
    a.id,
    (SELECT id FROM homeflip.accommodation_types WHERE name = 'Apartment'),
    5, 45, 1, 2
FROM homeflip.accommodations a
JOIN homeflip.users u ON a.owner_id = u.id
WHERE u.email = 'ivan@example.com';

INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests)
SELECT 
    a.id,
    (SELECT id FROM homeflip.accommodation_types WHERE name = 'Loft'),
    2, 80, 2, 4
FROM homeflip.accommodations a
JOIN homeflip.users u ON a.owner_id = u.id
WHERE u.email = 'petr@example.com';

INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests)
SELECT 
    a.id,
    (SELECT id FROM homeflip.accommodation_types WHERE name = 'House'),
    1, 120, 3, 6
FROM homeflip.accommodations a
JOIN homeflip.users u ON a.owner_id = u.id
WHERE u.email = 'anna@example.com';

-- 6. Удобства для объектов
INSERT INTO homeflip.accommodation_amenity (accommodation_id, amenity_id)
SELECT a.id, am.id
FROM homeflip.accommodations a, homeflip.amenities am
WHERE a.description LIKE '%Moscow%' AND am.short_name IN ('Wi-Fi', 'Kitchen');

INSERT INTO homeflip.accommodation_amenity (accommodation_id, amenity_id)
SELECT a.id, am.id
FROM homeflip.accommodations a, homeflip.amenities am
WHERE a.description LIKE '%Minsk%' AND am.short_name IN ('Wi-Fi', 'Parking', 'Pool');

-- 7. Предложения обмена
-- Анна хочет поехать к Ивану в Москву
INSERT INTO homeflip.exchange_offers (target_accommodation_id, from_user_id, start_date, end_date, status_id)
SELECT 
    a.id,
    u.id,
    CURRENT_DATE + INTERVAL '10 days',
    CURRENT_DATE + INTERVAL '15 days',
    (SELECT id FROM homeflip.exchange_offer_statuses WHERE code = 'pending')
FROM homeflip.accommodations a
JOIN homeflip.users owner ON a.owner_id = owner.id
JOIN homeflip.users u ON u.email = 'anna@example.com'
WHERE owner.email = 'ivan@example.com';

-- 8. Отзывы
-- Петр оставил отзыв Ивану (предположим, они уже менялись)
INSERT INTO homeflip.reviews_on_accommodations (author_id, accommodation_id, rating, comment)
SELECT 
    u.id,
    a.id,
    5,
    'Great apartment, very clean and cozy!'
FROM homeflip.users u
JOIN homeflip.accommodations a ON a.description LIKE '%Moscow%'
WHERE u.email = 'petr@example.com';
