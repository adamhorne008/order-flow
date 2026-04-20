# Meals Database Integration - Implementation Guide

## Overview
The personalization flow now loads meals from Supabase and saves individual votes to a normalized `meal_votes` table for detailed analytics.

## Changes Made

### 1. Database Schema (`meals-table-schema.sql`)

#### New Tables:
- **`meals`** - Stores your menu items
  - `meal_id` - Unique text identifier (e.g., 'meal-1', 'meal-2')
  - `name` - Meal name
  - `description` - Meal description
  - `category` - Category (e.g., 'pizza', 'salad', 'curry')
  - `is_active` - Show/hide meals without deleting
  - `display_order` - Control display order
  
- **`meal_votes`** (updated) - Stores individual votes
  - `order_id` - Links to the order
  - `meal_id` - Links to the meal (foreign key to meals table)
  - `vote` - 'up' or 'down'
  - `voted_at` - Timestamp
  - Unique constraint on (order_id, meal_id) - one vote per meal per order

#### Updated Views:
- **`meal_vote_summary`** - Now joins with meals table to show:
  - Meal name and category
  - Thumbs up/down counts
  - Total votes
  - Approval rating percentage

### 2. Application Updates (`personalization-flow-supabase.html`)

#### New Functions:
- **`fetchMealsFromDB()`** - Loads active meals from Supabase
  ```javascript
  // Fetches up to 10 active meals, ordered by display_order
  const meals = await fetchMealsFromDB();
  ```

#### Updated Functions:
- **`saveMealVoteToDB(mealId, vote)`** - Now saves to TWO tables:
  1. `personalization_responses` - JSONB storage for quick lookup
  2. `meal_votes` - Normalized table for detailed analytics
  
- **`renderCurrentMeal()`** - Uses `state.meals` loaded from database
  - Uses `meal.meal_id` instead of numeric ID
  - Adapts to actual number of meals loaded

- **`updateProgressBar()`** - Dynamic progress based on actual meal count
  - Shows "X/Y rated" where Y = number of meals loaded from database

#### State Changes:
```javascript
const state = {
  // ... existing fields
  meals: [] // New: Meals loaded from Supabase
};
```

## Setup Instructions

### Step 1: Run the SQL Schema

1. Go to your Supabase SQL Editor:
   https://app.supabase.com/project/fhwkyeccpqtdidnexxrr/sql

2. Open `meals-table-schema.sql` from your project

3. Copy the entire contents and paste into SQL Editor

4. Click "Run" to execute

This will:
- Create the `meals` table
- Recreate the `meal_votes` table with proper foreign keys
- Insert 10 sample meals
- Update the `meal_vote_summary` view

### Step 2: Test the Flow

1. Open `personalization-flow-supabase.html?order_id=test-order-123`

2. The flow will now:
   - Load meals from the database
   - Display them one by one
   - Save each vote to both tables when you click thumbs up/down

3. Check the console for:
   ```
   Loading meals from database...
   Loaded 10 meals
   Meal vote saved: meal-1 = up
   ```

### Step 3: Verify Data in Supabase

1. Go to Table Editor: https://app.supabase.com/project/fhwkyeccpqtdidnexxrr/editor

2. Check **meals** table:
   - Should see 10 sample meals
   - All with `is_active = true`

3. Check **meal_votes** table after voting:
   - Should see one row per voted meal
   - Each with order_id, meal_id, and vote

4. Check **personalization_responses** table:
   - Should see meal_votes JSONB updated

## Managing Meals

### Add a New Meal
```sql
INSERT INTO meals (meal_id, name, description, category, display_order, is_active)
VALUES ('meal-11', 'New Dish Name', 'Delicious description', 'category', 11, true);
```

### Hide a Meal (without deleting)
```sql
UPDATE meals 
SET is_active = false 
WHERE meal_id = 'meal-5';
```

### Reorder Meals
```sql
UPDATE meals 
SET display_order = 1 
WHERE meal_id = 'meal-7';  -- This will show first
```

### Update Meal Details
```sql
UPDATE meals 
SET name = 'Updated Name', 
    description = 'New description'
WHERE meal_id = 'meal-3';
```

## Analytics Queries

### Most Popular Meals
```sql
SELECT * FROM meal_vote_summary
ORDER BY approval_rating DESC
LIMIT 10;
```

### Meals with Most Votes
```sql
SELECT * FROM meal_vote_summary
ORDER BY total_votes DESC
LIMIT 10;
```

### Votes for Specific Order
```sql
SELECT mv.*, m.name as meal_name
FROM meal_votes mv
JOIN meals m ON mv.meal_id = m.meal_id
WHERE mv.order_id = 'test-order-123'
ORDER BY mv.voted_at;
```

### Category Performance
```sql
SELECT 
  category,
  COUNT(*) as meal_count,
  AVG(approval_rating) as avg_approval
FROM meal_vote_summary
GROUP BY category
ORDER BY avg_approval DESC;
```

## Data Flow

1. **User Opens Flow** → `fetchMealsFromDB()` loads active meals from database
2. **User Votes** → `saveMealVoteToDB()` saves to:
   - `meal_votes` table (order_id + meal_id + vote)
   - `personalization_responses` table (JSONB backup)
3. **Analytics** → Query `meal_votes` table or `meal_vote_summary` view

## Benefits

✅ **Centralized Meal Management** - Update meals in one place
✅ **Dynamic Content** - Add/remove meals without code changes
✅ **Detailed Analytics** - Track every vote individually
✅ **Flexible Display** - Control order and visibility
✅ **Data Integrity** - Foreign keys ensure valid meal_ids
✅ **One Vote Per Meal** - Unique constraint prevents duplicates

## Troubleshooting

**Error: relation "meals" does not exist**
→ Run `meals-table-schema.sql` in Supabase SQL Editor

**Error: No meals available**
→ Check meals table has `is_active = true` records

**Error: foreign key constraint violation**
→ Ensure order exists in `personalization_config` before voting

**Progress shows 0/0**
→ Check console logs - meals might not be loading from database
