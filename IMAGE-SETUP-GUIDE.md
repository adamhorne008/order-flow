# Adding Meal Images - Quick Guide

## Updated Schema

The `meals` table now includes:
- `image_url` - URL to the meal image
- `calories` - Calorie content (integer)
- `protein` - Protein content in grams (decimal)

## Sample Data Format

```sql
INSERT INTO meals (meal_id, name, description, image_url, calories, protein, tags) 
VALUES (
  'meal-16',
  'Tom Yum Sweet Potato & Chickpea Curry',
  'with pad Thai noodles, roasted peppers and tomatoes',
  'https://your-image-url.com/meal.jpg',
  508,
  10.8,
  ARRAY['Vegan', 'Vegetarian']
);
```

## Where to Get Meal Images

### Option 1: Use Your Own Images
Upload to a cloud storage service:
- **Supabase Storage** (recommended for your project)
  ```sql
  -- Example URL format:
  'https://fhwkyeccpqtdidnexxrr.supabase.co/storage/v1/object/public/meals/meal-1.jpg'
  ```

- **Cloudinary**, **AWS S3**, **Google Cloud Storage**

### Option 2: Use Unsplash (Free High-Quality Images)
The sample data includes Unsplash URLs:
```
https://images.unsplash.com/photo-[photo-id]
```

### Option 3: Use Your Website's CDN
If you have existing meal images:
```
https://yourwebsite.com/images/meals/meal-1.jpg
```

## Setting Up Supabase Storage (Recommended)

1. **Go to Supabase Storage:**
   https://app.supabase.com/project/fhwkyeccpqtdidnexxrr/storage/buckets

2. **Create a bucket called "meals":**
   - Click "New bucket"
   - Name: `meals`
   - Public: ✅ Yes
   - Click Create

3. **Upload Images:**
   - Click on the `meals` bucket
   - Click Upload files
   - Select your meal images
   - Get public URL for each image

4. **Update Database:**
   ```sql
   UPDATE meals 
   SET image_url = 'https://fhwkyeccpqtdidnexxrr.supabase.co/storage/v1/object/public/meals/chicken-tikka.jpg'
   WHERE meal_id = 'meal-3';
   ```

## Image Requirements

**Recommended Specs:**
- **Dimensions:** 800x600px minimum (4:3 ratio works well)
- **Format:** JPG or WebP (for faster loading)
- **File Size:** Under 200KB (optimized for web)
- **Quality:** High enough to look appetizing

**Content Guidelines:**
- Show the finished dish clearly
- Good lighting (natural light preferred)
- Overhead or 45-degree angle
- Clean background
- Make it look delicious! 😋

## Updating Existing Meals

### Add Image to Existing Meal
```sql
UPDATE meals 
SET image_url = 'https://your-url.com/image.jpg'
WHERE meal_id = 'meal-1';
```

### Update Nutrition Info
```sql
UPDATE meals 
SET calories = 508, 
    protein = 10.8
WHERE meal_id = 'meal-1';
```

### Batch Update Multiple Meals
```sql
UPDATE meals 
SET image_url = CASE meal_id
  WHEN 'meal-1' THEN 'https://url1.jpg'
  WHEN 'meal-2' THEN 'https://url2.jpg'
  WHEN 'meal-3' THEN 'https://url3.jpg'
END
WHERE meal_id IN ('meal-1', 'meal-2', 'meal-3');
```

## Card Display

The meal cards now display like the example you showed:
- **Top:** Meal image (covers full width)
- **Middle:** Meal name, description, calories, protein
- **Bottom:** Two voting buttons (thumbs down / thumbs up)

### Example Card Structure:
```
┌─────────────────────────┐
│                         │
│    [Meal Image]         │
│                         │
├─────────────────────────┤
│ Meal Name               │
│ Description text here   │
│ 508kcal | Protein: 10.8g│
├─────────────────────────┤
│ 👎 Not for me | 👍 Love │
└─────────────────────────┘
```

## Testing

After running the updated schema:

1. **Open the personalization flow**
2. **Select preferences**
3. **View meal cards** - should show:
   - Image at top
   - Meal details
   - Nutritional info (if available)
   - Vote buttons at bottom

## Fallback Image

If a meal has no `image_url`, a default placeholder is used:
```javascript
const imageUrl = meal.image_url || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c';
```

You can change this default in the code or ensure all meals have images.

## Pro Tips

✅ **Use consistent image dimensions** for a polished look
✅ **Optimize images** before uploading (use tools like TinyPNG)
✅ **Use WebP format** for better performance
✅ **Add alt text** in the future for accessibility
✅ **Consider CDN** for faster loading globally

## Next Steps

1. Run the updated SQL schema (meals-table-schema.sql)
2. Upload your meal images to Supabase Storage or use existing URLs
3. Update meal records with image URLs
4. Test the personalization flow to see the new card design!
