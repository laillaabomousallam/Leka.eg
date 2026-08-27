-- يضيف عمود categories (قائمة فئات) للمنتج بدل فئة واحدة بس
-- وبينقل كل منتج موجود لقيمته الحالية جوه القائمة عشان ماحدش يختفي من أي صفحة

alter table products add column if not exists categories jsonb default '[]'::jsonb;

update products
set categories = to_jsonb(array[cat])
where categories is null or categories = '[]'::jsonb;
