-- ============================================================
-- تحصين أمان قاعدة بيانات Leka
-- شغّلي الملف ده كامل مرة واحدة في Supabase SQL Editor
-- (بعد ما تعملي حساب Authentication User بإيميل order.leka.eg@gmail.com)
-- ============================================================

-- 0) دالة مساعدة: هل اللي عامل تسجيل دخول دلوقتي هو الأدمن بالظبط؟
--    (بنتحقق من الإيميل نفسه مش بس "مسجل دخول أو لأ" — عشان حتى لو حد
--    تاني عمل حساب لنفسه، برضو مش هيعتبر أدمن غير لو نفس الإيميل ده)
create or replace function is_admin()
returns boolean
language sql stable as $$
  select auth.email() = 'order.leka.eg@gmail.com';
$$;

-- 1) تفعيل الحماية (RLS) على كل جدول
alter table products enable row level security;
alter table inventory enable row level security;
alter table orders enable row level security;
alter table customers enable row level security;
alter table messages enable row level security;
alter table settings enable row level security;
alter table analytics enable row level security;

-- 2) PRODUCTS: القراءة عامة (عشان الموقع يعرض المنتجات)، أي تعديل/حذف يحتاج تسجيل دخول حقيقي
drop policy if exists "products_select_all" on products;
create policy "products_select_all" on products for select using (true);
drop policy if exists "products_write_admin" on products;
create policy "products_write_admin" on products for all
  using (is_admin()) with check (is_admin());

-- 3) INVENTORY: القراءة عامة (عشان يظهر المتاح من كل مقاس)، التعديل المباشر للأدمن بس
--    (تنقيص/زيادة المخزون وقت الشراء بيحصل عن طريق دوال RPC آمنة تحت مش تعديل مباشر)
drop policy if exists "inventory_select_all" on inventory;
create policy "inventory_select_all" on inventory for select using (true);
drop policy if exists "inventory_write_admin" on inventory;
create policy "inventory_write_admin" on inventory for all
  using (is_admin()) with check (is_admin());

-- 4) ORDERS: أي حد يقدر يعمل أوردر جديد (تشيك أوت)، لكن قراءة/تعديل/حذف الأوردرات للأدمن بس
--    (متابعة الأوردر بالتليفون أو رقم الطلب بتحصل عن طريق دوال RPC تحت، مش قراءة مباشرة من الجدول)
drop policy if exists "orders_insert_anyone" on orders;
create policy "orders_insert_anyone" on orders for insert with check (true);
drop policy if exists "orders_select_admin" on orders;
create policy "orders_select_admin" on orders for select using (is_admin());
drop policy if exists "orders_update_admin" on orders;
create policy "orders_update_admin" on orders for update
  using (is_admin()) with check (is_admin());
drop policy if exists "orders_delete_admin" on orders;
create policy "orders_delete_admin" on orders for delete using (is_admin());

-- 5) CUSTOMERS: أي حد يقدر يحفظ بروفايله بنفسه، لكن محدش يقدر يقرا الجدول كله دفعة واحدة
--    (قراءة بروفايل/حالة الحظر بتحصل عن طريق دوال RPC تحت، بحد أقصى سجل واحد في المرة)
drop policy if exists "customers_insert_anyone" on customers;
create policy "customers_insert_anyone" on customers for insert with check (true);
drop policy if exists "customers_update_anyone" on customers;
create policy "customers_update_anyone" on customers for update using (true) with check (true);
drop policy if exists "customers_select_admin" on customers;
create policy "customers_select_admin" on customers for select using (is_admin());
drop policy if exists "customers_delete_admin" on customers;
create policy "customers_delete_admin" on customers for delete using (is_admin());

-- 6) MESSAGES: أي حد يقدر يبعت رسالة تواصل، القراءة/التعديل/الحذف للأدمن بس
drop policy if exists "messages_insert_anyone" on messages;
create policy "messages_insert_anyone" on messages for insert with check (true);
drop policy if exists "messages_select_admin" on messages;
create policy "messages_select_admin" on messages for select using (is_admin());
drop policy if exists "messages_update_admin" on messages;
create policy "messages_update_admin" on messages for update
  using (is_admin()) with check (is_admin());
drop policy if exists "messages_delete_admin" on messages;
create policy "messages_delete_admin" on messages for delete using (is_admin());

-- 7) SETTINGS: القراءة عامة (مصاريف الشحن بتتعرض في الموقع)، التعديل للأدمن بس
drop policy if exists "settings_select_all" on settings;
create policy "settings_select_all" on settings for select using (true);
drop policy if exists "settings_write_admin" on settings;
create policy "settings_write_admin" on settings for all
  using (is_admin()) with check (is_admin());

-- 8) ANALYTICS: أي حد يقدر يسجل حدث (زيارة/شراء)، القراءة/الحذف للأدمن بس
drop policy if exists "analytics_insert_anyone" on analytics;
create policy "analytics_insert_anyone" on analytics for insert with check (true);
drop policy if exists "analytics_select_admin" on analytics;
create policy "analytics_select_admin" on analytics for select using (is_admin());
drop policy if exists "analytics_delete_admin" on analytics;
create policy "analytics_delete_admin" on analytics for delete using (is_admin());

-- ============================================================
-- دوال RPC آمنة — بتسمح للموقع يعمل حاجات محدودة ومضبوطة بدقة
-- (زي تتبع أوردر برقم تليفون معين) من غير ما نفتح الجداول
-- للقراءة العامة بالكامل زي ما كانت
-- ============================================================

-- تتبع الأوردرات برقم التليفون
create or replace function get_orders_by_phone(p_phone text, p_limit int default 20)
returns table (
  order_number text, first_name text, last_name text, phone text, status text,
  total text, items text, created_at timestamptz, governorate text, district text,
  street text, building_name text, building_number text, floor_number text, apartment_number text
)
language sql security definer set search_path = public as $$
  select order_number, first_name, last_name, phone, status, total, items, created_at,
         governorate, district, street, building_name, building_number, floor_number, apartment_number
  from orders where phone = p_phone order by created_at desc limit p_limit;
$$;
grant execute on function get_orders_by_phone(text, int) to anon, authenticated;

-- تتبع أوردر برقم الأوردر
create or replace function get_order_by_number(p_order_number text)
returns table (
  order_number text, first_name text, last_name text, phone text, status text,
  total text, items text, created_at timestamptz, governorate text, district text,
  street text, building_name text, building_number text, floor_number text, apartment_number text
)
language sql security definer set search_path = public as $$
  select order_number, first_name, last_name, phone, status, total, items, created_at,
         governorate, district, street, building_name, building_number, floor_number, apartment_number
  from orders where order_number = p_order_number limit 5;
$$;
grant execute on function get_order_by_number(text) to anon, authenticated;

-- أوردرات صاحبة الإيميل (صفحة الحساب)
create or replace function get_orders_by_email(p_email text, p_limit int default 20)
returns table (
  order_number text, first_name text, last_name text, phone text, status text,
  total text, items text, created_at timestamptz, governorate text, district text,
  street text, building_name text, building_number text, floor_number text, apartment_number text
)
language sql security definer set search_path = public as $$
  select order_number, first_name, last_name, phone, status, total, items, created_at,
         governorate, district, street, building_name, building_number, floor_number, apartment_number
  from orders where customer_email = p_email order by created_at desc limit p_limit;
$$;
grant execute on function get_orders_by_email(text, int) to anon, authenticated;

-- التأكد إن رقم الأوردر الجديد مش مكرر
create or replace function order_number_exists(p_candidate text)
returns boolean
language sql security definer set search_path = public as $$
  select exists(select 1 from orders where order_number = p_candidate);
$$;
grant execute on function order_number_exists(text) to anon, authenticated;

-- بيانات المنتجات المباعة بس (من غير اسم/تليفون/عنوان أي عميل) — لحساب بادچ "الأكثر مبيعاً"
create or replace function get_all_order_items()
returns table (items text)
language sql security definer set search_path = public as $$
  select items from orders;
$$;
grant execute on function get_all_order_items() to anon, authenticated;

-- تحديث بادچ "الأكثر مبيعاً" بس — مش أي بيانات تانية زي السعر أو التفعيل
create or replace function update_product_badge(p_id bigint, p_colors jsonb, p_badge text)
returns void
language sql security definer set search_path = public as $$
  update products set colors = p_colors, badge = p_badge where id = p_id;
$$;
grant execute on function update_product_badge(bigint, jsonb, text) to anon, authenticated;

-- بروفايل عميلة واحدة بالإيميل بتاعها (صفحة الحساب)
create or replace function get_customer_profile(p_email text)
returns table (id bigint, email text, name text, phone text, address text, blocked boolean)
language sql security definer set search_path = public as $$
  select id, email, name, phone, address, blocked from customers where email = p_email limit 1;
$$;
grant execute on function get_customer_profile(text) to anon, authenticated;

-- هل الرقم/الإيميل ده محظور؟ (بيتستخدم وقت التشيك أوت وفي صفحة الحساب)
create or replace function check_customer_blocked(p_phone text, p_email text)
returns boolean
language sql security definer set search_path = public as $$
  select exists(
    select 1 from customers
    where blocked = true
      and ((p_phone is not null and phone = p_phone) or (p_email is not null and email = p_email))
  );
$$;
grant execute on function check_customer_blocked(text, text) to anon, authenticated;

-- ============================================================
-- تحديث دوال المخزون القديمة عشان تفضل شغالة بعد قفل جدول inventory
-- (من غير التحديث ده، التشيك أوت هيفشل في تنقيص المخزون)
-- ============================================================
alter function decrement_shared_stock(text, text, bigint[], int) security definer set search_path = public;
alter function increment_shared_stock(text, text, bigint[], int) security definer set search_path = public;
