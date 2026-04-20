# Frive Personalization Flow - Supabase Integration

## Overview

This personalization flow collects user preferences and meal ratings, storing all data in Supabase against an `order_id`. The system supports conditional question display through configuration flags.

## Features

- ✅ **Order-based tracking** - Each personalization session linked to an order_id
- ✅ **Configurable questions** - Control which questions to show per order
- ✅ **Real-time saving** - Answers saved immediately to Supabase
- ✅ **Resume capability** - Users can continue where they left off
- ✅ **Analytics ready** - Built-in views for preference and vote analysis

## Database Schema

### Tables

1. **`personalization_config`**
   - Stores configuration flags for each order
   - Fields:
     - `order_id` (TEXT, unique) - The order identifier
     - `ask_preferences` (BOOLEAN) - Show meal preferences question?
     - `ask_meal_ratings` (BOOLEAN) - Show 10 meal rating questions?

2. **`personalization_responses`**
   - Stores all user answers for each order
   - Fields:
     - `order_id` (TEXT, unique) - Links to config
     - `preferences` (TEXT[]) - Array of selected preferences
     - `meal_votes` (JSONB) - Object mapping meal_id to vote
     - `credit_claimed` (BOOLEAN) - Has £5 credit been claimed?
     - `completed_at` (TIMESTAMP) - When flow was completed

3. **`meal_votes`** (optional)
   - Normalized table for individual meal votes
   - Useful for detailed analytics

## Setup Instructions

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note your project URL and anon key

### 2. Set Up Database

1. Open your Supabase dashboard
2. Go to **SQL Editor**
3. Copy the contents of `supabase-schema.sql`
4. Paste and execute the SQL
5. Verify tables are created in **Table Editor**

### 3. Configure the HTML File

Open `personalization-flow-supabase.html` and update:

```javascript
// Replace these with your actual Supabase credentials
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Find these in your Supabase dashboard:
- Go to **Settings** → **API**
- Copy **Project URL** → Use as SUPABASE_URL
- Copy **anon public** key → Use as SUPABASE_ANON_KEY

### 4. Test the Integration

Open the HTML file with an order_id parameter:

```
file:///path/to/personalization-flow-supabase.html?order_id=test-order-123
```

Or for production:
```
https://yoursite.com/personalization-flow-supabase.html?order_id=ORDER_ID_HERE
```

## Usage Examples

### Example 1: Full Flow (Both Questions)

```javascript
// In personalization_config table
{
  order_id: 'order-abc123',
  ask_preferences: true,
  ask_meal_ratings: true
}
```

User will see:
1. Meal preferences question (meat/fish/vegetarian/vegan)
2. 10 meal rating questions (thumbs up/down)
3. Success message with £5 credit

### Example 2: Only Meal Ratings

```javascript
// In personalization_config table
{
  order_id: 'order-xyz789',
  ask_preferences: false,  // Skip this
  ask_meal_ratings: true
}
```

User will see:
1. 10 meal rating questions only
2. Success message with £5 credit

### Example 3: Only Preferences

```javascript
// In personalization_config table
{
  order_id: 'order-def456',
  ask_preferences: true,
  ask_meal_ratings: false  // Skip this
}
```

User will see:
1. Meal preferences question only
2. Success message with £5 credit

## Data Flow

### When User Visits Page

1. Extract `order_id` from URL parameter
2. Fetch config from `personalization_config` table
3. Check for existing responses in `personalization_responses`
4. Show appropriate questions based on flags
5. Restore any previously saved answers

### When User Answers Questions

1. **Preference selected**: Immediately save to Supabase
2. **Meal voted**: Immediately save to Supabase
3. **Flow completed**: Mark `credit_claimed = true`

All saves use `upsert` to handle updates gracefully.

## API Integration Example

### Creating a New Order Config (Backend)

```javascript
// When a new order is created
const { data, error } = await supabase
  .from('personalization_config')
  .insert([{
    order_id: 'new-order-id',
    ask_preferences: true,
    ask_meal_ratings: true
  }]);
```

### Checking if User Completed Flow (Backend)

```javascript
const { data, error } = await supabase
  .from('personalization_responses')
  .select('credit_claimed')
  .eq('order_id', 'order-id')
  .single();

if (data?.credit_claimed) {
  // Apply £5 credit to order
}
```

### Getting User Preferences (Backend)

```javascript
const { data, error } = await supabase
  .from('personalization_responses')
  .select('preferences, meal_votes')
  .eq('order_id', 'order-id')
  .single();

console.log('User prefers:', data.preferences);
console.log('Meal votes:', data.meal_votes);
```

## Analytics Queries

The schema includes built-in views for analytics:

### Most Popular Preferences

```sql
SELECT * FROM preference_analytics;
```

Output:
```
preference   | count | percentage
-------------|-------|------------
meat         | 450   | 75.00
fish         | 320   | 53.33
vegetarian   | 180   | 30.00
vegan        | 90    | 15.00
```

### Meal Approval Ratings

```sql
SELECT * FROM meal_vote_summary ORDER BY approval_rating DESC LIMIT 5;
```

Output:
```
meal_id | meal_name                | thumbs_up | thumbs_down | approval_rating
--------|--------------------------|-----------|-------------|----------------
5       | Teriyaki Salmon Bowl     | 450       | 50          | 90.00
1       | Creamy Tuscan Chicken    | 420       | 80          | 84.00
7       | Korean Beef Bibimbap     | 380       | 120         | 76.00
```

### Completion Statistics

```sql
SELECT * FROM completion_stats;
```

Output:
```
total_started | total_completed | completion_rate | answered_preferences | answered_ratings
--------------|-----------------|-----------------|---------------------|------------------
1000          | 850             | 85.00           | 950                 | 850
```

## Security Notes

### Current Setup (Development)

- RLS (Row Level Security) is enabled
- Public policies allow any user to read/write
- Suitable for development/testing

### Production Recommendations

1. **Add Authentication**
   ```sql
   -- Only allow users to access their own data
   CREATE POLICY "Users can only access own data"
     ON personalization_responses
     FOR ALL
     USING (order_id IN (
       SELECT order_id FROM orders WHERE user_id = auth.uid()
     ));
   ```

2. **Restrict Config Changes**
   ```sql
   -- Only backend service can modify config
   CREATE POLICY "Only service role can modify config"
     ON personalization_config
     FOR ALL
     USING (auth.role() = 'service_role');
   ```

3. **Add Validation**
   - Validate order_id format
   - Check order belongs to authenticated user
   - Rate limit submissions

## Troubleshooting

### "No order ID provided" Error

- Ensure URL includes `?order_id=something`
- Check URL encoding if order_id contains special characters

### "Failed to load configuration" Error

- Verify Supabase credentials are correct
- Check if tables exist in Supabase dashboard
- Verify RLS policies are enabled

### Data Not Saving

- Check browser console for errors
- Verify RLS policies allow public access
- Check Supabase dashboard → Table Editor to see if data appears

### Resume Not Working

- Data is auto-saved on each answer
- Refresh page to test resume functionality
- Check `personalization_responses` table for saved data

## Files

- **`personalization-flow-supabase.html`** - Main HTML file with Supabase integration
- **`supabase-schema.sql`** - Database schema and setup SQL
- **`README-SUPABASE.md`** - This documentation file

## Next Steps

1. [ ] Replace placeholder meals with actual menu items
2. [ ] Add authentication for production
3. [ ] Implement backend order validation
4. [ ] Set up analytics dashboard using the built-in views
5. [ ] Add email notifications when credit is claimed
6. [ ] Create admin panel to manage configs

## Support

For questions or issues:
1. Check Supabase logs in dashboard
2. Review browser console for JavaScript errors
3. Verify database tables have correct structure
4. Test with sample order IDs from schema

## License

This implementation is part of the Frive order flow project.
