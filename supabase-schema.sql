-- ═══════════════════════════════════════════════════════════════════
-- CHRIXLIN AI RISE — Supabase PostgreSQL Schema
-- Paste this entire block into the Supabase SQL Editor and click Run.
-- Project: https://rciiztibyicwymrvsorr.supabase.co
-- ═══════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── TABLE 1: site_settings ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.site_settings (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  key         TEXT        NOT NULL UNIQUE,
  value_json  JSONB       NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_site_settings_key ON public.site_settings (key);
CREATE TRIGGER trg_site_settings_updated_at BEFORE UPDATE ON public.site_settings FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "site_settings_public_read"  ON public.site_settings FOR SELECT USING (true);
CREATE POLICY "site_settings_auth_write"   ON public.site_settings FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "site_settings_auth_update"  ON public.site_settings FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "site_settings_auth_delete"  ON public.site_settings FOR DELETE USING (auth.role() = 'authenticated');

-- ── TABLE 2: marketplace_products ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.marketplace_products (
  id              BIGINT      PRIMARY KEY,
  emoji           TEXT        NOT NULL DEFAULT '🤖',
  badge           TEXT        NOT NULL DEFAULT '',
  category        TEXT        NOT NULL DEFAULT 'voice-ai',
  category_label  TEXT        NOT NULL DEFAULT '',
  category_class  TEXT        NOT NULL DEFAULT '',
  price           TEXT        NOT NULL DEFAULT '$999',
  title           TEXT        NOT NULL,
  description     TEXT        NOT NULL DEFAULT '',
  long_desc       TEXT        NOT NULL DEFAULT '',
  image_url       TEXT        NOT NULL DEFAULT '',
  yt_id           TEXT        NOT NULL DEFAULT '',
  buy_url         TEXT        NOT NULL DEFAULT '',
  features        JSONB       NOT NULL DEFAULT '[]',
  how_it_works    JSONB       NOT NULL DEFAULT '[]',
  reviews         JSONB       NOT NULL DEFAULT '[]',
  screenshots     JSONB       NOT NULL DEFAULT '[]',
  sort_order      INTEGER     NOT NULL DEFAULT 0,
  is_active       BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_mp_category   ON public.marketplace_products (category);
CREATE INDEX IF NOT EXISTS idx_mp_is_active  ON public.marketplace_products (is_active);
CREATE INDEX IF NOT EXISTS idx_mp_sort_order ON public.marketplace_products (sort_order);
CREATE TRIGGER trg_mp_products_updated_at BEFORE UPDATE ON public.marketplace_products FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.marketplace_products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "mp_products_public_read"   ON public.marketplace_products FOR SELECT USING (true);
CREATE POLICY "mp_products_auth_insert"   ON public.marketplace_products FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "mp_products_auth_update"   ON public.marketplace_products FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "mp_products_auth_delete"   ON public.marketplace_products FOR DELETE USING (auth.role() = 'authenticated');

-- ── TABLE 3: pricing_plans ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pricing_plans (
  id             BIGINT      PRIMARY KEY,
  name           TEXT        NOT NULL,
  price          TEXT        NOT NULL DEFAULT '',
  price_label    TEXT        NOT NULL DEFAULT '',
  period         TEXT        NOT NULL DEFAULT '',
  badge          TEXT        NOT NULL DEFAULT '',
  badge_color    TEXT        NOT NULL DEFAULT '',
  description    TEXT        NOT NULL DEFAULT '',
  cta            TEXT        NOT NULL DEFAULT 'Get Started',
  cta_link       TEXT        NOT NULL DEFAULT '',
  is_highlighted BOOLEAN     NOT NULL DEFAULT FALSE,
  features       JSONB       NOT NULL DEFAULT '[]',
  sort_order     INTEGER     NOT NULL DEFAULT 0,
  is_active      BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_pricing_sort ON public.pricing_plans (sort_order);
CREATE TRIGGER trg_pricing_updated_at BEFORE UPDATE ON public.pricing_plans FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pricing_public_read"   ON public.pricing_plans FOR SELECT USING (true);
CREATE POLICY "pricing_auth_insert"   ON public.pricing_plans FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "pricing_auth_update"   ON public.pricing_plans FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "pricing_auth_delete"   ON public.pricing_plans FOR DELETE USING (auth.role() = 'authenticated');

-- ── TABLE 4: payment_settings ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.payment_settings (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_key     TEXT        NOT NULL UNIQUE DEFAULT 'default',
  account_name    TEXT        NOT NULL DEFAULT '',
  bank_name       TEXT        NOT NULL DEFAULT '',
  account_number  TEXT        NOT NULL DEFAULT '',
  sort_code       TEXT        NOT NULL DEFAULT '',
  iban            TEXT        NOT NULL DEFAULT '',
  swift           TEXT        NOT NULL DEFAULT '',
  ref_note        TEXT        NOT NULL DEFAULT '',
  instructions    TEXT        NOT NULL DEFAULT '',
  paypal_email    TEXT        NOT NULL DEFAULT '',
  paypal_link     TEXT        NOT NULL DEFAULT '',
  crypto_type     TEXT        NOT NULL DEFAULT '',
  crypto_address  TEXT        NOT NULL DEFAULT '',
  contact_email   TEXT        NOT NULL DEFAULT '',
  currency        TEXT        NOT NULL DEFAULT '$',
  success_msg     TEXT        NOT NULL DEFAULT '',
  refund_policy   TEXT        NOT NULL DEFAULT '',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_payment_updated_at BEFORE UPDATE ON public.payment_settings FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.payment_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "payment_auth_read"    ON public.payment_settings FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "payment_auth_insert"  ON public.payment_settings FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "payment_auth_update"  ON public.payment_settings FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "payment_auth_delete"  ON public.payment_settings FOR DELETE USING (auth.role() = 'authenticated');

CREATE OR REPLACE VIEW public.payment_settings_public AS
SELECT currency, contact_email, success_msg, refund_policy, paypal_email, paypal_link, crypto_type, crypto_address, ref_note, instructions
FROM public.payment_settings WHERE profile_key = 'default';
GRANT SELECT ON public.payment_settings_public TO anon;

-- ── TABLE 5: orders ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.orders (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_ref       TEXT        NOT NULL UNIQUE,
  product_id      BIGINT      REFERENCES public.marketplace_products(id) ON DELETE SET NULL,
  product_title   TEXT        NOT NULL DEFAULT '',
  product_price   TEXT        NOT NULL DEFAULT '',
  payment_method  TEXT        NOT NULL DEFAULT 'card',
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
CREATE INDEX IF NOT EXISTS idx_orders_email      ON public.orders (email);
CREATE INDEX IF NOT EXISTS idx_orders_status     ON public.orders (status);
CREATE INDEX IF NOT EXISTS idx_orders_product_id ON public.orders (product_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders (created_at DESC);
CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "orders_anon_insert"  ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "orders_auth_read"    ON public.orders FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "orders_auth_update"  ON public.orders FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "orders_auth_delete"  ON public.orders FOR DELETE USING (auth.role() = 'authenticated');

-- ── TABLE 6: contact_messages ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.contact_messages (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT        NOT NULL DEFAULT '',
  email       TEXT        NOT NULL DEFAULT '',
  subject     TEXT        NOT NULL DEFAULT '',
  message     TEXT        NOT NULL DEFAULT '',
  page        TEXT        NOT NULL DEFAULT '',
  is_read     BOOLEAN     NOT NULL DEFAULT FALSE,
  extra_data  JSONB       NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_contacts_email   ON public.contact_messages (email);
CREATE INDEX IF NOT EXISTS idx_contacts_is_read ON public.contact_messages (is_read);
CREATE INDEX IF NOT EXISTS idx_contacts_created ON public.contact_messages (created_at DESC);
CREATE TRIGGER trg_contacts_updated_at BEFORE UPDATE ON public.contact_messages FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "contacts_anon_insert"  ON public.contact_messages FOR INSERT WITH CHECK (true);
CREATE POLICY "contacts_auth_read"    ON public.contact_messages FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "contacts_auth_update"  ON public.contact_messages FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "contacts_auth_delete"  ON public.contact_messages FOR DELETE USING (auth.role() = 'authenticated');

-- ── SEED: default payment_settings row ────────────────────────────
INSERT INTO public.payment_settings (profile_key, account_name, contact_email, currency, success_msg, refund_policy)
VALUES ('default', 'Chrixlin AI Rise', 'info@chrixlin.tech', '$',
  'Thank you for your purchase! Our team will contact you within 24 hours to schedule your onboarding call.',
  '30-day satisfaction guarantee. Contact us within 30 days for a full refund if you''re not satisfied.')
ON CONFLICT (profile_key) DO NOTHING;

-- ── ALTER: add billing_cycle to pricing_plans ──────────────────────
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS billing_cycle TEXT NOT NULL DEFAULT 'monthly';
CREATE INDEX IF NOT EXISTS idx_pricing_billing ON public.pricing_plans (billing_cycle);

-- ── TABLE 7: strategy_calls ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.strategy_calls (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT        NOT NULL DEFAULT '',
  email       TEXT        NOT NULL DEFAULT '',
  phone       TEXT        NOT NULL DEFAULT '',
  date        DATE,
  notes       TEXT        NOT NULL DEFAULT '',
  status      TEXT        NOT NULL DEFAULT 'booked',  -- booked | completed | no-show
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_calls_email  ON public.strategy_calls (email);
CREATE INDEX IF NOT EXISTS idx_calls_status ON public.strategy_calls (status);
CREATE INDEX IF NOT EXISTS idx_calls_date   ON public.strategy_calls (date);
CREATE TRIGGER trg_calls_updated_at BEFORE UPDATE ON public.strategy_calls FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.strategy_calls ENABLE ROW LEVEL SECURITY;
CREATE POLICY "calls_anon_insert" ON public.strategy_calls FOR INSERT WITH CHECK (true);
CREATE POLICY "calls_auth_read"   ON public.strategy_calls FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "calls_auth_update" ON public.strategy_calls FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "calls_auth_delete" ON public.strategy_calls FOR DELETE USING (auth.role() = 'authenticated');
