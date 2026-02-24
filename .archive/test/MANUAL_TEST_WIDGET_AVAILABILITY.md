# Manual Test: Widget Availability During Navigation

## Test Overview

This manual test verifies that the navigation retry logic works correctly when widgets are not immediately available. This tests Requirements 4.2 and 6.2 from the smooth-ayah-scroll-animation spec.

**Validates: Requirements 4.2, 6.2**

## Test Scenarios

### Scenario 1: Navigation Immediately After App Start

**Objective**: Verify that navigation works when triggered before widgets are fully built.

**Steps**:
1. Close the app completely (force stop if necessary)
2. Launch the app
3. **IMMEDIATELY** tap the bookmark icon (within 1-2 seconds of app appearing)
4. Observe the behavior

**Expected Results**:
- The app should not crash
- The retry logic should attempt to find the target ayah multiple times
- Debug logs should show retry attempts (check logcat/console):
  - "🔖 Attempt X: Key not found. Initiating Dynamic Seek..."
  - Multiple retry messages
- Eventually, the animation should start when the widget becomes available
- The target ayah should be highlighted with golden background
- The highlight should clear after 3.5-4 seconds

**Pass Criteria**:
- ✅ No crashes or errors
- ✅ Retry logic executes (visible in logs)
- ✅ Animation starts when widget becomes available
- ✅ Target ayah is highlighted correctly

---

### Scenario 2: Navigation During Slow Network Load

**Objective**: Verify retry logic works when data is loading slowly.

**Steps**:
1. Enable network throttling or use a slow network connection
2. Launch the app
3. While the Quran content is still loading, tap the bookmark icon
4. Observe the behavior

**Expected Results**:
- The app remains responsive
- Retry logic attempts to find the widget
- Debug logs show retry attempts with delays
- Once content loads, animation proceeds smoothly
- Target ayah is highlighted

**Pass Criteria**:
- ✅ App remains responsive during retries
- ✅ No UI freezing or blocking
- ✅ Animation starts after content loads
- ✅ Correct ayah is highlighted

---

### Scenario 3: Rapid Navigation Attempts During Build

**Objective**: Verify that multiple rapid navigation attempts don't cause issues.

**Steps**:
1. Close and relaunch the app
2. Tap the bookmark icon 3-4 times rapidly (within 1 second)
3. Observe the behavior

**Expected Results**:
- The app should not crash
- Multiple retry sequences may start
- The final navigation should complete successfully
- Only one highlight should be visible at the end
- No duplicate animations or highlights

**Pass Criteria**:
- ✅ No crashes from rapid taps
- ✅ App handles multiple navigation requests gracefully
- ✅ Final navigation completes correctly
- ✅ Single highlight appears (not multiple)

---

### Scenario 4: Navigation to Different Surah (Widget Not Built)

**Objective**: Verify retry logic when navigating to a surah that hasn't been built yet.

**Steps**:
1. Launch the app (starts at Surah 1)
2. Save a last read position in a different surah (e.g., Surah 50)
   - Navigate to Surah 50 manually
   - Tap on an ayah to save it as last read
3. Navigate back to Surah 1 (scroll up or restart app)
4. Tap the bookmark icon to go to Surah 50
5. Observe the behavior

**Expected Results**:
- The app loads Surah 50
- Retry logic attempts to find the target ayah
- Debug logs show retry attempts
- Animation starts when widget is built
- Target ayah in Surah 50 is highlighted

**Pass Criteria**:
- ✅ Surah loads correctly
- ✅ Retry logic works across surahs
- ✅ Animation completes smoothly
- ✅ Correct ayah is highlighted

---

### Scenario 5: Maximum Retry Attempts (Timeout)

**Objective**: Verify error handling when widget never becomes available (edge case).

**Note**: This scenario is difficult to reproduce in normal conditions, as widgets should always load eventually. This is primarily for understanding the error path.

**Steps**:
1. Review the code in `_attemptJumpToAyah` method
2. Verify that after 20 retry attempts, an error message is shown
3. Check the error message text is clear and helpful

**Expected Code Behavior** (from code review):
```dart
if (attempt >= 20) {
  debugPrint('❌ Failed to navigate to ayah after 20 attempts...');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('تعذر الوصول إلى الآية...'),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
    ),
  );
}
```

**Pass Criteria**:
- ✅ Code has proper timeout handling
- ✅ Error message is clear and user-friendly
- ✅ App doesn't crash after timeout
- ✅ User can continue using the app

---

## Debug Log Monitoring

When running these tests, monitor the debug console for these key messages:

### Successful Retry Sequence:
```
🔖 Going to last read: Surah X, Ayah Y
🔖 Attempting to jump to ayah after frame build...
🔖 Attempt 1: Key not found. Initiating Dynamic Seek...
🔖 Attempt 2: Key not found. Initiating Dynamic Seek...
...
🎬 Starting smooth scroll animation to Surah X, Ayah Y (attempt N)
✅ Scroll animation completed. Highlighting ayah Y
🔄 Clearing highlight for ayah Y
```

### Failed Navigation (Timeout):
```
🔖 Going to last read: Surah X, Ayah Y
🔖 Attempt 1: Key not found...
...
🔖 Attempt 20: Key not found...
❌ Failed to navigate to ayah after 20 attempts. Target: Surah X, Ayah Y
```

---

## Test Results

### Test Environment
- **Device**: _________________
- **OS Version**: _________________
- **App Version**: _________________
- **Date**: _________________
- **Tester**: _________________

### Results Summary

| Scenario | Pass/Fail | Notes |
|----------|-----------|-------|
| 1. Navigation After App Start | ⬜ | |
| 2. Navigation During Slow Load | ⬜ | |
| 3. Rapid Navigation Attempts | ⬜ | |
| 4. Navigation to Different Surah | ⬜ | |
| 5. Timeout Handling (Code Review) | ⬜ | |

### Issues Found
_List any issues, unexpected behavior, or concerns:_

---

### Additional Notes
_Any other observations or comments:_

---

## Conclusion

**Overall Result**: ⬜ PASS / ⬜ FAIL

**Recommendation**: ⬜ Ready for production / ⬜ Needs fixes

**Signature**: _________________

**Date**: _________________
