# Experiment Design — Mobile Product Page

## Why this experiment

The strict sequential funnel shows a clear mobile weakness at **Product view → Add to cart**:

- Desktop session-level conversion: **37.82%**
- Mobile session-level conversion: **27.73%**

This observational gap does not establish causality. The next step is a randomized experiment.

## Hypothesis

If the mobile product page makes the primary Add-to-cart action clearer and reduces interaction friction, then more eligible mobile users will add a product to cart after viewing a product page.

Possible treatment elements:
- sticky Add-to-cart CTA;
- clearer size / variant selection;
- reduced visual competition around the primary CTA.

## Unit of randomization

**User (`fullVisitorId`)**

The same user should always see the same variant.

## Primary metric

**User-level Product view → Add to cart conversion**

For the power baseline, each user is counted once using the user's **first eligible mobile session with a product view**.

A user converts if that session contains an Add-to-cart event **after** the product-view event.

Historical baseline:
- eligible users: **23,102**
- converted users: **6,068**
- baseline conversion: **26.27%**

This aligns the analysis unit with user-level randomization.

## Test design

- Control: current mobile product page
- Treatment: redesigned mobile product page
- Allocation: 50/50
- Alpha: **0.05**
- Power: **80%**
- Two-sided two-proportion test

## MDE and sample size

Illustrative business MDE: **+5.0 percentage points**

- Baseline: **26.27%**
- Target: **31.27%**
- Relative uplift: **19.0%**

Required sample:
- **1,285 users per group**
- with a 10% buffer: **1,414 users per group**
- total with buffer: **2,828 users**

Historical eligibility volume is approximately **63.3 users/day**, implying roughly **45 days** at the sample's average traffic level.

This duration is only a feasibility estimate. A production experiment should use current traffic and run across complete weekly cycles.

## Secondary metrics

- Session → observed purchase conversion
- Add to cart → checkout conversion
- Checkout → purchase conversion
- Revenue per randomized user, if available

## Guardrails

- Product-page exits / bounce
- Error rate
- Page latency
- Revenue per randomized user
- Negative downstream funnel movement

## Decision rule

A treatment is considered promising if:
1. the primary metric improves with `p < 0.05`;
2. the observed effect is practically meaningful;
3. guardrails do not deteriorate materially;
4. downstream purchase/revenue metrics move consistently.

## Limitation

This section is **experiment design only**. No randomized treatment assignment exists in the public dataset.
