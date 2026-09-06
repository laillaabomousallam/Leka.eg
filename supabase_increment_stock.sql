-- عكس decrement_shared_stock بالظبط — بيرجع الكمية تاني للمخزون (restock)
-- بيتستخدم لما يتم حذف أوردر من الداشبورد، عشان المنتجات اللي كانت فيه ترجع تاني للمخزون
-- شغّليه مرة واحدة في Supabase SQL Editor

create or replace function increment_shared_stock(
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
  set quantity = quantity + p_qty
  where color = p_color and size = p_size and product_id = any(p_product_ids);

  select quantity into new_qty from inventory
  where color = p_color and size = p_size and product_id = any(p_product_ids)
  limit 1;

  return new_qty;
end;
$$;

grant execute on function increment_shared_stock(text, text, bigint[], int) to anon, authenticated;
