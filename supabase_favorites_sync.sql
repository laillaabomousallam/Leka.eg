-- مزامنة المفضلة بين الأجهزة (الموبايل واللاب توب) للعميلة اللي عاملة حساب
-- شغّلي الملف ده مرة واحدة في Supabase SQL Editor (مش هيمسح أي بيانات، بيضيف عمودين ودالتين بس)

alter table customers add column if not exists favorites jsonb;
alter table customers add column if not exists favorites_updated_at timestamptz;

-- قراءة مفضلة العميلة بالإيميل
create or replace function get_customer_favorites(p_email text)
returns table (favorites jsonb, updated_at timestamptz)
language sql security definer set search_path = public as $$
  select favorites, favorites_updated_at from customers where email = p_email limit 1;
$$;
grant execute on function get_customer_favorites(text) to anon, authenticated;

-- حفظ مفضلة العميلة (لو العميلة مش موجودة مبيعملش حاجة) — بيرجع وقت الحفظ على السيرفر
create or replace function save_customer_favorites(p_email text, p_favorites jsonb)
returns timestamptz
language sql security definer set search_path = public as $$
  update customers set favorites = p_favorites, favorites_updated_at = now()
  where email = p_email
  returning favorites_updated_at;
$$;
grant execute on function save_customer_favorites(text, jsonb) to anon, authenticated;
