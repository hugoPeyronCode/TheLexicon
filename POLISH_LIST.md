# Polish List

## Animations

### Swap Animation Overlay Issue
- **Location**: `ConnectionsGameView.swift` - `wordCardView` function
- **Issue**: Overlays (border, background) appear to go back and forth during swap animation
- **Symptom**: Visual "double swap" effect making user unsure if swap occurred
- **Possible causes**:
  - Animation applied to both offset and other properties simultaneously
  - State changes triggering multiple animation passes
  - Border/background being animated separately from the card itself
- **Priority**: Medium
- **Status**: To investigate

---

## Future Items

(Add new polish items here as they arise)
