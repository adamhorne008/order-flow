-- ═══════════════════════════════════════════════════════════
-- FIX MEAL_VOTES TABLE TO USE INTEGER VOTES
-- Run this script to update the meal_votes table from TEXT to INTEGER
-- ═══════════════════════════════════════════════════════════

-- Drop the old meal_votes table if it exists
DROP TABLE IF EXISTS meal_votes CASCADE;

-- Create new meal_votes table with INTEGER vote column
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

-- Create RLS policy for meal_votes (allow all operations for now)
DROP POLICY IF EXISTS "Allow public access to meal_votes" ON meal_votes;
CREATE POLICY "Allow public access to meal_votes"
  ON meal_votes
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Verify the change
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'meal_votes'
ORDER BY ordinal_position;
