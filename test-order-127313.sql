-- ═══════════════════════════════════════════════════════════
-- TEST CONFIGURATION FOR ORDER 127313
-- ═══════════════════════════════════════════════════════════
-- Use this file to quickly configure different test scenarios
-- Simply uncomment the scenario you want to test, or modify values

-- ═══════════════════════════════════════════════════════════
-- SCENARIO 1: Full Flow with All Features + Incentive
-- ═══════════════════════════════════════════════════════════
-- Shows: Preferences → Goals → Split Box → Meal Voting (with £5 credit)
-- Resets all previous responses (fresh customer experience)

-- Clear previous responses
DELETE FROM personalization_responses WHERE order_id = '127313';

-- Configure flow
UPDATE personalization_config 
SET 
  ask_preferences = true,
  ask_goals = true,
  ask_meal_ratings = true,
  ask_split_box = true,
  incentivise = true,
  number_of_meals = 15,
  delivery_day = 'Sun'
WHERE order_id = '127313';


-- ═══════════════════════════════════════════════════════════
-- SCENARIO 2: Full Flow WITHOUT Incentive (No £5 Credit Messaging)
-- ═══════════════════════════════════════════════════════════
-- Shows: Preferences → Goals → Split Box → Meal Voting (generic messaging)

DELETE FROM personalization_responses WHERE order_id = '127313';

UPDATE personalization_config 
SET 
  ask_preferences = true,
  ask_goals = true,
  ask_meal_ratings = true,
  ask_split_box = true,
  incentivise = false,
  number_of_meals = 15,
  delivery_day = 'Mon'
WHERE order_id = '127313';


-- ═══════════════════════════════════════════════════════════
-- SCENARIO 3: No Goals, With Split Box + Incentive
-- ═══════════════════════════════════════════════════════════
-- Shows: Preferences → Split Box → Meal Voting (with £5 credit)

DELETE FROM personalization_responses WHERE order_id = '127313';

UPDATE personalization_config 
SET 
  ask_preferences = true,
  ask_goals = false,
  ask_meal_ratings = true,
  ask_split_box = true,
  incentivise = true,
  number_of_meals = 16,
  delivery_day = 'Sun'
WHERE order_id = '127313';


-- ═══════════════════════════════════════════════════════════
-- SCENARIO 4: Goals Only (No Split Box) + Incentive
-- ═══════════════════════════════════════════════════════════
-- Shows: Preferences → Goals → Meal Voting (with £5 credit)
-- Split box won't show because meals <= 12 or delivery_day is not Sun/Mon

DELETE FROM personalization_responses WHERE order_id = '127313';

UPDATE personalization_config 
SET 
  ask_preferences = true,
  ask_goals = true,
  ask_meal_ratings = true,
  ask_split_box = true,
  incentivise = true,
  number_of_meals = 8,
  delivery_day = 'Wed'
WHERE order_id = '127313';


-- ═══════════════════════════════════════════════════════════
-- SCENARIO 5: Minimal Flow (Just Preferences & Voting)
-- ═══════════════════════════════════════════════════════════
-- Shows: Preferences → Meal Voting (with £5 credit)

DELETE FROM personalization_responses WHERE order_id = '127313';

UPDATE personalization_config 
SET 
  ask_preferences = true,
  ask_goals = false,
  ask_meal_ratings = true,
  ask_split_box = false,
  incentivise = true,
  number_of_meals = 10,
  delivery_day = 'Tue'
WHERE order_id = '127313';


-- ═══════════════════════════════════════════════════════════
-- SCENARIO 6: All Features WITHOUT Incentive (No £5 Messaging)
-- ═══════════════════════════════════════════════════════════
-- Shows: Preferences → Goals → Split Box → Meal Voting (generic)

DELETE FROM personalization_responses WHERE order_id = '127313';

UPDATE personalization_config 
SET 
  ask_preferences = true,
  ask_goals = true,
  ask_meal_ratings = true,
  ask_split_box = true,
  incentivise = false,
  number_of_meals = 18,
  delivery_day = 'Mon'
WHERE order_id = '127313';


-- ═══════════════════════════════════════════════════════════
-- SCENARIO 7: Just Meal Voting (Skip All Questions)
-- ═══════════════════════════════════════════════════════════
-- Shows: Meal Voting only (with £5 credit)

DELETE FROM personalization_responses WHERE order_id = '127313';

UPDATE personalization_config 
SET 
  ask_preferences = false,
  ask_goals = false,
  ask_meal_ratings = true,
  ask_split_box = false,
  incentivise = true,
  number_of_meals = 8,
  delivery_day = 'Thu'
WHERE order_id = '127313';


-- ═══════════════════════════════════════════════════════════
-- RESET RESPONSES (Clear Previous Answers)
-- ═══════════════════════════════════════════════════════════
-- Run this to clear all saved responses and test from scratch

-- DELETE FROM personalization_responses WHERE order_id = '127313';


-- ═══════════════════════════════════════════════════════════
-- CUSTOM CONFIGURATION TEMPLATE
-- ═══════════════════════════════════════════════════════════
-- Copy this block and modify values as needed

/*
UPDATE personalization_config 
SET 
  ask_preferences = true,           -- Show dietary preferences question
  ask_goals = true,                  -- Show health goals question
  ask_meal_ratings = true,           -- Show meal voting
  ask_split_box = true,              -- Enable split box logic (shows if meals > 12 AND day = Sun/Mon)
  incentivise = true,                -- Show £5 credit messaging (false = generic messaging)
  number_of_meals = 15,              -- Number of meals in order (affects split box)
  delivery_day = 'Sun'               -- Delivery day: Sun, Mon, Tue, Wed, Thu, Fri, Sat
WHERE order_id = '127313';
*/


-- ═══════════════════════════════════════════════════════════
-- FIELD REFERENCE
-- ═══════════════════════════════════════════════════════════
/*
ask_preferences (BOOLEAN)
  - true: Show dietary preferences question (vegan, vegetarian, etc)
  - false: Skip preferences, go straight to next step

ask_goals (BOOLEAN)
  - true: Show health goals question (6 options)
  - false: Skip goals question

ask_meal_ratings (BOOLEAN)
  - true: Show meal voting (rate 10 meals)
  - false: Skip meal voting

ask_split_box (BOOLEAN)
  - true: Enable split box logic (only shows if conditions met)
  - false: Never show split box question
  - Split box shows when: number_of_meals > 12 AND delivery_day IN ('Sun', 'Mon')

incentivise (BOOLEAN)
  - true: Show £5 credit messaging (info bar, progress text, success banner)
  - false: Show generic personalization messaging (no mention of credit)

number_of_meals (INTEGER)
  - Affects split box: must be > 12 for split box to appear

delivery_day (TEXT)
  - Affects split box: must be 'Sun' or 'Mon' for split box to appear
  - Options: 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'

FLOW ORDER:
1. Intro Screen (always shows)
2. Preferences (if ask_preferences = true)
3. Goals (if ask_goals = true)
4. Split Box (if ask_split_box = true AND number_of_meals > 12 AND delivery_day IN ('Sun', 'Mon'))
5. Meal Voting (if ask_meal_ratings = true)
6. Success Screen (always shows)
*/
