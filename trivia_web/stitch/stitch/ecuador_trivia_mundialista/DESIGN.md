---
name: Ecuador Trivia Mundialista
colors:
  surface: '#0b1229'
  surface-dim: '#0b1229'
  surface-bright: '#323851'
  surface-container-lowest: '#060d24'
  surface-container-low: '#141a32'
  surface-container: '#181e36'
  surface-container-high: '#222941'
  surface-container-highest: '#2d344c'
  on-surface: '#dce1ff'
  on-surface-variant: '#cfc6ab'
  inverse-surface: '#dce1ff'
  inverse-on-surface: '#292f48'
  outline: '#989177'
  outline-variant: '#4c4732'
  surface-tint: '#e4c600'
  primary: '#fffaf4'
  on-primary: '#393000'
  primary-container: '#ffdd00'
  on-primary-container: '#716100'
  inverse-primary: '#6d5e00'
  secondary: '#acc7ff'
  on-secondary: '#002f67'
  secondary-container: '#024ea2'
  on-secondary-container: '#a5c3ff'
  tertiary: '#fff9f8'
  on-tertiary: '#690006'
  tertiary-container: '#ffd4cf'
  on-tertiary-container: '#c60015'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe251'
  primary-fixed-dim: '#e4c600'
  on-primary-fixed: '#211b00'
  on-primary-fixed-variant: '#524600'
  secondary-fixed: '#d7e2ff'
  secondary-fixed-dim: '#acc7ff'
  on-secondary-fixed: '#001a40'
  on-secondary-fixed-variant: '#004591'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb4ab'
  on-tertiary-fixed: '#410002'
  on-tertiary-fixed-variant: '#93000d'
  background: '#0b1229'
  on-background: '#dce1ff'
  surface-variant: '#2d344c'
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
    fontWeight: '800'
    lineHeight: 40px
  headline-md:
    fontFamily: Montserrat
    fontSize: 24px
    fontWeight: '800'
    lineHeight: 32px
  headline-sm:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Montserrat
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 28px
  body-md:
    fontFamily: Montserrat
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Archivo Narrow
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Archivo Narrow
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  headline-lg-mobile:
    fontFamily: Montserrat
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1200px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style
The brand personality is electric, competitive, and deeply rooted in national pride. This design system captures the "La Tri" spirit—vibrant, high-energy, and celebratory. It is designed to evoke the adrenaline of a last-minute goal and the festive atmosphere of the World Cup.

The visual style is **High-Contrast / Bold**, utilizing the primary colors of the Ecuadorian flag against deep, stadium-inspired neutrals. To ground the energy, we incorporate soccer-specific motifs like subtle hexagonal pitch patterns and turf-inspired textures. The experience should feel like a premium sports broadcast combined with an engaging arcade game, balancing professional sports data with playful interactivity.

## Colors
The palette is dominated by the **Tricolor**—Yellow, Blue, and Red. 

- **Dominant Yellow (#FFDD00):** Used for primary actions, scores, and critical path highlights. It represents the sun and the gold of the flag.
- **Royal Blue (#034EA2):** Used for secondary elements, navigation bars, and progress indicators.
- **Red (#ED1C24):** Reserved for high-alert states, timers, and "incorrect" feedback loops.
- **Dark Navy (#0A1128):** The foundational canvas color. It provides a sophisticated, "stadium lights" backdrop that allows the yellow to vibrate with maximum legibility.

Gradients should transition from Royal Blue to Dark Navy to create depth in card backgrounds, while Yellow should always remain solid and punchy.

## Typography
The typography system uses **Montserrat** for its bold, geometric, and modern athletic feel. To provide a "sporty" data-driven contrast, **Archivo Narrow** is used for labels, stats, and metadata, mimicking the condensed fonts found on jersey numbers and scoreboards.

Headlines should utilize heavy weights (800-900) and tight letter-spacing to command attention. Use All-Caps for `label` styles to enhance the "broadcast" aesthetic. Ensure high contrast between text and backgrounds; Yellow text should only appear on Dark Navy or Blue backgrounds, never on White.

## Elevation & Depth
This design system avoids traditional grey shadows in favor of **Vibrant, Tinted Glows**. 

Depth is achieved through:
1.  **Tonal Layering:** The base background is the darkest navy. Surface cards use a slightly lighter blue tint (#14213D) with a 1px inner border in Royal Blue to define edges.
2.  **Chromatic Shadows:** Interactive elements like the "Primary Yellow Button" utilize a saturated yellow shadow (`0px 10px 20px rgba(255, 221, 0, 0.3)`) to make them appear as if they are emitting light.
3.  **Soccer Textures:** Apply a low-opacity (5%) hexagonal overlay to the main background to create a subtle sense of physical turf/ball texture without distracting from the content.

## Shapes
The shape language is **Rounded**, balancing the aggressiveness of the bold colors with a friendly, game-like feel. 

- **Standard Elements:** 0.5rem (8px) for input fields and small cards.
- **Large Components:** 1.5rem (24px) for the main trivia container and primary action buttons.
- **Circular Elements:** Progress rings and user avatars should remain perfectly circular to mirror the shape of a soccer ball.

Avoid sharp corners to keep the brand approachable and energetic.

## Components
- **Trivia Cards:** Use a Dark Navy background with a subtle gradient. The question text should be in Montserrat Bold White. 
- **Answer Buttons:** Use a "Glass-Sport" style—semi-transparent blue background with a thick 2px border. On hover, they transition to solid Royal Blue. On selection, "Correct" turns Green with a glow, and "Incorrect" turns Red.
- **Primary Action (Play/Submit):** Bold Yellow background, Black text, Montserrat 900. These must be the most prominent elements on the screen.
- **Life Indicators (Hearts):** Use Red (#ED1C24) icons with a soft pulse animation when the user has only 1 life remaining.
- **Progress Bar:** A Royal Blue track with a vibrant Yellow fill. The leading edge of the fill should have a small "glow" effect.
- **Score Chips:** Small, pill-shaped labels using Archivo Narrow. Use Yellow background for the current score to make it pop.
- **Feedback Overlays:** When a user finishes a round, use full-screen confetti in Yellow, Blue, and Red over a backdrop blur.