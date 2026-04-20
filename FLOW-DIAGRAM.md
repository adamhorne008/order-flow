# Frive Personalization Flow - Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PERSONALIZATION FLOW                         │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────┐
│   CUSTOMER   │
│ Places Order │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                          BACKEND SYSTEM                               │
│                                                                       │
│  1. Create order_id: "order-abc123"                                  │
│  2. Insert into personalization_config:                              │
│     {                                                                 │
│       order_id: "order-abc123",                                      │
│       ask_preferences: true,                                         │
│       ask_meal_ratings: true                                         │
│     }                                                                 │
│  3. Generate link:                                                   │
│     https://site.com/flow.html?order_id=order-abc123                │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                          EMAIL TO CUSTOMER                            │
│                                                                       │
│  Subject: Claim Your £5 Credit! 🎉                                   │
│                                                                       │
│  Hi [Name],                                                          │
│  Complete your personalization and get £5 off your next order!      │
│                                                                       │
│  [Start Personalizing →]  ← Links to flow with order_id             │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    CUSTOMER CLICKS LINK                               │
│                                                                       │
│  URL: https://site.com/flow.html?order_id=order-abc123              │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                      SUPABASE DATABASE                                │
│                                                                       │
│  Query: SELECT * FROM personalization_config                         │
│         WHERE order_id = 'order-abc123'                              │
│                                                                       │
│  Returns: { ask_preferences: true, ask_meal_ratings: true }         │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                       SHOW PREFERENCES QUESTION                       │
│                                                                       │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐                       │
│  │   🥩   │ │   🐟   │ │   🥗   │ │   🌱   │                       │
│  │  Meat  │ │  Fish  │ │  Veg   │ │  Vegan │                       │
│  └────────┘ └────────┘ └────────┘ └────────┘                       │
│                                                                       │
│  Customer selects: Meat + Fish ✓                                    │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    SAVE TO SUPABASE (IMMEDIATELY)                     │
│                                                                       │
│  UPSERT INTO personalization_responses:                              │
│  {                                                                    │
│    order_id: "order-abc123",                                         │
│    preferences: ["meat", "fish"],                                    │
│    meal_votes: {},                                                   │
│    credit_claimed: false                                             │
│  }                                                                    │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         SHOW MEAL VOTING                              │
│                                                                       │
│  Progress: [██████░░░░] 0/10 rated                                  │
│                                                                       │
│  ┌──────────────────────────────────────────┐                       │
│  │            🍗                             │                       │
│  │   Creamy Tuscan Chicken                  │                       │
│  │   Pan-seared chicken breast...           │                       │
│  │                                          │                       │
│  │   [ 👎 ]              [ 👍 ]             │                       │
│  └──────────────────────────────────────────┘                       │
│                                                                       │
│  Customer clicks: 👍                                                 │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    SAVE VOTE TO SUPABASE (IMMEDIATELY)                │
│                                                                       │
│  UPSERT INTO personalization_responses:                              │
│  {                                                                    │
│    order_id: "order-abc123",                                         │
│    preferences: ["meat", "fish"],                                    │
│    meal_votes: { "1": "up" },  ← Added vote                         │
│    credit_claimed: false                                             │
│  }                                                                    │
│                                                                       │
│  Progress: [███░░░░░░░] 1/10 rated                                  │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       │  (Repeat for remaining 9 meals...)
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    AFTER 10TH MEAL VOTED                              │
│                                                                       │
│  UPSERT INTO personalization_responses:                              │
│  {                                                                    │
│    order_id: "order-abc123",                                         │
│    preferences: ["meat", "fish"],                                    │
│    meal_votes: {                                                     │
│      "1": "up", "2": "down", "3": "up", "4": "up",                  │
│      "5": "down", "6": "up", "7": "up", "8": "down",                │
│      "9": "up", "10": "up"                                           │
│    },                                                                 │
│    credit_claimed: true,        ← MARKED AS CLAIMED                  │
│    completed_at: "2026-04-20T..."                                    │
│  }                                                                    │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         SHOW SUCCESS MESSAGE                          │
│                                                                       │
│  🎉                                                                   │
│  £5 credit added to your account!                                    │
│                                                                       │
│  Thank you for helping us personalize your meals...                  │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     BACKEND WEBHOOK (OPTIONAL)                        │
│                                                                       │
│  Supabase triggers webhook when credit_claimed = true                │
│                                                                       │
│  POST https://your-api.com/webhooks/personalization                  │
│  {                                                                    │
│    "order_id": "order-abc123",                                       │
│    "credit_claimed": true                                            │
│  }                                                                    │
│                                                                       │
└──────┬───────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    BACKEND APPLIES CREDIT                             │
│                                                                       │
│  1. Query: SELECT * FROM personalization_responses                   │
│            WHERE order_id = 'order-abc123'                           │
│                                                                       │
│  2. Get customer from order_id                                       │
│                                                                       │
│  3. Add £5 credit to customer account                                │
│                                                                       │
│  4. Send confirmation email                                          │
│                                                                       │
│  5. Use preferences for recommendations:                             │
│     - Show more meat & fish meals                                    │
│     - Prioritize highly-rated meals                                  │
│     - Avoid disliked meals                                           │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════

                         DATABASE STATE AT END

┌─────────────────────────────────────────────────────────────────────┐
│ Table: personalization_config                                        │
├──────────────┬────────────────┬───────────────┬─────────────────────┤
│ order_id     │ ask_prefs      │ ask_ratings   │ created_at          │
├──────────────┼────────────────┼───────────────┼─────────────────────┤
│ order-abc123 │ true           │ true          │ 2026-04-20 10:00:00 │
└──────────────┴────────────────┴───────────────┴─────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ Table: personalization_responses                                     │
├──────────────┬───────────────┬─────────────────┬─────────┬──────────┤
│ order_id     │ preferences   │ meal_votes      │ claimed │ completed│
├──────────────┼───────────────┼─────────────────┼─────────┼──────────┤
│ order-abc123 │ [meat, fish]  │ {1:up, 2:down,  │ true    │ 10:05:23 │
│              │               │  3:up...10:up}  │         │          │
└──────────────┴───────────────┴─────────────────┴─────────┴──────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ Table: meal_votes (optional normalized table)                        │
├──────────────┬─────────┬────────────────────────────┬───────────────┤
│ order_id     │ meal_id │ meal_name                  │ vote          │
├──────────────┼─────────┼────────────────────────────┼───────────────┤
│ order-abc123 │ 1       │ Creamy Tuscan Chicken      │ up            │
│ order-abc123 │ 2       │ Thai Red Curry             │ down          │
│ order-abc123 │ 3       │ BBQ Pulled Pork Tacos      │ up            │
│ ...          │ ...     │ ...                        │ ...           │
└──────────────┴─────────┴────────────────────────────┴───────────────┘


═══════════════════════════════════════════════════════════════════════

                          KEY FEATURES

✅ Order-based: Every session linked to order_id
✅ Auto-save: Data saved after every interaction
✅ Resumable: Users can refresh and continue where they left off
✅ Configurable: Control which questions to show per order
✅ Real-time: Backend can check status anytime
✅ Analytics: Built-in views for insights

═══════════════════════════════════════════════════════════════════════

                       CONDITIONAL FLOWS

Scenario 1: New Customer (Full Flow)
  ask_preferences = true, ask_meal_ratings = true
  → Shows: Preferences + 10 Meal Ratings

Scenario 2: Returning Customer (Skip Preferences)
  ask_preferences = false, ask_meal_ratings = true
  → Shows: 10 Meal Ratings only

Scenario 3: Quick Survey (Preferences Only)
  ask_preferences = true, ask_meal_ratings = false
  → Shows: Preferences only

Scenario 4: Already Completed
  credit_claimed = true
  → Shows: Success message immediately

```
