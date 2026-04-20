# Frive Order Flow Project

## Project Overview

This project contains multiple versions of the Frive meal subscription order flow interface. It's a multi-step customer journey designed to help users build personalized meal plans by selecting their goals, preferences, and meal types.

## Project Structure

```
Order Flow/
├── index.html              # Testing hub/homepage with links to all flow versions
├── order-flow.html         # Original/production version (6-step flow)
├── order-flow-v2.html      # Version 2 (variation/testing)
├── order-flow-v3.html      # Version 3 (latest redesign with modern UI)
├── order-flow-script.js    # Shared JavaScript utilities
├── summary.html            # Order summary page
├── fonts/                  # Custom Frive brand fonts
│   ├── FriveJokker-*.ttf
│   └── JokkerTRIAL-Heavy.otf
└── claude.md              # This file
```

## Design System

### Brand Colors
- **Kale (Primary)**: `#053827` - Dark green for text and CTAs
- **Lime (Accent)**: `#C6F432` / `#c6fa5f` - Bright green for highlights and banners
- **Cream Banner**: `#FFF7E8` - Soft background for promotions
- **Border**: `#E0E0E0` - Light grey for card borders
- **Grey-60/80**: Text hierarchy colors

### Typography
- **Font Family**: FriveJokker (custom brand font)
- **Weights**: Regular (400), Medium (500), Bold (700), Heavy (900)
- **Fallback**: Arial, sans-serif

## Flow Versions

### order-flow.html (Original - 6 Steps)

**Purpose**: Full-featured production order flow with comprehensive data collection

**Steps**:
1. **Goals** - User selects health/fitness goals (multiple selection allowed)
2. **Servings** - Choose number of servings per meal (1-4)
3. **Meals & Breakfast** - Select meals per day + optional breakfast inclusion
   - Displays 3 random breakfast items fetched from Frive API
   - Uses CORS proxy (`https://corsproxy.io/`) to access API
4. **Days** - Select delivery frequency (3-7 days/week)
5. **Allergens** - Gatekeeper question + allergen/ingredient selection
6. **Preferences** - Meal type preferences (Meat, Fish, Vegan, etc.)

**Key Features**:
- Session storage for state persistence
- URL-based navigation (step parameter)
- Dynamic breakfast showcase from API
- Allergen gatekeeper pattern
- Progress tracking (max step reached)
- Back button navigation

**API Integration**:
- **Endpoint**: `https://www.frive.co.uk/api/js/v1/menu?orderPriceData=%7B%22basePricingTabId%22%3A3%7D`
- **Method**: Fetches breakfast items where `category === 5`
- **Displays**: 
  - `targetMenuItem.title`
  - `targetMenuItem.medias[0].url` (prefixed with `https://www.frive.co.uk/`)
  - `targetMenuItem.adjustedCalories`
  - Macros: `adjustedProteins`, `adjustedCarbs`, `adjustedFat`
  - `targetMenuItem.price`

### order-flow-v3.html (Latest Redesign - 3 Steps)

**Purpose**: Streamlined, modern UI with mobile-first design

**Steps**:
1. **Goals** - Single selection only, with live banner feedback
2. **Preferences** - Meal type selection with calorie banner
3. **Menu** - Build your basket with filterable meal cards

**Key Features**:
- **Single Goal Selection**: Radio-button behavior (only one goal at a time)
- **Calorie Banner**: Shows "Your average daily calories 1172Kcal, From £7.49 £3.74 per meal"
- **Horizontal Menu Cards**: Deliveroo-style compact layout
  - Image on left (140px desktop, 120px mobile)
  - Title and badges at top
  - Calories/Protein stats + Price on left
  - Add button bottom-right
- **Delivery Date Selector**: Auto-defaults to first available date (2 days offset)
- **Filter Tabs**: All Meals, High Protein, Calorie Conscious
- **Selling Fast Badge**: Sweep-in animation from left
- **Quantity Controls**: +/- buttons when item in basket
- **Clickable Cards**: Entire card opens modal except buttons

**Animations**:
```css
@keyframes sweepInFromLeft {
  from { transform: translateX(-150px); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}
```

**State Management**:
```javascript
state = {
  goals: [],          // Single goal (array with 1 item)
  preferences: [],    // Multiple preferences
  basket: [],         // Items with quantity
  deliveryDate: ''    // Auto-selected date
}
```

### order-flow-v2.html

A variation/testing version (specific differences to be documented).

## Technical Implementation

### Session Storage
All flows use `sessionStorage` to persist user selections:
- State object saved as JSON
- Current step tracked
- Max step reached for back navigation
- Restored on page reload

### URL Navigation
```javascript
// Update URL with step parameter
url.searchParams.set('step', step);
window.history.pushState({}, '', url);
```

### Responsive Design
- **Mobile Breakpoint**: `@media (max-width: 767px)`
- **Mobile-first approach**: Compact cards, horizontal layouts
- **Touch-friendly**: Large tap targets, thumb-accessible controls

### CORS Handling
For API requests that face CORS restrictions:
```javascript
const proxyUrl = 'https://corsproxy.io/?' + encodeURIComponent(apiUrl);
```
**Note**: CORS proxy is a quick solution for development but not recommended for production.

## Development Workflow

### Making Changes
1. Edit the appropriate HTML file
2. Test in browser (index.html provides quick access to all versions)
3. Check mobile responsiveness
4. Verify session storage persistence
5. Test API integration (for order-flow.html)

### Git Workflow
```bash
git add .
git commit -m "Description of changes"
git push
```

### Testing Checklist
- [ ] All steps navigate correctly
- [ ] State persists across page refreshes
- [ ] Back button works
- [ ] URL parameters work
- [ ] Session storage saves/loads
- [ ] API data loads (breakfast cards)
- [ ] Mobile responsive
- [ ] Animations work smoothly

## Key Design Patterns

### Goal Banner Pattern (V3)
When a goal is selected, a light green banner appears at the bottom with a heart icon:
```html
<div class="goal-banner">
  ♥ [Goal message]
</div>
```

### Calorie Banner Pattern (V3)
Shows calculated daily calories and pricing at top of preferences:
```html
<div class="calorie-banner">
  Your average daily calories <strong>1172Kcal,</strong> 
  From £7.49 <strong class="green-price">£3.74</strong> per meal
</div>
```

### Allergen Gatekeeper Pattern (Original)
Ask a yes/no question before showing allergen selection:
1. "Do you have any allergens or ingredients you'd like to avoid?"
2. If Yes → Show allergen/ingredient selection
3. If No → Skip to next step

### Card Selection Patterns
- **Multi-select** (Original): Cards toggle on/off independently
- **Single-select** (V3 Goals): Clicking deselects all others
- **Add to basket** (V3 Menu): Cards show quantity controls when added

## Future Improvements

### Production Recommendations
1. **API Integration**: Replace CORS proxy with proper backend endpoint
2. **Error Handling**: Add user-friendly error messages for API failures
3. **Loading States**: Improve loading indicators for async operations
4. **Analytics**: Track user journey and drop-off points
5. **A/B Testing**: Compare 6-step vs 3-step flow conversion rates
6. **Accessibility**: Add ARIA labels, keyboard navigation
7. **Performance**: Lazy load images, optimize bundle size

### Feature Ideas
- Save favorite meal combinations
- Weekly meal planning view
- Dietary restriction filters
- Recipe preview modals
- Order history integration
- Referral code input
- Gift subscription option

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- ES6+ JavaScript features used
- CSS Grid and Flexbox for layouts
- Fetch API for data loading
- Session Storage API

## Contact & Support

**Repository**: github.com/adamhorne008/order-flow  
**Owner**: adamhorne008  
**Branch**: main

---

## Quick Reference

### Running Locally
1. Clone repository
2. Open `index.html` in browser (no build step required)
3. Click version links to test different flows

### Key Files to Edit
- **UI/Styling**: Edit `<style>` section in each HTML file
- **Logic**: Edit `<script>` section in each HTML file
- **Shared utilities**: `order-flow-script.js`

### Session Storage Keys
- `orderFlowState` - User selections
- `currentStep` - Current step number
- `maxStepReached` - Highest step accessed

### Common Tasks

**Add a new goal**:
```html
<label class="goal-card" onclick="toggleGoal(this)" 
       data-goal="Goal name" 
       data-icon="icon-url" 
       data-message="Banner message">
  <!-- Card content -->
</label>
```

**Add a new preference**:
```html
<button class="pref-card" onclick="togglePref(this)" data-preference="id">
  <!-- Card content -->
</button>
```

**Add a new menu item** (V3):
```javascript
menuItems.push({
  id: 10,
  name: "Meal Name",
  image: "image-url",
  calories: 500,
  protein: 30,
  price: 3.74,
  originalPrice: 7.49,
  categories: ['protein', 'calorie'],
  sellingFast: false,
  badges: ['new'],
  // ... other fields
});
```
