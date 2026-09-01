# UI specification — "quiet analytics" dashboard

This is the design contract. Every dashboard produced by this skill must match it, so that
two runs a month apart look like the same product. The template in `assets/dashboard-template.html`
already implements all of it; only depart from the template when the user explicitly asks for
a layout change, and even then keep every token below.

## The brief, verbatim

> Build a desktop web app in a calm, data-dense "quiet analytics" style — the opposite of a
> marketing dashboard. No gradients, no rounded pill-heavy chrome, no emoji, no icon soup.
>
> **Canvas & surfaces.** Page background is a pale cool gray-cyan (`#f2f8f9`); content cards are
> pure white with 1px `#e4edee` borders, 12–13px radii, and a near-invisible shadow
> (`0 1px 3px rgba(16,44,54,.05)`). The outer browser body is a deeper `#dfe9ec` so the app
> floats. Report documents are the exception: 6px radius, a stronger shadow
> (`0 6px 26px rgba(16,44,54,.07)`), max-width ~660px, centered — they should read as paper.
>
> **Top nav.** 60px tall, a subtle vertical wash from `#e7f0f3` to `#eff5f7`, bottom border
> `#dbe6e9`. Left: wordmark in soft sky blue (`#7cbcda`) beside a thin outlined ring glyph, then
> a small uppercase 9.5px letter-spaced outlined tag pill. Tabs are 13px, inactive `#7b8f96`,
> active near-black `#16262e` with a 2px black underline flush to the nav's bottom edge. Right:
> a plain 31px white search field and a soft-teal "Ask ⌘" button (`#e3f1f6` fill, `#1c6c7d` text).
>
> **Type.** DM Sans throughout, `font-variant-numeric: tabular-nums` globally. Page titles
> 29px/600 at `-0.7px` tracking. Hero metrics 30–40px/600 at `-1px` tracking, sitting under
> 10px/600 uppercase labels with `+0.9px` letter-spacing in `#8298a0`. Body 12.5–13px,
> `line-height 1.55`, `text-wrap: pretty`. Secondary text `#7b8f96`; tertiary `#9db0b6`.
>
> **KPI band.** Four metrics in a single row separated by hairline `#e8eff0` dividers, framed top
> and bottom by `#e3ecee` rules — no cards, no boxes.
>
> **Charts.** Inline SVG on white. Actual history is a 2.1px near-black polyline; the forecast is
> a 2.6px dashed (`7 6`) sky-blue (`#5fb4d8`) line fanning into a `#7fc7e4` band at 14% opacity,
> with hairline dashed P90/P10 edges. A 5px black dot marks today, with a vertical dashed
> `#d5e1e4` "TODAY" rule. Gridlines are `#eef3f4`; all axis and percentile labels are 10.5px
> `#9db0b6`, percentile labels set outside the plot on the right.
>
> **Status language.** State is carried by a 6px colored dot plus text, or a 20px-radius pill
> with a tinted background: green `#17a06a` on `#e4f4ec`, amber `#d08a12` on `#fdf1dc`, blue
> `#4a94b3` on `#e6f3f9` (pulsing when in flight), neutral `#b3c2c7` on `#eef3f4`. Warning
> banners are a full-width tinted strip under the nav, never a modal.
>
> **Third-party integration.** Represent the connected data source as a 10–15px rounded square
> in the vendor's own green (`#2CA01C`) followed by the company name in 10.5px `#728790` —
> repeated consistently in the nav, in page metadata, in the report footer, and in the assistant
> panel, so provenance is always one glance away.
>
> **Assistant panel.** 396px right drawer, white, 1px left border, slides in from the right in
> 180ms. Assistant replies are unstyled prose on white; user messages are `#eef7fb` bubbles with
> `#26647d` text and one squared corner (`12px 12px 4px 12px`). Follow-up suggestions are
> left-aligned, self-sizing outlined 10px-radius chips.
>
> **Motion.** Only functional: 140–200ms `popin` (6px rise + `0.985` scale) for dropdowns and
> toasts, `slidein` for drawers, a 0.8s spinner, a 1.1s opacity pulse for syncing. Nothing
> decorative.
>
> Primary action is deep teal `#1c6c7d`; destructive/connect actions borrow the vendor green.
> Interactive rows highlight on hover with `#f6fafb`, selected rows with `#f2f8fa` and a
> `#9ecfe4` border.

## Token table (matches `:root` in the template)

| Token | Value | Used for |
|---|---|---|
| `--body` | `#dfe9ec` | browser body behind the app |
| `--canvas` | `#f2f8f9` | app page background |
| `--card` / `--border` | `#fff` / `#e4edee` | cards |
| `--rule` / `--rule-frame` | `#e8eff0` / `#e3ecee` | KPI dividers / KPI frame |
| `--grid` | `#eef3f4` | chart gridlines |
| `--ink` | `#16262e` | primary text, actual line, active tab |
| `--label` | `#8298a0` | 10px uppercase labels |
| `--secondary` / `--tertiary` | `#7b8f96` / `#9db0b6` | secondary text / axis labels |
| `--meta` | `#728790` | provenance text next to vendor square |
| `--sky` / `--sky-line` / `--sky-band` | `#7cbcda` / `#5fb4d8` / `#7fc7e4` | wordmark / forecast line / band |
| `--teal` / `--teal-soft` | `#1c6c7d` / `#e3f1f6` | primary action / Ask button |
| `--qb` | `#2CA01C` | vendor square, connect button |
| green / amber / blue / neutral | see brief | status pills |
| `--hover` / `--selected` / `--selected-border` | `#f6fafb` / `#f2f8fa` / `#9ecfe4` | table rows |

## Fixed layout (do not reorder)

1. Nav: wordmark · tag · tabs (Overview, Accounts, Forecast, Report) · vendor provenance · search · Ask
2. Optional warning strip (only when something needs attention)
3. Page head: title, provenance + fetch time + status pill; right side: entity segmented control + connect-green sync button
4. **Overview**: KPI band (4) → two-column: forecast chart card (with scenario presets and three sliders) + outlook card → monthly cash flow table with a history note
5. **Accounts**: working-capital-by-entity table (group total + intercompany-removed subtotal) + aging chart card → customer-level receivables table with status pills
6. **Forecast**: projected balances table (P10 / Base / P90 / monthly net) + scenario basis note
7. **Report**: 660px paper document — position, what happened, receivables, outlook, caveats, provenance footer

## Things that must never appear

Gradients on cards, emoji, icon fonts, modals, decorative animation, external chart libraries
(the artifact viewer blocks CDNs — everything is inline SVG), rounded "pill" buttons for primary
actions, hardcoded company names (all copy comes from the data object).
