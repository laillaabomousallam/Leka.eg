-- مزامنة عربة التسوق بين الأجهزة (الموبايل واللاب توب) للعميلة اللي عاملة حساب
-- شغّلي الملف ده مرة واحدة في Supabase SQL Editor (مش هيمسح أي بيانات، بيضيف عمودين ودالتين بس)

alter table customers add column if not exists cart jsonb;
alter table customers add column if not exists cart_updated_at timestamptz;

-- قراءة عربة العميلة بالإيميل
create or replace function get_customer_cart(p_email text)
returns table (cart jsonb, updated_at timestamptz)
language sql security definer set search_path = public as $$
  select cart, cart_updated_at from customers where email = p_email limit 1;
$$;
grant execute on function get_customer_cart(text) to anon, authenticated;

-- حفظ عربة العميلة (لو العميلة مش موجودة مبيعملش حاجة) — بيرجع وقت الحفظ على السيرفر
create or replace function save_customer_cart(p_email text, p_cart jsonb)
returns timestamptz
language sql security definer set search_path = public as $$
  update customers set cart = p_cart, cart_updated_at = now()
  where email = p_email
  returning cart_updated_at;
$$;
grant execute on function save_customer_cart(text, jsonb) to anon, authenticated;
