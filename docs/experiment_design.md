# Experiment Design: Mobile Product Page

## Context

The funnel analysis found that mobile users convert from **Product view → Add to cart** at **32.46%**, compared with **42.76%** on desktop. This gap persists alongside lower mobile conversion at later funnel stages.

The observational analysis does not establish that mobile UX causes the difference. A randomized experiment is required to test a specific product change.

## Hypothesis

**If the mobile product page makes the add-to-cart action more prominent and reduces interaction friction, then Product view → Add to cart conversion will increase.**

Example treatment:
- sticky "Add to cart" CTA on mobile;
- clearer size/variant selection;
- reduced visual competition around the primary CTA.

## Experiment setup

- **Population:** mobile sessions with at least one product detail view
- **Randomization unit:** user (`fullVisitorId`) to avoid exposing the same user to both variants
- **Control:** current mobile product page
- **Treatment:** redesigned mobile product page
- **Allocation:** 50/50
- **Significance level (alpha):** 0.05
- **Power:** 80%
- **Test:** two-sided two-proportion z-test

## Metrics

### Primary metric
**Product view → Add to cart conversion**

Baseline: **32.46%**

### Secondary metrics
- Add to cart → Checkout conversion
- Session → Purchase conversion
- Purchase rate among users exposed to the experiment

### Guardrails
- Product-page exit/bounce rate
- Error rate
- Page performance / latency
- Revenue per exposed user, if available

## MDE and sample size

A minimum detectable effect of **+5 percentage points** is used for the MVP design:

- baseline: **32.46%**
- target: **37.46%**
- absolute uplift: **+5.00 p.p.**
- relative uplift: **15.4%**

Required sample size:

- **1,427 eligible sessions/users per group**
- **2,854 total** before a safety buffer
- with a 10% buffer: **1,570 per group / 3,140 total**

The historical sample contains **25,843 mobile product-view sessions per year** (~70.8/day). At that historical volume, the nominal sample would require roughly **41 days**, or about **45 days** with the 10% buffer.

This duration estimate is only a feasibility check: a real experiment should use current production traffic, account for user-level deduplication, seasonality, and a full-week-cycle requirement.

## Decision rule

The treatment is considered promising if:

1. the primary metric improves with **p < 0.05**;
2. the effect is practically meaningful, not only statistically significant;
3. guardrail metrics do not deteriorate materially;
4. secondary funnel/business metrics move in a consistent direction.

## Important limitation

This is an **experiment design**, not a completed A/B test. The public dataset contains observational historical data and no randomized treatment assignment.
