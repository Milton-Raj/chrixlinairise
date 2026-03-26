-- ═══════════════════════════════════════════════════════════════════════════
-- fix-rls-user-isolation.sql
-- Run this in Supabase → SQL Editor
-- Ensures each authenticated user sees ONLY their own data — no cross-user leakage
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. customer_orders ──────────────────────────────────────────────────────
ALTER TABLE public.customer_orders ENABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies to start clean
DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'customer_orders' AND schemaname = 'public')
  LOOP
    EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON public.customer_orders';
  END LOOP;
END $$;

-- Users see ONLY their own rows
CREATE POLICY "customer_orders_select_own"
  ON public.customer_orders FOR SELECT
  USING (auth.uid() = user_id);

-- Users insert ONLY rows with their own user_id
CREATE POLICY "customer_orders_insert_own"
  ON public.customer_orders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users update ONLY their own rows
CREATE POLICY "customer_orders_update_own"
  ON public.customer_orders FOR UPDATE
  USING (auth.uid() = user_id);

-- ─── 2. profiles (if exists) ─────────────────────────────────────────────────
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public') THEN
    ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

    EXECUTE 'DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles';
    EXECUTE 'DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles';
    EXECUTE 'DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles';

    EXECUTE $pol$
      CREATE POLICY "profiles_select_own" ON public.profiles FOR SELECT USING (auth.uid() = id)
    $pol$;
    EXECUTE $pol$
      CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id)
    $pol$;
    EXECUTE $pol$
      CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (auth.uid() = id)
    $pol$;
  END IF;
END $$;

-- ─── 3. orders (plan purchases — admin-only reads via get_all_orders RPC) ─────
-- The `orders` table stores plan purchases made via payment.html.
-- Regular customers do NOT read this table — only admin does via get_all_orders() RPC.
-- So: disable customer SELECT, keep INSERT open for anon (payment page).
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Drop existing permissive SELECT policy we set earlier
DROP POLICY IF EXISTS "anon_select_orders" ON public.orders;
DROP POLICY IF EXISTS "Allow all select on orders" ON public.orders;

-- Allow anon INSERT (payment page submits without auth)
DROP POLICY IF EXISTS "anon_insert_orders" ON public.orders;
CREATE POLICY "anon_insert_orders"
  ON public.orders FOR INSERT
  WITH CHECK (true);

-- Admin reads ALL orders via get_all_orders() SECURITY DEFINER RPC — no table SELECT policy needed.
-- (SECURITY DEFINER functions bypass RLS, so admin panel still works.)

-- ─── Verify ───────────────────────────────────────────────────────────────────
SELECT tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('customer_orders', 'orders', 'profiles')
ORDER BY tablename, policyname;
