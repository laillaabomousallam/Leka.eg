-- يمنع نهائيًا إن اتنين أوردرات ياخدوا نفس order_number حتى لو حصل تعارض نادر
-- (مثلاً لو اتنين عملوا Checkout في نفس اللحظة بالظبط)
-- شغّليه مرة واحدة في Supabase SQL editor
alter table orders
  add constraint orders_order_number_unique unique (order_number);
