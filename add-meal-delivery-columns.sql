-- ═══════════════════════════════════════════════════════════
-- ADD MEAL COUNT AND DELIVERY DAY COLUMNS
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

-- Add comments for documentation
COMMENT ON COLUMN personalization_config.number_of_meals IS 'Number of meals in the order';
COMMENT ON COLUMN personalization_config.delivery_day IS 'Delivery day of the week (Sun, Mon, Tue, Wed, Thu, Fri, Sat)';
COMMENT ON COLUMN personalization_config.ask_split_box IS 'Whether to show the split box question (auto-set based on meal count and delivery day)';

-- Add index for querying by delivery day
CREATE INDEX IF NOT EXISTS idx_config_delivery_day ON personalization_config(delivery_day);

-- Example: Update existing records or insert new test data
-- UPDATE personalization_config 
-- SET number_of_meals = 15, delivery_day = 'Sun'
-- WHERE order_id = '127313';

-- Add split_box_preference column to personalization_responses
ALTER TABLE personalization_responses
ADD COLUMN IF NOT EXISTS split_box_preference TEXT;

-- Add comment
COMMENT ON COLUMN personalization_responses.split_box_preference IS 'User preference for splitting large boxes ("yes" or "no")';

-- Verify the changes
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns
WHERE table_name = 'personalization_config'
ORDER BY ordinal_position;

SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns
WHERE table_name = 'personalization_responses'
ORDER BY ordinal_position;
