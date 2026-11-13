# Accessibility Checklist

- [ ] All interactive widgets ≥48dp tap target
- [ ] Every `Image` / icon-only button has `Semantics(label: …)`
- [ ] Text contrast ≥4.5:1 (verify pink-on-white — likely fails)
- [ ] Charts have a text-summary alternative for screen readers
- [ ] Respect `MediaQuery.textScaler` (no fixed heights on text rows)
- [ ] Honor `MediaQuery.disableAnimations`
- [ ] Test with TalkBack + VoiceOver before release
