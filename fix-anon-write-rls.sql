-- ─────────────────────────────────────────────────────────────────────────
-- CRITICAL SECURITY FIX: lock down anonymous write access
--
-- The following tables currently allow ANY visitor (using the public anon
-- key that ships in supabase-client.js) to INSERT / UPDATE / DELETE rows
-- directly, with no login required — the admin.html login screen is only
-- a client-side UI gate and does nothing to stop this. Anyone with basic
-- browser dev tools knowledge can rewrite your entire site content,
-- change the booking link, wipe your Projects, edit pricing, or alter
-- your Terms/Privacy pages.
--
-- This script drops those permissive policies and replaces them with
-- policies that require a real authenticated Supabase session — exactly
-- what admin.html already establishes via auth.signInWithPassword(), so
-- your admin panel keeps working normally. Public SELECT (read) access
-- is left untouched since the site needs it to render for visitors.
--
-- Run this once in the Supabase SQL Editor for your project.
-- ─────────────────────────────────────────────────────────────────────────

-- site_settings (booking link, tracking IDs, terms, privacy, theme, SEO, etc.)
DROP POLICY IF EXISTS "site_settings_anon_write"  ON public.site_settings;
DROP POLICY IF EXISTS "site_settings_anon_update" ON public.site_settings;
CREATE POLICY "site_settings_auth_insert" ON public.site_settings FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "site_settings_auth_update" ON public.site_settings FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "site_settings_auth_delete" ON public.site_settings FOR DELETE USING (auth.role() = 'authenticated');

-- marketplace_products (Projects listings)
DROP POLICY IF EXISTS "mp_products_anon_insert" ON public.marketplace_products;
DROP POLICY IF EXISTS "mp_products_anon_update" ON public.marketplace_products;
DROP POLICY IF EXISTS "mp_products_anon_delete" ON public.marketplace_products;
CREATE POLICY "mp_products_auth_insert" ON public.marketplace_products FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "mp_products_auth_update" ON public.marketplace_products FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "mp_products_auth_delete" ON public.marketplace_products FOR DELETE USING (auth.role() = 'authenticated');

-- marketplace_categories (Projects category tabs — only present if you ran setup-complete-db.sql)
-- Wrapped in a existence check so this script doesn't error if the table isn't present.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'marketplace_categories') THEN
    DROP POLICY IF EXISTS "mcat_anon_insert" ON public.marketplace_categories;
    DROP POLICY IF EXISTS "mcat_anon_update" ON public.marketplace_categories;
    DROP POLICY IF EXISTS "mcat_anon_delete" ON public.marketplace_categories;
    CREATE POLICY "mcat_auth_insert" ON public.marketplace_categories FOR INSERT WITH CHECK (auth.role() = 'authenticated');
    CREATE POLICY "mcat_auth_update" ON public.marketplace_categories FOR UPDATE USING (auth.role() = 'authenticated');
    CREATE POLICY "mcat_auth_delete" ON public.marketplace_categories FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- pricing_plans
DROP POLICY IF EXISTS "pricing_anon_insert" ON public.pricing_plans;
DROP POLICY IF EXISTS "pricing_anon_update" ON public.pricing_plans;
DROP POLICY IF EXISTS "pricing_anon_delete" ON public.pricing_plans;
CREATE POLICY "pricing_auth_insert" ON public.pricing_plans FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "pricing_auth_update" ON public.pricing_plans FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "pricing_auth_delete" ON public.pricing_plans FOR DELETE USING (auth.role() = 'authenticated');

-- hero_section
DROP POLICY IF EXISTS "hero_anon_insert" ON public.hero_section;
DROP POLICY IF EXISTS "hero_anon_update" ON public.hero_section;
CREATE POLICY "hero_auth_insert" ON public.hero_section FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "hero_auth_update" ON public.hero_section FOR UPDATE USING (auth.role() = 'authenticated');

-- stat_items
DROP POLICY IF EXISTS "stat_anon_insert" ON public.stat_items;
DROP POLICY IF EXISTS "stat_anon_update" ON public.stat_items;
DROP POLICY IF EXISTS "stat_anon_delete" ON public.stat_items;
CREATE POLICY "stat_auth_insert" ON public.stat_items FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "stat_auth_update" ON public.stat_items FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "stat_auth_delete" ON public.stat_items FOR DELETE USING (auth.role() = 'authenticated');

-- story_items
DROP POLICY IF EXISTS "story_anon_insert" ON public.story_items;
DROP POLICY IF EXISTS "story_anon_update" ON public.story_items;
DROP POLICY IF EXISTS "story_anon_delete" ON public.story_items;
CREATE POLICY "story_auth_insert" ON public.story_items FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "story_auth_update" ON public.story_items FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "story_auth_delete" ON public.story_items FOR DELETE USING (auth.role() = 'authenticated');

-- process_steps
DROP POLICY IF EXISTS "process_anon_insert" ON public.process_steps;
DROP POLICY IF EXISTS "process_anon_update" ON public.process_steps;
DROP POLICY IF EXISTS "process_anon_delete" ON public.process_steps;
CREATE POLICY "process_auth_insert" ON public.process_steps FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "process_auth_update" ON public.process_steps FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "process_auth_delete" ON public.process_steps FOR DELETE USING (auth.role() = 'authenticated');

-- feature_items
DROP POLICY IF EXISTS "feature_anon_insert" ON public.feature_items;
DROP POLICY IF EXISTS "feature_anon_update" ON public.feature_items;
DROP POLICY IF EXISTS "feature_anon_delete" ON public.feature_items;
CREATE POLICY "feature_auth_insert" ON public.feature_items FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "feature_auth_update" ON public.feature_items FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "feature_auth_delete" ON public.feature_items FOR DELETE USING (auth.role() = 'authenticated');

-- testimonial_items
DROP POLICY IF EXISTS "testimonial_anon_insert" ON public.testimonial_items;
DROP POLICY IF EXISTS "testimonial_anon_update" ON public.testimonial_items;
DROP POLICY IF EXISTS "testimonial_anon_delete" ON public.testimonial_items;
CREATE POLICY "testimonial_auth_insert" ON public.testimonial_items FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "testimonial_auth_update" ON public.testimonial_items FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "testimonial_auth_delete" ON public.testimonial_items FOR DELETE USING (auth.role() = 'authenticated');

-- for_who_items
DROP POLICY IF EXISTS "for_who_anon_insert" ON public.for_who_items;
DROP POLICY IF EXISTS "for_who_anon_update" ON public.for_who_items;
DROP POLICY IF EXISTS "for_who_anon_delete" ON public.for_who_items;
CREATE POLICY "for_who_auth_insert" ON public.for_who_items FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "for_who_auth_update" ON public.for_who_items FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "for_who_auth_delete" ON public.for_who_items FOR DELETE USING (auth.role() = 'authenticated');

-- faq_items (kept for legacy data even though the FAQ section was removed from the live site)
DROP POLICY IF EXISTS "faq_anon_insert" ON public.faq_items;
DROP POLICY IF EXISTS "faq_anon_update" ON public.faq_items;
DROP POLICY IF EXISTS "faq_anon_delete" ON public.faq_items;
CREATE POLICY "faq_auth_insert" ON public.faq_items FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "faq_auth_update" ON public.faq_items FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "faq_auth_delete" ON public.faq_items FOR DELETE USING (auth.role() = 'authenticated');

-- ─────────────────────────────────────────────────────────────────────────
-- After running this, verify: log into admin.html and confirm you can still
-- save each section (Hero, Stats, Story, Process, Features, Testimonials,
-- For Who, Projects, Pricing, Settings). If a save fails, it means your
-- admin session isn't authenticating as expected — check that admin.html's
-- login is completing supabase.auth.signInWithPassword() successfully.
-- ─────────────────────────────────────────────────────────────────────────
