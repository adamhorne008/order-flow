-- ═══════════════════════════════════════════════════════════
-- MEALS TABLE SCHEMA
-- ═══════════════════════════════════════════════════════════

-- Check if meals table exists, if so alter it, otherwise create it
DO $$ 
BEGIN
  -- Add new columns if they don't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'meals' AND column_name = 'tags') THEN
    ALTER TABLE meals ADD COLUMN tags TEXT[] DEFAULT ARRAY[]::TEXT[];
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'meals' AND column_name = 'image_url') THEN
    ALTER TABLE meals ADD COLUMN image_url TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'meals' AND column_name = 'calories') THEN
    ALTER TABLE meals ADD COLUMN calories INTEGER;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'meals' AND column_name = 'protein') THEN
    ALTER TABLE meals ADD COLUMN protein DECIMAL(5,1);
  END IF;
END $$;

-- If table doesn't exist at all, create it
CREATE TABLE IF NOT EXISTS meals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  meal_id TEXT UNIQUE NOT NULL,  -- e.g., 'meal-1', 'meal-2', etc.
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,  -- URL to meal image
  calories INTEGER,  -- e.g., 508
  protein DECIMAL(5,1),  -- e.g., 10.8
  tags TEXT[] DEFAULT ARRAY[]::TEXT[],  -- e.g., ['Meat', 'Gluten-Free'] or ['Vegan', 'Dairy-Free']
  is_active BOOLEAN DEFAULT true,  -- to hide/show meals without deleting them
  display_order INTEGER DEFAULT 0,  -- for sorting meals
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_meals_meal_id ON meals(meal_id);
CREATE INDEX IF NOT EXISTS idx_meals_is_active ON meals(is_active);
CREATE INDEX IF NOT EXISTS idx_meals_display_order ON meals(display_order);

-- Add comments
COMMENT ON TABLE meals IS 'Menu items that users can vote on';
COMMENT ON COLUMN meals.meal_id IS 'Unique text identifier for the meal (e.g., meal-1)';
COMMENT ON COLUMN meals.image_url IS 'URL to meal image';
COMMENT ON COLUMN meals.calories IS 'Calorie content (kcal)';
COMMENT ON COLUMN meals.protein IS 'Protein content in grams';
COMMENT ON COLUMN meals.tags IS 'Array of tags like Meat, Vegan, Fish, Vegetarian, Gluten-Free, Dairy-Free, etc.';
COMMENT ON COLUMN meals.is_active IS 'Whether this meal should be shown to users';
COMMENT ON COLUMN meals.display_order IS 'Order in which meals are shown (lower numbers first)';

-- Enable RLS
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow public read access to active meals" ON meals;
DROP POLICY IF EXISTS "Allow public read access to all meals" ON meals;

-- Policy: Allow public read access to active meals
CREATE POLICY "Allow public read access to active meals"
  ON meals
  FOR SELECT
  USING (is_active = true);

-- Policy: Allow public read access to all meals (for admin purposes, you can restrict this later)
CREATE POLICY "Allow public read access to all meals"
  ON meals
  FOR SELECT
  USING (true);

-- ═══════════════════════════════════════════════════════════
-- UPDATE MEAL_VOTES TABLE
-- ═══════════════════════════════════════════════════════════

-- Drop the old meal_votes table if it exists
DROP TABLE IF EXISTS meal_votes CASCADE;

-- Create new meal_votes table with foreign key to meals
CREATE TABLE meal_votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id TEXT NOT NULL,
  meal_id TEXT NOT NULL,
  vote INTEGER CHECK (vote IN (0, 1)) NOT NULL,  -- 0 = disliked, 1 = liked
  voted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_meal_votes_order_id FOREIGN KEY (order_id) REFERENCES personalization_config(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_meal_votes_meal_id FOREIGN KEY (meal_id) REFERENCES meals(meal_id) ON DELETE CASCADE,
  CONSTRAINT unique_order_meal_vote UNIQUE (order_id, meal_id)  -- One vote per meal per order
);

-- Add indexes for analytics
CREATE INDEX idx_meal_votes_order_id ON meal_votes(order_id);
CREATE INDEX idx_meal_votes_meal_id ON meal_votes(meal_id);
CREATE INDEX idx_meal_votes_vote ON meal_votes(vote);

-- Add comments for documentation
COMMENT ON TABLE meal_votes IS 'Individual meal votes stored separately for analytics';
COMMENT ON COLUMN meal_votes.order_id IS 'Links to the order making the vote';
COMMENT ON COLUMN meal_votes.meal_id IS 'Links to the meal being voted on';
COMMENT ON COLUMN meal_votes.vote IS '0 = disliked (thumbs down), 1 = liked (thumbs up)';

-- Enable RLS
ALTER TABLE meal_votes ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Allow public access to meal votes" ON meal_votes;

-- Policy: Allow public read/write access to meal votes
CREATE POLICY "Allow public access to meal votes"
  ON meal_votes
  FOR ALL
  USING (true);

-- Add trigger for updated_at on meals (drop first if exists)
DROP TRIGGER IF EXISTS update_meals_updated_at ON meals;

CREATE TRIGGER update_meals_updated_at
  BEFORE UPDATE ON meals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ═══════════════════════════════════════════════════════════
-- SAMPLE MEAL DATA
-- ═══════════════════════════════════════════════════════════

-- Update existing meals or insert new ones
INSERT INTO meals (meal_id, name, description, image_url, calories, protein, tags, display_order) VALUES
  ('meal-1', 'Margherita Pizza', 'Classic tomato, mozzarella & basil', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002', 420, 15.5, ARRAY['Vegetarian'], 1),
  ('meal-2', 'Caesar Salad', 'Crispy romaine, parmesan & croutons', 'https://images.unsplash.com/photo-1546793665-c74683f339c1', 280, 8.2, ARRAY['Vegetarian'], 2),
  ('meal-3', 'Chicken Tikka Masala', 'Tender chicken in creamy curry sauce', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641', 485, 28.5, ARRAY['Meat'], 3),
  ('meal-4', 'Beef Burger', 'Juicy beef patty with all the toppings', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd', 620, 32.0, ARRAY['Meat'], 4),
  ('meal-5', 'Vegetable Stir Fry', 'Fresh veggies in savory sauce', 'https://images.unsplash.com/photo-1512058564366-18510be2db19', 320, 8.5, ARRAY['Vegan', 'Vegetarian'], 5),
  ('meal-6', 'Salmon Teriyaki', 'Glazed salmon with steamed rice', 'https://images.unsplash.com/photo-1580959375944-f789412dba95', 445, 35.8, ARRAY['Fish'], 6),
  ('meal-7', 'Pasta Carbonara', 'Creamy bacon & parmesan pasta', 'https://images.unsplash.com/photo-1612874742237-6526221588e3', 550, 22.0, ARRAY['Meat'], 7),
  ('meal-8', 'Greek Salad', 'Feta, olives, cucumber & tomatoes', 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe', 245, 6.5, ARRAY['Vegetarian'], 8),
  ('meal-9', 'Thai Green Curry', 'Coconut curry with vegetables', 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd', 380, 9.2, ARRAY['Vegan', 'Vegetarian'], 9),
  ('meal-10', 'Fish & Chips', 'Crispy battered fish with fries', 'https://images.unsplash.com/photo-1580274455191-1c62238fa333', 685, 28.5, ARRAY['Fish'], 10),
  ('meal-11', 'Grilled Chicken Breast', 'Herb-marinated grilled chicken', 'https://images.unsplash.com/photo-1532550907401-a500c9a57435', 340, 42.0, ARRAY['Meat', 'High-Protein'], 11),
  ('meal-12', 'Tuna Poke Bowl', 'Fresh tuna with rice and avocado', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c', 425, 28.0, ARRAY['Fish'], 12),
  ('meal-13', 'Lentil Dahl', 'Spiced red lentils with rice', 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db', 365, 18.5, ARRAY['Vegan', 'Vegetarian', 'High-Protein'], 13),
  ('meal-14', 'BBQ Ribs', 'Slow-cooked pork ribs with BBQ sauce', 'https://images.unsplash.com/photo-1544025162-d76694265947', 720, 35.0, ARRAY['Meat'], 14),
  ('meal-15', 'Quinoa Buddha Bowl', 'Roasted vegetables with quinoa', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd', 385, 12.5, ARRAY['Vegan', 'Vegetarian'], 15)
ON CONFLICT (meal_id) 
DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url,
  calories = EXCLUDED.calories,
  protein = EXCLUDED.protein,
  tags = EXCLUDED.tags,
  display_order = EXCLUDED.display_order,
  updated_at = NOW();

-- ═══════════════════════════════════════════════════════════
-- UPDATED ANALYTICS VIEWS
-- ═══════════════════════════════════════════════════════════

-- Drop old view and recreate with meal names
DROP VIEW IF EXISTS meal_vote_summary;

CREATE OR REPLACE VIEW meal_vote_summary AS
SELECT 
  m.meal_id,
  m.name as meal_name,
  m.tags,
  COUNT(CASE WHEN mv.vote = 1 THEN 1 END) as thumbs_up,
  COUNT(CASE WHEN mv.vote = 0 THEN 1 END) as thumbs_down,
  COUNT(*) as total_votes,
  ROUND(
    COUNT(CASE WHEN mv.vote = 1 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 
    2
  ) as approval_rating
FROM meals m
LEFT JOIN meal_votes mv ON m.meal_id = mv.meal_id
WHERE m.is_active = true
GROUP BY m.meal_id, m.name, m.tags
ORDER BY approval_rating DESC NULLS LAST;

COMMENT ON VIEW meal_vote_summary IS 'Shows thumbs up/down counts and approval ratings for each meal';

-- ═══════════════════════════════════════════════════════════
-- SETUP COMPLETE
-- ═══════════════════════════════════════════════════════════

-- To use this schema:
-- 1. Copy this entire file
-- 2. Go to your Supabase project dashboard SQL Editor
-- 3. Paste and run this SQL
-- 4. The meals table will be created with 10 sample meals
-- 5. The meal_votes table will be recreated to link to meals properly
