---
name: Academic Pulse
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#4b4450'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#7c7481'
  outline-variant: '#cdc3d1'
  surface-tint: '#734c9e'
  primary: '#30015a'
  on-primary: '#ffffff'
  primary-container: '#461f70'
  on-primary-container: '#b48be2'
  inverse-primary: '#dbb8ff'
  secondary: '#765b00'
  on-secondary: '#ffffff'
  secondary-container: '#ffc70a'
  on-secondary-container: '#6e5400'
  tertiary: '#002517'
  on-tertiary: '#ffffff'
  tertiary-container: '#003d28'
  on-tertiary-container: '#00b37c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#efdbff'
  primary-fixed-dim: '#dbb8ff'
  on-primary-fixed: '#2b0052'
  on-primary-fixed-variant: '#5a3484'
  secondary-fixed: '#ffdf95'
  secondary-fixed-dim: '#f5bf00'
  on-secondary-fixed: '#251a00'
  on-secondary-fixed-variant: '#594400'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
  background-dark: '#1A0B2E'
  streak-orange: '#F97316'
  surface-admin: '#F8FAFC'
  glass-fill: rgba(255, 255, 255, 0.08)
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  score-display:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '800'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 20px
  gutter: 16px
---

## Brand & Style

The design system bridges the gap between institutional prestige and the high-energy world of competitive gaming. It is built to serve two distinct user personas: the **Participant**, who seeks excitement, instant feedback, and social proof; and the **Administrator**, who requires efficiency, clarity, and a professional workspace.

The design style is a hybrid of **Corporate Modern** for administrative functions and **Vibrant Gamification** for the student experience. This is achieved through a "layered reality" approach:
- **For Participants:** A high-fidelity mobile environment using deep gradients, glassmorphism, and neon-tinged accents to drive engagement.
- **For Administrators:** A clean, high-white-space environment that prioritizes data density and task completion while maintaining brand continuity through typography and accent colors.

The overall mood is **energetic, technological, and rewarding**. Every interaction in the participant view should feel like a "win," utilizing micro-animations and glowing depth to celebrate progress.

## Colors

The color palette is rooted in the ISUTJ institutional identity but expanded for digital gamification.

- **Primary (Institutional Purple):** Used for brand presence, headers in admin views, and as the "deep" end of participant gradients.
- **Secondary (Achievement Gold):** Reserved for high-value rewards, progress bars, and "1st Place" indicators.
- **Tertiary (Success Green):** Used specifically for correct answers, point gains, and positive feedback loops.
- **Neutral:** A range of cool grays used primarily in the Administrator panel for text and secondary interface elements.

**Gradient Logic:**
The participant experience must never use flat purple. Use a linear gradient (`#461F70` to `#1A0B2E`) for backgrounds. Interactive elements like "Start Quiz" or "Claim Reward" should utilize the **Gold-to-Orange** gradient to denote high energy and urgency.

## Typography

Typography is used to distinguish between "data" and "experience." 

**Plus Jakarta Sans** is the primary display face. Its modern, slightly rounded geometric forms provide the friendly yet technological feel required for a gamified education platform. It is used for all headlines, buttons, and numeric score displays.

**Inter** is used for body copy and administrative tables. Its high legibility at small sizes ensures that even dense quiz questions or administrative logs remain accessible.

For scores and countdown timers, use `tabular-nums` to prevent layout shift during active countdowns or point tallies.

## Layout & Spacing

The system uses an **8px base grid** for most components, but reduces to **4px (xs)** for tight gamification elements like badge icons and micro-labels.

### Mobile (Participant)
A **fluid vertical stack** with a 20px safe-margin on the left and right. 
- **Header:** Fixed at 64px height, containing the Logo and the "Point Pill" (Current Score).
- **Navigation:** Bottom Tab Bar (64px) with frosted glass effect (`backdrop-filter: blur(12px)`).
- **Content:** Large cards with 16px vertical spacing.

### Desktop (Administrator)
A **fixed Sidebar grid** model.
- **Sidebar:** 260px fixed width.
- **Main Content:** Fluid area with a maximum readable width of 1200px for data tables.
- **Gutter:** 24px between dashboard widgets.

## Elevation & Depth

Elevation is the primary tool for distinguishing between the two system roles.

**For Participants (Glassmorphism & Glow):**
Depth is achieved through semi-transparent layers. Cards use a `glass-fill` (8% white) with a 1px inner border (15% white). 
- **Active State:** When a user selects a quiz option, the card gains an external glow using the primary purple color: `box-shadow: 0 0 20px rgba(70, 31, 112, 0.4)`.

**For Administrators (Tonal Layers):**
Depth is traditional and clean. Surfaces are differentiated by slight shifts in background color (e.g., a light gray sidebar against a white content area). 
- **Low Elevation:** Used for standard content cards (`shadow-sm`).
- **High Elevation:** Reserved only for floating action buttons or modal dialogs.

## Shapes

The design uses a **Rounded** (0.5rem base) corner strategy to feel approachable and modern.

- **Standard Elements (Buttons, Inputs):** 8px (0.5rem) radius.
- **Main Content Containers (Cards):** 16px (1rem) radius.
- **Gamified "Pills" (Score counters, Chips):** Fully rounded (Pill-shaped) to distinguish them as floating, interactive metadata.

In the Administrator view, edges may feel slightly more structured, but maintain the 8px radius for all primary action buttons to ensure brand consistency.

## Components

### Buttons
- **Primary (Participant):** Use the Secondary Gold-to-Orange gradient. 16px vertical padding. Bold typography. Should have a subtle "press" animation (scale 0.98).
- **Secondary (Admin):** Solid purple with white text. Clean, flat design.

### Progress Bars
- Use a thick 12px track. The track should be semi-transparent purple. The "fill" should be a vibrant gradient (Gold to Green) to represent the "living" nature of the quiz progress.

### Quiz Cards (Options)
- Large, touch-friendly targets (minimum height 64px).
- **Default State:** Glass background with thin white border.
- **Selected State:** Purple border with inner glow.
- **Correct State:** Green border with checkmark icon.
- **Incorrect State:** Red border with "shake" animation.

### Medals & Podiums
- The Top 3 in rankings must use a 3D-effect podium. 
- **1st Place:** Gold medal with a "shine" micro-animation (a white light sweep moving across the medal every 5 seconds).

### Input Fields (Admin)
- Minimalist style: 1px border (`#E2E8F0`), focus state uses the Primary Purple for the border and a subtle glow.