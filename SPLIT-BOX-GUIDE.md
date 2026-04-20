# Split Box Feature - Implementation Guide

## Overview
This feature allows Frive to ask customers if they want to split large orders into multiple delivery boxes based on the number of meals and delivery day.

## Database Schema Changes

### New Columns Added to `personalization_config`

1. **`number_of_meals`** (INTEGER)
   - Stores the number of meals in the order
   - Used to determine if split box question should be shown

2. **`delivery_day`** (TEXT)
   - Stores the delivery day: 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
   - Used with meal count to determine if split box question should be shown

3. **`ask_split_box`** (BOOLEAN, DEFAULT false)
   - Flag to control whether to show the split box question
   - Automatically calculated based on business logic

### New Column Added to `personalization_responses`

1. **`split_box_preference`** (TEXT)
   - Stores the user's choice: 'yes' or 'no'
   - 'yes' = customer wants to split the box
   - 'no' = customer wants everything in one box

## Business Logic

The split box question is shown when **ALL** of these conditions are met:

1. **Number of meals > 12**
2. **Delivery day is Sunday OR Monday**

This logic is implemented in the `fetchOrderConfig()` function:

```javascript
const shouldAskSplitBox = data.number_of_meals > 12 && 
                         (data.delivery_day === 'Sun' || data.delivery_day === 'Mon');
```

## Setup Instructions

### Step 1: Run the SQL Migration

Execute the SQL file in your Supabase SQL Editor:

```bash
add-meal-delivery-columns.sql
```

This will:
- Add the three new columns to `personalization_config`
- Add the split box preference column to `personalization_responses`
- Create appropriate indexes
- Add documentation comments

### Step 2: Populate Order Data

When creating or updating orders in `personalization_config`, include the new fields:

```sql
-- Example: Insert new order with meal count and delivery day
INSERT INTO personalization_config (
  order_id, 
  number_of_meals, 
  delivery_day,
  ask_preferences,
  ask_meal_ratings
) VALUES (
  '127313',
  15,              -- 15 meals
  'Sun',           -- Sunday delivery
  true,
  true
);

-- Example: Update existing order
UPDATE personalization_config 
SET 
  number_of_meals = 15, 
  delivery_day = 'Sun'
WHERE order_id = '127313';
```

### Step 3: Test the Flow

1. **Test Case 1: Should Show Split Box Question**
   - Order ID: 127313
   - Meals: 15
   - Delivery Day: Sun
   - Expected: Split box question appears after preferences

2. **Test Case 2: Should NOT Show Split Box Question (Low Meal Count)**
   - Order ID: 127314
   - Meals: 10
   - Delivery Day: Sun
   - Expected: Goes directly to meal voting

3. **Test Case 3: Should NOT Show Split Box Question (Wrong Day)**
   - Order ID: 127315
   - Meals: 15
   - Delivery Day: Wed
   - Expected: Goes directly to meal voting

## Flow Diagram

```
User visits page with order_id
         ↓
   Load config from DB
         ↓
   Check meal count & delivery day
         ↓
    ┌─────────────────┐
    │  Show Intro     │
    └────────┬────────┘
             ↓
    ┌─────────────────┐
    │  Preferences    │ (Select meal types)
    └────────┬────────┘
             ↓
    ┌─────────────────┐
    │ If meals > 12   │
    │ AND (Sun|Mon)   │
    └────┬───────┬────┘
         │       │
    YES  │       │  NO
         ↓       ↓
   ┌──────────┐  Skip
   │Split Box?│   ↓
   │ □ One    │   ↓
   │ □ Split  │   ↓
   └────┬─────┘   ↓
        │         │
        └────┬────┘
             ↓
    ┌─────────────────┐
    │  Rate 10 Meals  │
    └────────┬────────┘
             ↓
    ┌─────────────────┐
    │  £5 Credit!     │
    └─────────────────┘
```

## User Interface

### Split Box Section

The split box question appears as two cards:

**One Box 📦**
- Keep all meals in a single delivery

**Split Box 📦📦**
- Divide meals into multiple boxes

The user must select one option before continuing.

## Data Storage

When the user selects an option, it's saved to the database:

```javascript
// Stored in personalization_responses table
{
  order_id: "127313",
  split_box_preference: "yes", // or "no"
  ...other fields
}
```

## Querying Split Box Preferences

### Get all orders that want split boxes

```sql
SELECT 
  pr.order_id,
  pc.number_of_meals,
  pc.delivery_day,
  pr.split_box_preference
FROM personalization_responses pr
JOIN personalization_config pc ON pr.order_id = pc.order_id
WHERE pr.split_box_preference = 'yes';
```

### Get split box statistics by day

```sql
SELECT 
  pc.delivery_day,
  COUNT(*) FILTER (WHERE pr.split_box_preference = 'yes') as want_split,
  COUNT(*) FILTER (WHERE pr.split_box_preference = 'no') as want_single,
  COUNT(*) as total_asked
FROM personalization_responses pr
JOIN personalization_config pc ON pr.order_id = pc.order_id
WHERE pr.split_box_preference IS NOT NULL
GROUP BY pc.delivery_day
ORDER BY pc.delivery_day;
```

## Integration with Existing System

### When Creating Orders

Your order creation system should populate the new fields:

```javascript
// Example: When creating a new order
const orderData = {
  order_id: orderId,
  number_of_meals: basket.items.length,
  delivery_day: getDeliveryDay(basket.delivery_date), // Returns 'Sun', 'Mon', etc.
  ask_preferences: true,
  ask_meal_ratings: true
};

await supabase
  .from('personalization_config')
  .insert([orderData]);
```

### Helper Function to Get Day Name

```javascript
function getDeliveryDay(dateString) {
  const date = new Date(dateString);
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  return days[date.getDay()];
}
```

## Customizing the Logic

To change when the split box question appears, modify the condition in `personalization-flow.html`:

```javascript
// Current logic: >12 meals AND (Sun OR Mon)
const shouldAskSplitBox = data.number_of_meals > 12 && 
                         (data.delivery_day === 'Sun' || data.delivery_day === 'Mon');

// Example: Show for all large orders regardless of day
const shouldAskSplitBox = data.number_of_meals > 12;

// Example: Show for >15 meals on weekends
const shouldAskSplitBox = data.number_of_meals > 15 && 
                         (data.delivery_day === 'Sun' || data.delivery_day === 'Sat');

// Example: Different thresholds for different days
const shouldAskSplitBox = 
  (data.delivery_day === 'Sun' && data.number_of_meals > 10) ||
  (data.delivery_day === 'Mon' && data.number_of_meals > 12) ||
  (data.number_of_meals > 15);
```

## Testing Checklist

- [ ] SQL migration runs without errors
- [ ] New columns appear in Supabase tables
- [ ] Order with >12 meals + Sun delivery shows split box question
- [ ] Order with <12 meals skips split box question
- [ ] Order with >12 meals + Wed delivery skips split box question
- [ ] Selected preference saves to database correctly
- [ ] Can complete full flow with split box question
- [ ] Can complete full flow without split box question
- [ ] Returning to page restores split box preference

## Troubleshooting

### Split box question not appearing

1. Check order configuration in database:
```sql
SELECT * FROM personalization_config WHERE order_id = 'YOUR_ORDER_ID';
```

2. Verify `number_of_meals` > 12
3. Verify `delivery_day` is 'Sun' or 'Mon'
4. Check browser console for errors

### Preference not saving

1. Check Supabase RLS policies allow public access
2. Verify the order exists in `personalization_responses` table
3. Check browser console for database errors

## Future Enhancements

Possible improvements:

1. **Dynamic messaging** - Show actual meal count in the question
2. **Suggested split** - "We recommend splitting into 2 boxes of 8 and 7 meals"
3. **Custom split** - Let users choose how many boxes
4. **Calendar integration** - Different thresholds based on delivery calendar
5. **Analytics dashboard** - Track split preferences over time

## Questions?

If you need help implementing this feature or want to customize the logic, please reach out!
