# Preference-Based Meal Filtering - Implementation Guide

## Overview
The system now filters and randomizes meals based on user-selected dietary preferences using a tag-based system.

## How It Works

### 1. User Flow
1. **Select Preferences** - User chooses from: Meat Lover, Seafood, Vegetarian, Vegan
2. **Click Continue** - System saves preferences and fetches matching meals
3. **Vote on Meals** - User sees only meals matching their preferences, in random order
4. **Each Vote Saves** - Individual votes stored in `meal_votes` table

### 2. Tag System

#### Available Tags
- **Meat** - Chicken, beef, pork, lamb dishes
- **Fish** - Salmon, tuna, seafood dishes
- **Vegetarian** - No meat/fish but may contain dairy/eggs
- **Vegan** - Plant-based, no animal products
- **Gluten-Free** - No gluten (extensible)
- **Dairy-Free** - No dairy (extensible)
- **Low-Carb** - Low carbohydrate (extensible)
- **High-Protein** - High protein content (extensible)

#### Preference → Tag Mapping
```javascript
{
  'meat': 'Meat',
  'fish': 'Fish',
  'vegetarian': 'Vegetarian',
  'vegan': 'Vegan'
}
```

### 3. Filtering Logic

#### If No Preferences Selected
- Shows **all active meals** (randomized)
- Gives maximum variety

#### If Preferences Selected
```javascript
// Example: User selects "Vegetarian" and "Vegan"
// System shows meals tagged with EITHER Vegetarian OR Vegan

Meals shown:
- Margherita Pizza (Vegetarian)
- Vegetable Stir Fry (Vegan, Vegetarian)
- Greek Salad (Vegetarian)
- Thai Green Curry (Vegan, Vegetarian)
- Quinoa Buddha Bowl (Vegan, Vegetarian)
```

#### Randomization
- Meals are shuffled using Fisher-Yates algorithm
- Limited to 10 meals max
- Different order each time preferences are submitted

## Database Schema Changes

### Updated `meals` Table
```sql
CREATE TABLE meals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  meal_id TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  tags TEXT[] DEFAULT ARRAY[]::TEXT[],  -- Changed from category
  is_active BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Sample Data (15 meals)
```sql
INSERT INTO meals (meal_id, name, description, tags, display_order) VALUES
  ('meal-1', 'Margherita Pizza', 'Classic tomato, mozzarella & basil', 
   ARRAY['Vegetarian'], 1),
  
  ('meal-3', 'Chicken Tikka Masala', 'Tender chicken in creamy curry sauce', 
   ARRAY['Meat'], 3),
  
  ('meal-5', 'Vegetable Stir Fry', 'Fresh veggies in savory sauce', 
   ARRAY['Vegan', 'Vegetarian'], 5),
  
  ('meal-6', 'Salmon Teriyaki', 'Glazed salmon with steamed rice', 
   ARRAY['Fish'], 6),
  
  ('meal-13', 'Lentil Dahl', 'Spiced red lentils with rice', 
   ARRAY['Vegan', 'Vegetarian', 'High-Protein'], 13);
```

## Code Changes

### `fetchMealsFromDB(preferences)`
```javascript
// NOW ACCEPTS: Array of user preferences
// RETURNS: Filtered and randomized meals

// Example usage:
const meals = await fetchMealsFromDB(['meat', 'fish']);
// Returns: Randomized meals tagged with Meat OR Fish
```

### `startMealVoting()`
```javascript
async function startMealVoting() {
  // 1. Save preferences to database
  await savePreferencesToDB();
  
  // 2. Reload meals with filtering
  state.meals = await fetchMealsFromDB(state.preferences);
  
  // 3. Reset voting state
  currentMealIndex = 0;
  state.votesCount = 0;
  state.mealVotes = {};
  
  // 4. Show first randomized meal
  renderCurrentMeal();
}
```

### `shuffleArray(array)`
```javascript
// Fisher-Yates shuffle algorithm
// Ensures truly random distribution
// Returns new array (doesn't mutate original)
```

## Managing Meal Tags

### Add a Meal with Tags
```sql
INSERT INTO meals (meal_id, name, description, tags, is_active)
VALUES (
  'meal-16', 
  'Grilled Steak', 
  'Ribeye with garlic butter', 
  ARRAY['Meat', 'High-Protein', 'Low-Carb'],
  true
);
```

### Update Meal Tags
```sql
-- Add a tag
UPDATE meals 
SET tags = array_append(tags, 'Gluten-Free')
WHERE meal_id = 'meal-1';

-- Remove a tag
UPDATE meals 
SET tags = array_remove(tags, 'Vegetarian')
WHERE meal_id = 'meal-5';

-- Replace all tags
UPDATE meals 
SET tags = ARRAY['Vegan', 'Gluten-Free', 'Dairy-Free']
WHERE meal_id = 'meal-9';
```

### Find Meals by Tag
```sql
-- Meals with 'Vegan' tag
SELECT * FROM meals 
WHERE 'Vegan' = ANY(tags) 
AND is_active = true;

-- Meals with BOTH 'Vegan' AND 'High-Protein'
SELECT * FROM meals 
WHERE tags @> ARRAY['Vegan', 'High-Protein']::TEXT[] 
AND is_active = true;

-- Count meals per tag
SELECT 
  unnest(tags) as tag,
  COUNT(*) as meal_count
FROM meals
WHERE is_active = true
GROUP BY tag
ORDER BY meal_count DESC;
```

## Analytics Queries

### Preference Popularity
```sql
-- Which preferences are most selected?
SELECT 
  unnest(preferences) as preference,
  COUNT(*) as times_selected
FROM personalization_responses
WHERE array_length(preferences, 1) > 0
GROUP BY preference
ORDER BY times_selected DESC;
```

### Tag Performance
```sql
-- Which tags get the most thumbs up?
SELECT 
  unnest(m.tags) as tag,
  COUNT(CASE WHEN mv.vote = 'up' THEN 1 END) as thumbs_up,
  COUNT(CASE WHEN mv.vote = 'down' THEN 1 END) as thumbs_down,
  ROUND(
    COUNT(CASE WHEN mv.vote = 'up' THEN 1 END) * 100.0 / 
    NULLIF(COUNT(*), 0), 2
  ) as approval_rating
FROM meals m
JOIN meal_votes mv ON m.meal_id = mv.meal_id
GROUP BY tag
ORDER BY approval_rating DESC;
```

### Preference Match Rate
```sql
-- Do users vote positively on meals matching their preferences?
SELECT 
  pr.preferences,
  COUNT(CASE WHEN mv.vote = 'up' THEN 1 END) as liked_meals,
  COUNT(*) as total_rated,
  ROUND(
    COUNT(CASE WHEN mv.vote = 'up' THEN 1 END) * 100.0 / 
    NULLIF(COUNT(*), 0), 2
  ) as like_rate
FROM personalization_responses pr
JOIN meal_votes mv ON pr.order_id = mv.order_id
GROUP BY pr.preferences
ORDER BY like_rate DESC;
```

## Testing Scenarios

### Scenario 1: Meat Lover
```
User selects: "Meat Lover"
Expected meals: Chicken Tikka Masala, Beef Burger, Pasta Carbonara, 
                Grilled Chicken, BBQ Ribs (randomized)
```

### Scenario 2: Vegan
```
User selects: "Vegan"
Expected meals: Vegetable Stir Fry, Thai Green Curry, Lentil Dahl, 
                Quinoa Buddha Bowl (randomized)
```

### Scenario 3: Multiple Preferences
```
User selects: "Seafood" + "Vegetarian"
Expected meals: ALL meals tagged Fish OR Vegetarian (randomized)
                (Wider variety since it's OR logic)
```

### Scenario 4: No Preferences
```
User selects: Nothing
Expected meals: ALL active meals (randomized, max 10)
```

## Benefits

✅ **Personalized Experience** - Users see relevant meals only
✅ **Flexible Tagging** - One meal can have multiple tags
✅ **Easy Management** - Update tags in database, no code changes
✅ **Randomization** - Fresh experience each time
✅ **Scalable** - Easy to add new tags (Halal, Kosher, etc.)
✅ **Analytics** - Track preference vs. vote correlation

## Next Steps

1. **Run Updated Schema**
   ```bash
   # In Supabase SQL Editor
   - Run meals-table-schema.sql
   - Creates meals table with tags
   - Inserts 15 sample meals
   ```

2. **Test Filtering**
   ```
   - Open personalization flow
   - Select "Vegetarian"
   - Click Continue
   - Check console: "Loaded X meals matching preferences"
   - Verify only vegetarian meals appear
   ```

3. **Verify Randomization**
   ```
   - Complete the flow
   - Reset and select same preferences
   - Notice different meal order
   ```

4. **Check Analytics**
   ```sql
   -- See which tags are most popular
   SELECT * FROM meal_vote_summary
   ORDER BY total_votes DESC;
   ```

## Troubleshooting

**Issue: No meals appear after selecting preferences**
→ Check console: "Loaded 0 meals matching preferences"
→ Verify meals table has items with matching tags
→ Check tags are in correct case (Meat not meat)

**Issue: Same meals appear in same order**
→ Check shuffleArray is being called
→ Verify Math.random() is working

**Issue: Meals don't match preferences**
→ Check preferenceMap has correct mappings
→ Verify meal tags in database match exactly

**Issue: Too few meals**
→ Add more meals to database with diverse tags
→ Consider lowering limit from 10 to 5 for small menus
