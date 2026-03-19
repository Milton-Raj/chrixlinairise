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
CREATE POLICY "site_settings_anon_write"   ON public.site_settings FOR INSERT WITH CHECK (true);
CREATE POLICY "site_settings_anon_update"  ON public.site_settings FOR UPDATE USING (true);

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
CREATE POLICY "mp_products_anon_insert"   ON public.marketplace_products FOR INSERT WITH CHECK (true);
CREATE POLICY "mp_products_anon_update"   ON public.marketplace_products FOR UPDATE USING (true);
CREATE POLICY "mp_products_anon_delete"   ON public.marketplace_products FOR DELETE USING (true);

INSERT INTO public.marketplace_products (id, emoji, badge, category, category_label, category_class, price, title, description, long_desc, buy_url, features, sort_order, is_active) VALUES
(1, '📞', 'Bestseller', 'voice-ai', 'Voice AI', 'cat-voice', '$1,499', 'Voice AI Appointment Agent',
 'AI-powered voice assistant that handles incoming calls, books appointments, and sends follow-up reminders — 24/7 without human intervention.',
 'Deploy a fully autonomous AI voice agent that handles every incoming call for your business. It answers questions, qualifies leads, books appointments directly into your calendar, and sends automated SMS/email reminders — all without any human involvement. Perfect for clinics, service businesses, salons, and any business that relies on phone bookings.',
 'mailto:info@chrixlin.tech?subject=Buying: Voice AI Appointment Agent',
 '["24/7 automated call handling","Direct calendar integration","SMS & email appointment reminders","CRM pipeline integration","Custom voice, tone & script","Multilingual support","Full setup & onboarding included"]',
 1, true),
(2, '🔥', 'Hot', 'sales', 'Sales AI', 'cat-sales', '$499', 'Lead Reactivation AI Platform',
 'Autonomous system that identifies dormant contacts in your CRM and turns them into confirmed bookings through personalized AI outreach.',
 'Stop leaving money on the table. This platform automatically scans your CRM for leads that went cold, crafts personalized follow-up messages based on their history, and drives them to take action — whether that''s booking a call, signing up for a trial, or making a purchase. 100% automated.',
 'mailto:info@chrixlin.tech?subject=Buying: Lead Reactivation AI Platform',
 '["CRM integration (GoHighLevel, HubSpot, etc.)","AI-personalized outreach sequences","Multi-channel: SMS, email, voicemail drops","Automatic booking on positive replies","Detailed analytics dashboard","A/B testing for message optimization"]',
 2, true),
(3, '🏥', 'Premium', 'voice-ai', 'Voice AI', 'cat-voice', '$1,497', 'Patient Acquisition AI System',
 'Complete patient acquisition pipeline with AI voice agent, marketing funnels, CRM pipeline, and automated appointment scheduling for healthcare.',
 'A turnkey patient acquisition system built specifically for healthcare providers. Includes a custom AI voice agent for inbound calls, automated marketing funnels, HIPAA-compliant CRM pipeline, and seamless appointment scheduling. Delivered as a ready-to-import GoHighLevel snapshot.',
 'mailto:info@chrixlin.tech?subject=Buying: Patient Acquisition AI System',
 '["HIPAA-compliant architecture","AI inbound & outbound calling","Automated marketing funnels","GoHighLevel snapshot included","Patient intake automation","Review collection system","White-label ready"]',
 3, true),
(4, '✍️', '', 'content', 'Content AI', 'cat-content', '$997', 'AI Content & Marketing Agent',
 'Plug-and-play AI agent that generates and publishes social content, ad copy, email campaigns, and blog posts from a single prompt.',
 'Give this AI agent a topic, product, or goal and it produces a full content calendar: social media posts, email sequences, ad copy, and blog articles — all optimized for your brand voice. Integrates directly with your publishing tools. Save 20+ hours per week on content creation.',
 'mailto:info@chrixlin.tech?subject=Buying: AI Content & Marketing Agent',
 '["Multi-platform content generation","Brand voice training","Auto-publish to social media","Email sequence writer","SEO-optimized blog posts","Ad copy generator","Content calendar scheduler"]',
 4, true),
(5, '🎯', '', 'lead', 'Lead Gen', 'cat-lead', '$1,297', 'AI Lead Generation System',
 'End-to-end lead generation machine that finds prospects, qualifies them with AI conversations, and books them directly into your sales calendar.',
 'Automate your entire top-of-funnel. This system sources targeted leads from LinkedIn, web scraping, and third-party data, then engages them with personalized AI conversations that qualify interest and intent. Hot leads get automatically booked into your calendar — zero manual effort required.',
 'mailto:info@chrixlin.tech?subject=Buying: AI Lead Generation System',
 '["Multi-source lead sourcing","AI qualification conversations","LinkedIn outreach automation","Automatic calendar booking","Lead scoring & prioritization","Custom ICP targeting","Full analytics & reporting"]',
 5, true),
(6, '⚙️', 'New', 'automation', 'Automation', 'cat-automation', '$799', 'Business Automation Workflow Suite',
 'A comprehensive suite of AI-powered automation workflows that eliminate repetitive tasks across your entire business operation.',
 'Stop wasting hours on tasks a machine can do. This suite includes pre-built automation workflows for onboarding, invoicing, follow-ups, reporting, and internal communications — all connected via AI. Works with 200+ apps including Slack, Google Workspace, Notion, QuickBooks, and more.',
 'mailto:info@chrixlin.tech?subject=Buying: Business Automation Workflow Suite',
 '["200+ app integrations","Automated client onboarding","Invoice & payment automation","AI-powered reporting","Internal workflow automation","Custom trigger + action builder","Zapier/Make compatible"]',
 6, true)
ON CONFLICT (id) DO NOTHING;

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
CREATE POLICY "pricing_anon_insert"   ON public.pricing_plans FOR INSERT WITH CHECK (true);
CREATE POLICY "pricing_anon_update"   ON public.pricing_plans FOR UPDATE USING (true);
CREATE POLICY "pricing_anon_delete"   ON public.pricing_plans FOR DELETE USING (true);

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

-- ── TABLE 8: hero_section ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.hero_section (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_name      TEXT        NOT NULL DEFAULT 'Chrixlin AI Rise',
  badge_text      TEXT        NOT NULL DEFAULT 'Join 160+ AI Entrepreneurs',
  title           TEXT        NOT NULL DEFAULT 'Build a $5K–$50K/Mo AI Bot Business',
  subtitle        TEXT        NOT NULL DEFAULT 'Learn to create, sell, and scale AI automation solutions for real businesses. Get your first paying client by Week 4 — or you don''t pay a cent.',
  cta_primary_text   TEXT     NOT NULL DEFAULT 'Book My Free Strategy Call',
  cta_primary_url    TEXT     NOT NULL DEFAULT '#pricing',
  cta_secondary_text TEXT     NOT NULL DEFAULT 'See Real Results',
  cta_secondary_url  TEXT     NOT NULL DEFAULT '#testimonials',
  trust_item_1    TEXT        NOT NULL DEFAULT '100% Risk-Free',
  trust_item_2    TEXT        NOT NULL DEFAULT 'No Experience Required',
  trust_item_3    TEXT        NOT NULL DEFAULT 'Results in 60 Days',
  story_title     TEXT        NOT NULL DEFAULT 'From College Student to AI Business Pioneer',
  story_p1        TEXT        NOT NULL DEFAULT 'In 2020, I was a broke college student with zero connections and no clear path. But I discovered something that would change everything — businesses were desperate for automation, and almost nobody knew how to build it.',
  story_p2        TEXT        NOT NULL DEFAULT 'By senior year, I had crossed $150,000 in revenue building AI and automation tools. After being featured in Business Insider, I made it my mission to help others replicate the same path — faster.',
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_hero_updated_at BEFORE UPDATE ON public.hero_section FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.hero_section ENABLE ROW LEVEL SECURITY;
CREATE POLICY "hero_public_read"  ON public.hero_section FOR SELECT USING (true);
CREATE POLICY "hero_anon_insert"  ON public.hero_section FOR INSERT WITH CHECK (true);
CREATE POLICY "hero_anon_update"  ON public.hero_section FOR UPDATE USING (true);
INSERT INTO public.hero_section (brand_name) VALUES ('Chrixlin AI Rise') ON CONFLICT DO NOTHING;

-- ── TABLE 9: stat_items ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.stat_items (
  id          BIGINT      PRIMARY KEY,
  value       TEXT        NOT NULL DEFAULT '',
  label       TEXT        NOT NULL DEFAULT '',
  sort_order  INTEGER     NOT NULL DEFAULT 0,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_stat_updated_at BEFORE UPDATE ON public.stat_items FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.stat_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "stat_public_read"  ON public.stat_items FOR SELECT USING (true);
CREATE POLICY "stat_anon_insert"  ON public.stat_items FOR INSERT WITH CHECK (true);
CREATE POLICY "stat_anon_update"  ON public.stat_items FOR UPDATE USING (true);
CREATE POLICY "stat_anon_delete"  ON public.stat_items FOR DELETE USING (true);
INSERT INTO public.stat_items (id, value, label, sort_order) VALUES
  (1, '160+',   'Entrepreneurs Trained',      1),
  (2, '$1.8M+', 'Mentee Revenue Generated',   2),
  (3, '60',     'Days Avg. to First Client',  3),
  (4, '4.9★',   'Average Mentor Rating',      4)
ON CONFLICT (id) DO NOTHING;

-- ── TABLE 10: story_items ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.story_items (
  id          BIGINT      PRIMARY KEY,
  year        TEXT        NOT NULL DEFAULT '',
  title       TEXT        NOT NULL DEFAULT '',
  body        TEXT        NOT NULL DEFAULT '',
  sort_order  INTEGER     NOT NULL DEFAULT 0,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_story_updated_at BEFORE UPDATE ON public.story_items FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.story_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "story_public_read"  ON public.story_items FOR SELECT USING (true);
CREATE POLICY "story_anon_insert"  ON public.story_items FOR INSERT WITH CHECK (true);
CREATE POLICY "story_anon_update"  ON public.story_items FOR UPDATE USING (true);
CREATE POLICY "story_anon_delete"  ON public.story_items FOR DELETE USING (true);
INSERT INTO public.story_items (id, year, title, body, sort_order) VALUES
  (1, '2020',      'The Beginning',             'Broke college student with big ambitions. Discovered that businesses would pay premium prices for automation tools.',                                       1),
  (2, '2021',      'First Big Win',              'Built a PS5 automation tool during the GPU shortage. First taste of what AI bots could generate.',                                                       2),
  (3, '2022–2023', 'Scaling to $150K',           'By senior year, crossed $150,000 in revenue. Word spread fast — people wanted to learn the playbook.',                                                  3),
  (4, '2024–2025', 'Chrixlin AI Rise Launch',    'Launched the mentorship program. Featured in Business Insider. 160+ students, $1.8M+ in combined revenue.',                                             4)
ON CONFLICT (id) DO NOTHING;

-- ── TABLE 11: process_steps ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.process_steps (
  id          BIGINT      PRIMARY KEY,
  num         TEXT        NOT NULL DEFAULT '',
  week_label  TEXT        NOT NULL DEFAULT '',
  title       TEXT        NOT NULL DEFAULT '',
  body        TEXT        NOT NULL DEFAULT '',
  sort_order  INTEGER     NOT NULL DEFAULT 0,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_process_updated_at BEFORE UPDATE ON public.process_steps FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.process_steps ENABLE ROW LEVEL SECURITY;
CREATE POLICY "process_public_read"  ON public.process_steps FOR SELECT USING (true);
CREATE POLICY "process_anon_insert"  ON public.process_steps FOR INSERT WITH CHECK (true);
CREATE POLICY "process_anon_update"  ON public.process_steps FOR UPDATE USING (true);
CREATE POLICY "process_anon_delete"  ON public.process_steps FOR DELETE USING (true);
INSERT INTO public.process_steps (id, num, week_label, title, body, sort_order) VALUES
  (1, '01', 'Week 1–2', 'Strategy & Foundation',   'Book your free call. We build your personalized 60-day AI business roadmap based on your skills, goals, and timeline. Zero guesswork.',                                         1),
  (2, '02', 'Week 2–4', 'Build & Master AI Tools',  'Learn the exact AI tools clients pay $2,000–$10,000+ for. Build real projects under mentor guidance. No tutorials — actual deliverables.',                                     2),
  (3, '03', 'Week 4+',  'Get Clients & Scale',       'Start earning with live paid projects. We personally connect you with clients. Hit your income targets and scale to $5K–$50K/mo.',                                              3)
ON CONFLICT (id) DO NOTHING;

-- ── TABLE 12: feature_items ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.feature_items (
  id          BIGINT      PRIMARY KEY,
  icon        TEXT        NOT NULL DEFAULT '🎯',
  title       TEXT        NOT NULL DEFAULT '',
  body        TEXT        NOT NULL DEFAULT '',
  sort_order  INTEGER     NOT NULL DEFAULT 0,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_feature_updated_at BEFORE UPDATE ON public.feature_items FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.feature_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "feature_public_read"  ON public.feature_items FOR SELECT USING (true);
CREATE POLICY "feature_anon_insert"  ON public.feature_items FOR INSERT WITH CHECK (true);
CREATE POLICY "feature_anon_update"  ON public.feature_items FOR UPDATE USING (true);
CREATE POLICY "feature_anon_delete"  ON public.feature_items FOR DELETE USING (true);
INSERT INTO public.feature_items (id, icon, title, body, sort_order) VALUES
  (1, '🎯', 'Personalized Strategy Call', 'A custom 60-day business roadmap tailored to your background, skills, and income goals. Not a generic plan.',            1),
  (2, '📹', 'Weekly Live Coaching',        'Group sessions covering AI tools, client acquisition, pricing strategies, and scaling your business.',                   2),
  (3, '💼', 'Real Client Projects',        'Access to live paid projects starting Week 4. We make warm introductions — you close and deliver.',                      3),
  (4, '🤝', '1-on-1 Mentorship',           'Direct access to mentors who have built $50K+/month AI businesses. Get unstuck fast.',                                  4),
  (5, '🛠️', 'Done-With-You Support',       'We don''t just teach. We roll up our sleeves and help you build and deliver your first projects.',                      5),
  (6, '🏆', 'Private Community',           'Network with 160+ AI entrepreneurs. Share wins, get feedback, find accountability partners.',                            6)
ON CONFLICT (id) DO NOTHING;

-- ── TABLE 13: testimonial_items ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.testimonial_items (
  id          BIGINT      PRIMARY KEY,
  name        TEXT        NOT NULL DEFAULT '',
  role        TEXT        NOT NULL DEFAULT '',
  emoji       TEXT        NOT NULL DEFAULT '👤',
  result      TEXT        NOT NULL DEFAULT '',
  quote       TEXT        NOT NULL DEFAULT '',
  stars       INTEGER     NOT NULL DEFAULT 5,
  sort_order  INTEGER     NOT NULL DEFAULT 0,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_testimonial_updated_at BEFORE UPDATE ON public.testimonial_items FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.testimonial_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "testimonial_public_read"  ON public.testimonial_items FOR SELECT USING (true);
CREATE POLICY "testimonial_anon_insert"  ON public.testimonial_items FOR INSERT WITH CHECK (true);
CREATE POLICY "testimonial_anon_update"  ON public.testimonial_items FOR UPDATE USING (true);
CREATE POLICY "testimonial_anon_delete"  ON public.testimonial_items FOR DELETE USING (true);
INSERT INTO public.testimonial_items (id, name, role, emoji, result, quote, stars, sort_order) VALUES
  (1, 'Shubham S.', 'Software Engineer @ Big Tech',  '👨‍💻', '$0 → $120,000+ in profits', 'I was skeptical — I already had a good job. But within 8 weeks I was earning an extra $12,000 a month. The mentorship showed me exactly how to package my existing skills for premium AI clients.', 5, 1),
  (2, 'Ilya P.',    'Former Food Delivery Driver',    '🚗',   '$0 → $100,000+ in profits', 'I had zero tech background. The program walked me through everything step by step. I made $1,000 in my very first day selling an AI QR generator. It changed my entire life trajectory.', 5, 2),
  (3, 'Ron M.',     'College Student',                '🎓',   '$0 → $30,000+ secured',     'While my classmates were applying for $15/hr internships, I closed my first $25,000 AI development project. This is the best investment I''ve made in my college career, bar none.', 5, 3),
  (4, 'Sarah C.',   'Former Marketing Manager',       '💼',   '$0 → $30K+/month agency',   'I quit my corporate job after 3 months in the program. I was terrified at first, but the risk-free model made it easy to start. Now I run a full AI agency making $30K+ a month on my own terms.', 5, 4)
ON CONFLICT (id) DO NOTHING;

-- ── TABLE 14: for_who_items ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.for_who_items (
  id          BIGINT      PRIMARY KEY,
  icon        TEXT        NOT NULL DEFAULT '🏢',
  title       TEXT        NOT NULL DEFAULT '',
  body        TEXT        NOT NULL DEFAULT '',
  sort_order  INTEGER     NOT NULL DEFAULT 0,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_for_who_updated_at BEFORE UPDATE ON public.for_who_items FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.for_who_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "for_who_public_read"  ON public.for_who_items FOR SELECT USING (true);
CREATE POLICY "for_who_anon_insert"  ON public.for_who_items FOR INSERT WITH CHECK (true);
CREATE POLICY "for_who_anon_update"  ON public.for_who_items FOR UPDATE USING (true);
CREATE POLICY "for_who_anon_delete"  ON public.for_who_items FOR DELETE USING (true);
INSERT INTO public.for_who_items (id, icon, title, body, sort_order) VALUES
  (1, '🏢', '9-5 Employees',     'Tired of trading time for money. Ready to build a business that generates income while you sleep.',                    1),
  (2, '🎓', 'College Students',  'Build real income and high-demand skills while your peers are still figuring out their career.',                      2),
  (3, '💻', 'Freelancers',       'Level up from generic gigs to high-value AI development projects that pay 10x more.',                                3),
  (4, '⚙️', 'Tech Professionals','Monetize your existing skills in the fastest-growing market before your role gets automated.',                       4)
ON CONFLICT (id) DO NOTHING;

-- ── TABLE 15: faq_items ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.faq_items (
  id          BIGINT      PRIMARY KEY,
  question    TEXT        NOT NULL DEFAULT '',
  answer      TEXT        NOT NULL DEFAULT '',
  sort_order  INTEGER     NOT NULL DEFAULT 0,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_faq_updated_at BEFORE UPDATE ON public.faq_items FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
ALTER TABLE public.faq_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "faq_public_read"  ON public.faq_items FOR SELECT USING (true);
CREATE POLICY "faq_anon_insert"  ON public.faq_items FOR INSERT WITH CHECK (true);
CREATE POLICY "faq_anon_update"  ON public.faq_items FOR UPDATE USING (true);
CREATE POLICY "faq_anon_delete"  ON public.faq_items FOR DELETE USING (true);
INSERT INTO public.faq_items (id, question, answer, sort_order) VALUES
  (1, 'Do I need any coding or technical experience to start?',
      'None at all. Many of our most successful students started with zero technical background. The program teaches you exactly what you need at your own pace. What matters is your commitment and drive — not your current skill level.', 1),
  (2, 'What''s the difference between the Free Strategy Call and the paid plans?',
      'The Free Strategy Call is a zero-pressure 30-minute consultation where we map out your AI business roadmap — no credit card needed. The AI Starter ($197/mo) gives you full curriculum access, weekly group coaching, and templates. The AI Accelerator ($497/mo) adds 2× weekly 1-on-1 mentorship, direct client introductions, done-with-you project delivery, and an income guarantee.', 2),
  (3, 'How soon can I expect to land my first paying client?',
      'Most students who commit to the program land their first paid project between weeks 4 and 8. We actively make warm client introductions so you''re not starting from scratch. Some students close their first deal even sooner.', 3),
  (4, 'What kind of AI products will I be building and selling?',
      'You''ll build and sell AI voice assistants, chatbots, sales automation tools, lead generation systems, custom AI agents, and workflow automations. These are tools real businesses pay $2,000–$15,000+ per project for.', 4),
  (5, 'How much time do I need to commit each week?',
      'We recommend 8–12 hours per week to get the most out of the program. This includes live coaching sessions (2–3 hrs), self-paced learning, and project work. Many students do this while working a full-time job.', 5),
  (6, 'Is there a refund policy?',
      'Yes. We offer a 30-day satisfaction guarantee. If you complete the onboarding, attend at least 2 coaching sessions, and don''t feel the program is delivering value, we''ll give you a full refund — no questions asked.', 6),
  (7, 'Can I switch between Monthly and Yearly billing?',
      'Yes. You can start on the monthly plan and upgrade to yearly at any time to lock in the savings. Our team will handle the transition and credit any unused portion of your monthly subscription.', 7),
  (8, 'What AI tools and platforms do you teach?',
      'We cover Make.com, Zapier, Voiceflow, Botpress, OpenAI API, Retell AI, Vapi, and more. The curriculum is updated regularly as new tools emerge. You''ll learn whichever tools are most in-demand with paying clients right now.', 8)
ON CONFLICT (id) DO NOTHING;
