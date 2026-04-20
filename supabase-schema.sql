-- ═══════════════════════════════════════════════════════════
-- FRIVE PERSONALIZATION FLOW - SUPABASE SCHEMA
-- ═══════════════════════════════════════════════════════════

-- Table 1: Configuration for each order
-- Controls which questions to show for each order
CREATE TABLE personalization_config (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id TEXT UNIQUE NOT NULL,
  ask_preferences BOOLEAN DEFAULT true,
  ask_meal_ratings BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add index on order_id for faster lookups
CREATE INDEX idx_config_order_id ON personalization_config(order_id);

-- Add comments for documentation
COMMENT ON TABLE personalization_config IS 'Configuration flags controlling which personalization questions to show for each order';
COMMENT ON COLUMN personalization_config.order_id IS 'Unique identifier for the order (passed via URL)';
COMMENT ON COLUMN personalization_config.ask_preferences IS 'Whether to show the meal preferences question';
COMMENT ON COLUMN personalization_config.ask_meal_ratings IS 'Whether to show the 10 meal rating questions';


-- Table 2: User responses for each order
-- Stores all answers against the order_id
CREATE TABLE personalization_responses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id TEXT UNIQUE NOT NULL,
  preferences TEXT[] DEFAULT ARRAY[]::TEXT[],
  meal_votes JSONB DEFAULT '{}'::JSONB,
  credit_claimed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_order_id FOREIGN KEY (order_id) REFERENCES personalization_config(order_id) ON DELETE CASCADE
);

-- Add index on order_id for faster lookups
CREATE INDEX idx_responses_order_id ON personalization_responses(order_id);

-- Add index on credit_claimed for analytics queries
CREATE INDEX idx_responses_credit_claimed ON personalization_responses(credit_claimed);

-- Add comments for documentation
COMMENT ON TABLE personalization_responses IS 'Stores all personalization answers for each order';
COMMENT ON COLUMN personalization_responses.order_id IS 'Links to the order_id in personalization_config';
COMMENT ON COLUMN personalization_responses.preferences IS 'Array of selected meal preferences (e.g., ["meat", "fish", "vegetarian"])';
COMMENT ON COLUMN personalization_responses.meal_votes IS 'JSON object mapping meal_id to vote (e.g., {"1": "up", "2": "down"})';
COMMENT ON COLUMN personalization_responses.credit_claimed IS 'Whether the £5 credit has been claimed';
COMMENT ON COLUMN personalization_responses.completed_at IS 'Timestamp when the user completed all questions';


-- Table 3: Individual meal votes (optional - for detailed analytics)
-- Normalized table for easier querying of individual votes
CREATE TABLE meal_votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id TEXT NOT NULL,
  meal_id INTEGER NOT NULL,
  meal_name TEXT,
  vote TEXT CHECK (vote IN ('up', 'down')),
  voted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_meal_votes_order_id FOREIGN KEY (order_id) REFERENCES personalization_config(order_id) ON DELETE CASCADE
);

-- Add indexes for analytics
CREATE INDEX idx_meal_votes_order_id ON meal_votes(order_id);
CREATE INDEX idx_meal_votes_meal_id ON meal_votes(meal_id);
CREATE INDEX idx_meal_votes_vote ON meal_votes(vote);

-- Add comments for documentation
COMMENT ON TABLE meal_votes IS 'Normalized table storing individual meal votes for analytics';
COMMENT ON COLUMN meal_votes.order_id IS 'Links to the order making the vote';
COMMENT ON COLUMN meal_votes.meal_id IS 'ID of the meal being voted on';
COMMENT ON COLUMN meal_votes.vote IS 'Either "up" (thumbs up) or "down" (thumbs down)';


-- ═══════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ═══════════════════════════════════════════════════════════

-- Enable RLS on all tables
ALTER TABLE personalization_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE personalization_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_votes ENABLE ROW LEVEL SECURITY;

-- Policy: Allow public read access to config (so users can see if they should answer questions)
CREATE POLICY "Allow public read access to config"
  ON personalization_config
  FOR SELECT
  USING (true);

-- Policy: Allow public insert/update to config (for creating default configs)
CREATE POLICY "Allow public insert/update to config"
  ON personalization_config
  FOR ALL
  USING (true);

-- Policy: Allow public read/write access to responses (users can save their own answers)
CREATE POLICY "Allow public access to responses"
  ON personalization_responses
  FOR ALL
  USING (true);

-- Policy: Allow public read/write access to meal votes
CREATE POLICY "Allow public access to meal votes"
  ON meal_votes
  FOR ALL
  USING (true);

-- Note: In production, you should restrict these policies based on authentication
-- For example, only allow users to access their own order data


-- ═══════════════════════════════════════════════════════════
-- FUNCTIONS & TRIGGERS
-- ═══════════════════════════════════════════════════════════

-- Function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for personalization_config
CREATE TRIGGER update_config_updated_at
  BEFORE UPDATE ON personalization_config
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for personalization_responses
CREATE TRIGGER update_responses_updated_at
  BEFORE UPDATE ON personalization_responses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- ═══════════════════════════════════════════════════════════
-- SAMPLE DATA (for testing)
-- ═══════════════════════════════════════════════════════════

-- Insert sample config for testing
INSERT INTO personalization_config (order_id, ask_preferences, ask_meal_ratings)
VALUES 
  ('test-order-123', true, true),
  ('test-order-456', false, true),  -- Skip preferences, only show meal ratings
  ('test-order-789', true, false);  -- Only show preferences, skip meal ratings

-- Insert sample responses
INSERT INTO personalization_responses (order_id, preferences, meal_votes, credit_claimed)
VALUES 
  ('test-order-123', ARRAY['meat', 'fish'], '{"1": "up", "2": "down", "3": "up"}'::JSONB, false);


-- ═══════════════════════════════════════════════════════════
-- ANALYTICS VIEWS (optional)
-- ═══════════════════════════════════════════════════════════

-- View: Most popular preferences
CREATE OR REPLACE VIEW preference_analytics AS
SELECT 
  unnest(preferences) as preference,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM personalization_responses WHERE array_length(preferences, 1) > 0), 2) as percentage
FROM personalization_responses
WHERE array_length(preferences, 1) > 0
GROUP BY preference
ORDER BY count DESC;

COMMENT ON VIEW preference_analytics IS 'Shows the most popular meal preferences across all orders';


-- View: Meal vote summary
CREATE OR REPLACE VIEW meal_vote_summary AS
SELECT 
  meal_id,
  meal_name,
  COUNT(CASE WHEN vote = 'up' THEN 1 END) as thumbs_up,
  COUNT(CASE WHEN vote = 'down' THEN 1 END) as thumbs_down,
  ROUND(
    COUNT(CASE WHEN vote = 'up' THEN 1 END) * 100.0 / COUNT(*), 
    2
  ) as approval_rating
FROM meal_votes
GROUP BY meal_id, meal_name
ORDER BY approval_rating DESC;

COMMENT ON VIEW meal_vote_summary IS 'Shows thumbs up/down counts and approval ratings for each meal';


-- View: Completion stats
CREATE OR REPLACE VIEW completion_stats AS
SELECT 
  COUNT(*) as total_started,
  COUNT(CASE WHEN credit_claimed THEN 1 END) as total_completed,
  ROUND(
    COUNT(CASE WHEN credit_claimed THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 
    2
  ) as completion_rate,
  COUNT(CASE WHEN array_length(preferences, 1) > 0 THEN 1 END) as answered_preferences,
  COUNT(CASE WHEN meal_votes IS NOT NULL AND meal_votes != '{}'::JSONB THEN 1 END) as answered_ratings
FROM personalization_responses;

COMMENT ON VIEW completion_stats IS 'Shows overall completion statistics for the personalization flow';


-- ═══════════════════════════════════════════════════════════
-- SETUP COMPLETE
-- ═══════════════════════════════════════════════════════════

-- To use this schema:
-- 1. Copy this entire file
-- 2. Go to your Supabase project dashboard
-- 3. Navigate to SQL Editor
-- 4. Paste and run this SQL
-- 5. Update the SUPABASE_URL and SUPABASE_ANON_KEY in the HTML file
-- 6. Test with URL: ?order_id=test-order-123
