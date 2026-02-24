# Manual Test: Short-Distance Ayah Scroll Animation

**Task**: 6.1 Test short-distance scrolls (within same surah)  
**Requirements**: 1.1, 1.4, 4.1  
**Date**: $(date)

## Test Objective

Verify that the smooth ayah scroll animation works correctly for short-distance scrolls within the same surah, including:
- Smooth animation execution
- Correct highlight behavior
- Proper animation parameters (duration, curve, alignment)
- Responsive performance

## Prerequisites

1. App must be running on a physical device or emulator
2. Last read position should be set to a nearby ayah in the same surah
3. QuranTextScreen must be accessible

## Test Cases

### Test Case 1: Basic Short-Distance Scroll

**Steps**:
1. Open the app and navigate to Surah 2 (Al-Baqarah)
2. Scroll to ayah 1 manually
3. Set last read position to ayah 5 (nearby, same surah)
4. Tap the bookmark icon (gold bookmark button at bottom left)

**Expected Results**:
- ✅ Animation should start smoothly
- ✅ Scroll should take approximately 1 second (1000ms)
- ✅ Animation should use easeInOutCubic curve (smooth acceleration/deceleration)
- ✅ Target ayah (ayah 5) should be positioned near the top of screen (alignment 0.1)
- ✅ Ayah 5 should be highlighted with golden background after animation completes
- ✅ Highlight should clear after 3.5-4 seconds
- ✅ No jarring jumps or stuttering during animation

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _______________________________________________

---

### Test Case 2: Verify Animation Parameters

**Steps**:
1. Open the app and navigate to Surah 1 (Al-Fatihah)
2. Set last read to ayah 3
3. Tap bookmark icon
4. Observe the animation carefully

**Expected Results**:
- ✅ Animation duration: ~1000ms (use stopwatch or count "one thousand")
- ✅ Smooth acceleration at start
- ✅ Smooth deceleration at end
- ✅ No sudden speed changes mid-animation
- ✅ Target ayah appears near top of screen (not centered, not at very top)

**Actual Results**:
- [ ] Pass / [ ] Fail
- Animation duration: _______ ms
- Notes: _______________________________________________

---

### Test Case 3: Highlight Behavior During Animation

**Steps**:
1. Navigate to Surah 2, ayah 1
2. Set last read to ayah 8
3. Tap bookmark icon
4. Watch the highlight state during and after animation

**Expected Results**:
- ✅ Highlight state is set during animation (ayah is marked for highlighting)
- ✅ After animation completes, ayah 8 has golden background
- ✅ Golden background has slight transparency (not fully opaque)
- ✅ Border appears around highlighted ayah
- ✅ Highlight automatically clears after 3.5-4 seconds
- ✅ No highlight remains after timeout

**Actual Results**:
- [ ] Pass / [ ] Fail
- Highlight duration: _______ seconds
- Notes: _______________________________________________

---

### Test Case 4: Frame Rate and Performance

**Steps**:
1. Navigate to Surah 2, ayah 1
2. Set last read to ayah 10
3. Enable performance overlay (if available in Flutter DevTools)
4. Tap bookmark icon
5. Observe frame rate during animation

**Expected Results**:
- ✅ Frame rate stays at or above 55 FPS during animation
- ✅ No dropped frames or stuttering
- ✅ Smooth visual experience
- ✅ App remains responsive during animation

**Actual Results**:
- [ ] Pass / [ ] Fail
- Average FPS: _______
- Dropped frames: _______
- Notes: _______________________________________________

---

### Test Case 5: Multiple Ayahs in Same Surah

**Steps**:
1. Test scrolling to different nearby ayahs in Surah 2:
   - From ayah 1 to ayah 5
   - From ayah 10 to ayah 15
   - From ayah 20 to ayah 25
   - From ayah 50 to ayah 55
2. For each, tap bookmark icon and observe

**Expected Results**:
- ✅ All scrolls are smooth and consistent
- ✅ Animation duration is similar for similar distances
- ✅ Highlight behavior is consistent
- ✅ No errors or crashes

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _______________________________________________

---

### Test Case 6: Rapid Navigation Requests

**Steps**:
1. Navigate to Surah 2, ayah 1
2. Set last read to ayah 5
3. Tap bookmark icon rapidly 3-4 times in quick succession
4. Observe behavior

**Expected Results**:
- ✅ No crashes or errors
- ✅ Previous animations are cancelled cleanly
- ✅ Final animation completes successfully
- ✅ App remains responsive
- ✅ Correct ayah is highlighted at the end

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _______________________________________________

---

### Test Case 7: User Interruption

**Steps**:
1. Navigate to Surah 2, ayah 1
2. Set last read to ayah 10
3. Tap bookmark icon to start animation
4. Immediately start scrolling manually during animation

**Expected Results**:
- ✅ User scroll is not blocked
- ✅ User can take control during animation
- ✅ App remains responsive
- ✅ No errors or crashes

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _______________________________________________

---

## Test Summary

**Total Test Cases**: 7  
**Passed**: _______  
**Failed**: _______  
**Pass Rate**: _______%

## Issues Found

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

## Recommendations

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

## Tester Information

**Tester Name**: _______________________  
**Date**: _______________________  
**Device**: _______________________  
**OS Version**: _______________________  
**App Version**: _______________________

## Sign-off

**Tester Signature**: _______________________  
**Date**: _______________________

---

## Technical Notes

### Animation Configuration Constants

The following constants are used in the implementation (from `quran_text_screen.dart`):

```dart
/// Duration for the scroll animation when navigating to last read position.
static const Duration _kScrollAnimationDuration = Duration(milliseconds: 1000);

/// Animation curve for smooth acceleration and deceleration during scroll.
static const Curve _kScrollAnimationCurve = Curves.easeInOutCubic;

/// Scroll alignment determines where the target ayah appears on screen.
/// 0.0 = top, 0.5 = center, 1.0 = bottom. Set to 0.1 to keep ayah near top.
static const double _kScrollAlignment = 0.1;
```

### Key Methods

- `_goToLastRead(LastReadPosition)`: Main entry point for navigation
- `_attemptJumpToAyah(LastReadPosition, int attempt)`: Handles scroll animation with retry logic
- Uses `Scrollable.ensureVisible()` with the configured parameters

### Debug Logging

Look for these debug messages in the console:
- `🔖 Going to last read: Surah X, Ayah Y`
- `🎬 Starting smooth scroll animation to Surah X, Ayah Y`
- `✅ Scroll animation completed. Highlighting ayah Y`
- `🔄 Clearing highlight for ayah Y`

