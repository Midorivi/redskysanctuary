# Decisions — Red Sky Sanctuary iOS App

## Architecture
- SwiftData + CloudKit (not Firebase, not Supabase, not custom backend)
- Offline-first: local DB is source of truth
- MVVM with @Observable (not TCA — overkill for 2 users)
- No SPM modules — single Xcode target for simplicity
- 5-tab navigation: Dashboard, Animals, Tasks, Supplies, More
