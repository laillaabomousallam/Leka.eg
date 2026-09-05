-- بيضيف عمود "رقم موبايل تاني" اختياري للأوردرات — لازم تشغّليه في Supabase SQL editor
-- قبل ما تنشري تحديث الموقع، وإلا الطلبات هتفشل في الحفظ
alter table orders
  add column if not exists phone2 text;
