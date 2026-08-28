-- دالة تنقيص المخزون المشترك بشكل آمن (atomic) — بتحل مشكلة إن لو اتنين اشتروا
-- في نفس اللحظة تقريبًا، الكمية تتحسب غلط. التنقيص بيحصل جوه قاعدة البيانات
-- نفسها على القيمة الحالية الفعلية، مش على نسخة قديمة محفوظة على المتصفح.
-- شغّلي الكود ده مرة واحدة بس في Supabase SQL Editor.

create or replace function decrement_shared_stock(
  p_color text,
  p_size text,
  p_product_ids bigint[],
  p_qty int
)
returns int
language plpgsql
as $$
declare
  new_qty int;
begin
  update inventory
  set quantity = greatest(quantity - p_qty, 0)
  where color = p_color and size = p_size and product_id = any(p_product_ids);

  select quantity into new_qty from inventory
  where color = p_color and size = p_size and product_id = any(p_product_ids)
  limit 1;

  return new_qty;
end;
$$;

grant execute on function decrement_shared_stock(text, text, bigint[], int) to anon, authenticated;
