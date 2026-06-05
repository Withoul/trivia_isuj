---
name: Trivia Mundialista Design System
colors:
  surface: '#190d29'
  surface-dim: '#190d29'
  surface-bright: '#403351'
  surface-container-lowest: '#140824'
  surface-container-low: '#221632'
  surface-container: '#261a36'
  surface-container-high: '#312441'
  surface-container-highest: '#3c2f4d'
  on-surface: '#eddcff'
  on-surface-variant: '#cdc3d2'
  inverse-surface: '#eddcff'
  inverse-on-surface: '#372b48'
  outline: '#968e9b'
  outline-variant: '#4a4450'
  surface-tint: '#d8b9ff'
  primary: '#d8b9ff'
  on-primary: '#411871'
  primary-container: '#5a348b'
  on-primary-container: '#cda6ff'
  inverse-primary: '#714ba3'
  secondary: '#ffdb9d'
  on-secondary: '#412d00'
  secondary-container: '#feb700'
  on-secondary-container: '#6b4b00'
  tertiary: '#ffb77f'
  on-tertiary: '#4e2600'
  tertiary-container: '#713a00'
  on-tertiary-container: '#ffa252'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#eedcff'
  primary-fixed-dim: '#d8b9ff'
  on-primary-fixed: '#290054'
  on-primary-fixed-variant: '#583289'
  secondary-fixed: '#ffdea8'
  secondary-fixed-dim: '#ffba20'
  on-secondary-fixed: '#271900'
  on-secondary-fixed-variant: '#5e4200'
  tertiary-fixed: '#ffdcc4'
  tertiary-fixed-dim: '#ffb77f'
  on-tertiary-fixed: '#2f1500'
  on-tertiary-fixed-variant: '#6f3900'
  background: '#190d29'
  on-background: '#eddcff'
  surface-variant: '#3c2f4d'
typography:
  display-lg:
    fontFamily: Montserrat
    fontSize: 48px
    fontWeight: '900'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Montserrat
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  title-md:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Montserrat
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Montserrat
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-bold:
    fontFamily: Montserrat
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 64px
---

## Brand & Style
The brand personality is energetic, competitive, and festive, capturing the global excitement of world football. The design system is tailored for sports enthusiasts who value speed, engagement, and a high-energy atmosphere.

The visual style is **High-Contrast / Bold**, utilizing a "dark mode by default" approach where deep purples provide a sophisticated, pitch-like backdrop for vibrant orange accents. This creates a high-visibility environment perfect for quick-reaction trivia and celebratory game moments. We employ subtle noise textures—inspired by the reference image—to add depth and a tangible "stadium" feel to flat surfaces.

## Colors
This design system uses a palette rooted in the deep purple and radiant orange found in the brand mark. 

- **Primary Purple (#5A348B):** Used for primary UI containers and brand-defining surfaces.
- **Accent Orange (#FFB800 to #FF8A00):** A warm gradient used for calls-to-action, highlights, and "winning" states.
- **Deep Neutral (#1E122E):** The base background color, providing maximum contrast for the lighter purple cards and orange text.
- **Success/Error:** While not in the primary variables, vibrant lime greens and hot pinks are used sparingly for immediate feedback during gameplay.

## Typography
Montserrat is the exclusive typeface for this design system. Its geometric construction and wide range of weights allow for a "sports-broadcast" aesthetic that remains legible during fast-paced gameplay.

- **Headlines:** Use Bold (700) or Black (900) weights to create a sense of urgency and importance. Tighten letter spacing on larger displays to enhance the "impact" feel.
- **Body Text:** Use Regular (400) for general information to ensure readability against dark backgrounds.
- **Interactive Labels:** Use Bold (700) with Uppercase styling for buttons and navigation items to distinguish them from content.

## Layout & Spacing
The layout follows a **Fluid Grid** model with a heavy emphasis on vertical rhythm based on an 8px square module.

- **Mobile:** 4-column grid with 20px side margins. Content is primarily stacked to allow for large, thumb-friendly tap targets.
- **Desktop:** 12-column grid with 64px margins. Cards and trivia modules are centered or grouped into dashboard-style layouts.
- **Gaps:** Gutters remain a constant 16px (sm) to keep the UI feeling tight and interconnected, reflecting the density of a sports scoreboard.

## Elevation & Depth
Depth is achieved through **Tonal Layering** rather than traditional shadows. Because the background is dark, we use progressively lighter shades of purple to "lift" elements toward the user.

- **Level 0 (Background):** Deepest Neutral (#1E122E).
- **Level 1 (Cards/Containers):** Primary Purple (#321D4D).
- **Level 2 (Active States):** Mid-purple with a subtle inner glow or a 1px border using the Accent Orange at 20% opacity.
- **Accent Depth:** High-priority elements (like the current question or a 'Play' button) utilize a soft orange outer glow to simulate illumination on the pitch.

## Shapes
In alignment with the "Round 8" requirement, this design system utilizes a **Rounded** shape language.

- **Standard Elements:** Buttons, input fields, and small cards use a 0.5rem (8px) corner radius.
- **Large Containers:** Hero sections or main game boards use `rounded-lg` (16px) to feel more substantial and friendly.
- **Interactive Feedback:** When a user selects an answer, the container should maintain its 8px radius, avoiding sharp corners to keep the experience approachable and modern.

## Components
Consistent component styling ensures the game feels cohesive and high-quality.

- **Buttons:** Primary buttons are solid Orange (#FFB800) with Black Montserrat Bold text. Secondary buttons use a Purple stroke with Orange text.
- **Trivia Cards:** Large, centered containers with a `surface` background. On hover or selection, the border illuminates in Orange.
- **Progress Bars:** Thin, high-contrast tracks. The filling is a gradient from `primary_color_hex` to `secondary_color_hex`, representing the momentum of the game.
- **Chips/Badges:** Small, 8px rounded capsules used for "Difficulty Level" or "Category." These use low-opacity versions of the accent colors (e.g., 15% Orange background with 100% Orange text).
- **Input Fields:** Dark backgrounds with a 1px Purple border that turns Orange on focus.
- **Scoreboard:** A specialized component using `display-lg` typography and heavy containers to celebrate point accumulation.