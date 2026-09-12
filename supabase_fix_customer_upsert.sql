-- إصلاح مشكلة حفظ/تعديل بيانات العميلة (upsert customers)
-- السبب: عملية الـ upsert (INSERT ... ON CONFLICT DO UPDATE) محتاجة صلاحية قراءة (SELECT)
-- عشان تتأكد لو العميلة موجودة قبل كده، وده متعارض مع سياسة إخفاء بيانات العملاء عن غير الأدمن.
-- الحل: دالة آمنة (SECURITY DEFINER) بتعمل الحفظ بنفسها من غير ما تحتاج صلاحية قراءة عامة.
-- شغّلي الملف ده مرة واحدة في Supabase SQL Editor

create or replace function upsert_customer_profile(
  p_email text, p_name text, p_phone text, p_address text
)
returns void
language sql security definer set search_path = public as $$
  insert into customers (email, name, phone, address)
  values (p_email, p_name, p_phone, p_address)
  on conflict (email) do update
    set name = excluded.name, phone = excluded.phone, address = excluded.address;
$$;
grant execute on function upsert_customer_profile(text, text, text, text) to anon, authenticated;
