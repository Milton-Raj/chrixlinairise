// ═══════════════════════════════════════════════════════════════════
// supabase-client.js  —  Chrixlin AI Rise
// Vanilla JS, no npm. Falls back to localStorage on any Supabase error.
//
// Add to every HTML page BEFORE the inline <script>:
//   <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js"></script>
//   <script src="supabase-client.js"></script>
// ═══════════════════════════════════════════════════════════════════

(function (global) {
  'use strict';

  const SUPABASE_URL      = 'https://rciiztibyicwymrvsorr.supabase.co';
  const SUPABASE_ANON_KEY = 'sb_publishable_-GeJmorCfVyDgjSIZuPV6A_Zx79rOLf';

  const LS = {
    SITE_DATA:    'agentrise_data',
    TEXT_KEYS:    'agentrise_textkeys',
    THEME:        'agentrise_theme',
    THEME_CSS:    'agentrise_theme_css',
    MARKETPLACE:  'chrixlin_marketplace',
    PRICING:      'chrixlin_pricing',
    BANK_DETAILS: 'chrixlin_bank_details',
  };

  let _sb = null;
  function _getClient() {
    if (_sb) return _sb;
    try {
      if (typeof supabase !== 'undefined' && supabase.createClient) {
        _sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
      }
    } catch (e) {
      console.warn('[ChrixlinDB] Supabase client init failed, using localStorage only.', e);
    }
    return _sb;
  }

  // ─── GENERIC SITE SETTINGS ───────────────────────────────────────
  async function loadFromSupabase(table, key) {
    const client = _getClient();
    if (!client) return _lsGet(key);
    try {
      const { data, error } = await client.from(table).select('value_json').eq('key', key).single();
      if (error) throw error;
      return data ? data.value_json : null;
    } catch (err) {
      console.warn(`[ChrixlinDB] loadFromSupabase(${table}, ${key}) failed.`, err);
      return _lsGet(key);
    }
  }

  async function saveToSupabase(table, key, data) {
    _lsSet(key, data);
    const client = _getClient();
    if (!client) return false;
    try {
      const { error } = await client.from(table).upsert({ key, value_json: data }, { onConflict: 'key' });
      if (error) throw error;
      return true;
    } catch (err) {
      console.warn(`[ChrixlinDB] saveToSupabase(${table}, ${key}) failed.`, err);
      return false;
    }
  }

  // ─── MARKETPLACE PRODUCTS ─────────────────────────────────────────
  async function loadAllProducts() {
    const client = _getClient();
    if (!client) return _lsGetProducts();
    try {
      const { data, error } = await client.from('marketplace_products').select('*').eq('is_active', true).order('sort_order', { ascending: true }).order('id', { ascending: true });
      if (error) throw error;
      const products = (data || []).map(_rowToProduct);
      const blob = _lsGetMPBlob(); blob.products = products; _lsSetMPBlob(blob);
      return products;
    } catch (err) {
      console.warn('[ChrixlinDB] loadAllProducts() failed.', err);
      return _lsGetProducts();
    }
  }

  async function upsertProduct(product) {
    const blob = _lsGetMPBlob();
    const idx = blob.products.findIndex(p => p.id === product.id);
    if (idx !== -1) blob.products[idx] = product; else blob.products.push(product);
    _lsSetMPBlob(blob);
    const client = _getClient();
    if (!client) return false;
    try {
      const { error } = await client.from('marketplace_products').upsert(_productToRow(product), { onConflict: 'id' });
      if (error) throw error;
      return true;
    } catch (err) { console.warn('[ChrixlinDB] upsertProduct() failed.', err); return false; }
  }

  async function deleteProduct(id) {
    const blob = _lsGetMPBlob(); blob.products = blob.products.filter(p => p.id !== id); _lsSetMPBlob(blob);
    const client = _getClient();
    if (!client) return false;
    try {
      const { error } = await client.from('marketplace_products').delete().eq('id', id);
      if (error) throw error;
      return true;
    } catch (err) { console.warn('[ChrixlinDB] deleteProduct() failed.', err); return false; }
  }

  // ─── PRICING PLANS ───────────────────────────────────────────────
  async function loadAllPricingPlans() {
    const client = _getClient();
    if (!client) return _lsGetPlans();
    try {
      const { data, error } = await client.from('pricing_plans').select('*').eq('is_active', true).order('sort_order', { ascending: true });
      if (error) throw error;
      const plans = (data || []).map(_rowToPlan);
      localStorage.setItem(LS.PRICING, JSON.stringify(plans));
      return plans;
    } catch (err) { console.warn('[ChrixlinDB] loadAllPricingPlans() failed.', err); return _lsGetPlans(); }
  }

  async function upsertPricingPlan(plan) {
    const existing = _lsGetPlans();
    const isNew = !existing.find(p => p.id === plan.id);
    if (isNew && existing.length >= 3) { console.warn('[ChrixlinDB] Max 3 plans allowed.'); return false; }
    const idx = existing.findIndex(p => p.id === plan.id);
    if (idx !== -1) existing[idx] = plan; else existing.push(plan);
    localStorage.setItem(LS.PRICING, JSON.stringify(existing));
    const client = _getClient();
    if (!client) return false;
    try {
      const { error } = await client.from('pricing_plans').upsert(_planToRow(plan), { onConflict: 'id' });
      if (error) throw error;
      return true;
    } catch (err) { console.warn('[ChrixlinDB] upsertPricingPlan() failed.', err); return false; }
  }

  async function deletePricingPlan(id) {
    localStorage.setItem(LS.PRICING, JSON.stringify(_lsGetPlans().filter(p => p.id !== id)));
    const client = _getClient();
    if (!client) return false;
    try {
      const { error } = await client.from('pricing_plans').delete().eq('id', id);
      if (error) throw error;
      return true;
    } catch (err) { console.warn('[ChrixlinDB] deletePricingPlan() failed.', err); return false; }
  }

  // ─── PAYMENT SETTINGS ────────────────────────────────────────────
  async function loadPaymentSettings() {
    const client = _getClient();
    if (!client) return _lsGetBank();
    try {
      const { data, error } = await client.from('payment_settings').select('*').eq('profile_key', 'default').single();
      if (error) throw error;
      if (!data) return _lsGetBank();
      const bank = _rowToBank(data);
      localStorage.setItem(LS.BANK_DETAILS, JSON.stringify(bank));
      return bank;
    } catch (err) { console.warn('[ChrixlinDB] loadPaymentSettings() failed.', err); return _lsGetBank(); }
  }

  async function loadPublicPaymentSettings() {
    const client = _getClient();
    if (!client) return _lsGetBank();
    try {
      const { data, error } = await client.from('payment_settings_public').select('*').single();
      if (error) throw error;
      return data ? _rowToBank(data) : _lsGetBank();
    } catch (err) { console.warn('[ChrixlinDB] loadPublicPaymentSettings() failed.', err); return _lsGetBank(); }
  }

  async function savePaymentSettings(bankObj) {
    localStorage.setItem(LS.BANK_DETAILS, JSON.stringify(bankObj));
    const client = _getClient();
    if (!client) return false;
    try {
      const { error } = await client.from('payment_settings').upsert(_bankToRow(bankObj), { onConflict: 'profile_key' });
      if (error) throw error;
      return true;
    } catch (err) { console.warn('[ChrixlinDB] savePaymentSettings() failed.', err); return false; }
  }

  // ─── ORDERS ──────────────────────────────────────────────────────
  async function submitOrder(orderObj) {
    const client = _getClient();
    if (!client) return { success: false, orderId: null };
    try {
      const { data, error } = await client.from('orders').insert({
        order_ref: orderObj.orderRef, product_id: orderObj.productId || null,
        product_title: orderObj.productTitle || '', product_price: orderObj.productPrice || '',
        payment_method: orderObj.paymentMethod || 'card', first_name: orderObj.firstName || '',
        last_name: orderObj.lastName || '', email: orderObj.email || '', phone: orderObj.phone || '',
        country: orderObj.country || '', address: orderObj.address || '', city: orderObj.city || '',
        postcode: orderObj.postcode || '', notes: orderObj.notes || '',
        status: 'pending', extra_data: orderObj.extraData || {},
      }).select('id').single();
      if (error) throw error;
      return { success: true, orderId: data.id };
    } catch (err) { console.warn('[ChrixlinDB] submitOrder() failed.', err); return { success: false, orderId: null }; }
  }

  // ─── CONTACT MESSAGES ────────────────────────────────────────────
  async function submitContactMessage(msgObj) {
    const client = _getClient();
    if (!client) return false;
    try {
      const { error } = await client.from('contact_messages').insert({
        name: msgObj.name || '', email: msgObj.email || '', subject: msgObj.subject || '',
        message: msgObj.message || '', page: msgObj.page || '', extra_data: msgObj.extraData || {},
      });
      if (error) throw error;
      return true;
    } catch (err) { console.warn('[ChrixlinDB] submitContactMessage() failed.', err); return false; }
  }

  // ─── ADMIN AUTH ───────────────────────────────────────────────────
  async function adminSignIn(email, password) {
    const client = _getClient();
    if (!client) return { user: null, session: null, error: 'No client' };
    const { data, error } = await client.auth.signInWithPassword({ email, password });
    return { user: data?.user || null, session: data?.session || null, error };
  }
  async function adminSignOut() { const c = _getClient(); if (c) await c.auth.signOut(); }
  async function getSession() { const c = _getClient(); if (!c) return null; const { data } = await c.auth.getSession(); return data?.session || null; }

  // ─── CUSTOMER AUTH ────────────────────────────────────────────────
  async function customerSignUp(email, password, fullName) {
    const client = _getClient();
    if (!client) return { user: null, session: null, error: new Error('No client') };
    const { data, error } = await client.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    });
    return { user: data?.user || null, session: data?.session || null, error };
  }

  async function customerSignIn(email, password) {
    const client = _getClient();
    if (!client) return { user: null, session: null, error: new Error('No client') };
    const { data, error } = await client.auth.signInWithPassword({ email, password });
    return { user: data?.user || null, session: data?.session || null, error };
  }

  async function customerSignInWithGoogle() {
    const client = _getClient();
    if (!client) return { error: new Error('No client') };
    const { data, error } = await client.auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo: window.location.origin + '/dashboard.html' },
    });
    return { data, error };
  }

  async function customerSignOut() {
    const client = _getClient();
    if (client) await client.auth.signOut();
  }

  async function getCustomerSession() {
    const client = _getClient();
    if (!client) return null;
    const { data } = await client.auth.getSession();
    return data?.session || null;
  }

  async function getCustomerUser() {
    const client = _getClient();
    if (!client) return null;
    const { data } = await client.auth.getUser();
    return data?.user || null;
  }

  // ─── CUSTOMER ORDERS ──────────────────────────────────────────────
  async function createCustomerOrder(orderData) {
    const client = _getClient();
    if (!client) return { success: false, orderId: null };
    const session = await getCustomerSession();
    if (!session) return { success: false, orderId: null, error: 'Not authenticated' };
    try {
      const orderRef = `CAIR-${orderData.productId || 0}-${Date.now().toString(36).toUpperCase().slice(-6)}`;
      const numericAmount = parseFloat(String(orderData.amount || orderData.productPrice || '0').replace(/[^0-9.]/g, '')) || 0;
      const { data, error } = await client.from('customer_orders').insert({
        user_id:        session.user.id,
        order_ref:      orderRef,
        product_id:     orderData.productId   || null,
        product_title:  orderData.productTitle || '',
        product_price:  orderData.productPrice || '',
        payment_method: orderData.paymentMethod || 'bank_transfer',
        amount:         numericAmount,
        status:         'pending',
      }).select('id').single();
      if (error) throw error;
      return { success: true, orderId: data.id, orderRef };
    } catch (err) {
      console.warn('[ChrixlinDB] createCustomerOrder() failed.', err);
      return { success: false, orderId: null, error: err };
    }
  }

  async function getMyOrders() {
    const client = _getClient();
    if (!client) return [];
    try {
      const { data, error } = await client.from('customer_orders').select('*').order('created_at', { ascending: false });
      if (error) throw error;
      return data || [];
    } catch (err) {
      console.warn('[ChrixlinDB] getMyOrders() failed.', err);
      return [];
    }
  }

  async function getMyProfile() {
    const client = _getClient();
    if (!client) return null;
    const { data } = await client.auth.getUser();
    return data?.user || null;
  }

  async function updateMyProfile(profileData) {
    const client = _getClient();
    if (!client) return { error: new Error('No client') };
    const { data, error } = await client.auth.updateUser({ data: profileData });
    if (!error) await upsertMyProfile(profileData);
    return { user: data?.user || null, error };
  }

  // ─── PROFILES ────────────────────────────────────────────────────────────────
  // Upsert the current user's profile (called from dashboard after profile edit)
  async function upsertMyProfile(data) {
    // data: { full_name, phone, avatar_url }
    const client = _getClient();
    if (!client) return false;
    try {
      const { data: userData } = await client.auth.getUser();
      if (!userData?.user) return false;
      const { error } = await client.from('profiles').upsert({
        id: userData.user.id,
        email: userData.user.email || '',
        full_name: data.full_name || '',
        phone: data.phone || '',
        avatar_url: data.avatar_url || '',
      }, { onConflict: 'id' });
      if (error) throw error;
      return true;
    } catch (err) { console.warn('[ChrixlinDB] upsertMyProfile() failed.', err); return false; }
  }

  // Admin: get all profiles with order counts (calls SECURITY DEFINER function)
  async function adminGetAllProfiles() {
    const client = _getClient();
    if (!client) return [];
    try {
      const { data, error } = await client.rpc('get_all_profiles');
      if (error) throw error;
      return data || [];
    } catch (err) { console.warn('[ChrixlinDB] adminGetAllProfiles() failed.', err); return []; }
  }

  // Admin: get all orders with user info (calls SECURITY DEFINER function)
  async function adminGetAllOrders() {
    const client = _getClient();
    if (!client) return [];
    try {
      const { data, error } = await client.rpc('get_all_orders');
      if (error) throw error;
      return data || [];
    } catch (err) { console.warn('[ChrixlinDB] adminGetAllOrders() failed.', err); return []; }
  }

  // ─── SECTION CONTENT (landing page tables) ────────────────────────
  async function loadSectionItems(tableName) {
    const client = _getClient();
    if (!client) return null;
    try {
      const { data, error } = await client.from(tableName).select('*').order('sort_order', { ascending: true });
      if (error) throw error;
      return data || [];
    } catch (err) {
      console.warn('[ChrixlinDB] loadSectionItems(' + tableName + ') failed.', err);
      return null;
    }
  }

  async function saveSectionItems(tableName, items) {
    const client = _getClient();
    if (!client) return false;
    try {
      const { error } = await client.from(tableName).upsert(items, { onConflict: 'id' });
      if (error) throw error;
      return true;
    } catch (err) {
      console.warn('[ChrixlinDB] saveSectionItems(' + tableName + ') failed.', err);
      return false;
    }
  }

  async function loadHeroSection() {
    const client = _getClient();
    if (!client) return null;
    try {
      const { data, error } = await client.from('hero_section').select('*').single();
      if (error) throw error;
      return data;
    } catch (err) {
      console.warn('[ChrixlinDB] loadHeroSection() failed.', err);
      return null;
    }
  }

  async function saveHeroSection(heroObj) {
    const client = _getClient();
    if (!client) return false;
    try {
      const existing = await loadHeroSection();
      if (existing) {
        const { error } = await client.from('hero_section').update(heroObj).eq('id', existing.id);
        if (error) throw error;
      } else {
        const { error } = await client.from('hero_section').insert(heroObj);
        if (error) throw error;
      }
      return true;
    } catch (err) {
      console.warn('[ChrixlinDB] saveHeroSection() failed.', err);
      return false;
    }
  }

  // ─── MAPPERS ──────────────────────────────────────────────────────
  function _productToRow(p) {
    return { id: p.id, emoji: p.emoji||'🤖', badge: p.badge||'', category: p.category||'voice-ai', category_label: p.categoryLabel||'', category_class: p.categoryClass||'', price: p.price||'$999', title: p.title||'', description: p.desc||'', long_desc: p.longDesc||'', image_url: p.image||'', yt_id: p.ytId||'', buy_url: p.buyUrl||'', features: p.features||[], how_it_works: p.howItWorks||[], reviews: p.reviews||[], screenshots: p.screenshots||[], sort_order: p.sortOrder||0, is_active: p.isActive!==false };
  }
  function _rowToProduct(r) {
    return { id: r.id, emoji: r.emoji, badge: r.badge, category: r.category, categoryLabel: r.category_label, categoryClass: r.category_class, price: r.price, title: r.title, desc: r.description, longDesc: r.long_desc, image: r.image_url, ytId: r.yt_id, buyUrl: r.buy_url, features: r.features||[], howItWorks: r.how_it_works||[], reviews: r.reviews||[], screenshots: r.screenshots||[], sortOrder: r.sort_order, isActive: r.is_active };
  }
  function _planToRow(p) {
    return { id: p.id, name: p.name||'', price: String(p.price||''), price_label: p.priceLabel||'', period: p.period||'', badge: p.badge||'', badge_color: p.badgeColor||'', description: p.description||'', cta: p.cta||'Get Started', cta_link: p.ctaLink||'', is_highlighted: !!p.highlighted, features: p.features||[], sort_order: p.sortOrder||0, is_active: p.isActive!==false };
  }
  function _rowToPlan(r) {
    return { id: r.id, name: r.name, price: r.price, priceLabel: r.price_label, period: r.period, badge: r.badge, badgeColor: r.badge_color, description: r.description, cta: r.cta, ctaLink: r.cta_link, highlighted: r.is_highlighted, features: r.features||[], sortOrder: r.sort_order, isActive: r.is_active };
  }
  function _bankToRow(b) {
    return { profile_key: 'default', account_name: b.accountName||'', bank_name: b.bankName||'', account_number: b.accountNumber||'', sort_code: b.sortCode||'', iban: b.iban||'', swift: b.swift||'', ref_note: b.refNote||'', instructions: b.instructions||'', paypal_email: b.paypalEmail||'', paypal_link: b.paypalLink||'', crypto_type: b.cryptoType||'', crypto_address: b.cryptoAddress||'', contact_email: b.contactEmail||'', currency: b.currency||'$', success_msg: b.successMsg||'', refund_policy: b.refundPolicy||'' };
  }
  function _rowToBank(r) {
    return { accountName: r.account_name||'', bankName: r.bank_name||'', accountNumber: r.account_number||'', sortCode: r.sort_code||'', iban: r.iban||'', swift: r.swift||'', refNote: r.ref_note||'', instructions: r.instructions||'', paypalEmail: r.paypal_email||'', paypalLink: r.paypal_link||'', cryptoType: r.crypto_type||'', cryptoAddress: r.crypto_address||'', contactEmail: r.contact_email||'', currency: r.currency||'$', successMsg: r.success_msg||'', refundPolicy: r.refund_policy||'' };
  }

  // ─── localStorage FALLBACKS ───────────────────────────────────────
  function _lsGet(key) { try { return JSON.parse(localStorage.getItem(key)); } catch { return null; } }
  function _lsSet(key, value) { try { localStorage.setItem(key, JSON.stringify(value)); } catch {} }
  function _lsGetMPBlob() { try { const s = localStorage.getItem(LS.MARKETPLACE); return s ? JSON.parse(s) : { hero:{}, videos:[], products:[], book:{} }; } catch { return { hero:{}, videos:[], products:[], book:{} }; } }
  function _lsSetMPBlob(blob) { try { localStorage.setItem(LS.MARKETPLACE, JSON.stringify(blob)); } catch {} }
  function _lsGetProducts() { return _lsGetMPBlob().products || []; }
  function _lsGetPlans() { try { const s = localStorage.getItem(LS.PRICING); return s ? JSON.parse(s) : []; } catch { return []; } }
  function _lsGetBank() { try { const s = localStorage.getItem(LS.BANK_DETAILS); return s ? JSON.parse(s) : {}; } catch { return {}; } }

  // ─── PUBLIC API ───────────────────────────────────────────────────
  global.ChrixlinDB = {
    loadFromSupabase, saveToSupabase,
    loadAllProducts, upsertProduct, deleteProduct,
    loadAllPricingPlans, upsertPricingPlan, deletePricingPlan,
    loadPaymentSettings, loadPublicPaymentSettings, savePaymentSettings,
    submitOrder, submitContactMessage,
    adminSignIn, adminSignOut, getSession,
    loadSectionItems, saveSectionItems, loadHeroSection, saveHeroSection,
    // Customer Auth
    customerSignUp, customerSignIn, customerSignInWithGoogle,
    customerSignOut, getCustomerSession, getCustomerUser,
    // Customer Orders & Profile
    createCustomerOrder, getMyOrders, getMyProfile, updateMyProfile,
    upsertMyProfile, adminGetAllProfiles, adminGetAllOrders,
    _getClient,
  };

})(window);
