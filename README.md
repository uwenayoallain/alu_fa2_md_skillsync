# SkillSync

SkillSync connects ALU students seeking internship experience with **verified
student-led startups** in the ALU ecosystem. Startups post opportunities;
students discover, save and apply for them, and track their applications
through a live review pipeline.

Built with **Flutter**, **Firebase** (Authentication + Cloud Firestore) and
**Riverpod** state management.

## The problem it solves

Many ALU students struggle to land internships at established companies, while
student founders on campus need help with engineering, design, marketing,
research and operations. SkillSync bridges that gap — and solves the trust
problem with an **admin verification gate**: startups register freely but can
only post opportunities after the ALU venture team flips their `verified` flag
(enforced server-side by Firestore security rules, not just UI).

## Feature highlights

- Email/password **authentication** with role-based onboarding (student / founder)
- **Startup verification** workflow — pending startups see a live banner that
  disappears the instant an admin verifies them from the Firebase console
- Opportunity **posting, editing, closing and deleting** (full CRUD)
- **Discovery**: instant search plus category and commitment filters
- **Skill matching**: a "Recommended for you" rail ranked by overlap between
  the student's skills and each opportunity's required skills
- **Applications** with a short pitch, live status pipeline
  (submitted → under review → shortlisted → accepted/not selected) and withdrawal
- **Bookmarks**, live profile stats, and real-time updates on every screen
  (all lists are Firestore snapshot streams)

## Architecture

```
lib/
├── main.dart                  # Firebase init + ProviderScope
├── core/                      # theme, constants, validators, shared widgets
├── models/                    # AppUser, Startup, Opportunity, Application
├── data/repositories.dart     # ONLY place that talks to Firebase
├── providers/providers.dart   # Riverpod graph (streams + UI state notifiers)
└── features/
    ├── auth/                  # login, signup, onboarding, AuthGate router
    ├── student/               # home, explore, detail, applications, profile
    └── founder/               # dashboard, post form, applicants, startup profile
```

**State management:** UI watches Riverpod providers; providers derive from
repository streams; repositories wrap Firestore. Widgets never import
Firebase directly. `AuthGate` watches the auth stream and swaps the entire
shell on login/logout/role changes — no manual navigation.

**Firestore collections:** `users`, `startups`, `opportunities`,
`applications` (flat, top-level; identifying fields are denormalised onto
opportunities/applications so each list screen is a single query).

**Security rules** (`firestore.rules`) enforce: profile writes only by owner,
`verified` can never be changed by a client, only owners of *verified*
startups can post, and application status changes are restricted to the
startup owner.

## Running

```bash
flutter pub get
flutter run          # on an Android emulator or device
flutter test         # unit + widget tests
```

Firebase project: `skillsync-app-e7ae7` (config in `lib/firebase_options.dart`,
rules/indexes deployable with `firebase deploy --only firestore`).

### Demoing the verification flow

Sign up as a founder and register a startup — it starts **unverified** (the
dashboard shows a pending banner and posting is locked). Then, in the Firebase
console, open the startup's document under `startups/` and set
`verified = true`: the banner disappears and posting unlocks in real time,
with no refresh. The `verified` flag cannot be set from the client — the
security rules reject it.
