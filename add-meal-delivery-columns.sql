-- ═══════════════════════════════════════════════════════════
-- ADD MEAL COUNT, DELIVERY DAY, GOALS, AND INCENTIVISE COLUMNS
-- ═══════════════════════════════════════════════════════════
-- Run this in your Supabase SQL Editor to add the new columns

-- Add number_of_meals column to personalization_config
ALTER TABLE personalization_config
ADD COLUMN IF NOT EXISTS number_of_meals INTEGER;

-- Add delivery_day column to personalization_config
-- Values should be: 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
ALTER TABLE personalization_config
ADD COLUMN IF NOT EXISTS delivery_day TEXT;

-- Add ask_split_box column to control whether to show the split box question
ALTER TABLE personalization_config
ADD COLUMN IF NOT EXISTS ask_split_box BOOLEAN DEFAULT false;

-- Add ask_goals column to control whether to show the goals question
ALTER TABLE personalization_config
ADD COLUMN IF NOT EXISTS ask_goals BOOLEAN DEFAULT false;

-- Add incentivise column to control whether to show £5 credit messaging
ALTER TABLE personalization_config
ADD COLUMN IF NOT EXISTS incentivise BOOLEAN DEFAULT true;

-- Add comments for documentation
COMMENT ON COLUMN personalization_config.number_of_meals IS 'Number of meals in the order';
COMMENT ON COLUMN personalization_config.delivery_day IS 'Delivery day of the week (Sun, Mon, Tue, Wed, Thu, Fri, Sat)';
COMMENT ON COLUMN personalization_config.ask_split_box IS 'Whether to show the split box question (auto-set based on meal count and delivery day)';
COMMENT ON COLUMN personalization_config.ask_goals IS 'Whether to show the goals question';
COMMENT ON COLUMN personalization_config.incentivise IS 'Whether to show £5 credit messaging (default: true)';

-- Add index for querying by delivery day
CREATE INDEX IF NOT EXISTS idx_config_delivery_day ON personalization_config(delivery_day);

-- Example: Update existing records or insert new test data
-- UPDATE personalization_config 
-- SET number_of_meals = 15, delivery_day = 'Sun', ask_goals = true, incentivise = true
-- WHERE order_id = '127313';

-- Add split_box_preference column to personalization_responses
ALTER TABLE personalization_responses
ADD COLUMN IF NOT EXISTS split_box_preference TEXT;

-- Add goals column to personalization_responses to store selected goals
ALTER TABLE personalization_responses
ADD COLUMN IF NOT EXISTS goals TEXT[] DEFAULT ARRAY[]::TEXT[];

-- Add comments
COMMENT ON COLUMN personalization_responses.split_box_preference IS 'User preference for splitting large boxes ("yes" or "no")';
COMMENT ON COLUMN personalization_responses.goals IS 'Array of selected health goals (e.g., ["improve_health", "build_muscle"])';

-- Verify the changes
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns
WHERE table_name = 'personalization_config'
ORDER BY ordinal_position;

SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns
WHERE table_name = 'personalization_responses'
ORDER BY ordinal_position;
