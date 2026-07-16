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
research and operations. SkillSync solves that problem with an **admin verification gate**: startups register freely but can
only post opportunities after the ALU venture team flips their `verified` flag.

## Feature highlights

- Email/password **authentication** with role-based onboarding (student / founder)
- **Startup verification** pending startups see a live banner that
  disappears the instant an admin verifies them from the Firebase console
- Opportunity **posting, editing, closing and deleting**
- **Discovery**: instant search plus category and commitment filters
- **Skill matching**: a "Recommended for you" rail ranked by overlap between
  the student's skills and each opportunity's required skills
- **Applications** with a short pitch, live status pipeline
  (submitted => under review => shortlisted => accepted/not selected) and withdrawal
- **Bookmarks**, live profile stats, and real-time updates on every screen

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

**State management:** UI watches Riverpod providers, providers derive from
repository streams, repositories wrap Firestore. `AuthGate` watches the auth stream and swaps the entire
shell on login/logout/role changes with no manual navigation.

**Firestore collections:** `users`, `startups`, `opportunities`,
`applications` (top level).

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
