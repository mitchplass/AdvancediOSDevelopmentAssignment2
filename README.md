# RideReady

RideReady is an iOS MVP that walks a motorbike rider through a bike-specific pre-ride safety check in under three minutes.

It is built for **Alex Nguyen**, the Assessment 1 stakeholder: a commuter on a Yamaha MT-07 who already knows he should check tyres, chain, and lights, but skips items when he is late. The app is a rider-safety tool for that morning walk-around, not a generic checklist or a service-interval log.

## Domain

Riders inspect the bike *before* they leave. The physical work stays with Alex (press tyres, look at the chain, check lights). RideReady’s job is to:

- match the checklist to **this** motorcycle (chain vs shaft/belt, saved tyre pressures, chain slack)
- stop him treating the bike as **ride ready** if something still needs attention
- keep a **calendar-day streak** so a second check on the same day does not count as a new safe-riding day
- show **not ride ready** on Home until today’s walk-around has been logged with every item OK

If those rules are wrong, Alex can leave on an unsafe bike. That is the real-world failure the architecture is built around.

## Architecture

Layers follow the assessment structure. Views never talk to the store. Business rules live in use cases, not in SwiftUI.

```
Views → ViewModels (MVVM) → Use Cases → Models → Data (RideReadyStoring)
```

| Layer | What it holds |
| --- | --- |
| **Views** | Rider language and navigation: Home, bike profile, pre-ride check, item detail, ride ready |
| **ViewModels** | Screen state; they call use cases and map results/errors for the UI |
| **Use Cases** | One business operation each, with rider-facing `LocalizedError` values |
| **Models** | `Motorcycle`, `InspectionItem`, `PreRideInspection`, `InspectionFinding`, `RideReadiness`, `SafetyStreak` |
| **Data** | `RideReadyStoring` protocol; `UserDefaultsRideReadyStore` persists JSON (and the optional bike photo as `Data`) |

### Use cases

1. **StartPreRideInspectionUseCase** — starts a walk-around. Fails if no motorcycle is set up, or if a check is already in progress.
2. **RecordInspectionFindingUseCase** — records OK or needs-attention for one item. Fails if no walk-around is active, or if the item does not belong on this bike (for example a chain check on a shaft-drive motorcycle).
3. **CompletePreRideInspectionUseCase** — logs the finished check as ride ready or not ride ready. Ride-ready is blocked while any item needs attention. The streak counts consecutive calendar days; a second completion the same day updates last-check time but does not increment the streak.
4. **SaveMotorcycleUseCase** — saves the bike profile (name, final drive, tyre PSI, chain slack, photo). Blocked while a walk-around is in progress so the in-progress checklist cannot drift off the bike Alex is actually inspecting.

## Screens

Aligned to the Assessment 1 lo-fi flow, plus the bike profile A1 called out as customisation:

1. **Home** — bike photo/name, ride-ready banner, streak, last check, start/continue
2. **Bike profile** — name, photo, chain/shaft/belt, tyre pressures, chain slack
3. **Pre-ride check** — progress and bike-specific items
4. **Item detail** — guidance (PSI / slack) and OK / Issue
5. **Ride ready** — log ride, or log as not ride ready

## Setup

1. Clone this repository and open `RideReady/RideReady.xcodeproj` in Xcode 26.
2. Select the **RideReady** scheme and an iOS Simulator (the project targets iOS 26.2).
3. Run the app. First launch seeds a Yamaha MT-07 if no motorcycle is stored yet. Edit the bike from Home → **Edit bike profile**.
4. Run tests with **Product → Test**, or:

```sh
xcodebuild test \
  -project RideReady/RideReady.xcodeproj \
  -scheme RideReady \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' \
  -parallel-testing-enabled NO
```

Data stays on device in `UserDefaults`. There is no backend.

## Tests

Unit tests cover use-case happy paths, domain failures, streak calendar boundaries, chain vs shaft items, and bike profile saves. Test names describe the rider scenario, not the assertion number.
