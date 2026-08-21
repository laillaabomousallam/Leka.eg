-- ============================================
-- Leka products table + storage setup
-- Run this once in the Supabase SQL Editor (project > SQL Editor > New query > Run)
-- ============================================

create table if not exists products (
  id bigint primary key,
  cat text not null,
  name_ar text not null,
  name_en text not null,
  desc_ar text,
  desc_en text,
  price numeric not null,
  original_price numeric,
  badge text,
  sizes jsonb not null default '["S","M","L","XL"]',
  colors jsonb not null default '[]',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table products enable row level security;

drop policy if exists "Public read products" on products;
create policy "Public read products" on products for select using (true);
drop policy if exists "Public write products" on products;
create policy "Public write products" on products for insert with check (true);
drop policy if exists "Public update products" on products;
create policy "Public update products" on products for update using (true);
drop policy if exists "Public delete products" on products;
create policy "Public delete products" on products for delete using (true);

-- Storage bucket for product images uploaded from the dashboard
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

drop policy if exists "Public read product images" on storage.objects;
create policy "Public read product images" on storage.objects for select using (bucket_id = 'product-images');
drop policy if exists "Public upload product images" on storage.objects;
create policy "Public upload product images" on storage.objects for insert with check (bucket_id = 'product-images');
drop policy if exists "Public update product images" on storage.objects;
create policy "Public update product images" on storage.objects for update using (bucket_id = 'product-images');
drop policy if exists "Public delete product images" on storage.objects;
create policy "Public delete product images" on storage.objects for delete using (bucket_id = 'product-images');

-- Migrate the 14 existing products (keeps their current ids so inventory.product_id still matches)
insert into products (id, cat, name_ar, name_en, desc_ar, desc_en, price, original_price, badge, sizes, colors, active) values
(1, 'half', 'أصل الحكاية', 'Asl Alhekaya', ' أوڤر سايز يونيسكس — قطن 100%', 'Oversized unisex — 100% cotton', 650, 700, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Asl/1.png", "imgs/Black Asl/2.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Asl/1.png", "imgs/White Asl/2.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Asl/1.png", "imgs/Red Asl/2.png"]}]'::jsonb, true),
(2, 'half', 'تيشرت الثمانينات ', '80s Tee', ' أوڤر سايز يونيسكس —  أوڤر سايز يونيسكس — تصميم كلاسيكي من الثمانينات — قطن 100%', 'Oversized unisex — 80s collage design — 100% cotton', 650, 700, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black 80s/1.png", "imgs/Black 80s/2.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White 80s/1.png", "imgs/White 80s/2.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red 80s/1.png", "imgs/Red 80s/2.png"]}]'::jsonb, true),
(3, 'half', 'تيشرت جرافيتي', 'Graffiti Tee', '  أوڤر سايز يونيسكس — تيشرت جرافيتي - كُن أنت الرسام — قطن 100%', 'Oversized unisex — Graffiti Tee - Be the Artist — 100% cotton ', 650, 700, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Graffity/1.png", "imgs/Black Graffity/2.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Graffity/1.png", "imgs/White Graffity/2.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Graffity/1.png", "imgs/Red Graffity/2.png"]}]'::jsonb, true),
(4, 'half', 'تيشرت ليكا رحلة التعلم', 'Leka Learning Journey Tee', '  أوڤر سايز يونيسكس — تيشرت ليكا- كن فخوراً بمحاولاتك — قطن 100%', 'Oversized unisex — Be Proud of Your Attempts — 100% cotton', 650, 700, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black English/1.png", "imgs/Black English/2.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White English/1.png", "imgs/White English/2.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red English/1.png", "imgs/Red English/2.png"]}]'::jsonb, true),
(5, 'full', 'أصل الحكاية — حجابي', 'Asl Alhekaya — Hijabi', ' أوڤر سايز بكم طويل — قطن 100%', 'Oversized long sleeve — Hijabi — 100% cotton', 700, 750, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Asl Hj/1.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Asl Hj/1.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Asl Hj/1.png"]}]'::jsonb, true),
(6, 'full', 'تيشرت الثمانينات — حجابي', '80s Tee — Hijabi ', ' أوڤر سايز بكم طويل — تصميم كلاسيكي من الثمانينات— قطن 100%', 'Oversized long sleeve — Hijabi — 80s collage design — 100% cotton', 700, 750, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black 80s Hj/1.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White 80s Hj/1.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red 80s Hj/1.png"]}]'::jsonb, true),
(7, 'full', 'تيشرت الجرافيتي — حجابي', 'Graffiti Tee — Hijabi', ' أوڤر سايز بكم طويل — كُن أنت الرسام— قطن 100%', 'Oversized long sleeve — Hijabi —  Be the Artist — 100% cotton', 700, 750, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Graffity Hj/1.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Graffity Hj/1.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Graffity Hj/1.png"]}]'::jsonb, true),
(8, 'full', 'تيشرت ليكا رحلة التعلم — حجابي', 'Leka Learning Journey Tee — Hijabi', ' أوڤر سايز بكم طويل— تيشرت ليكا- كن فخوراً بمحاولاتك — قطن 100% ', 'Oversized long sleeve — Hijabi— Be Proud of Your Attempts — 100% cotton', 700, 750, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black English Hj/1.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White English Hj/1.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red English Hj/1.png"]}]'::jsonb, true),
(9, 'half', 'تيشرت ليكا', 'Leka', ' أوڤر سايز يونيسكس — قطن 100%', 'Oversized unisex — 100% cotton', 650, 700, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Leka/1.png", "imgs/Black Leka/2.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Leka/1.png", "imgs/White Leka/2.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Leka/1.png", "imgs/Red Leka/2.png"]}]'::jsonb, true),
(10, 'half', 'تيشرت الذهبي', 'Al Dahabi', ' أوڤر سايز يونيسكس — قطن 100%', 'Oversized unisex — 100% cotton', 650, 700, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Dahabi/1.png", "imgs/Black Dahabi/2.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Dahabi/1.png", "imgs/White Dahabi/2.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Dahabi/1.png", "imgs/Red Dahabi/2.png"]}]'::jsonb, true),
(11, 'full', 'تيشرت ليكا — حجابي', 'Leka — Hijabi', ' أوڤر سايز بكم طويل — قطن 100%', 'Oversized long sleeve — Hijabi — 100% cotton', 700, 750, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Leka Hj/1.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Leka Hj/1.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Leka Hj/1.png"]}]'::jsonb, true),
(12, 'full', 'تيشرت الذهبي — حجابي', 'Al Dahabi — Hijabi', ' أوڤر سايز بكم طويل — قطن 100%', 'Oversized long sleeve — Hijabi — 100% cotton', 700, 750, NULL, '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Dahabi Hj/1.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Dahabi Hj/1.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Dahabi Hj/1.png"]}]'::jsonb, true),
(13, 'half', 'تيشرت بيسيك', 'Basic', ' أوڤر سايز يونيسكس — قطن 100%', 'Oversized unisex — 100% cotton', 500, 550, 'new', '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Basic/1.png", "imgs/Black Basic/2.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Basic/1.png", "imgs/White Basic/2.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Basic/1.png", "imgs/Red Basic/2.png"]}]'::jsonb, true),
(14, 'full', 'تيشرت بيسيك — حجابي', 'Basic — Hijabi', ' أوڤر سايز بكم طويل — قطن 100%', 'Oversized long sleeve — Hijabi — 100% cotton', 550, 600, 'new', '["S", "M", "L", "XL"]'::jsonb, '[{"nameAr": "أسود", "nameEn": "Black", "hex": "#0a0a0a", "key": "Black", "images": ["imgs/Black Basic Hj/1.png"]}, {"nameAr": "أبيض", "nameEn": "White", "hex": "#f0f0f0", "key": "White", "images": ["imgs/White Basic Hj/1.png"]}, {"nameAr": "برجاندي", "nameEn": "Burgundy", "hex": "#800020", "key": "Burgundy", "images": ["imgs/Red Basic Hj/1.png"]}]'::jsonb, true)
on conflict (id) do nothing;

-- Make future admin-added products auto-increment starting after id 14
alter table products alter column id add generated always as identity (start with 15);
