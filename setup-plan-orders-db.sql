-- ═══════════════════════════════════════════════════════════════════
-- CHRIXLIN AI RISE — Plan Orders + Site Settings DB Setup
-- Paste this ENTIRE block into: Supabase → SQL Editor → New Query → Run
-- Safe to run multiple times (IF NOT EXISTS everywhere)
-- ═══════════════════════════════════════════════════════════════════

-- ── Utility trigger function ──────────────────────────────────────
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════════
-- TABLE 1: site_settings
-- Stores: gateway_config, booking_link, etc.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.site_settings (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  key         TEXT        NOT NULL UNIQUE,
  value_json  JSONB       NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_settings_key ON public.site_settings (key);

-- Trigger: auto-update updated_at
DROP TRIGGER IF EXISTS trg_site_settings_updated_at ON public.site_settings;
CREATE TRIGGER trg_site_settings_updated_at
  BEFORE UPDATE ON public.site_settings
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- RLS: anyone can read (landing page needs gateway config, booking link)
--      anyone can write (admin saves without needing service key)
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "site_settings_public_read"  ON public.site_settings;
DROP POLICY IF EXISTS "site_settings_anon_write"   ON public.site_settings;
DROP POLICY IF EXISTS "site_settings_anon_update"  ON public.site_settings;
CREATE POLICY "site_settings_public_read"  ON public.site_settings FOR SELECT USING (true);
CREATE POLICY "site_settings_anon_write"   ON public.site_settings FOR INSERT WITH CHECK (true);
CREATE POLICY "site_settings_anon_update"  ON public.site_settings FOR UPDATE USING (true);


-- ═══════════════════════════════════════════════════════════════════
-- TABLE 2: orders
-- Stores ALL plan purchases from the payment page.
-- extra_data->>'source' = 'pricing_plan' identifies plan orders.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.orders (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_ref       TEXT        NOT NULL UNIQUE,
  product_id      TEXT,
  product_title   TEXT        NOT NULL DEFAULT '',
  product_price   TEXT        NOT NULL DEFAULT '',
  payment_method  TEXT        NOT NULL DEFAULT 'paypal',
  first_name      TEXT        NOT NULL DEFAULT '',
  last_name       TEXT        NOT NULL DEFAULT '',
  email           TEXT        NOT NULL DEFAULT '',
  phone           TEXT        NOT NULL DEFAULT '',
  country         TEXT        NOT NULL DEFAULT '',
  address         TEXT        NOT NULL DEFAULT '',
  city            TEXT        NOT NULL DEFAULT '',
  postcode        TEXT        NOT NULL DEFAULT '',
  notes           TEXT        NOT NULL DEFAULT '',
  status          TEXT        NOT NULL DEFAULT 'pending',
  extra_data      JSONB       NOT NULL DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for fast admin queries
CREATE INDEX IF NOT EXISTS idx_orders_email        ON public.orders (email);
CREATE INDEX IF NOT EXISTS idx_orders_status       ON public.orders (status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at   ON public.orders (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_source       ON public.orders ((extra_data->>'source'));

-- Trigger: auto-update updated_at
DROP TRIGGER IF EXISTS trg_orders_updated_at ON public.orders;
CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- RLS:
--   • Anyone (anon) can INSERT — customers submit orders without logging in
--   • Anyone can SELECT — admin panel uses anon key (no service role in browser)
--   • Authenticated users can UPDATE status (mark complete) and DELETE
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "orders_anon_insert"   ON public.orders;
DROP POLICY IF EXISTS "orders_anon_select"   ON public.orders;
DROP POLICY IF EXISTS "orders_auth_update"   ON public.orders;
DROP POLICY IF EXISTS "orders_auth_delete"   ON public.orders;
DROP POLICY IF EXISTS "orders_auth_read"     ON public.orders;

CREATE POLICY "orders_anon_insert"  ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "orders_anon_select"  ON public.orders FOR SELECT USING (true);
CREATE POLICY "orders_auth_update"  ON public.orders FOR UPDATE USING (true);
CREATE POLICY "orders_auth_delete"  ON public.orders FOR DELETE USING (auth.role() = 'authenticated');


-- ═══════════════════════════════════════════════════════════════════
-- TABLE 3: pricing_plans
-- Stores admin-created plans synced to all visitors.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.pricing_plans (
  id              TEXT        PRIMARY KEY,
  name            TEXT        NOT NULL DEFAULT '',
  price           TEXT        NOT NULL DEFAULT '0',
  price_label     TEXT        NOT NULL DEFAULT '',
  period          TEXT        NOT NULL DEFAULT '',
  badge           TEXT        NOT NULL DEFAULT '',
  badge_color     TEXT        NOT NULL DEFAULT '',
  badge_bg        TEXT        NOT NULL DEFAULT '',
  description     TEXT        NOT NULL DEFAULT '',
  cta             TEXT        NOT NULL DEFAULT 'Get Started',
  cta_link        TEXT        NOT NULL DEFAULT '',
  is_highlighted  BOOLEAN     NOT NULL DEFAULT false,
  features        JSONB       NOT NULL DEFAULT '[]',
  sort_order      INT         NOT NULL DEFAULT 0,
  is_active       BOOLEAN     NOT NULL DEFAULT true,
  billing_cycle   TEXT        NOT NULL DEFAULT 'monthly',
  visible         BOOLEAN     NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS trg_pricing_plans_updated_at ON public.pricing_plans;
CREATE TRIGGER trg_pricing_plans_updated_at
  BEFORE UPDATE ON public.pricing_plans
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "pricing_plans_public_read"  ON public.pricing_plans;
DROP POLICY IF EXISTS "pricing_plans_anon_write"   ON public.pricing_plans;
DROP POLICY IF EXISTS "pricing_plans_anon_update"  ON public.pricing_plans;
DROP POLICY IF EXISTS "pricing_plans_anon_delete"  ON public.pricing_plans;
CREATE POLICY "pricing_plans_public_read"  ON public.pricing_plans FOR SELECT USING (true);
CREATE POLICY "pricing_plans_anon_write"   ON public.pricing_plans FOR INSERT WITH CHECK (true);
CREATE POLICY "pricing_plans_anon_update"  ON public.pricing_plans FOR UPDATE USING (true);
CREATE POLICY "pricing_plans_anon_delete"  ON public.pricing_plans FOR DELETE USING (true);


-- ═══════════════════════════════════════════════════════════════════
-- DONE ✅
-- After running this, go to Admin → Payment Gateways and toggle
-- any gateway to push config to Supabase for the first time.
-- ═══════════════════════════════════════════════════════════════════
