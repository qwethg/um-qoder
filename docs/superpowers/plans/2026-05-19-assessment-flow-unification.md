# Assessment Flow Unification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify "Deep Assessment" and "Quick Assessment" into a single cohesive experience: a guided multi-page flow for the first time (with a skip option), and a streamlined, auto-populated single-page flow for all subsequent routine assessments.

**Architecture:**
- Create a new unified wrapper/routing screen `AssessmentEntryScreen` that checks `AssessmentProvider.hasAssessments` and routes the user.
- Create a new `UnifiedAssessmentScreen` to replace the old `QuickAssessmentScreen`, featuring a color-blocked layout, ghost cursors for previous scores, and no notes input.
- Modify `DeepAssessmentScreen` to add a "Skip to Quick" button.
- Update `AppRouter` and `HomeScreen` to use the unified entry point.
- The `Assessment` model retains the `notes` field for future extensibility, but the UI will no longer prompt for it during routine assessments.

**Tech Stack:** Flutter, Provider, GoRouter, Hive

---

### Task 1: Create the Unified Assessment Screen (Single Page)

**Files:**
- Create: `lib/screens/assessment/unified_assessment_screen.dart`

- [ ] **Step 1: Scaffold the new unified screen**
Create `UnifiedAssessmentScreen` as a `StatefulWidget`. In its `initState`, fetch the latest assessment from `AssessmentProvider`. If it exists, initialize `_scores` with the previous scores. If not, initialize with 0.0.

- [ ] **Step 2: Implement the Ghost Cursor (Previous Score) Logic**
In the state, store a `_previousScores` map. 

- [ ] **Step 3: Build the Color-Blocked UI**
Instead of using large cards for each ability, map over `AbilityCategory.values`. For each category, create a container with a very light background color `color.withOpacity(0.05)`.

- [ ] **Step 4: Build the Custom Slider with Ghost Indicator and Diff**
Inside the category block, list the abilities using a custom row layout (not full cards). Show the ability name, current score, and a diff indicator (e.g., `+0.5` in green or `-0.5` in red) compared to `_previousScores`. Implement a slider that visually indicates the previous score (this might require a custom slider theme or a stacked layout with a disabled, transparent slider track underneath).

- [ ] **Step 5: Implement Save Logic**
Add a "Save Assessment" button at the bottom. It should save an `Assessment` object with `type: AssessmentType.quick` (or a new unified type if you prefer, but keeping `quick` ensures backward compatibility). Notes should be an empty map `{}`.

### Task 2: Create the Assessment Entry Wrapper

**Files:**
- Create: `lib/screens/assessment/assessment_entry_screen.dart`

- [ ] **Step 1: Create the wrapper widget**
Create a `StatelessWidget` that listens to `AssessmentProvider`.

- [ ] **Step 2: Implement routing logic**
If `provider.hasAssessments` is true, render the new `UnifiedAssessmentScreen()`.
If false, render `DeepAssessmentScreen()`.

### Task 3: Modify Deep Assessment Screen (Add Skip Button)

**Files:**
- Modify: `lib/screens/assessment/deep_assessment_screen.dart`

- [ ] **Step 1: Add "Skip" action**
In the `AppBar` actions of the `_buildCategoryPage` (or the main build method), add a `TextButton` labeled "跳过引导" (Skip).

- [ ] **Step 2: Implement Skip logic**
When pressed, the skip button should navigate to the new unified flow. Since `AssessmentEntryScreen` dynamically renders based on state, you might need to handle this by either pushing the unified screen directly or using a local state variable in the wrapper if you integrate them tightly. The simplest approach is to use `Navigator.pushReplacement` to swap to `UnifiedAssessmentScreen()`.

### Task 4: Update Routing and Navigation

**Files:**
- Modify: `lib/config/router.dart`
- Modify: `lib/screens/home/home_screen.dart`
- Delete: `lib/screens/assessment/assessment_hub_screen.dart` (Optional, or repurpose)

- [ ] **Step 1: Update AppRouter**
Change the `/assessment` route. Instead of pointing to `AssessmentHubScreen`, point it to the new `AssessmentEntryScreen`.
Remove the nested `deep` and `quick` routes as they are now handled internally or no longer needed as direct deep links.

- [ ] **Step 2: Update Home Screen Button**
In `home_screen.dart`, ensure the "开始评估" (Start Assessment) button navigates to `/assessment`.

- [ ] **Step 3: Update Main Navigation Bar**
Ensure the bottom navigation bar "评估" tab correctly routes to `/assessment`.

### Task 5: Cleanup and Verification

**Files:**
- Modify: `lib/screens/assessment/quick_assessment_screen.dart` (Delete or mark deprecated)

- [ ] **Step 1: Deprecate old screen**
Add a `@Deprecated` annotation to `QuickAssessmentScreen` or delete the file entirely if you are confident in the replacement.

- [ ] **Step 2: Verify translations**
Ensure any new strings (like "跳过引导", score diffs) are added to `lib/config/translations.dart`.

- [ ] **Step 3: Run app and verify flow**
Verify that a new user sees the deep assessment. Verify they can skip. Verify that an existing user goes straight to the unified single page. Verify the ghost cursor and diff logic work correctly.