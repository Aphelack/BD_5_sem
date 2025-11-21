# Основные сущности и таблицы базы данных

## 1. **countries** (Страны)

**Назначение:** хранит статический справочник стран мира.

### Атрибуты:

* **id** (UUID, PK) — Уникальный идентификатор страны
* **name** (TEXT, UNIQUE) — Название (2–100 символов)
* **iso_code** (TEXT, UNIQUE) — ISO-код (2 заглавные буквы)
* **created_at** (TIMESTAMPTZ) — Дата создания записи

---

## 2. **cities** (Города)

**Назначение:** хранит города, привязанные к странам.

### Атрибуты:

* **id** (UUID, PK)
* **name** (TEXT) — Название (2–100 символов)
* **country_id** (UUID, FK → countries.id) — Страна
* **region** (TEXT, nullable) — Регион/область (2–100 символов)
* **created_at** (TIMESTAMPTZ)

---

## 3. **addresses** (Адреса)

**Назначение:** хранит полные адреса объектов недвижимости.

### Атрибуты:

* **id** (UUID, PK)
* **street_address** (TEXT) — Улица + дом (5–500 символов)
* **city_id** (UUID, FK → cities.id)
* **postal_code** (TEXT, nullable) — Почтовый индекс (3–20 символов)
* **created_at** (TIMESTAMPTZ)
* **updated_at** (TIMESTAMPTZ)

---

## 4. **users** (Пользователи)

**Назначение:** хранит данные зарегистрированных пользователей.

### Атрибуты:

* **id** (UUID, PK)
* **yandex_id** (TEXT, UNIQUE)
* **email** (TEXT, UNIQUE)
* **first_name** (TEXT, 2–50)
* **last_name** (TEXT, 2–50)
* **phone_number** (TEXT, 7–20)
* **created_at** (TIMESTAMPTZ)
* **has_approved_accommodation** (BOOLEAN)
* **role_id** (UUID, FK → roles.id)

---

## 5. **accommodations** (Объекты недвижимости)

**Назначение:** содержит информацию об объектах, доступных для обмена.

### Атрибуты:

* **id** (UUID, PK)
* **owner_id** (UUID, FK → users.id)
* **telegram** (TEXT) — @username (5–32 символов)
* **description** (TEXT, 10–5000)
* **status_id** (UUID, FK → accommodation_statuses.id)
* **address_id** (UUID, FK → addresses.id)

---

## 6. **accommodation_details** (Детали объектов)

**Назначение:** технические характеристики недвижимости.

### Атрибуты:

* **accommodation_id** (UUID, PK, FK → accommodations.id)
* **type_id** (UUID, FK → accommodation_types.id)
* **floor** (INTEGER)
* **has_elevator** (BOOLEAN)
* **area_sqm** (INTEGER, ≤ 10000)
* **bedrooms** (INTEGER)
* **max_guests** (INTEGER)
* **pets_allowed** (BOOLEAN)
* **children_allowed** (BOOLEAN)
* **created_at** (TIMESTAMPTZ)
* **updated_at** (TIMESTAMPTZ)

---

## 7. **accommodation_types** (Типы жилья)

**Назначение:** справочник типов объектов.

### Атрибуты:

* **id** (UUID, PK)
* **name** (TEXT, UNIQUE, 2–50)
* **description** (TEXT, nullable, 5–500)
* **created_at** (TIMESTAMPTZ)

---

## 8. **accommodation_statuses** (Статусы объектов)

**Назначение:** статусы модерации объектов.

### Атрибуты:

* **id** (UUID, PK)
* **code** (TEXT, UNIQUE, 2–20)
* **name** (TEXT, 2–50)
* **description** (TEXT)
* **created_at** (TIMESTAMPTZ)

---

## 9. **accommodation_photos** (Фотографии объектов)

**Назначение:** хранит URL изображений объектов.

### Атрибуты:

* **id** (UUID, PK)
* **accommodation_id** (UUID, FK → accommodations.id)
* **url** (TEXT)
* **is_primary** (BOOLEAN)

---

## 10. **amenities** (Удобства)

**Назначение:** справочник доступных удобств.

### Атрибуты:

* **id** (UUID, PK)
* **short_name** (TEXT, UNIQUE, 2–50)

---

## 11. **accommodation_amenity** (Связь удобств с объектами)

**Назначение:** связь многие-ко-многим между объектами и удобствами.

### Атрибуты:

* **accommodation_id** (UUID, FK → accommodations.id)
* **amenity_id** (UUID, FK → amenities.id)

---

## 12. **accommodation_posted_periods** (Периоды размещения)

**Назначение:** периоды доступности объекта.

### Атрибуты:

* **id** (UUID, PK)
* **accommodation_id** (UUID, FK → accommodations.id)
* **start_date** (TIMESTAMPTZ) — не раньше текущей даты
* **end_date** (TIMESTAMPTZ)

---

## 13. **accommodation_booked_periods** (Забронированные периоды)

**Назначение:** хранит периоды брони объекта.

### Атрибуты:

* **id** (UUID, PK)
* **accommodation_id** (UUID, FK → accommodations.id)
* **exchange_offer_id** (UUID, FK → exchange_offers.id)
* **start_date** (TIMESTAMPTZ)
* **end_date** (TIMESTAMPTZ)
* **is_valid_period** (BOOLEAN)

---

## 14. **exchange_offers** (Предложения обмена)

**Назначение:** хранит все предложения по обменам.

### Атрибуты:

* **id** (UUID, PK)
* **target_accommodation_id** (UUID, FK → accommodations.id)
* **from_user_id** (UUID, FK → users.id)
* **start_date** (TIMESTAMPTZ)
* **end_date** (TIMESTAMPTZ)
* **status_id** (UUID, FK → exchange_offer_statuses.id)

---

## 15. **exchange_offer_statuses** (Статусы предложений)

**Назначение:** справочник статусов обменов.

### Атрибуты:

* **id** (UUID, PK)
* **code** (TEXT, UNIQUE, 2–20)
* **name** (TEXT, 2–50)
* **description** (TEXT)
* **created_at** (TIMESTAMPTZ)

---

## 16. **reviews_on_accommodations** (Отзывы)

**Назначение:** отзывы пользователей о недвижимости.

### Атрибуты:

* **id** (UUID, PK)
* **author_id** (UUID, FK → users.id)
* **accommodation_id** (UUID, FK → accommodations.id)
* **comment** (TEXT, 10–2000)
* **rating** (INTEGER, 1–5)

---

# Система ролей и привилегий

## **roles** (Роли)

### Назначение:

Определяет роли пользователей.

### Атрибуты:

* **id** (UUID, PK)
* **name** (TEXT, UNIQUE, 2–50)
* **description** (TEXT, 5–500)
* **created_at** (TIMESTAMPTZ)

### Роли:

* **guest** — просмотр главной страницы
* **user** — управление собственными объектами
* **admin** — полные права, включая модерацию и управление пользователями

---

## **privileges** (Привилегии)

### Атрибуты:

* **id** (UUID, PK)
* **name** (TEXT, UNIQUE, 2–50)
* **description** (TEXT, 5–500)
* **created_at** (TIMESTAMPTZ)

### Основные привилегии:

* view_main_page
* search_accommodations
* view_own_accommodation
* add_accommodation
* edit_own_accommodation
* delete_own_accommodation
* accept_accommodation
* view_all_accommodations
* manage_users
* manage_roles

---

## **role_privileges** (Связь ролей и привилегий)

**Назначение:** M:N связь.

### Атрибуты:

* **role_id** (UUID, FK → roles.id)
* **privilege_id** (UUID, FK → privileges.id)
* **created_at** (TIMESTAMPTZ)

---

## **whitelist_emails** (Белый список email)

### Атрибуты:

* **id** (UUID, PK)
* **email** (TEXT, UNIQUE)

