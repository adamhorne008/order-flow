// ═══════════════════════════════════════════════════════════
// FRIVE PERSONALIZATION FLOW - BACKEND INTEGRATION EXAMPLES
// ═══════════════════════════════════════════════════════════

// These examples show how to integrate the personalization flow
// with your backend system (Node.js/Express example)

import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client (server-side with service role key)
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY  // Use service role for backend
);


// ═══════════════════════════════════════════════════════════
// 1. CREATE PERSONALIZATION LINK FOR NEW ORDER
// ═══════════════════════════════════════════════════════════

/**
 * When a customer places an order, create a personalization config
 * and generate a link for them to complete the flow
 */
async function createPersonalizationLink(orderId, options = {}) {
  const {
    askPreferences = true,
    askMealRatings = true,
    baseUrl = 'https://yoursite.com'
  } = options;

  try {
    // Create config in Supabase
    const { data, error } = await supabase
      .from('personalization_config')
      .insert([{
        order_id: orderId,
        ask_preferences: askPreferences,
        ask_meal_ratings: askMealRatings
      }])
      .select()
      .single();

    if (error) throw error;

    // Generate personalization URL
    const personalizationUrl = `${baseUrl}/personalization-flow-supabase.html?order_id=${orderId}`;

    return {
      success: true,
      url: personalizationUrl,
      orderId: orderId
    };
  } catch (error) {
    console.error('Error creating personalization link:', error);
    return {
      success: false,
      error: error.message
    };
  }
}

// Usage example
const result = await createPersonalizationLink('order-12345', {
  askPreferences: true,
  askMealRatings: true
});

console.log('Send this link to customer:', result.url);


// ═══════════════════════════════════════════════════════════
// 2. SEND PERSONALIZATION EMAIL TO CUSTOMER
// ═══════════════════════════════════════════════════════════

/**
 * Send email with personalization link after order placement
 */
async function sendPersonalizationEmail(orderId, customerEmail, customerName) {
  // Create personalization link
  const { success, url } = await createPersonalizationLink(orderId);

  if (!success) {
    throw new Error('Failed to create personalization link');
  }

  // Email template
  const emailHtml = `
    <html>
      <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #053827;">Hi ${customerName}! 🎉</h1>
        
        <p>Thanks for your order! Help us personalize your meals and claim your <strong>£5 credit</strong>.</p>
        
        <p>It only takes 2 minutes:</p>
        <ul>
          <li>✅ Tell us your meal preferences</li>
          <li>✅ Rate 10 meals with thumbs up/down</li>
          <li>✅ Claim your £5 credit!</li>
        </ul>
        
        <a href="${url}" 
           style="display: inline-block; 
                  background: #053827; 
                  color: white; 
                  padding: 14px 32px; 
                  text-decoration: none; 
                  border-radius: 8px;
                  font-weight: bold;
                  margin: 20px 0;">
          Start Personalizing →
        </a>
        
        <p style="color: #666; font-size: 14px;">
          Your credit will be automatically applied to your next order.
        </p>
        
        <p style="color: #999; font-size: 12px; margin-top: 40px;">
          Order ID: ${orderId}<br>
          If you have any questions, reply to this email.
        </p>
      </body>
    </html>
  `;

  // Send email using your email service (e.g., SendGrid, AWS SES, etc.)
  // await sendEmail(customerEmail, 'Claim Your £5 Credit!', emailHtml);

  return { success: true, url };
}


// ═══════════════════════════════════════════════════════════
// 3. CHECK IF CUSTOMER COMPLETED PERSONALIZATION
// ═══════════════════════════════════════════════════════════

/**
 * Check if customer has completed the personalization flow
 * and claimed their credit
 */
async function checkPersonalizationStatus(orderId) {
  try {
    const { data, error } = await supabase
      .from('personalization_responses')
      .select('*')
      .eq('order_id', orderId)
      .single();

    if (error && error.code !== 'PGRST116') {
      throw error;
    }

    if (!data) {
      return {
        started: false,
        completed: false,
        creditClaimed: false
      };
    }

    return {
      started: true,
      completed: data.credit_claimed,
      creditClaimed: data.credit_claimed,
      preferences: data.preferences,
      mealVotes: data.meal_votes,
      completedAt: data.completed_at
    };
  } catch (error) {
    console.error('Error checking status:', error);
    throw error;
  }
}

// Usage example
const status = await checkPersonalizationStatus('order-12345');
if (status.creditClaimed) {
  console.log('Apply £5 credit to customer account');
}


// ═══════════════════════════════════════════════════════════
// 4. APPLY CREDIT TO CUSTOMER ACCOUNT
// ═══════════════════════════════════════════════════════════

/**
 * Apply £5 credit when personalization is completed
 * This would integrate with your payment/billing system
 */
async function applyCreditToAccount(orderId) {
  const status = await checkPersonalizationStatus(orderId);

  if (!status.creditClaimed) {
    return {
      success: false,
      message: 'Personalization not completed yet'
    };
  }

  // Get customer from order
  // const customer = await getCustomerFromOrder(orderId);

  // Apply credit to their account
  // await addCreditToAccount(customer.id, 5.00, 'Personalization bonus');

  return {
    success: true,
    message: '£5 credit applied',
    preferences: status.preferences
  };
}


// ═══════════════════════════════════════════════════════════
// 5. GET CUSTOMER PREFERENCES FOR RECOMMENDATIONS
// ═══════════════════════════════════════════════════════════

/**
 * Retrieve customer preferences to personalize their experience
 */
async function getCustomerPreferences(orderId) {
  try {
    const { data, error } = await supabase
      .from('personalization_responses')
      .select('preferences, meal_votes')
      .eq('order_id', orderId)
      .single();

    if (error) throw error;

    // Parse the data for recommendations
    const preferences = {
      dietary: data.preferences || [],
      likedMeals: [],
      dislikedMeals: []
    };

    // Extract liked/disliked meals from votes
    for (const [mealId, vote] of Object.entries(data.meal_votes || {})) {
      if (vote === 'up') {
        preferences.likedMeals.push(parseInt(mealId));
      } else if (vote === 'down') {
        preferences.dislikedMeals.push(parseInt(mealId));
      }
    }

    return preferences;
  } catch (error) {
    console.error('Error getting preferences:', error);
    return null;
  }
}

// Usage example
const prefs = await getCustomerPreferences('order-12345');
console.log('Customer prefers:', prefs.dietary);
console.log('Customer likes meals:', prefs.likedMeals);
console.log('Customer dislikes meals:', prefs.dislikedMeals);


// ═══════════════════════════════════════════════════════════
// 6. WEBHOOK HANDLER FOR REAL-TIME UPDATES
// ═══════════════════════════════════════════════════════════

/**
 * Set up Supabase webhook to get notified when personalization is completed
 * In Supabase: Database → Webhooks → Create a new webhook
 */
async function handlePersonalizationWebhook(req, res) {
  const { type, table, record } = req.body;

  // Check if this is a personalization completion
  if (table === 'personalization_responses' && record.credit_claimed) {
    const orderId = record.order_id;

    console.log(`Personalization completed for order: ${orderId}`);

    // Apply credit
    await applyCreditToAccount(orderId);

    // Send confirmation email
    // await sendConfirmationEmail(orderId);

    // Update order status
    // await updateOrderStatus(orderId, 'personalization_complete');

    // Trigger recommendation engine
    // await generatePersonalizedRecommendations(orderId);
  }

  res.status(200).json({ success: true });
}

// Express.js route example
// app.post('/webhooks/supabase', handlePersonalizationWebhook);


// ═══════════════════════════════════════════════════════════
// 7. ANALYTICS: GET MOST POPULAR MEALS
// ═══════════════════════════════════════════════════════════

/**
 * Get meal popularity statistics for menu optimization
 */
async function getMealPopularity() {
  try {
    const { data, error } = await supabase
      .from('meal_vote_summary')
      .select('*')
      .order('approval_rating', { ascending: false });

    if (error) throw error;

    return data.map(meal => ({
      mealId: meal.meal_id,
      name: meal.meal_name,
      thumbsUp: meal.thumbs_up,
      thumbsDown: meal.thumbs_down,
      approvalRating: meal.approval_rating,
      totalVotes: meal.thumbs_up + meal.thumbs_down
    }));
  } catch (error) {
    console.error('Error getting meal popularity:', error);
    return [];
  }
}

// Usage example
const popularMeals = await getMealPopularity();
console.log('Top 5 meals:', popularMeals.slice(0, 5));


// ═══════════════════════════════════════════════════════════
// 8. ANALYTICS: GET PREFERENCE STATISTICS
// ═══════════════════════════════════════════════════════════

/**
 * Get statistics on customer dietary preferences
 */
async function getPreferenceStatistics() {
  try {
    const { data, error } = await supabase
      .from('preference_analytics')
      .select('*')
      .order('count', { ascending: false });

    if (error) throw error;

    return data;
  } catch (error) {
    console.error('Error getting preference stats:', error);
    return [];
  }
}

// Usage example
const prefStats = await getPreferenceStatistics();
console.log('Preference breakdown:', prefStats);


// ═══════════════════════════════════════════════════════════
// 9. CONDITIONAL FLOW: SKIP QUESTIONS FOR RETURNING CUSTOMERS
// ═══════════════════════════════════════════════════════════

/**
 * For returning customers, skip preferences if already answered
 */
async function createSmartPersonalizationLink(orderId, customerId) {
  // Check if customer has answered preferences before
  const { data: previousResponses } = await supabase
    .from('personalization_responses')
    .select('preferences')
    .eq('customer_id', customerId)  // You'd need to add this field
    .not('preferences', 'is', null)
    .limit(1);

  const hasAnsweredBefore = previousResponses && previousResponses.length > 0;

  // Create link with conditional flags
  return createPersonalizationLink(orderId, {
    askPreferences: !hasAnsweredBefore,  // Skip if answered before
    askMealRatings: true                 // Always ask about meals
  });
}


// ═══════════════════════════════════════════════════════════
// 10. BULK OPERATIONS: SEND TO MULTIPLE CUSTOMERS
// ═══════════════════════════════════════════════════════════

/**
 * Send personalization links to multiple recent orders
 */
async function sendBulkPersonalizationEmails(orderIds) {
  const results = {
    success: [],
    failed: []
  };

  for (const orderId of orderIds) {
    try {
      // Get customer email from order
      // const order = await getOrder(orderId);
      
      // Create and send link
      // await sendPersonalizationEmail(orderId, order.email, order.name);
      
      results.success.push(orderId);
    } catch (error) {
      console.error(`Failed to send to ${orderId}:`, error);
      results.failed.push({ orderId, error: error.message });
    }
  }

  return results;
}


// ═══════════════════════════════════════════════════════════
// EXPORT ALL FUNCTIONS
// ═══════════════════════════════════════════════════════════

export {
  createPersonalizationLink,
  sendPersonalizationEmail,
  checkPersonalizationStatus,
  applyCreditToAccount,
  getCustomerPreferences,
  handlePersonalizationWebhook,
  getMealPopularity,
  getPreferenceStatistics,
  createSmartPersonalizationLink,
  sendBulkPersonalizationEmails
};
