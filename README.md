# PROJECT: INSTITUTION OPERATING SYSTEM (IOS)

**Platform:** Hybrid (Web & App functioning on the same database).

---

## 1. ലോഗിൻ സംവിധാനം (THE NEW LOGIN FLOW)

ഇതാണ് സിസ്റ്റത്തിന്റെ ഏറ്റവും വലിയ പ്രത്യേകത. ലോഗിൻ പേജ് "സ്മാർട്ട്" ആയി പ്രവർത്തിക്കും.

**Step 1:** പബ്ലിക് പേജിലെ **Login Button** ക്ലിക്ക് ചെയ്യുന്നു.  
**Step 2:** സ്ക്രീനിൽ രണ്ട് ഓപ്ഷനുകൾ തെളിയുന്നു:

1. **Student / Parent**
2. **Management / Staff**

### Case A: Student/Parent തിരഞ്ഞെടുക്കുന്നു

1. **Select Class:** ആദ്യം ഒരു ഡ്രോപ്പ് ഡൗണിൽ നിന്ന് ക്ലാസ്സ് തിരഞ്ഞെടുക്കുന്നു (ഉദാ: Class 10 A).
2. **Select Name:** ക്ലാസ്സ് സെലക്ട് ചെയ്ത ഉടനെ, അതിലെ കുട്ടികളുടെ പേര് മാത്രം ലോഡ് ആകും.
   - അവിടെ പേര് ടൈപ്പ് ചെയ്യുമ്പോൾ **Auto-suggestion** വരും.
   - ലിസ്റ്റിൽ നിന്ന് സ്വന്തം പേര് സെലക്ട് ചെയ്യുക.
3. **Password:** അവിടെ രജിസ്റ്റർ ചെയ്ത **ഫോൺ നമ്പർ** പാസ്‌വേഡ് ആയി നൽകുക.
4. **Action:** ശരിയാണെങ്കിൽ **Student Dashboard**-ലേക്ക് പോകുന്നു.

### Case B: Management/Staff തിരഞ്ഞെടുക്കുന്നു

1. **Search Name:** പേര് ടൈപ്പ് ചെയ്യുമ്പോൾ തന്നെ സിസ്റ്റത്തിൽ ഉള്ള സ്റ്റാഫിന്റെ പേരുകൾ **Auto-suggestion** ആയി വരും.
2. **Select Name:** സ്വന്തം പേര് ലിസ്റ്റിൽ നിന്ന് സെലക്ട് ചെയ്യുക.
3. **Password:** അഡ്മിൻ ഇവർക്ക് വേണ്ടി പ്രത്യേകം സെറ്റ് ചെയ്ത **Custom Password** ടൈപ്പ് ചെയ്യുക. (ഫോൺ നമ്പർ അല്ല).
4. **Action:** റോൾ അനുസരിച്ച് (Staff or Admin) അതാത് ഡാഷ്ബോർഡിലേക്ക് പോകുന്നു.

---

## 2. മൊഡ്യൂളുകൾ (DETAILED MODULES)

### A. PUBLIC PAGE (Web & App Start)

ലോഗിൻ ചെയ്യുന്നതിന് മുൻപ് എല്ലാവരും കാണുന്ന പേജ്.

**ഉള്ളടക്കം (12 Sections):**
1. **Header:** Logo, Name, **Login Button**.
2. **Hero:** Welcome Banner.
3. **About:** Institution Details.
4. **Management & Staff:** Photos & Roles.
5. **Academic:** Courses Offered.
6. **Gallery:** Photos.
7. **Notices:** Public Announcements.
8. **Why Choose Us:** Highlights.
9. **FAQ & Enquiry:** Questions & Form.
10. **CTA:** Login Prompt.
11. **Contact:** Address & Map.
12. **Footer:** Social Media & Copyright.

---

### B. ADMIN PANEL (Owner/Principal)

പൂർണ്ണ നിയന്ത്രണം ഇവിടെയാണ്.

**പ്രധാന മാറ്റം (HR Tab):** സ്റ്റാഫിനെയും മാനേജ്മെന്റിനെയും ചേർക്കുമ്പോൾ **Password** സെറ്റ് ചെയ്യാനുള്ള ഫീൽഡ് ഉണ്ടാകും.

**Tabs:**
1. **Dashboard:** മൊത്തം കണക്കുകൾ.
2. **Academic Year:** വർഷം സെറ്റ് ചെയ്യുക.
3. **HR Management (Staff & Mgmt):**
   - Add Member (Name, Role, Phone, **Set Password**).
   - ഇവിടെ കൊടുക്കുന്ന പാസ്‌വേഡ് ആണ് അവർ ലോഗിൻ ചെയ്യാൻ ഉപയോഗിക്കുക.
4. **Student Management:** കുട്ടിയെ ചേർക്കുക (Name, Class, Phone).
5. **Fee Structure:** ഫീസ് പ്ലാനുകൾ ഉണ്ടാക്കുക.
6. **Public Content:** വെബ്സൈറ്റ് നിയന്ത്രിക്കുക.
7. **Reports:** വരവ്/ചെലവ് റിപ്പോർട്ടുകൾ.

---

### C. STAFF & MANAGEMENT PANEL (Employees)

ഇവർക്ക് നൽകിയിരിക്കുന്ന പാസ്‌വേഡ് ഉപയോഗിച്ച് ലോഗിൻ ചെയ്യുന്നു.

**പ്രവർത്തനങ്ങൾ:**
1. **Dashboard:** സ്വന്തം ഡ്യൂട്ടികൾ, പിരിച്ച ഫീസ്.
2. **Fee Collection (Main Job):**
   - കുട്ടിയെ സെലക്ട് ചെയ്യുക -> ഫീസ് അടയ്ക്കുക -> സേവ് ചെയ്യുക.
   - *Condition:* താൻ ചെയ്ത എൻട്രി മാത്രമേ എഡിറ്റ് ചെയ്യാൻ പറ്റൂ.
3. **Student List:** കുട്ടികളുടെ വിവരങ്ങൾ കാണുക (View Only).
4. **Notices:** ഓഫീസിൽ നിന്നുള്ള അറിയിപ്പുകൾ.
5. **Profile:** സ്വന്തം വിവരങ്ങൾ.

---

### D. STUDENT PANEL (View Only)

കുട്ടികൾ ക്ലാസ്സ് -> പേര് -> ഫോൺ നമ്പർ വഴി ലോഗിൻ ചെയ്യുന്നു.

**കാണുന്ന കാര്യങ്ങൾ:**
1. **Fee Status:** അടച്ച ഫീസ്, ബാക്കിയുള്ള ഫീസ്.
2. **Profile:** സ്വന്തം വിവരങ്ങൾ.
3. **Notices:** തനിക്ക് വന്ന അറിയിപ്പുകൾ.

*ഇവർക്ക് ഒന്നും എഡിറ്റ് ചെയ്യാൻ അനുവാദമില്ല.*

---

## 3. ടെക്നിക്കൽ പ്ലാൻ (TECHNICAL STRUCTURE)

```
lib/
├── main.dart                  (Checks Platform -> Loads Public Page)
├── config/
│   ├── routes.dart            (Navigation Paths)
│   └── theme.dart             (Colors & Styles)
│
├── auth/
│   ├── login_page.dart        (The NEW Login Logic Screen)
│   └── auth_service.dart      (Check Password/Phone logic)
│
├── public/
│   ├── public_page.dart       (Main Website View)
│   └── sections/              (Header, Hero, About, Footer...)
│
├── admin/
│   ├── admin_dashboard.dart
│   └── tabs/                  (HR_with_password, Fee, Students...)
│
├── staff/
│   ├── staff_dashboard.dart
│   └── tabs/                  (Fee Entry, Student List...)
│
└── student/
    ├── student_dashboard.dart (Fee Status View)
```
