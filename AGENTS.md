# AGENTS.md

This file provides guidance to Qoder (qoder.com) when working with code in this repository.

## Project Overview

**Project Name:** Ultimate Wheel (飞盘之轮 / Ultimate Frisbee Wheel)

**Core Philosophy:**
This is a self-assessment tool for Ultimate Frisbee players. The core philosophy is "dialogue with your ideal self, not comparison with others." Users rate their satisfaction with 12 abilities on a 1-10 scale with notes. The goal is to generate a radar chart visualization and track personal growth.

**Technology Stack:**
- Language: Dart
- Framework: Flutter
- Primary Platform: Web application
- Secondary Platform: iOS application

## Core Ability Model (12 Dimensions)

### Physical (Athleticism) - 3 items:
- Running/Jumping (跑跳): Speed, explosive power, vertical leap
- Agility (灵敏): Change of direction, sudden stops, body control and coordination
- Stamina (体力): On-field endurance, recovery speed, multi-game capability

### Awareness (意识) - 3 items:
- Spatial Awareness (空间感): Field positioning, observing and utilizing space
- Timing (时机感): Predicting disc flight and player movement
- Game IQ (明智): Tactical understanding, on-field decision-making

### Technique (技术) - 4 items:
- Throwing (传盘): Precision, power, and spin control across various throws
- Catching/Reading (接盘/读盘): Reading flight trajectories, stable catches, extreme catches
- Marking (盯防): Limiting opponent's throws through positioning, footwork, reaction speed
- Defense/Blocking (跟防): Getting defensive scores through positioning, prediction, jumping or layout

### Mind/Spirit (心灵) - 2 items:
- Teamwork (团队): Communication, encouragement, system integration, team chemistry
- Mentality (心态): Focus, stress resistance, emotional control, spirit of the game

## Design Philosophy

**Core Values:**
- **Introverted Assessment**: Scoring baseline is not external benchmarks but one's own ideal state
- **Satisfaction-Driven**: Scores represent satisfaction, measuring the gap between current and target
- **Process as Ritual**: The 20-minute assessment process itself is a mindfulness exercise
- **Balance & Growth**: The wheel shape reveals imbalance points; goal is becoming more "complete"
- **Low-Pressure & Acceptance**: "Know yourself, understand yourself, forgive yourself" - gentle, encouraging attitude

**Visual Identity:**
- The app should have warmth and soul, embodying the core philosophy in every design detail
- Use petal-style rainbow gradient radar charts with stepped/banded gradient fills
- Each major category (Physical/Awareness/Technique/Mind) should have a color scheme, with subcategories in different shades
- Charts should be 12-sided (dodecagon) spider web structure with 10 concentric rings for scoring

## UI Structure Overview

**Page Organization (numbers indicate page IDs in the requirements doc):**

1. **Welcome/Onboarding (01)**: First-time app launch, explains core philosophy with 3-4 swipeable cards
2. **Home Page (02-1/02-2)**: Shows latest radar chart (02-2) or empty state prompting first assessment (02-1)
3. **Assessment Hub (03)**: Three main entry points: Goal Setting, Deep Assessment, Quick Assessment
4. **Goal Setting (03-1)**: Define what 10/10 looks like for each dimension (also 7, 5, 3)
5. **Deep Assessment (03-2)**: Full ritual experience with category-by-category flow (03-02-01 through 03-02-04)
6. **Quick Assessment (03-3)**: 5-minute rapid update with sliders for all 12 dimensions
7. **Assessment Results (03-4)**: Display completed assessment with radar chart
8. **History (04)**: View past assessments with overlay comparison features
9. **Suggestions (05)**: Reserved for future AI recommendations
10. **Settings (06)**: Customize dimensions, radar chart appearance
11. **Share (07)**: Export assessment results as images

**Navigation (100)**: Bottom bar with 4 tabs: Home, Assessment, History, Settings

## Key Features to Implement

**Assessment Flow:**
- Deep Assessment uses PageView with left-right swipe between categories (Physical → Awareness → Technique → Mind)
- Progress indicator showing current step (e.g., "1 • 2 3 4")
- Sliders with 0.5 increments and haptic feedback
- When hitting 3/5/7 scores, show pre-defined descriptions
- Text fields for notes (max 30 characters) on gaps between current and ideal

**Radar Chart Specifications:**
- Petal/sector style with 12 spokes (dodecagon structure)
- Stepped gradient fills (not smooth gradients) - each concentric band has distinct color saturation
- Semi-transparent colors so grid lines remain visible
- No outlines on petals for soft, clean look
- Support for overlay comparison of multiple assessments

**Goal Setting System:**
- Users define their own 10/10 ideal for each dimension
- Optional: define 7, 5, and 3-point descriptions
- Provide defaults with "restore defaults" option
- Store personalized versions

**Data Management:**
- Changing core dimensions (12 items or 4 categories) deletes all historical data
- Track assessment history with timestamps
- Support comparison of any two historical assessments

## Implementation Notes

- Prioritize creating a calm, focused, ritual-like user experience
- Use gentle, encouraging language throughout
- Avoid competitive or comparative framing
- Share functionality should emphasize personal growth journey, not achievement display
- All UI text should reinforce "dialogue with ideal self, not racing against others"
