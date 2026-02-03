# MVP Scope & File Responsibilities

ഈ ഡോക്യൂമെന്റ് നിലവിലെ **MVP** (Minimum Viable Product) എന്താണെന്നും, ഓരോ ഫയലും എന്ത് ജോലി ചെയ്യുന്നു എന്നതിന്റെ വിശദീകരണവും നൽകുന്നു.

---

## 🎯 MVP (ഇപ്പോൾ പൂർത്തിയാക്കേണ്ട ഫീച്ചറുകൾ)

### 1) Public Landing Page (Web + App Start)
- **Header + Hero + CTA** വഴി ഉപയോക്താവിനെ Login flow‑ലേക്ക് നയിക്കുക.
- Public‑page ഉള്ള 12 sections സ്ക്രീനിൽ പ്രദർശിപ്പിക്കുക.

### 2) Smart Login Flow
**Student/Parent:**
- Class തിരഞ്ഞെടുക്കുക → Name auto‑suggestion → Phone number password.

**Management/Staff:**
- Staff name auto‑suggestion → Custom password.

### 3) Role Dashboards (View Only)
- **Admin Dashboard**: key tiles + summary card.
- **Staff Dashboard**: fee collection flow‑ക്ക് placeholder tiles.
- **Student Dashboard**: fee status/profile/notices tiles.

### 4) Firebase Readiness (Web)
- Firebase initialize ചെയ്യപ്പെടണം (web config).

---

## 📁 File‑wise Responsibilities

### `lib/main.dart`
- Firebase initialize ചെയ്യുന്നു.
- App shell & routes load ചെയ്യുന്നു.

### `lib/firebase_options.dart`
- Firebase Web config values സംഭരിക്കുന്നു.

### `lib/config/routes.dart`
- Routes map → Public, Login, Admin, Staff, Student pages.

### `lib/config/theme.dart`
- UI theme (colors, cards, inputs, buttons).

---

## 🔐 Login Flow

### `lib/auth/login_page.dart`
- Role selection (Student / Staff).
- Student flow: Class → Name auto‑complete → Phone password.
- Staff flow: Name auto‑complete → Custom password.
- Validation + navigation to role dashboard.

---

## 🌐 Public Page

### `lib/public/public_page.dart`
- Public home page layout.
- Header/Hero/CTA click‑ൽ login page തുറക്കുന്നു.

### `lib/public/sections/*`
Public page‑ലെ ഓരോ section‑വും ഫയലായി സൂക്ഷിക്കുന്നു.

### `lib/public/sections/section_card.dart`
Reusable section card UI (icon + title + subtitle).

---

## 🧭 Dashboards (MVP placeholders)

### `lib/admin/admin_dashboard.dart`
- Admin summary + modules list.

### `lib/staff/staff_dashboard.dart`
- Staff summary + tasks tiles.

### `lib/student/student_dashboard.dart`
- Student summary + view‑only tiles.

---

## ✅ അടുത്ത ഘട്ടങ്ങൾ (Post‑MVP)
- Firebase Auth + Firestore models.
- Real data collections (students, staff, fees).
- Role‑based access control.
- Admin HR module with password setup.
