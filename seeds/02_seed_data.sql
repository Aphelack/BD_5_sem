-- =============================================================================
-- Заполнение тестовыми данными (Расширенный набор)
-- =============================================================================

-- 1. Справочники
INSERT INTO homeflip.countries (name, iso_code) VALUES
('Russia', 'RU'),
('Belarus', 'BY'),
('Kazakhstan', 'KZ'),
('Turkey', 'TR'),
('Georgia', 'GE');

INSERT INTO homeflip.cities (name, country_id, region) VALUES
('Moscow', (SELECT id FROM homeflip.countries WHERE iso_code = 'RU'), 'Moscow Region'),
('Saint Petersburg', (SELECT id FROM homeflip.countries WHERE iso_code = 'RU'), 'Leningrad Region'),
('Sochi', (SELECT id FROM homeflip.countries WHERE iso_code = 'RU'), 'Krasnodar Krai'),
('Kazan', (SELECT id FROM homeflip.countries WHERE iso_code = 'RU'), 'Tatarstan'),
('Minsk', (SELECT id FROM homeflip.countries WHERE iso_code = 'BY'), 'Minsk Region'),
('Brest', (SELECT id FROM homeflip.countries WHERE iso_code = 'BY'), 'Brest Region'),
('Almaty', (SELECT id FROM homeflip.countries WHERE iso_code = 'KZ'), 'Almaty Region'),
('Astana', (SELECT id FROM homeflip.countries WHERE iso_code = 'KZ'), 'Akmola Region'),
('Istanbul', (SELECT id FROM homeflip.countries WHERE iso_code = 'TR'), 'Marmara Region'),
('Antalya', (SELECT id FROM homeflip.countries WHERE iso_code = 'TR'), 'Mediterranean Region'),
('Tbilisi', (SELECT id FROM homeflip.countries WHERE iso_code = 'GE'), 'Tbilisi');

INSERT INTO homeflip.accommodation_types (name, description) VALUES
('Apartment', 'Standard city apartment'),
('House', 'Detached house with garden'),
('Loft', 'Industrial style apartment'),
('Cottage', 'Small house in the countryside'),
('Villa', 'Luxurious house with pool'),
('Room', 'Private room in shared apartment');

INSERT INTO homeflip.accommodation_statuses (code, name, description) VALUES
('draft', 'Draft', 'Accommodation is being edited'),
('published', 'Published', 'Visible to everyone'),
('archived', 'Archived', 'No longer available'),
('moderation', 'On Moderation', 'Waiting for admin approval');

INSERT INTO homeflip.exchange_offer_statuses (code, name, description) VALUES
('pending', 'Pending', 'Waiting for owner response'),
('accepted', 'Accepted', 'Exchange agreed'),
('rejected', 'Rejected', 'Exchange declined'),
('completed', 'Completed', 'Exchange finished'),
('cancelled', 'Cancelled', 'Cancelled by requester');

INSERT INTO homeflip.amenities (short_name) VALUES
('Wi-Fi'), ('Kitchen'), ('Washing Machine'), ('Air Conditioning'), ('Parking'), ('Pool'),
('Gym'), ('Pet Friendly'), ('Balcony'), ('TV'), ('Workspace'), ('Elevator');

-- 2. Роли и Привилегии
INSERT INTO homeflip.roles (name, description) VALUES
('admin', 'System administrator with full access'),
('user', 'Regular user who can exchange homes'),
('guest', 'Unregistered user'),
('moderator', 'Can approve accommodations');

INSERT INTO homeflip.privileges (name, description) VALUES
('view_all', 'Can view all accommodations'),
('manage_users', 'Can ban/unban users'),
('create_accommodation', 'Can post new accommodation'),
('edit_own_accommodation', 'Can edit own accommodation'),
('approve_accommodation', 'Can approve accommodations');

-- Связь ролей и привилегий
INSERT INTO homeflip.role_privileges (role_id, privilege_id)
SELECT r.id, p.id FROM homeflip.roles r, homeflip.privileges p
WHERE r.name = 'admin'; -- Admin gets all privileges

INSERT INTO homeflip.role_privileges (role_id, privilege_id)
SELECT r.id, p.id FROM homeflip.roles r, homeflip.privileges p
WHERE r.name = 'user' AND p.name IN ('view_all', 'create_accommodation', 'edit_own_accommodation');

INSERT INTO homeflip.role_privileges (role_id, privilege_id)
SELECT r.id, p.id FROM homeflip.roles r, homeflip.privileges p
WHERE r.name = 'moderator' AND p.name IN ('view_all', 'approve_accommodation');

-- 3. Пользователи
INSERT INTO homeflip.users (yandex_id, email, first_name, last_name, phone_number, role_id) VALUES
('ya_123', 'admin@homeflip.com', 'Admin', 'User', '+79001234567', (SELECT id FROM homeflip.roles WHERE name = 'admin')),
('ya_456', 'ivan@example.com', 'Ivan', 'Ivanov', '+79007654321', (SELECT id FROM homeflip.roles WHERE name = 'user')),
('ya_789', 'petr@example.com', 'Petr', 'Petrov', '+79009876543', (SELECT id FROM homeflip.roles WHERE name = 'user')),
('ya_101', 'anna@example.com', 'Anna', 'Sidorova', '+375291234567', (SELECT id FROM homeflip.roles WHERE name = 'user')),
('ya_202', 'maria@example.com', 'Maria', 'Kuznetsova', '+79001112233', (SELECT id FROM homeflip.roles WHERE name = 'user')),
('ya_303', 'alex@example.com', 'Alex', 'Smirnov', '+79004445566', (SELECT id FROM homeflip.roles WHERE name = 'user')),
('ya_404', 'elena@example.com', 'Elena', 'Popova', '+905551234567', (SELECT id FROM homeflip.roles WHERE name = 'user')),
('ya_505', 'dmitry@example.com', 'Dmitry', 'Volkov', '+995555987654', (SELECT id FROM homeflip.roles WHERE name = 'user')),
('ya_606', 'mod@homeflip.com', 'Moderator', 'One', '+79009998877', (SELECT id FROM homeflip.roles WHERE name = 'moderator'));

-- 4. Адреса и Объекты
-- Ivan (Moscow)
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

-- Petr (SPb)
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

-- Anna (Minsk)
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

-- Maria (Sochi)
WITH new_address AS (
    INSERT INTO homeflip.addresses (street_address, city_id, postal_code)
    VALUES ('Kurortny pr, 100', (SELECT id FROM homeflip.cities WHERE name = 'Sochi'), '354000')
    RETURNING id
)
INSERT INTO homeflip.accommodations (owner_id, address_id, status_id, description, telegram)
SELECT 
    (SELECT id FROM homeflip.users WHERE email = 'maria@example.com'),
    id,
    (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'published'),
    'Sunny apartment with sea view',
    '@maria_sochi'
FROM new_address;

-- Alex (Kazan) - Draft
WITH new_address AS (
    INSERT INTO homeflip.addresses (street_address, city_id, postal_code)
    VALUES ('Baumana st, 15', (SELECT id FROM homeflip.cities WHERE name = 'Kazan'), '420000')
    RETURNING id
)
INSERT INTO homeflip.accommodations (owner_id, address_id, status_id, description, telegram)
SELECT 
    (SELECT id FROM homeflip.users WHERE email = 'alex@example.com'),
    id,
    (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'draft'),
    'Apartment in historic center',
    '@alex_kazan'
FROM new_address;

-- Elena (Istanbul)
WITH new_address AS (
    INSERT INTO homeflip.addresses (street_address, city_id, postal_code)
    VALUES ('Istiklal Cd, 55', (SELECT id FROM homeflip.cities WHERE name = 'Istanbul'), '34433')
    RETURNING id
)
INSERT INTO homeflip.accommodations (owner_id, address_id, status_id, description, telegram)
SELECT 
    (SELECT id FROM homeflip.users WHERE email = 'elena@example.com'),
    id,
    (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'published'),
    'Authentic flat in Beyoglu',
    '@elena_ist'
FROM new_address;

-- Dmitry (Tbilisi)
WITH new_address AS (
    INSERT INTO homeflip.addresses (street_address, city_id, postal_code)
    VALUES ('Rustaveli Ave, 10', (SELECT id FROM homeflip.cities WHERE name = 'Tbilisi'), '0108')
    RETURNING id
)
INSERT INTO homeflip.accommodations (owner_id, address_id, status_id, description, telegram)
SELECT 
    (SELECT id FROM homeflip.users WHERE email = 'dmitry@example.com'),
    id,
    (SELECT id FROM homeflip.accommodation_statuses WHERE code = 'published'),
    'Old Tbilisi charm apartment',
    '@dmitry_geo'
FROM new_address;

-- 5. Детали объектов
INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests, has_elevator, pets_allowed)
SELECT a.id, (SELECT id FROM homeflip.accommodation_types WHERE name = 'Apartment'), 5, 45, 1, 2, true, false
FROM homeflip.accommodations a JOIN homeflip.users u ON a.owner_id = u.id WHERE u.email = 'ivan@example.com';

INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests, has_elevator, pets_allowed)
SELECT a.id, (SELECT id FROM homeflip.accommodation_types WHERE name = 'Loft'), 2, 80, 2, 4, false, true
FROM homeflip.accommodations a JOIN homeflip.users u ON a.owner_id = u.id WHERE u.email = 'petr@example.com';

INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests, has_elevator, pets_allowed)
SELECT a.id, (SELECT id FROM homeflip.accommodation_types WHERE name = 'House'), 1, 120, 3, 6, false, true
FROM homeflip.accommodations a JOIN homeflip.users u ON a.owner_id = u.id WHERE u.email = 'anna@example.com';

INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests, has_elevator, pets_allowed)
SELECT a.id, (SELECT id FROM homeflip.accommodation_types WHERE name = 'Apartment'), 8, 60, 2, 4, true, false
FROM homeflip.accommodations a JOIN homeflip.users u ON a.owner_id = u.id WHERE u.email = 'maria@example.com';

INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests, has_elevator, pets_allowed)
SELECT a.id, (SELECT id FROM homeflip.accommodation_types WHERE name = 'Apartment'), 3, 50, 1, 2, false, false
FROM homeflip.accommodations a JOIN homeflip.users u ON a.owner_id = u.id WHERE u.email = 'alex@example.com';

INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests, has_elevator, pets_allowed)
SELECT a.id, (SELECT id FROM homeflip.accommodation_types WHERE name = 'Apartment'), 4, 70, 2, 3, true, true
FROM homeflip.accommodations a JOIN homeflip.users u ON a.owner_id = u.id WHERE u.email = 'elena@example.com';

INSERT INTO homeflip.accommodation_details (accommodation_id, type_id, floor, area_sqm, bedrooms, max_guests, has_elevator, pets_allowed)
SELECT a.id, (SELECT id FROM homeflip.accommodation_types WHERE name = 'House'), 2, 100, 3, 5, false, true
FROM homeflip.accommodations a JOIN homeflip.users u ON a.owner_id = u.id WHERE u.email = 'dmitry@example.com';

-- 6. Удобства для объектов
INSERT INTO homeflip.accommodation_amenity (accommodation_id, amenity_id)
SELECT a.id, am.id FROM homeflip.accommodations a, homeflip.amenities am
WHERE a.description LIKE '%Moscow%' AND am.short_name IN ('Wi-Fi', 'Kitchen', 'TV');

INSERT INTO homeflip.accommodation_amenity (accommodation_id, amenity_id)
SELECT a.id, am.id FROM homeflip.accommodations a, homeflip.amenities am
WHERE a.description LIKE '%Minsk%' AND am.short_name IN ('Wi-Fi', 'Parking', 'Pool', 'Gym');

INSERT INTO homeflip.accommodation_amenity (accommodation_id, amenity_id)
SELECT a.id, am.id FROM homeflip.accommodations a, homeflip.amenities am
WHERE a.description LIKE '%Sochi%' AND am.short_name IN ('Wi-Fi', 'Air Conditioning', 'Balcony');

INSERT INTO homeflip.accommodation_amenity (accommodation_id, amenity_id)
SELECT a.id, am.id FROM homeflip.accommodations a, homeflip.amenities am
WHERE a.description LIKE '%Istanbul%' AND am.short_name IN ('Wi-Fi', 'Kitchen', 'Workspace');

-- 7. Предложения обмена
-- Anna -> Ivan (Pending)
INSERT INTO homeflip.exchange_offers (target_accommodation_id, from_user_id, start_date, end_date, status_id)
SELECT a.id, u.id, CURRENT_DATE + INTERVAL '10 days', CURRENT_DATE + INTERVAL '15 days',
(SELECT id FROM homeflip.exchange_offer_statuses WHERE code = 'pending')
FROM homeflip.accommodations a JOIN homeflip.users owner ON a.owner_id = owner.id JOIN homeflip.users u ON u.email = 'anna@example.com'
WHERE owner.email = 'ivan@example.com';

-- Maria -> Petr (Accepted)
INSERT INTO homeflip.exchange_offers (target_accommodation_id, from_user_id, start_date, end_date, status_id)
SELECT a.id, u.id, CURRENT_DATE + INTERVAL '20 days', CURRENT_DATE + INTERVAL '25 days',
(SELECT id FROM homeflip.exchange_offer_statuses WHERE code = 'accepted')
FROM homeflip.accommodations a JOIN homeflip.users owner ON a.owner_id = owner.id JOIN homeflip.users u ON u.email = 'maria@example.com'
WHERE owner.email = 'petr@example.com';

-- Dmitry -> Elena (Rejected)
INSERT INTO homeflip.exchange_offers (target_accommodation_id, from_user_id, start_date, end_date, status_id)
SELECT a.id, u.id, CURRENT_DATE + INTERVAL '5 days', CURRENT_DATE + INTERVAL '7 days',
(SELECT id FROM homeflip.exchange_offer_statuses WHERE code = 'rejected')
FROM homeflip.accommodations a JOIN homeflip.users owner ON a.owner_id = owner.id JOIN homeflip.users u ON u.email = 'dmitry@example.com'
WHERE owner.email = 'elena@example.com';

-- Ivan -> Maria (Completed)
INSERT INTO homeflip.exchange_offers (target_accommodation_id, from_user_id, start_date, end_date, status_id)
SELECT a.id, u.id, CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE - INTERVAL '5 days',
(SELECT id FROM homeflip.exchange_offer_statuses WHERE code = 'completed')
FROM homeflip.accommodations a JOIN homeflip.users owner ON a.owner_id = owner.id JOIN homeflip.users u ON u.email = 'ivan@example.com'
WHERE owner.email = 'maria@example.com';

-- 8. Отзывы
-- Petr -> Ivan
INSERT INTO homeflip.reviews_on_accommodations (author_id, accommodation_id, rating, comment)
SELECT u.id, a.id, 5, 'Great apartment, very clean and cozy!'
FROM homeflip.users u JOIN homeflip.accommodations a ON a.description LIKE '%Moscow%'
WHERE u.email = 'petr@example.com';

-- Ivan -> Maria
INSERT INTO homeflip.reviews_on_accommodations (author_id, accommodation_id, rating, comment)
SELECT u.id, a.id, 4, 'Nice view, but a bit noisy.'
FROM homeflip.users u JOIN homeflip.accommodations a ON a.description LIKE '%Sochi%'
WHERE u.email = 'ivan@example.com';

-- Maria -> Ivan
INSERT INTO homeflip.reviews_on_accommodations (author_id, accommodation_id, rating, comment)
SELECT u.id, a.id, 5, 'Ivan is a great guest!'
FROM homeflip.users u JOIN homeflip.accommodations a ON a.description LIKE '%Moscow%'
WHERE u.email = 'maria@example.com';
