-- ─── Fix customer_orders RLS: each user sees only their own rows ────────────────
-- Run this once in Supabase → SQL Editor

-- 1. Enable RLS (idempotent)
ALTER TABLE public.customer_orders ENABLE ROW LEVEL SECURITY;

-- 2. Drop any existing overly-permissive SELECT policy
DROP POLICY IF EXISTS "Allow all select on customer_orders" ON public.customer_orders;
DROP POLICY IF EXISTS "Users can view all orders"           ON public.customer_orders;
DROP POLICY IF EXISTS "anon_select_customer_orders"        ON public.customer_orders;

-- 3. Users can only read their OWN orders
CREATE POLICY "users_select_own_orders"
  ON public.customer_orders
  FOR SELECT
  USING (auth.uid() = user_id);

-- 4. Users can insert their own orders (already authenticated at insert time)
DROP POLICY IF EXISTS "users_insert_own_orders" ON public.customer_orders;
CREATE POLICY "users_insert_own_orders"
  ON public.customer_orders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 5. Users can update their own orders (e.g. cancel, download)
DROP POLICY IF EXISTS "users_update_own_orders" ON public.customer_orders;
CREATE POLICY "users_update_own_orders"
  ON public.customer_orders
  FOR UPDATE
  USING (auth.uid() = user_id);

-- 6. Admin service role bypasses RLS automatically — no changes needed for admin.
--    If your admin panel uses the anon key + get_all_orders() RPC, that function
--    is already SECURITY DEFINER so it reads all rows regardless of RLS.
