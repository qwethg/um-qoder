# Unified Assessment Zen Result Page Design

## 1. Overview
A new result page (`UnifiedAssessmentResultScreen`) specifically designed to match the "Zen" aesthetic of the new `UnifiedAssessmentScreen`. It completes the closed loop for the unified assessment flow, providing a seamless, calming experience after the user submits their self-assessment.

## 2. Visual Design & Layout
- **Background:** Uses `LinearBindingGradient` and `extendBodyBehindAppBar` to seamlessly continue the visual flow from the assessment screen.
- **Radar Chart:** Displayed prominently without heavy card borders. It will float or sit inside a subtle frosted glass (`BackdropFilter`) container to emphasize the petal structure.
- **AI Analysis:** The existing `AiAnalysisSection` will be integrated, but its surrounding container will be styled minimally (frosted glass or transparent with subtle borders) to fit the Zen theme.
- **Score Details:** Category and total scores will be presented using clean typography and subtle color indicators, avoiding rigid grids or heavy cards.
- **Bottom Actions:** Frosted glass buttons for "回到首页" (Back to Home) and "分享" (Share).

## 3. Fixes to Assessment Screen
- The "保存并生成雷达图" (Save) button in `UnifiedAssessmentScreen` is currently hidden behind the `MainNavigation` bottom bar. This will be fixed by adjusting the layout (e.g., adding bottom padding or using a Stack) so the user can actually click it and navigate to this new result page.

## 4. Routing Updates
- Add a new route in `lib/config/router.dart` for `/assessment/unified-result/:id`.
- Update `UnifiedAssessmentScreen` to navigate to `/assessment/unified-result/${assessment.id}` upon save.

## 5. Components & Data Flow
- Receives `assessmentId` via route parameters.
- Uses `AssessmentProvider` to fetch the completed assessment.
- Uses `RadarThemeProvider` to render the radar chart.
- Integrates `ShareService` for the share button.