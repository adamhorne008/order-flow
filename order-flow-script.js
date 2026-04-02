// Order Flow JavaScript
// This file should be enqueued separately in WordPress

let currentStep = 1;
let breakfastItems = [];

// State object
const state = {
  goals: [],
  servings: 1,
  meals: 2,
  breakfastIncluded: false,
  days: 4,
  allergens: [],
  ingredients: [],
  preferences: []
};

// Save state to localStorage
function saveState() {
  try {
    localStorage.setItem('orderFlowState', JSON.stringify(state));
    localStorage.setItem('orderFlowCurrentStep', currentStep.toString());
  } catch (e) {
    console.error('Error saving state:', e);
  }
}

// Load state from localStorage
function loadState() {
  try {
    const saved = localStorage.getItem('orderFlowState');
    if (saved) {
      Object.assign(state, JSON.parse(saved));
    }
    const savedStep = localStorage.getItem('orderFlowCurrentStep');
    if (savedStep) {
      currentStep = parseInt(savedStep);
    }
    restoreUIFromState();
  } catch (e) {
    console.error('Error loading state:', e);
  }
}

function restoreUIFromState() {
  // Restore goals
  if (state.goals.length > 0) {
    document.querySelectorAll('.goal-card').forEach(card => {
      const goalName = card.getAttribute('data-goal');
      if (state.goals.includes(goalName)) {
        card.classList.add('selected');
        const goalIcon = card.getAttribute('data-icon');
        const goalMessage = card.getAttribute('data-message');
        const banner = document.getElementById('goalBanner');
        const bannerIcon = document.getElementById('goalBannerIcon');
        const bannerText = document.getElementById('goalBannerText');
        if (banner && bannerIcon && bannerText) {
          bannerIcon.src = goalIcon;
          bannerText.textContent = goalMessage;
          banner.style.display = 'flex';
        }
      }
    });
  }
  
  // Restore servings
  document.querySelectorAll('#step-2 .serving-card').forEach(card => {
    if (parseInt(card.dataset.value) === state.servings) {
      card.classList.add('selected');
    }
  });
  
  // Restore meals
  document.querySelectorAll('#step-3 .meal-card').forEach(card => {
    if (parseInt(card.dataset.value) === state.meals) {
      card.classList.add('selected');
    }
  });
  
  // Restore breakfast checkbox
  if (state.breakfastIncluded) {
    document.getElementById('bfastBox').classList.add('checked');
    if (breakfastItems.length > 0) {
      document.getElementById('breakfastShowcaseWrapper').style.display = 'block';
    }
  }
  
  // Restore days
  document.querySelectorAll('#step-4 .day-card').forEach(card => {
    if (parseInt(card.dataset.value) === state.days) {
      card.classList.add('selected');
    }
  });
  
  // Restore allergens
  if (state.allergens.length > 0) {
    document.querySelectorAll('.allergy-pill').forEach(pill => {
      if (state.allergens.includes(pill.textContent.trim())) {
        pill.classList.add('selected');
      }
    });
  }
  
  // Restore ingredients
  if (state.ingredients.length > 0) {
    updateCMSPlaceholder();
  }
  
  // Restore preferences
  if (state.preferences && state.preferences.length > 0) {
    document.querySelectorAll('.pref-card').forEach(card => {
      const prefId = parseInt(card.dataset.preference);
      if (state.preferences.includes(prefId)) {
        card.classList.add('selected');
      }
    });
  }
}

function updateURLStep(step) {
  const url = new URL(window.location);
  url.searchParams.set('step', step);
  window.history.pushState({}, '', url);
}

// Fetch Breakfast Items from API
async function fetchBreakfastItems() {
  try {
    const response = await fetch('https://www.frive.co.uk/api/klaviyo/product-catalog');
    const products = await response.json();
    
    const today = new Date();
    
    const breakfasts = products.filter(item => 
      item.categories && item.categories.includes('Breakfast')
    );
    
    breakfasts.sort((a, b) => {
      const dateA = new Date(a.$menu_date);
      const dateB = new Date(b.$menu_date);
      const diffA = Math.abs(dateA - today);
      const diffB = Math.abs(dateB - today);
      return diffA - diffB;
    });
    
    breakfastItems = breakfasts.slice(0, 3);
    
    if (breakfastItems.length > 0) {
      renderBreakfastCards();
    } else {
      document.getElementById('breakfastShowcaseWrapper').style.display = 'none';
    }
    
  } catch (error) {
    console.error('Error fetching breakfast items:', error);
    const wrapper = document.getElementById('breakfastShowcaseWrapper');
    if (wrapper) {
      wrapper.style.display = 'none';
    }
  }
}

function renderBreakfastCards() {
  const container = document.getElementById('breakfastShowcase');
  
  if (breakfastItems.length === 0) {
    return;
  }
  
  container.innerHTML = breakfastItems.map(item => `
    <div class="breakfast-card">
      <img src="${item.$image_link}" alt="${item.$title}" class="breakfast-card-img" onerror="this.src='https://via.placeholder.com/150?text=No+Image'">
      <div class="breakfast-card-content">
        <h4 class="breakfast-card-title">${item.$title}</h4>
      </div>
    </div>
  `).join('');
}

// Build newOrderFlowModel
function buildNewOrderFlowModel() {
  console.log('========== buildNewOrderFlowModel START ==========');
  
  function isoDate(d) {
    const pad = n => String(n).padStart(2, '0');
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
  }
  
  function defaultNextDeliveryDate() {
    const d = new Date();
    d.setDate(d.getDate() + 3);
    return d;
  }
  
  function buildDeliveryDayNumber(dateStr) {
    const d = new Date(dateStr + 'T00:00:00');
    return d.getDay();
  }
  
  const futureTimestamp = Math.floor(Date.now() / 1000) + (7 * 24 * 60 * 60);
  
  const selectedPreferences = state.preferences || [];
  
  console.log('[buildNewOrderFlowModel] selectedPreferences:', selectedPreferences);
  
  const numberOfBreakfasts = state.breakfastIncluded ? 1 : 0;
  const numberOfMeals = Math.max(0, state.meals - numberOfBreakfasts);
  
  const totalMealsPerWeek = state.meals * state.servings * state.days;
  const totalBreakfastsPerWeek = numberOfBreakfasts * state.servings * state.days;
  
  console.log('[buildNewOrderFlowModel] meal breakdown:', {
    meals: state.meals,
    servings: state.servings,
    days: state.days,
    breakfastIncluded: state.breakfastIncluded,
    numberOfBreakfasts: numberOfBreakfasts,
    numberOfMeals: numberOfMeals,
    totalMealsPerWeek: totalMealsPerWeek,
    totalBreakfastsPerWeek: totalBreakfastsPerWeek
  });
  
  const items = [];
  let itemNumber = 0;
  
  for (let day = 1; day <= state.days; day++) {
    for (let person = 0; person < state.servings; person++) {
      for (let mealInDay = 0; mealInDay < state.meals; mealInDay++) {
        const isBreakfast = state.breakfastIncluded && (mealInDay === 0);
        items.push({
          box: 1,
          day: day,
          menu_id: null,
          number: itemNumber,
          type: isBreakfast ? 11 : 10
        });
        itemNumber++;
      }
    }
  }
  
  console.log('[buildNewOrderFlowModel] generated items:', items.length);
  
  const chosenDate = defaultNextDeliveryDate();
  const nextDateStr = isoDate(chosenDate);
  const deliveryDay = buildDeliveryDayNumber(nextDateStr);
  
  let couponCode = null;
  try {
    const c1 = localStorage.getItem('coupon') || '';
    const c2 = localStorage.getItem('couponCode') || '';
    const c3 = localStorage.getItem('discountCode') || '';
    couponCode = (c1 || c2 || c3).trim() || null;
  } catch (err) {
    console.error('[buildNewOrderFlowModel] Error reading coupon:', err);
  }
  
  let existingModel = null;
  try {
    const saved = localStorage.getItem('newOrderFlowModel');
    if (saved) {
      existingModel = JSON.parse(saved);
      console.log('[buildNewOrderFlowModel] Found existing model');
    }
  } catch (err) {
    console.error('[buildNewOrderFlowModel] Error reading existing model:', err);
  }
  
  const newOrderFlowModel = {
    delivery_count: 1,
    delivery_day: deliveryDay,
    delivery_days: [deliveryDay],
    early_delivery_days: [],
    exclusions: state.allergens || [],
    items: items,
    next_delivery_date: nextDateStr,
    nextDeliveryDateSelection: nextDateStr,
    secondDeliveryDateSelection: '0',
    num_days: state.days,
    numDaysSelection: state.days,
    number_of_breakfasts: numberOfBreakfasts,
    number_of_meals: numberOfMeals,
    number_of_snacks: 0,
    number_of_servings: state.servings,
    selectedBreakfasts: numberOfBreakfasts,
    selectedMeals: state.meals,
    selectedSnacks: 0,
    
    preferences: selectedPreferences,
    goals: state.goals || [],
    
    hasAllergies: state.allergens.length > 0 ? '1' : '0',
    allergies: state.allergens.length > 0 ? state.allergens.join(', ') : null,
    allergiesComplete: true,
    
    cms_avoid: state.ingredients || [],
    
    coupon: couponCode,
    multiproteins_enabled: null,
    goals_question_enabled: true,
    weekly_generated_plans_enabled: false,
    new_summary_enabled: true,
    two_box_upsell_enabled: false,
    one_box_days_of_week: true,
    one_box_plan_recommendation: false,
    one_box_delivery: true,
    isOneBoxDelivery: true,
    
    daysChanged: false,
    has_out_of_stock: false,
    has_out_of_stock_next: false,
    itemsChanged: false,
    hasBreakfasts: state.breakfastIncluded,
    mealsSelected: true,
    
    total_meals_per_week: totalMealsPerWeek,
    total_breakfasts_per_week: totalBreakfastsPerWeek,
    
    meal_id: 13,
    expires: futureTimestamp
  };
  
  if (existingModel) {
    console.log('[buildNewOrderFlowModel] Updating existing model');
    if (existingModel.items && existingModel.items.length === newOrderFlowModel.items.length) {
      newOrderFlowModel.items = newOrderFlowModel.items.map((item, idx) => ({
        ...item,
        menu_id: existingModel.items[idx]?.menu_id || null
      }));
    }
  }
  
  console.log('[buildNewOrderFlowModel] Final model:', newOrderFlowModel);
  
  try {
    localStorage.setItem('newOrderFlowModel', JSON.stringify(newOrderFlowModel));
    localStorage.setItem('newOrderStep', '7');
    console.log('[buildNewOrderFlowModel] Model saved successfully');
  } catch (err) {
    console.error('[buildNewOrderFlowModel] Error saving model:', err);
  }
  
  console.log('========== buildNewOrderFlowModel END ==========');
  return newOrderFlowModel;
}

// Step navigation functions
function showStep(n) {
  const steps = document.querySelectorAll('.order-flow-step');
  const buttons = document.querySelectorAll('.order-flow-button');
  const progressBar = document.querySelector('.progress-fill');
  const voucherBar = document.getElementById('voucherBar');
  const mainBtn = document.getElementById('mainBtn');
  const backBtn = document.getElementById('backBtn');
  
  if (n < 1) n = 1;
  if (n > steps.length) n = steps.length;
  
  currentStep = n;
  
  steps.forEach((step, i) => {
    step.classList.toggle('active', i === n - 1);
  });
  
  buttons.forEach((btn, i) => {
    btn.classList.toggle('active', i === n - 1);
  });
  
  if (progressBar) {
    const progress = ((n - 1) / 5) * 100;
    progressBar.style.width = progress + '%';
  }
  
  if (voucherBar) {
    voucherBar.style.display = n === 1 ? 'block' : 'none';
  }
  
  if (mainBtn) {
    if (n === 6) {
      mainBtn.textContent = 'See My Meals';
    } else {
      mainBtn.textContent = 'Continue';
    }
  }
  
  if (backBtn) {
    backBtn.style.display = n === 1 ? 'none' : 'flex';
  }
  
  if (n === 5) {
    const gatekeeperSection = document.getElementById('allergenGatekeeper');
    const allergenContent = document.getElementById('allergenContent');
    if (gatekeeperSection && allergenContent) {
      gatekeeperSection.style.display = 'block';
      allergenContent.style.display = 'none';
    }
  }
  
  if (n === 6) {
    updateAllergenNotice();
  }
  
  saveState();
  updateURLStep(n);
}

function goToStep(n) {
  showStep(n);
}

function goBack() {
  if (currentStep > 1) {
    showStep(currentStep - 1);
  }
}

function handleMainBtn() {
  if (currentStep < 6) {
    showStep(currentStep + 1);
  } else {
    buildNewOrderFlowModel();
    window.location.href = 'summary.html';
  }
}

// Step 1: Goals
function toggleGoal(el) {
  const goalName = el.getAttribute('data-goal');
  const goalIcon = el.getAttribute('data-icon');
  const goalMessage = el.getAttribute('data-message');
  
  const isSelected = el.classList.contains('selected');
  
  if (isSelected) {
    el.classList.remove('selected');
    const index = state.goals.indexOf(goalName);
    if (index > -1) state.goals.splice(index, 1);
    
    const banner = document.getElementById('goalBanner');
    if (banner && state.goals.length === 0) {
      banner.style.display = 'none';
    }
  } else {
    document.querySelectorAll('.goal-card').forEach(card => card.classList.remove('selected'));
    el.classList.add('selected');
    state.goals = [goalName];
    
    const banner = document.getElementById('goalBanner');
    const bannerIcon = document.getElementById('goalBannerIcon');
    const bannerText = document.getElementById('goalBannerText');
    
    if (banner && bannerIcon && bannerText) {
      bannerIcon.src = goalIcon;
      bannerText.textContent = goalMessage;
      banner.style.display = 'flex';
    }
  }
  
  saveState();
}

// Step 2 & 3 & 4: Radio selection
function selectRadio(el, selector) {
  document.querySelectorAll(selector).forEach(card => card.classList.remove('selected'));
  el.classList.add('selected');
  
  const val = parseInt(el.dataset.value);
  
  if (selector.includes('serving')) {
    state.servings = val;
  } else if (selector.includes('meal')) {
    state.meals = val;
  } else if (selector.includes('day')) {
    state.days = val;
  }
  
  saveState();
}

// Step 3: Breakfast
function toggleBreakfast(el) {
  state.breakfastIncluded = !state.breakfastIncluded;
  document.getElementById('bfastBox').classList.toggle('checked', state.breakfastIncluded);
  
  const showcaseWrapper = document.getElementById('breakfastShowcaseWrapper');
  if (state.breakfastIncluded && breakfastItems.length > 0) {
    showcaseWrapper.style.display = 'block';
  } else {
    showcaseWrapper.style.display = 'none';
  }
  
  saveState();
}

// Step 5: Allergen Gatekeeper
function answerAllergenQuestion(answer) {
  const gatekeeperSection = document.getElementById('allergenGatekeeper');
  const allergenContent = document.getElementById('allergenContent');
  const buttons = document.querySelectorAll('.gatekeeper-btn');
  
  buttons.forEach(btn => btn.classList.remove('selected'));
  event.target.classList.add('selected');
  
  if (answer === 'yes') {
    setTimeout(() => {
      gatekeeperSection.style.display = 'none';
      allergenContent.style.display = 'block';
    }, 300);
  } else {
    setTimeout(() => {
      showStep(currentStep + 1);
    }, 300);
  }
}

// Step 5: Allergens
function toggleAllergen(el) {
  el.classList.toggle('selected');
  const text = el.textContent.trim();
  if (el.classList.contains('selected')) state.allergens.push(text);
  else state.allergens = state.allergens.filter(a => a !== text);
  saveState();
}

function toggleCMS() {
  const dd = document.getElementById('cmsDropdown');
  const arrow = document.getElementById('cmsArrow');
  dd.classList.toggle('open');
  arrow.style.transform = dd.classList.contains('open')
    ? 'translateY(-50%) rotate(180deg)'
    : 'translateY(-50%)';
}

function selectIngredient(el) {
  if (el.classList.contains('selected')) {
    el.classList.remove('selected');
    state.ingredients = state.ingredients.filter(i => i !== el.textContent);
  } else {
    if (state.ingredients.length >= 3) return;
    el.classList.add('selected');
    state.ingredients.push(el.textContent.trim());
  }
  const placeholder = document.getElementById('cmsPlaceholder');
  placeholder.textContent = state.ingredients.length ? state.ingredients.join(', ') : 'Select items';
  saveState();
}

function updateCMSPlaceholder() {
  const placeholder = document.getElementById('cmsPlaceholder');
  if (placeholder && state.ingredients.length > 0) {
    placeholder.textContent = state.ingredients.join(', ');
    document.querySelectorAll('.cms-option').forEach(option => {
      if (state.ingredients.includes(option.textContent.trim())) {
        option.classList.add('selected');
      }
    });
  }
}

// Step 6: Preferences
function togglePref(el) { 
  el.classList.toggle('selected');
  const prefId = parseInt(el.dataset.preference);
  
  if (el.classList.contains('selected')) {
    if (!state.preferences.includes(prefId)) {
      state.preferences.push(prefId);
    }
  } else {
    state.preferences = state.preferences.filter(p => p !== prefId);
  }
  
  saveState();
}

function updateAllergenNotice() {
  const notice = document.getElementById('allergenNotice');
  const text = document.getElementById('allergenNoticeText');
  if (state.allergens.length > 0) {
    notice.classList.add('visible');
    text.textContent = 'Your allergens: ' + state.allergens.join(', ');
  } else {
    notice.classList.remove('visible');
  }
}

// Close dropdown on outside click
document.addEventListener('click', e => {
  const dd = document.getElementById('cmsDropdown');
  if (dd && !e.target.closest('.custom-multiselect')) {
    dd.classList.remove('open');
    document.getElementById('cmsArrow').style.transform = 'translateY(-50%)';
  }
});

// Event Listeners Setup
function setupEventListeners() {
  // Step 1: Goals
  document.querySelectorAll('.goal-card').forEach(card => {
    card.addEventListener('click', function(e) {
      e.preventDefault();
      toggleGoal(this);
    });
  });

  // Step 2: Servings
  document.querySelectorAll('#step-2 .serving-card').forEach(card => {
    card.addEventListener('click', function(e) {
      e.preventDefault();
      selectRadio(this, '#step-2 .serving-card');
    });
  });

  // Step 3: Meals
  document.querySelectorAll('#step-3 .meal-card').forEach(card => {
    card.addEventListener('click', function(e) {
      e.preventDefault();
      selectRadio(this, '#step-3 .meal-card');
    });
  });

  // Step 3: Breakfast checkbox
  const breakfastRow = document.querySelector('.breakfast-row');
  if (breakfastRow) {
    breakfastRow.addEventListener('click', function(e) {
      e.preventDefault();
      toggleBreakfast(this);
    });
  }

  // Step 4: Days
  document.querySelectorAll('#step-4 .day-card').forEach(card => {
    card.addEventListener('click', function(e) {
      e.preventDefault();
      selectRadio(this, '#step-4 .day-card');
    });
  });

  // Step 5: Gatekeeper buttons
  document.querySelectorAll('.gatekeeper-btn').forEach(btn => {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      const text = this.textContent.trim().toLowerCase();
      const answer = text === 'yes' ? 'yes' : 'no';
      answerAllergenQuestion(answer);
    });
  });

  // Step 5: Allergen pills
  document.querySelectorAll('.allergy-pill').forEach(pill => {
    pill.addEventListener('click', function(e) {
      e.preventDefault();
      toggleAllergen(this);
    });
  });

  // Step 5: CMS dropdown toggle
  const cmsInput = document.querySelector('.cms-input');
  if (cmsInput) {
    cmsInput.addEventListener('click', function(e) {
      e.preventDefault();
      toggleCMS();
    });
  }

  // Step 5: CMS options
  document.querySelectorAll('.cms-option').forEach(option => {
    option.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      selectIngredient(this);
    });
  });

  // Step 6: Preferences
  document.querySelectorAll('.pref-card').forEach(card => {
    card.addEventListener('click', function(e) {
      e.preventDefault();
      togglePref(this);
    });
  });

  // Main button
  const mainBtn = document.getElementById('mainBtn');
  if (mainBtn) {
    mainBtn.addEventListener('click', function(e) {
      e.preventDefault();
      handleMainBtn();
    });
  }

  // Back button
  const backBtn = document.getElementById('backBtn');
  if (backBtn) {
    backBtn.addEventListener('click', function(e) {
      e.preventDefault();
      goBack();
    });
  }

  // Step navigation buttons
  document.querySelectorAll('.order-flow-button').forEach(btn => {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      const step = parseInt(this.dataset.step);
      if (step) goToStep(step);
    });
  });
}

// Init
window.addEventListener('DOMContentLoaded', function() {
  setupEventListeners();
  loadState();
  fetchBreakfastItems();
  showStep(currentStep || 1);
});
