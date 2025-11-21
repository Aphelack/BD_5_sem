-- Создание схемы
CREATE SCHEMA IF NOT EXISTS homeflip;

-- Подключение расширений
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- =============================================================================
-- 1. Справочники и независимые таблицы
-- =============================================================================

-- Страны
CREATE TABLE homeflip.countries (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    name text NOT NULL UNIQUE CHECK (length(name) >= 2 AND length(name) <= 100),
    iso_code text UNIQUE CHECK (length(iso_code) = 2 AND iso_code ~ '^[A-Z]{2}$'),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Удобства
CREATE TABLE homeflip.amenities (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    short_name text NOT NULL UNIQUE CHECK (length(short_name) >= 2 AND length(short_name) <= 50)
);

-- Статусы жилья
CREATE TABLE homeflip.accommodation_statuses (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    code text NOT NULL UNIQUE CHECK (length(code) >= 2 AND length(code) <= 20),
    name text NOT NULL CHECK (length(name) >= 2 AND length(name) <= 50),
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Типы жилья
CREATE TABLE homeflip.accommodation_types (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    name text NOT NULL UNIQUE CHECK (length(name) >= 2 AND length(name) <= 50),
    description text CHECK (description IS NULL OR (length(description) >= 5 AND length(description) <= 500)),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Статусы предложений обмена
CREATE TABLE homeflip.exchange_offer_statuses (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    code text NOT NULL UNIQUE CHECK (length(code) >= 2 AND length(code) <= 20),
    name text NOT NULL CHECK (length(name) >= 2 AND length(name) <= 50),
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Роли пользователей
CREATE TABLE homeflip.roles (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    name text NOT NULL UNIQUE CHECK (length(name) >= 2 AND length(name) <= 50),
    description text NOT NULL CHECK (length(description) >= 5 AND length(description) <= 500),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Привилегии
CREATE TABLE homeflip.privileges (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    name text NOT NULL UNIQUE CHECK (length(name) >= 2 AND length(name) <= 50),
    description text NOT NULL CHECK (length(description) >= 5 AND length(description) <= 500),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Белый список email
CREATE TABLE homeflip.whitelist_emails (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    email text NOT NULL UNIQUE CHECK (email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
);

-- =============================================================================
-- 2. Зависимые таблицы (Уровень 1)
-- =============================================================================

-- Города
CREATE TABLE homeflip.cities (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    name text NOT NULL CHECK (length(name) >= 2 AND length(name) <= 100),
    country_id uuid NOT NULL REFERENCES homeflip.countries(id),
    region text CHECK (region IS NULL OR (length(region) >= 2 AND length(region) <= 100)),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (name, country_id)
);

-- Связь ролей и привилегий
CREATE TABLE homeflip.role_privileges (
    role_id uuid NOT NULL REFERENCES homeflip.roles(id) ON DELETE CASCADE,
    privilege_id uuid NOT NULL REFERENCES homeflip.privileges(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, privilege_id)
);

-- Пользователи
CREATE TABLE homeflip.users (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    yandex_id text NOT NULL UNIQUE,
    email text NOT NULL UNIQUE CHECK (email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    first_name text NOT NULL CHECK (length(first_name) >= 2 AND length(first_name) <= 50),
    last_name text NOT NULL CHECK (length(last_name) >= 2 AND length(last_name) <= 50),
    phone_number text NOT NULL CHECK (length(phone_number) >= 7 AND length(phone_number) <= 20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    has_approved_accommodation boolean DEFAULT false,
    role_id uuid REFERENCES homeflip.roles(id)
);

-- =============================================================================
-- 3. Зависимые таблицы (Уровень 2)
-- =============================================================================

-- Адреса
CREATE TABLE homeflip.addresses (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    street_address text NOT NULL CHECK (length(street_address) >= 5 AND length(street_address) <= 500),
    postal_code text CHECK (postal_code IS NULL OR (length(postal_code) >= 3 AND length(postal_code) <= 20)),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    city_id uuid NOT NULL REFERENCES homeflip.cities(id)
);

-- Объекты недвижимости (Accommodations)
CREATE TABLE homeflip.accommodations (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    owner_id uuid NOT NULL REFERENCES homeflip.users(id),
    telegram text NOT NULL CHECK (telegram ~ '^@[a-zA-Z0-9_]{5,32}$'),
    description text NOT NULL CHECK (length(description) >= 10 AND length(description) <= 5000),
    status_id uuid NOT NULL REFERENCES homeflip.accommodation_statuses(id),
    address_id uuid NOT NULL REFERENCES homeflip.addresses(id)
);

-- =============================================================================
-- 4. Зависимые таблицы (Уровень 3)
-- =============================================================================

-- Детали объектов недвижимости
CREATE TABLE homeflip.accommodation_details (
    accommodation_id uuid NOT NULL PRIMARY KEY REFERENCES homeflip.accommodations(id) ON DELETE CASCADE,
    type_id uuid NOT NULL REFERENCES homeflip.accommodation_types(id),
    floor integer CHECK (floor IS NULL OR (floor >= -5 AND floor <= 200)),
    has_elevator boolean DEFAULT false,
    area_sqm integer CHECK (area_sqm IS NULL OR (area_sqm > 0 AND area_sqm <= 10000)),
    bedrooms integer CHECK (bedrooms IS NULL OR bedrooms >= 0),
    max_guests integer CHECK (max_guests IS NULL OR max_guests > 0),
    pets_allowed boolean DEFAULT false,
    children_allowed boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Фотографии объектов
CREATE TABLE homeflip.accommodation_photos (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    accommodation_id uuid NOT NULL REFERENCES homeflip.accommodations(id),
    url text NOT NULL,
    is_primary boolean DEFAULT false
);

-- Связь объектов и удобств
CREATE TABLE homeflip.accommodation_amenity (
    accommodation_id uuid NOT NULL REFERENCES homeflip.accommodations(id),
    amenity_id uuid NOT NULL REFERENCES homeflip.amenities(id),
    PRIMARY KEY (accommodation_id, amenity_id)
);

-- Периоды размещения (Posted Periods)
CREATE TABLE homeflip.accommodation_posted_periods (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    accommodation_id uuid NOT NULL REFERENCES homeflip.accommodations(id),
    start_date timestamp with time zone NOT NULL CHECK (start_date >= CURRENT_DATE),
    end_date timestamp with time zone NOT NULL CHECK (end_date > start_date),
    CONSTRAINT prevent_overlapping_posted_periods EXCLUDE USING gist (
        accommodation_id WITH =,
        tstzrange(start_date, end_date, '[]') WITH &&
    )
);

-- Предложения обмена (Exchange Offers)
CREATE TABLE homeflip.exchange_offers (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    target_accommodation_id uuid NOT NULL REFERENCES homeflip.accommodations(id),
    from_user_id uuid NOT NULL REFERENCES homeflip.users(id),
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL CHECK (end_date > start_date),
    status_id uuid NOT NULL REFERENCES homeflip.exchange_offer_statuses(id)
);

-- Забронированные периоды (Booked Periods)
CREATE TABLE homeflip.accommodation_booked_periods (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    accommodation_id uuid NOT NULL REFERENCES homeflip.accommodations(id),
    exchange_offer_id uuid NOT NULL REFERENCES homeflip.exchange_offers(id),
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL CHECK (end_date > start_date),
    is_valid_period boolean DEFAULT false,
    CONSTRAINT prevent_overlapping_booked_periods EXCLUDE USING gist (
        accommodation_id WITH =,
        tstzrange(start_date, end_date, '[]') WITH &&
    )
);

-- Отзывы
CREATE TABLE homeflip.reviews_on_accommodations (
    id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
    author_id uuid NOT NULL REFERENCES homeflip.users(id),
    accommodation_id uuid NOT NULL REFERENCES homeflip.accommodations(id),
    comment text NOT NULL CHECK (length(comment) >= 10 AND length(comment) <= 2000),
    rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5)
);

-- =============================================================================
-- 5. Представления (Views)
-- =============================================================================

CREATE VIEW homeflip.user_privileges AS
SELECT 
    u.id AS user_id,
    u.email,
    r.name AS role_name,
    p.name AS privilege_name,
    p.description AS privilege_description
FROM homeflip.users u
LEFT JOIN homeflip.roles r ON u.role_id = r.id
LEFT JOIN homeflip.role_privileges rp ON r.id = rp.role_id
LEFT JOIN homeflip.privileges p ON rp.privilege_id = p.id;

-- =============================================================================
-- 6. Функции и Триггеры
-- =============================================================================

-- Функция для обновления updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггеры для updated_at
CREATE TRIGGER update_accommodation_details_updated_at
    BEFORE UPDATE ON homeflip.accommodation_details
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_addresses_updated_at
    BEFORE UPDATE ON homeflip.addresses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Функция проверки привилегий
CREATE OR REPLACE FUNCTION homeflip.user_has_privilege(p_user_id text, p_privilege_name text)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM homeflip.users u
        JOIN homeflip.roles r ON u.role_id = r.id
        JOIN homeflip.role_privileges rp ON r.id = rp.role_id
        JOIN homeflip.privileges p ON rp.privilege_id = p.id
        WHERE u.id = p_user_id AND p.name = p_privilege_name
    );
END;
$$ LANGUAGE plpgsql;

-- Функция получения привилегий пользователя
CREATE OR REPLACE FUNCTION homeflip.get_user_privileges(p_user_id text)
RETURNS TABLE(privilege_name text, privilege_description text) AS $$
BEGIN
    RETURN QUERY
    SELECT p.name, p.description
    FROM homeflip.users u
    JOIN homeflip.roles r ON u.role_id = r.id
    JOIN homeflip.role_privileges rp ON r.id = rp.role_id
    JOIN homeflip.privileges p ON rp.privilege_id = p.id
    WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- 7. Индексы
-- =============================================================================

CREATE INDEX idx_cities_country_id ON homeflip.cities(country_id);
CREATE INDEX idx_addresses_city_id ON homeflip.addresses(city_id);
CREATE INDEX idx_users_role_id ON homeflip.users(role_id);
CREATE INDEX idx_accommodations_owner_id ON homeflip.accommodations(owner_id);
CREATE INDEX idx_accommodations_status_id ON homeflip.accommodations(status_id);
CREATE INDEX idx_accommodations_address_id ON homeflip.accommodations(address_id);
CREATE INDEX idx_accommodation_details_type_id ON homeflip.accommodation_details(type_id);
CREATE INDEX idx_accommodation_photos_accommodation_id ON homeflip.accommodation_photos(accommodation_id);
CREATE INDEX idx_accommodation_amenity_amenity_id ON homeflip.accommodation_amenity(amenity_id);
CREATE INDEX idx_posted_periods_dates ON homeflip.accommodation_posted_periods(start_date, end_date);
CREATE INDEX idx_exchange_offers_target_accommodation_id ON homeflip.exchange_offers(target_accommodation_id);
CREATE INDEX idx_exchange_offers_from_user_id ON homeflip.exchange_offers(from_user_id);
CREATE INDEX idx_exchange_offers_status_id ON homeflip.exchange_offers(status_id);
CREATE INDEX idx_booked_periods_dates ON homeflip.accommodation_booked_periods(start_date, end_date);
CREATE INDEX idx_reviews_author_id ON homeflip.reviews_on_accommodations(author_id);
CREATE INDEX idx_reviews_accommodation_id ON homeflip.reviews_on_accommodations(accommodation_id);
