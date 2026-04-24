# iPhone Testing Before App Store Release

## Best path right now

For full private testing on your own phone, use **Xcode direct install** first.

### What you need
- A Mac with Xcode
- Your iPhone connected by cable the first time
- Developer Mode enabled on the iPhone
- An Apple ID signed into Xcode

### Fastest setup
1. Open `RedSkySanctuary/RedSkySanctuary.xcodeproj` in Xcode.
2. Plug in your iPhone and trust the Mac.
3. In Xcode, choose your phone as the run destination.
4. Turn on **Automatically manage signing** for the app target.
5. Use your Apple ID team for signing.
6. Build and run.

## Free Apple ID vs paid Apple Developer account

### Free Apple ID
- Good for personal testing during development
- App install works on your own phone
- Build expires after about **7 days** and must be reinstalled from Xcode

### Paid Apple Developer account
- Best for serious/private testing
- Lets you keep development builds installed without the 7-day free-account friction
- Lets you use **TestFlight**, which is the best next step before public App Store release

## Recommended rollout for Red Sky Sanctuary

### Phase 1 — right now
Use **Xcode direct install** on your own phone so you can test everything fully before release.

### Phase 2 — when you want easier ongoing testing
Move to a **paid Apple Developer account** and use **TestFlight internal testing**.

That gives you:
- easier installs
- no manual cable workflow for every build
- better beta testing for you and trusted testers
- a path to private testing before public App Store release

## Notes
- You do **not** need to publish to the App Store to test on your phone.
- You **do** need proper signing from Xcode.
- For your use case, the practical answer is:
  - **now:** Xcode install to iPhone
  - **later:** TestFlight
