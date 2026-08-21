-- Allow the dashboard to create/remove inventory rows when adding/deleting a product
drop policy if exists "Public insert inventory" on inventory;
create policy "Public insert inventory" on inventory for insert with check (true);
drop policy if exists "Public delete inventory" on inventory;
create policy "Public delete inventory" on inventory for delete using (true);
