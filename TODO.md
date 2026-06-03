# Plan: Add Privacy Policy Page to Landing

## Information Gathered
- **Project Type:** Flutter Islamic app (IslamHome/بيت الإسلام) landing page
- **Current Structure:** Landing folder contains:
  - `index.html` - Main landing page
  - `app.js` - JavaScript with i18n translations (Arabic/English)
  - `styles.css` - Complete styling with RTL/LTR support
- **Design Pattern:** Uses glassmorphism, glass class, data-i18n attributes, RTL support via `document.dir`
- **Language System:** Bilingual (Arabic/English) with translations in `translations` object

## Plan

### Step 1: Create `privacy-policy.html`
Create a dedicated privacy policy page with:
- Same header/navbar as index.html
- Privacy policy content section with Arabic RTL layout
- Footer matching landing page
- Proper meta tags and SEO
- Link to main page

### Step 2: Create `privacy-policy.js`
Create JavaScript file with:
- Same language switching functionality
- Privacy policy translations (Arabic/English)
- Same utilities: language switch, scroll effects

### Step 3: Update `index.html`
- Add link to privacy policy page in footer under "Important Links"

### Step 4: Update `app.js`
- Add navigation keys for privacy policy page in translations

## Files to Create
1. `landing/privacy-policy.html` - Privacy policy page HTML
2. `landing/privacy-policy.js` - Privacy policy page JS

## Files to Edit
1. `landing/index.html` - Add privacy policy link
2. `landing/app.js` - Add navigation translation keys

## Status: COMPLETED ✅
- privacy-policy.html already existed with comprehensive content
- privacy-policy.js already existed with translations
- Added privacy policy link to index.html footer
- Added footer_privacy translation keys to both app.js and privacy-policy.js
