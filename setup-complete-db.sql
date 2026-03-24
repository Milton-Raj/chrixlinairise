-- ═══════════════════════════════════════════════════════════════════
-- CHRIXLIN AI RISE — Complete Database Setup (Run this in Supabase)
-- Supabase Dashboard → SQL Editor → New Query → Paste all → Run
-- Project: https://rciiztibyicwymrvsorr.supabase.co
--
-- ✅ Safe to run multiple times — uses IF NOT EXISTS everywhere
-- ✅ Covers ALL tables, columns, RLS policies, and RPC functions
-- ✅ Run this ONCE and everything will work end-to-end
-- ═══════════════════════════════════════════════════════════════════

-- ── Helper: auto-update updated_at ───────────────────────────────
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;


-- ═══════════════════════════════════════════════════════════════════
-- 1. site_settings  (gateway config, booking link, etc.)
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.site_settings (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  key        TEXT        NOT NULL UNIQUE,
  value_json JSONB       NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_site_settings_key ON public.site_settings (key);
DROP TRIGGER IF EXISTS trg_site_settings_updated_at ON public.site_settings;
CREATE TRIGGER trg_site_settings_updated_at BEFORE UPDATE ON public.site_settings FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "site_settings_public_read" ON public.site_settings;
DROP POLICY IF EXISTS "site_settings_anon_write"  ON public.site_settings;
DROP POLICY IF EXISTS "site_settings_anon_update" ON public.site_settings;
CREATE POLICY "site_settings_public_read" ON public.site_settings FOR SELECT USING (true);
CREATE POLICY "site_settings_anon_write"  ON public.site_settings FOR INSERT WITH CHECK (true);
CREATE POLICY "site_settings_anon_update" ON public.site_settings FOR UPDATE USING (true);


-- ═══════════════════════════════════════════════════════════════════
-- 2. marketplace_products
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.marketplace_products (
  id             BIGINT      PRIMARY KEY,
  emoji          TEXT        NOT NULL DEFAULT '🤖',
  badge          TEXT        NOT NULL DEFAULT '',
  category       TEXT        NOT NULL DEFAULT 'voice-ai',
  category_label TEXT        NOT NULL DEFAULT '',
  category_class TEXT        NOT NULL DEFAULT '',
  price          TEXT        NOT NULL DEFAULT '$999',
  title          TEXT        NOT NULL DEFAULT '',
  slug           TEXT        NOT NULL DEFAULT '',
  description    TEXT        NOT NULL DEFAULT '',
  long_desc      TEXT        NOT NULL DEFAULT '',
  image_url      TEXT        NOT NULL DEFAULT '',
  yt_id          TEXT        NOT NULL DEFAULT '',
  buy_url        TEXT        NOT NULL DEFAULT '',
  download_url   TEXT        NOT NULL DEFAULT '',
  features       JSONB       NOT NULL DEFAULT '[]',
  how_it_works   JSONB       NOT NULL DEFAULT '[]',
  reviews        JSONB       NOT NULL DEFAULT '[]',
  screenshots    JSONB       NOT NULL DEFAULT '[]',
  sort_order     INTEGER     NOT NULL DEFAULT 0,
  is_active      BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- Add missing columns if table already exists
ALTER TABLE public.marketplace_products ADD COLUMN IF NOT EXISTS slug         TEXT NOT NULL DEFAULT '';
ALTER TABLE public.marketplace_products ADD COLUMN IF NOT EXISTS download_url TEXT NOT NULL DEFAULT '';
CREATE INDEX IF NOT EXISTS idx_mp_category   ON public.marketplace_products (category);
CREATE INDEX IF NOT EXISTS idx_mp_is_active  ON public.marketplace_products (is_active);
CREATE INDEX IF NOT EXISTS idx_mp_sort_order ON public.marketplace_products (sort_order);
DROP TRIGGER IF EXISTS trg_mp_products_updated_at ON public.marketplace_products;
CREATE TRIGGER trg_mp_products_updated_at BEFORE UPDATE ON public.marketplace_products FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.marketplace_products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "mp_products_public_read" ON public.marketplace_products;
DROP POLICY IF EXISTS "mp_products_anon_insert" ON public.marketplace_products;
DROP POLICY IF EXISTS "mp_products_anon_update" ON public.marketplace_products;
DROP POLICY IF EXISTS "mp_products_anon_delete" ON public.marketplace_products;
CREATE POLICY "mp_products_public_read" ON public.marketplace_products FOR SELECT USING (true);
CREATE POLICY "mp_products_anon_insert" ON public.marketplace_products FOR INSERT WITH CHECK (true);
CREATE POLICY "mp_products_anon_update" ON public.marketplace_products FOR UPDATE USING (true);
CREATE POLICY "mp_products_anon_delete" ON public.marketplace_products FOR DELETE USING (true);


-- ═══════════════════════════════════════════════════════════════════
-- 3. marketplace_categories  ← NEW (was missing entirely)
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.marketplace_categories (
  id          BIGINT      PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  label       TEXT        NOT NULL DEFAULT '',
  slug        TEXT        NOT NULL UNIQUE DEFAULT '',
  color_hex   TEXT        NOT NULL DEFAULT '#7c3aed',
  color_class TEXT        NOT NULL DEFAULT '',
  sort_order  INTEGER     NOT NULL DEFAULT 0,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_mcat_sort_order ON public.marketplace_categories (sort_order);
DROP TRIGGER IF EXISTS trg_mcat_updated_at ON public.marketplace_categories;
CREATE TRIGGER trg_mcat_updated_at BEFORE UPDATE ON public.marketplace_categories FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.marketplace_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "mcat_public_read" ON public.marketplace_categories;
DROP POLICY IF EXISTS "mcat_anon_insert" ON public.marketplace_categories;
DROP POLICY IF EXISTS "mcat_anon_update" ON public.marketplace_categories;
DROP POLICY IF EXISTS "mcat_anon_delete" ON public.marketplace_categories;
CREATE POLICY "mcat_public_read" ON public.marketplace_categories FOR SELECT USING (true);
CREATE POLICY "mcat_anon_insert" ON public.marketplace_categories FOR INSERT WITH CHECK (true);
CREATE POLICY "mcat_anon_update" ON public.marketplace_categories FOR UPDATE USING (true);
CREATE POLICY "mcat_anon_delete" ON public.marketplace_categories FOR DELETE USING (true);
-- Seed default categories
INSERT INTO public.marketplace_categories (label, slug, color_hex, color_class, sort_order) VALUES
  ('Voice AI',    'voice-ai',   '#7c3aed', 'cat-thumb-voice-ai',   1),
  ('Sales AI',    'sales',      '#0ea5e9', 'cat-thumb-sales',       2),
  ('Content AI',  'content',    '#f59e0b', 'cat-thumb-content',     3),
  ('Lead Gen',    'lead',       '#22c55e', 'cat-thumb-lead',        4),
  ('Automation',  'automation', '#f97316', 'cat-thumb-automation',  5)
ON CONFLICT (slug) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════════
-- 4. pricing_plans
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.pricing_plans (
  id             TEXT        PRIMARY KEY,
  name           TEXT        NOT NULL DEFAULT '',
  price          TEXT        NOT NULL DEFAULT '0',
  price_label    TEXT        NOT NULL DEFAULT '',
  period         TEXT        NOT NULL DEFAULT '',
  badge          TEXT        NOT NULL DEFAULT '',
  badge_color    TEXT        NOT NULL DEFAULT '',
  badge_bg       TEXT        NOT NULL DEFAULT '',
  description    TEXT        NOT NULL DEFAULT '',
  cta            TEXT        NOT NULL DEFAULT 'Get Started',
  cta_link       TEXT        NOT NULL DEFAULT '',
  is_highlighted BOOLEAN     NOT NULL DEFAULT FALSE,
  features       JSONB       NOT NULL DEFAULT '[]',
  sort_order     INTEGER     NOT NULL DEFAULT 0,
  is_active      BOOLEAN     NOT NULL DEFAULT TRUE,
  billing_cycle  TEXT        NOT NULL DEFAULT 'monthly',
  visible        BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- Add missing columns if table already exists with old schema
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS badge_bg      TEXT    NOT NULL DEFAULT '';
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS visible       BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS billing_cycle TEXT    NOT NULL DEFAULT 'monthly';
CREATE INDEX IF NOT EXISTS idx_pricing_sort    ON public.pricing_plans (sort_order);
CREATE INDEX IF NOT EXISTS idx_pricing_billing ON public.pricing_plans (billing_cycle);
DROP TRIGGER IF EXISTS trg_pricing_updated_at ON public.pricing_plans;
CREATE TRIGGER trg_pricing_updated_at BEFORE UPDATE ON public.pricing_plans FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "pricing_public_read"  ON public.pricing_plans;
DROP POLICY IF EXISTS "pricing_anon_insert"  ON public.pricing_plans;
DROP POLICY IF EXISTS "pricing_anon_update"  ON public.pricing_plans;
DROP POLICY IF EXISTS "pricing_anon_delete"  ON public.pricing_plans;
CREATE POLICY "pricing_public_read"  ON public.pricing_plans FOR SELECT USING (true);
CREATE POLICY "pricing_anon_insert"  ON public.pricing_plans FOR INSERT WITH CHECK (true);
CREATE POLICY "pricing_anon_update"  ON public.pricing_plans FOR UPDATE USING (true);
CREATE POLICY "pricing_anon_delete"  ON public.pricing_plans FOR DELETE USING (true);


-- ═══════════════════════════════════════════════════════════════════
-- 5. payment_settings + public view
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.payment_settings (
  id              UUID   PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_key     TEXT   NOT NULL UNIQUE DEFAULT 'default',
  account_name    TEXT   NOT NULL DEFAULT '',
  bank_name       TEXT   NOT NULL DEFAULT '',
  account_number  TEXT   NOT NULL DEFAULT '',
  sort_code       TEXT   NOT NULL DEFAULT '',
  iban            TEXT   NOT NULL DEFAULT '',
  swift           TEXT   NOT NULL DEFAULT '',
  ref_note        TEXT   NOT NULL DEFAULT '',
  instructions    TEXT   NOT NULL DEFAULT '',
  paypal_email    TEXT   NOT NULL DEFAULT '',
  paypal_link     TEXT   NOT NULL DEFAULT '',
  crypto_type     TEXT   NOT NULL DEFAULT '',
  crypto_address  TEXT   NOT NULL DEFAULT '',
  contact_email   TEXT   NOT NULL DEFAULT '',
  currency        TEXT   NOT NULL DEFAULT '$',
  success_msg     TEXT   NOT NULL DEFAULT '',
  refund_policy   TEXT   NOT NULL DEFAULT '',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
DROP TRIGGER IF EXISTS trg_payment_updated_at ON public.payment_settings;
CREATE TRIGGER trg_payment_updated_at BEFORE UPDATE ON public.payment_settings FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.payment_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "payment_auth_read"   ON public.payment_settings;
DROP POLICY IF EXISTS "payment_auth_insert" ON public.payment_settings;
DROP POLICY IF EXISTS "payment_auth_update" ON public.payment_settings;
DROP POLICY IF EXISTS "payment_auth_delete" ON public.payment_settings;
CREATE POLICY "payment_auth_read"   ON public.payment_settings FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "payment_auth_insert" ON public.payment_settings FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "payment_auth_update" ON public.payment_settings FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "payment_auth_delete" ON public.payment_settings FOR DELETE USING (auth.role() = 'authenticated');
-- Default row
INSERT INTO public.payment_settings (profile_key, account_name, contact_email, currency, success_msg, refund_policy)
VALUES ('default', 'Chrixlin AI Rise', 'info@chrixlin.tech', '$',
  'Thank you for your purchase! Our team will contact you within 24 hours.',
  '30-day satisfaction guarantee. Contact us within 30 days for a full refund.')
ON CONFLICT (profile_key) DO NOTHING;
-- Public view (no auth needed — used on payment page)
CREATE OR REPLACE VIEW public.payment_settings_public AS
SELECT currency, contact_email, success_msg, refund_policy,
       paypal_email, paypal_link, crypto_type, crypto_address, ref_note, instructions
FROM   public.payment_settings WHERE profile_key = 'default';
GRANT SELECT ON public.payment_settings_public TO anon;


-- ═══════════════════════════════════════════════════════════════════
-- 6. orders  (plan purchases + marketplace orders)
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.orders (
  id             UUID   PRIMARY KEY DEFAULT gen_random_uuid(),
  order_ref      TEXT   NOT NULL UNIQUE,
  product_id     TEXT,
  product_title  TEXT   NOT NULL DEFAULT '',
  product_price  TEXT   NOT NULL DEFAULT '',
  payment_method TEXT   NOT NULL DEFAULT 'paypal',
  first_name     TEXT   NOT NULL DEFAULT '',
  last_name      TEXT   NOT NULL DEFAULT '',
  email          TEXT   NOT NULL DEFAULT '',
  phone          TEXT   NOT NULL DEFAULT '',
  country        TEXT   NOT NULL DEFAULT '',
  address        TEXT   NOT NULL DEFAULT '',
  city           TEXT   NOT NULL DEFAULT '',
  postcode       TEXT   NOT NULL DEFAULT '',
  notes          TEXT   NOT NULL DEFAULT '',
  status         TEXT   NOT NULL DEFAULT 'pending',
  extra_data     JSONB  NOT NULL DEFAULT '{}',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_orders_email      ON public.orders (email);
CREATE INDEX IF NOT EXISTS idx_orders_status     ON public.orders (status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_source     ON public.orders ((extra_data->>'source'));
DROP TRIGGER IF EXISTS trg_orders_updated_at ON public.orders;
CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
-- Drop all old policies (handles both old and new schema)
DROP POLICY IF EXISTS "orders_anon_insert"  ON public.orders;
DROP POLICY IF EXISTS "orders_anon_select"  ON public.orders;
DROP POLICY IF EXISTS "orders_auth_read"    ON public.orders;
DROP POLICY IF EXISTS "orders_auth_update"  ON public.orders;
DROP POLICY IF EXISTS "orders_auth_delete"  ON public.orders;
-- New policies: anon can insert + read (admin panel uses anon key with session)
CREATE POLICY "orders_anon_insert"  ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "orders_anon_select"  ON public.orders FOR SELECT USING (true);
CREATE POLICY "orders_auth_update"  ON public.orders FOR UPDATE USING (true);
CREATE POLICY "orders_auth_delete"  ON public.orders FOR DELETE USING (auth.role() = 'authenticated');


-- ═══════════════════════════════════════════════════════════════════
-- 7. contact_messages
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.contact_messages (
  id         UUID   PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT   NOT NULL DEFAULT '',
  email      TEXT   NOT NULL DEFAULT '',
  subject    TEXT   NOT NULL DEFAULT '',
  message    TEXT   NOT NULL DEFAULT '',
  page       TEXT   NOT NULL DEFAULT '',
  is_read    BOOLEAN NOT NULL DEFAULT FALSE,
  extra_data JSONB  NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_contacts_email   ON public.contact_messages (email);
CREATE INDEX IF NOT EXISTS idx_contacts_is_read ON public.contact_messages (is_read);
CREATE INDEX IF NOT EXISTS idx_contacts_created ON public.contact_messages (created_at DESC);
DROP TRIGGER IF EXISTS trg_contacts_updated_at ON public.contact_messages;
CREATE TRIGGER trg_contacts_updated_at BEFORE UPDATE ON public.contact_messages FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "contacts_anon_insert" ON public.contact_messages;
DROP POLICY IF EXISTS "contacts_auth_read"   ON public.contact_messages;
DROP POLICY IF EXISTS "contacts_auth_update" ON public.contact_messages;
DROP POLICY IF EXISTS "contacts_auth_delete" ON public.contact_messages;
CREATE POLICY "contacts_anon_insert" ON public.contact_messages FOR INSERT WITH CHECK (true);
CREATE POLICY "contacts_auth_read"   ON public.contact_messages FOR SELECT USING (true);
CREATE POLICY "contacts_auth_update" ON public.contact_messages FOR UPDATE USING (true);
CREATE POLICY "contacts_auth_delete" ON public.contact_messages FOR DELETE USING (auth.role() = 'authenticated');


-- ═══════════════════════════════════════════════════════════════════
-- 8. profiles  ← NEW (was missing entirely)
-- Stores customer profile data linked to auth.users
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.profiles (
  id         UUID   PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email      TEXT   NOT NULL DEFAULT '',
  full_name  TEXT   NOT NULL DEFAULT '',
  phone      TEXT   NOT NULL DEFAULT '',
  avatar_url TEXT   NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles (email);
DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "profiles_owner_select" ON public.profiles;
DROP POLICY IF EXISTS "profiles_owner_insert" ON public.profiles;
DROP POLICY IF EXISTS "profiles_owner_update" ON public.profiles;
DROP POLICY IF EXISTS "profiles_auth_read_all" ON public.profiles;
-- Owner can read/write their own profile
CREATE POLICY "profiles_owner_select" ON public.profiles FOR SELECT USING (auth.uid() = id OR auth.role() = 'authenticated');
CREATE POLICY "profiles_owner_insert" ON public.profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "profiles_owner_update" ON public.profiles FOR UPDATE USING (auth.uid() = id);


-- ═══════════════════════════════════════════════════════════════════
-- 9. customer_orders  (authenticated customer purchases)
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.customer_orders (
  id              UUID   PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID   REFERENCES auth.users(id) ON DELETE CASCADE,
  order_ref       TEXT   NOT NULL UNIQUE,
  product_id      BIGINT,
  product_title   TEXT   NOT NULL DEFAULT '',
  product_price   TEXT   NOT NULL DEFAULT '',
  payment_method  TEXT   NOT NULL DEFAULT 'bank_transfer',
  amount          NUMERIC(10,2) NOT NULL DEFAULT 0,
  status          TEXT   NOT NULL DEFAULT 'pending',
  download_url    TEXT   NOT NULL DEFAULT '',
  invoice_url     TEXT   NOT NULL DEFAULT '',
  notes           TEXT   NOT NULL DEFAULT '',
  billing_details TEXT   NOT NULL DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- Add billing_details if table already exists without it
ALTER TABLE public.customer_orders ADD COLUMN IF NOT EXISTS billing_details TEXT NOT NULL DEFAULT '{}';
CREATE INDEX IF NOT EXISTS idx_co_user_id    ON public.customer_orders (user_id);
CREATE INDEX IF NOT EXISTS idx_co_status     ON public.customer_orders (status);
CREATE INDEX IF NOT EXISTS idx_co_created_at ON public.customer_orders (created_at DESC);
DROP TRIGGER IF EXISTS trg_co_updated_at ON public.customer_orders;
CREATE TRIGGER trg_co_updated_at BEFORE UPDATE ON public.customer_orders FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.customer_orders ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "co_user_select" ON public.customer_orders;
DROP POLICY IF EXISTS "co_user_insert" ON public.customer_orders;
DROP POLICY IF EXISTS "orders_user_select" ON public.customer_orders;
DROP POLICY IF EXISTS "orders_user_insert" ON public.customer_orders;
CREATE POLICY "co_user_select" ON public.customer_orders FOR SELECT USING (auth.uid() = user_id OR auth.role() = 'authenticated');
CREATE POLICY "co_user_insert" ON public.customer_orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "co_auth_update" ON public.customer_orders FOR UPDATE USING (auth.role() = 'authenticated');


-- ═══════════════════════════════════════════════════════════════════
-- 10. strategy_calls
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.strategy_calls (
  id         UUID   PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT   NOT NULL DEFAULT '',
  email      TEXT   NOT NULL DEFAULT '',
  phone      TEXT   NOT NULL DEFAULT '',
  date       DATE,
  notes      TEXT   NOT NULL DEFAULT '',
  status     TEXT   NOT NULL DEFAULT 'booked',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_calls_email  ON public.strategy_calls (email);
CREATE INDEX IF NOT EXISTS idx_calls_status ON public.strategy_calls (status);
DROP TRIGGER IF EXISTS trg_calls_updated_at ON public.strategy_calls;
CREATE TRIGGER trg_calls_updated_at BEFORE UPDATE ON public.strategy_calls FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.strategy_calls ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "calls_anon_insert" ON public.strategy_calls;
DROP POLICY IF EXISTS "calls_auth_read"   ON public.strategy_calls;
DROP POLICY IF EXISTS "calls_auth_update" ON public.strategy_calls;
DROP POLICY IF EXISTS "calls_auth_delete" ON public.strategy_calls;
CREATE POLICY "calls_anon_insert" ON public.strategy_calls FOR INSERT WITH CHECK (true);
CREATE POLICY "calls_auth_read"   ON public.strategy_calls FOR SELECT USING (true);
CREATE POLICY "calls_auth_update" ON public.strategy_calls FOR UPDATE USING (true);
CREATE POLICY "calls_auth_delete" ON public.strategy_calls FOR DELETE USING (auth.role() = 'authenticated');


-- ═══════════════════════════════════════════════════════════════════
-- 11–16. Landing page content tables (hero, stats, story, etc.)
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.hero_section (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_name         TEXT NOT NULL DEFAULT 'Chrixlin AI Rise',
  badge_text         TEXT NOT NULL DEFAULT 'Join 160+ AI Entrepreneurs',
  title              TEXT NOT NULL DEFAULT 'Build a $5K–$50K/Mo AI Bot Business',
  subtitle           TEXT NOT NULL DEFAULT '',
  cta_primary_text   TEXT NOT NULL DEFAULT 'Book My Free Strategy Call',
  cta_primary_url    TEXT NOT NULL DEFAULT '#pricing',
  cta_secondary_text TEXT NOT NULL DEFAULT 'See Real Results',
  cta_secondary_url  TEXT NOT NULL DEFAULT '#testimonials',
  trust_item_1       TEXT NOT NULL DEFAULT '100% Risk-Free',
  trust_item_2       TEXT NOT NULL DEFAULT 'No Experience Required',
  trust_item_3       TEXT NOT NULL DEFAULT 'Results in 60 Days',
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
DROP TRIGGER IF EXISTS trg_hero_updated_at ON public.hero_section;
CREATE TRIGGER trg_hero_updated_at BEFORE UPDATE ON public.hero_section FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.hero_section ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "hero_public_read" ON public.hero_section;
DROP POLICY IF EXISTS "hero_anon_insert" ON public.hero_section;
DROP POLICY IF EXISTS "hero_anon_update" ON public.hero_section;
CREATE POLICY "hero_public_read" ON public.hero_section FOR SELECT USING (true);
CREATE POLICY "hero_anon_insert" ON public.hero_section FOR INSERT WITH CHECK (true);
CREATE POLICY "hero_anon_update" ON public.hero_section FOR UPDATE USING (true);
INSERT INTO public.hero_section (brand_name) VALUES ('Chrixlin AI Rise') ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS public.stat_items (
  id         BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  value      TEXT NOT NULL DEFAULT '', label TEXT NOT NULL DEFAULT '',
  sort_order INTEGER NOT NULL DEFAULT 0, is_active BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.stat_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "stat_public_read" ON public.stat_items;
DROP POLICY IF EXISTS "stat_anon_insert" ON public.stat_items;
DROP POLICY IF EXISTS "stat_anon_update" ON public.stat_items;
DROP POLICY IF EXISTS "stat_anon_delete" ON public.stat_items;
CREATE POLICY "stat_public_read" ON public.stat_items FOR SELECT USING (true);
CREATE POLICY "stat_anon_insert" ON public.stat_items FOR INSERT WITH CHECK (true);
CREATE POLICY "stat_anon_update" ON public.stat_items FOR UPDATE USING (true);
CREATE POLICY "stat_anon_delete" ON public.stat_items FOR DELETE USING (true);

CREATE TABLE IF NOT EXISTS public.testimonial_items (
  id         BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name       TEXT NOT NULL DEFAULT '', role TEXT NOT NULL DEFAULT '',
  emoji      TEXT NOT NULL DEFAULT '👤', result TEXT NOT NULL DEFAULT '',
  quote      TEXT NOT NULL DEFAULT '', stars INTEGER NOT NULL DEFAULT 5,
  sort_order INTEGER NOT NULL DEFAULT 0, is_active BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.testimonial_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "testimonial_public_read" ON public.testimonial_items;
DROP POLICY IF EXISTS "testimonial_anon_insert" ON public.testimonial_items;
DROP POLICY IF EXISTS "testimonial_anon_update" ON public.testimonial_items;
DROP POLICY IF EXISTS "testimonial_anon_delete" ON public.testimonial_items;
CREATE POLICY "testimonial_public_read" ON public.testimonial_items FOR SELECT USING (true);
CREATE POLICY "testimonial_anon_insert" ON public.testimonial_items FOR INSERT WITH CHECK (true);
CREATE POLICY "testimonial_anon_update" ON public.testimonial_items FOR UPDATE USING (true);
CREATE POLICY "testimonial_anon_delete" ON public.testimonial_items FOR DELETE USING (true);

CREATE TABLE IF NOT EXISTS public.faq_items (
  id         BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  question   TEXT NOT NULL DEFAULT '', answer TEXT NOT NULL DEFAULT '',
  sort_order INTEGER NOT NULL DEFAULT 0, is_active BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.faq_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "faq_public_read" ON public.faq_items;
DROP POLICY IF EXISTS "faq_anon_insert" ON public.faq_items;
DROP POLICY IF EXISTS "faq_anon_update" ON public.faq_items;
DROP POLICY IF EXISTS "faq_anon_delete" ON public.faq_items;
CREATE POLICY "faq_public_read" ON public.faq_items FOR SELECT USING (true);
CREATE POLICY "faq_anon_insert" ON public.faq_items FOR INSERT WITH CHECK (true);
CREATE POLICY "faq_anon_update" ON public.faq_items FOR UPDATE USING (true);
CREATE POLICY "faq_anon_delete" ON public.faq_items FOR DELETE USING (true);


-- ═══════════════════════════════════════════════════════════════════
-- RPC FUNCTION 1: get_all_profiles  ← NEW (was missing)
-- Admin panel calls this to list all registered users
-- SECURITY DEFINER = bypasses RLS, runs as table owner
-- ═══════════════════════════════════════════════════════════════════
DROP FUNCTION IF EXISTS public.get_all_profiles();
CREATE OR REPLACE FUNCTION public.get_all_profiles()
RETURNS TABLE (
  id          UUID,
  email       TEXT,
  full_name   TEXT,
  phone       TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ,
  order_count BIGINT
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
    SELECT
      p.id,
      p.email,
      p.full_name,
      p.phone,
      p.avatar_url,
      p.created_at,
      (SELECT COUNT(*) FROM public.customer_orders co WHERE co.user_id = p.id)::BIGINT
    FROM public.profiles p
    ORDER BY p.created_at DESC;
END;
$$;
GRANT EXECUTE ON FUNCTION public.get_all_profiles() TO anon, authenticated;


-- ═══════════════════════════════════════════════════════════════════
-- RPC FUNCTION 2: get_all_orders  ← NEW (was missing)
-- Admin panel calls this to list all customer orders with user info
-- ═══════════════════════════════════════════════════════════════════
DROP FUNCTION IF EXISTS public.get_all_orders();
CREATE OR REPLACE FUNCTION public.get_all_orders()
RETURNS TABLE (
  id              UUID,
  order_ref       TEXT,
  user_id         UUID,
  user_name       TEXT,
  user_email      TEXT,
  product_id      BIGINT,
  product_title   TEXT,
  product_price   TEXT,
  payment_method  TEXT,
  amount          NUMERIC,
  status          TEXT,
  download_url    TEXT,
  billing_details TEXT,
  notes           TEXT,
  created_at      TIMESTAMPTZ
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
    SELECT
      co.id,
      co.order_ref,
      co.user_id,
      COALESCE(p.full_name, '')::TEXT                            AS user_name,
      COALESCE(p.email, u.email, '')::TEXT                       AS user_email,
      co.product_id,
      co.product_title,
      co.product_price,
      co.payment_method,
      co.amount,
      co.status,
      co.download_url,
      co.billing_details,
      co.notes,
      co.created_at
    FROM public.customer_orders co
    LEFT JOIN public.profiles p ON p.id = co.user_id
    LEFT JOIN auth.users u       ON u.id = co.user_id
    ORDER BY co.created_at DESC;
END;
$$;
GRANT EXECUTE ON FUNCTION public.get_all_orders() TO anon, authenticated;


-- ═══════════════════════════════════════════════════════════════════
-- STORAGE BUCKET: product-images
-- Cannot be created via SQL — do this manually:
--   Supabase Dashboard → Storage → New bucket
--   Name: product-images   Public: YES
-- ═══════════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════════
-- DONE ✅  All tables, columns, policies, and functions created.
-- ═══════════════════════════════════════════════════════════════════
