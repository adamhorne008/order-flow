-- ═══════════════════════════════════════════════════════════
-- UPDATE MEALS TABLE FROM CSV EXPORT
-- This script updates the meals table with data from Meal_export (1).csv
-- ═══════════════════════════════════════════════════════════

-- Clear existing sample data (optional - comment out if you want to keep some meals)
-- DELETE FROM meals WHERE is_active = true;

-- Insert/Update meals from export (only sku_type = 'meals' or 'Fish', 'Meat', 'Vegan')
-- Using ON CONFLICT to update existing or insert new

-- Fish meals
INSERT INTO meals (meal_id, name, description, image_url, calories, protein, tags, is_active, display_order)
VALUES 
  ('meal-566', 'Creamy Garlic Tuscan Salmon', 'with lemon and herb crushed potatoes and green beans', 'https://cloudfront.frive.co.uk/media/7157/opt_upload.png', 629, 31.8, ARRAY['Fish'], true, 1),
  ('meal-570', 'Coconut & Lime Leaf King Prawns', 'with rice and stir-fried vegetables', 'https://cloudfront.frive.co.uk/media/7159/opt_upload.png', 631, 39.3, ARRAY['Fish'], true, 2),
  ('meal-632', 'Thai-Style King Prawns With Noodles & Tom Yum-Inspired Sauce', 'With Noodles, Roasted Peppers & Cherry Tomatoes', 'https://cloudfront.frive.co.uk/media/7160/opt_upload.png', 540, 28.6, ARRAY['Fish'], true, 3),
  ('meal-652', 'Saffron & Paprika Baked Bass', 'with stewed fennel, garbanzo beans and peppers', 'https://cloudfront.frive.co.uk/media/7164/opt_upload.png', 584, 34.6, ARRAY['Fish'], true, 4),
  ('meal-655', 'Massaman King Prawns', 'with rice, peanuts and Thai basil carrots', 'https://cloudfront.frive.co.uk/media/6730/opt_upload.png', 512, 29.5, ARRAY['Fish'], true, 5),
  ('meal-736', 'Mediterranean Baked Sea Bass', 'with crushed potatoes and basil roasted courgettes', 'https://cloudfront.frive.co.uk/media/7174/opt_upload.png', 592, 34.2, ARRAY['Fish'], true, 6),
  ('meal-750', 'Red Thai Salmon', 'with sticky rice and stir-fried vegetables', 'https://cloudfront.frive.co.uk/media/6740/opt_upload.png', 628, 31.7, ARRAY['Fish'], true, 7),
  ('meal-903', 'Red Thai King Prawns', 'with sticky rice and stir-fried vegetables', 'https://cloudfront.frive.co.uk/media/7182/opt_upload.png', 582, 35.4, ARRAY['Fish'], true, 8),
  ('meal-917', 'Steamed Sea Bass & Green Thai Curry', 'with sticky rice and green beans', 'https://cloudfront.frive.co.uk/media/6915/opt_917-Steamed_Seabass_with_Green_Thai_Curry,-Jasmine_Rice_Green_Beans.jpg', 549, 32.3, ARRAY['Fish'], true, 9),
  ('meal-970', 'Roasted Sea Bass With Tomato & Herb Penne Pasta', 'With Tomato Penne Pasta & Green Beans', 'https://cloudfront.frive.co.uk/media/6755/opt_upload.png', 565, 39.3, ARRAY['Fish'], true, 10),
  ('meal-977', 'Vietnamese Sea Bass', 'with rice and green beans', 'https://cloudfront.frive.co.uk/media/6758/opt_upload.png', 560, 32.7, ARRAY['Fish'], true, 11),
  ('meal-1097', 'Hazelnut Dukkah Crusted Salmon', 'with herby potatoes, carrots and a Moroccan sauce', 'https://cloudfront.frive.co.uk/media/7104/opt_upload.png', 606, 30.6, ARRAY['Fish'], true, 12),
  ('meal-1125', 'King Prawn Korma', 'with rice and tandoori roasted cauliflower', 'https://cloudfront.frive.co.uk/media/6772/opt_upload.png', 596, 35.2, ARRAY['Fish'], true, 13),
  ('meal-1177', 'Citrus & Miso Salmon Poke Bowl', 'with sticky edamame rice and pickled ginger', 'https://cloudfront.frive.co.uk/media/6777/opt_upload.png', 622, 34.8, ARRAY['Fish'], true, 14),
  ('meal-1228', 'Chilli Lemon & Garlic King Prawns', 'with roast potatoes and tomatoes', 'https://cloudfront.frive.co.uk/media/6960/opt_1228-Chilli_Lemon_&_Garlic_Prawns_with_Roasted_Potatoes_&_Tomatoes.jpg', 572, 33.1, ARRAY['Fish'], true, 15),
  ('meal-1278', 'Lemongrass & Coconut Sea Bass Curry', 'with brown rice, squash and broccoli', 'https://cloudfront.frive.co.uk/media/6923/opt_1278-Lemongrass_Coconut_Sea_Bass_Curry-Brown_Rice-Squash_Broccoli.jpg', 587, 35.8, ARRAY['Fish'], true, 16),
  ('meal-1396', 'Prawn Panang Curry', 'with Jasmine Rice, Crunchy Green Beans', 'https://cloudfront.frive.co.uk/media/7829/opt_900x600_5576-PRAWN_PANANG-BALANCED_(1).png', 540, 33.3, ARRAY['Fish'], true, 17),
  ('meal-1436', 'Mediterranean-Inspired Basa With Roasted Potatoes & Peppers', 'With Roasted Potatoes, Peppers, Olives & Capers', 'https://cloudfront.frive.co.uk/media/7688/opt_LP-REC-3102-Basa_Panzanella.png', 712, 38.9, ARRAY['Fish'], true, 18),
  ('meal-1437', 'Smoky Tomato Basa', 'with Sweet Potatoes and Cherry Tomatoes', 'https://cloudfront.frive.co.uk/media/7672/opt_LP-REC-3033-Smoky_Tomato_Basa.png', 645, 36.3, ARRAY['Fish'], true, 19),
  ('meal-1438', 'Asian BBQ Basa', 'with Jasmine Rice and Japanese Vegetables', 'https://cloudfront.frive.co.uk/media/7670/opt_LP-REC-3036-BBQ_Basa.png', 634, 39.5, ARRAY['Fish'], true, 20),
  ('meal-1439', 'Thai Basa Curry', 'with Jasmine Rice and Green Beans', 'https://cloudfront.frive.co.uk/media/7671/opt_LP-REC-3039-Red_Thai_Basa.png', 629, 38.0, ARRAY['Fish'], true, 21),
  ('meal-1443', 'Cajun King Prawns & Spanish-Style Rice', 'With Spanish-Style Rice, Butternut Squash & Peas', 'https://cloudfront.frive.co.uk/media/7729/opt_1443_Prawn_Paella.png', 374, 29.2, ARRAY['Fish'], true, 22),
  ('meal-1444', 'Smoky Chipotle Prawns With Black Bean Rice', 'With Black Bean Rice, Shredded Veg & Avocado Dressing', 'https://cloudfront.frive.co.uk/media/7730/opt_LP-REC-3085-Baja_Prawns.png', 505, 33.7, ARRAY['Fish'], true, 23),
  ('meal-1445', 'Pesto Seabass', 'Roasted Potatoes, Cherry Tomatoes, Pepper Salsa', 'https://cloudfront.frive.co.uk/media/7709/opt_1445-PESTO_BASS.png', 598, 34.0, ARRAY['Fish'], true, 24),
  ('meal-1446', 'Thai-Inspired Ginger Bass', 'With Jasmine Rice, Mango & Thai Basil Salad', 'https://cloudfront.frive.co.uk/media/7710/opt_1446-THAI_GINGER_BASS.png', 563, 32.8, ARRAY['Fish'], true, 25),
  ('meal-1451', 'Citrus Sea Bass With Quinoa & Roasted Veg', 'With Quinoa and Roasted Veg', 'https://cloudfront.frive.co.uk/media/7715/opt_1451-LEMON_BASS-QUINOA-SUMMER_PEA_MEDLEY.png', 515, 37.0, ARRAY['Fish'], true, 26),
  ('meal-1453', 'Teriyaki Salmon Noodles', 'with Matchstick Vegetable Stir Fry', 'https://cloudfront.frive.co.uk/media/7717/opt_1453-TERIYAKI_SALMON-BALANCED.png', 550, 29.2, ARRAY['Fish'], true, 27)
ON CONFLICT (meal_id) 
DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url,
  calories = EXCLUDED.calories,
  protein = EXCLUDED.protein,
  tags = EXCLUDED.tags,
  is_active = EXCLUDED.is_active,
  display_order = EXCLUDED.display_order,
  updated_at = NOW();

-- Meat meals
INSERT INTO meals (meal_id, name, description, image_url, calories, protein, tags, is_active, display_order)
VALUES 
  ('meal-665', 'Satay Chicken', 'with rice and peppers', 'https://cloudfront.frive.co.uk/media/7673/opt_LP-REC-745-Satay_Chicken_Balanced.png', 586, 56.8, ARRAY['Meat'], true, 28),
  ('meal-738', 'Lamb Rendang', 'with rice, roasted peppers, tomatoes', 'https://cloudfront.frive.co.uk/media/6738/opt_upload.png', 633, 44.3, ARRAY['Meat'], true, 29),
  ('meal-760', 'Shoyu Chicken Thighs', 'with Hawaiian rice, chilli roasted corn and pineapple chutney', 'https://cloudfront.frive.co.uk/media/6360/opt_upload.png', 557, 41.2, ARRAY['Meat'], true, 30),
  ('meal-905', 'Smokey Baharat Mango Chicken', 'with smashed sweet potato and roasted cherry tomatoes', 'https://cloudfront.frive.co.uk/media/7184/opt_upload.png', 585, 49.4, ARRAY['Meat'], true, 31),
  ('meal-915', 'Roasted Turkey Slices', 'with roast potatoes, broccoli, carrots and homemade gravy', 'https://cloudfront.frive.co.uk/media/6866/opt_915_Roasted_Turkey_Slices_with_Roast_Potatoes_Broccoli_Carrots_Gravy.jpg', 601, 42.1, ARRAY['Meat'], true, 32),
  ('meal-934', 'Firecracker Chicken Thighs', 'with cabbage rice and peppers', 'https://cloudfront.frive.co.uk/media/6338/opt_upload.png', 504, 39.0, ARRAY['Meat'], true, 33),
  ('meal-935', 'Firecracker Chicken Thighs', 'with rice and peppers', 'https://cloudfront.frive.co.uk/media/6339/opt_upload.png', 558, 39.3, ARRAY['Meat'], true, 34),
  ('meal-945', 'Turkish Lamb Kofte Balls', 'Aromatic Rice, Warm Cabbage with Lemon and Herbs, Light Coconut Curry Sauce and Pepper Salsa', 'https://cloudfront.frive.co.uk/media/7675/opt_LP-REC-3145-Turkish_Lamb_Kofte_Balls_balanced.png', 587, 34.7, ARRAY['Meat'], true, 35),
  ('meal-983', 'Harissa Lamb & Chickpea Stew', 'with lemon and herb potatoes and green beans', 'https://cloudfront.frive.co.uk/media/6919/opt_983-Harissa_Lamb_Chickpeas_with_Lemon_Herb_Steamed_Potatoes_Green_Beans.jpg', 551, 34.4, ARRAY['Meat'], true, 36),
  ('meal-1004', 'Thai Basil Beef', 'with jasmine rice and mixed greens', 'https://cloudfront.frive.co.uk/media/7095/opt_upload.png', 565, 37.1, ARRAY['Meat'], true, 37),
  ('meal-1016', 'Taiwanese Chilli Chicken', 'with noodles, dressed greens', 'https://cloudfront.frive.co.uk/media/6759/opt_upload.png', 607, 57.1, ARRAY['Meat'], true, 38),
  ('meal-1018', 'Tandoori Grilled Chicken', 'with rice, roasted tomatoes and mango glaze', 'https://cloudfront.frive.co.uk/media/6761/opt_upload.png', 604, 50.6, ARRAY['Meat'], true, 39),
  ('meal-1059', 'Beef Jalfrezi', 'with peppers and aromatic rice', 'https://cloudfront.frive.co.uk/media/7099/opt_upload.png', 622, 47.3, ARRAY['Meat'], true, 40),
  ('meal-1082', 'Massaman Beef Curry', 'with rice, carrots and peppers', 'https://cloudfront.frive.co.uk/media/6765/opt_upload.png', 594, 46.6, ARRAY['Meat'], true, 41),
  ('meal-1089', 'Harissa Lamb Meatballs', 'with rice, roasted peppers and harissa sauce', 'https://cloudfront.frive.co.uk/media/6249/opt_upload.png', 589, 35.3, ARRAY['Meat'], true, 42),
  ('meal-1090', 'Harissa Lamb Meatballs', 'with cabbage rice, roasted peppers and harissa sauce', 'https://cloudfront.frive.co.uk/media/6250/opt_upload.png', 512, 33.6, ARRAY['Meat'], true, 43),
  ('meal-1099', 'Chicken Tikka Masala', 'with rice, tomatoes and peppers', 'https://cloudfront.frive.co.uk/media/7795/opt_900x600_1098-Chicken_Tikka_Masala_Pilau_Rice_Tomatoes_Peppers_(5).png', 610, 51.6, ARRAY['Meat'], true, 44),
  ('meal-1148', 'Ground Beef & Coconut Curry', 'with mixed rice and green beans', 'https://cloudfront.frive.co.uk/media/7107/opt_upload.png', 641, 37.8, ARRAY['Meat'], true, 45),
  ('meal-1195', 'Chicken Thigh Shawarma', 'with rice, pickled red cabbage and chilli sauce', 'https://cloudfront.frive.co.uk/media/6785/opt_upload.png', 633, 47.3, ARRAY['Meat'], true, 46),
  ('meal-1196', 'Chicken Thigh Shawarma', 'with cabbage rice, pickled red cabbage and chilli sauce', 'https://cloudfront.frive.co.uk/media/6786/opt_upload.png', 537, 45.1, ARRAY['Meat'], true, 47),
  ('meal-1218', 'Chicken Korma', 'with cabbage rice and broccoli', 'https://cloudfront.frive.co.uk/media/6787/opt_upload.png', 512, 47.5, ARRAY['Meat'], true, 48),
  ('meal-1219', 'Chicken Korma', 'with pilau rice and broccoli', 'https://cloudfront.frive.co.uk/media/6788/opt_upload.png', 583, 49.1, ARRAY['Meat'], true, 49),
  ('meal-1241', 'Lamb Burger', 'with smashed sweet potato and Mediterranean vegetables', 'https://cloudfront.frive.co.uk/media/7117/opt_upload.png', 608, 30.4, ARRAY['Meat'], true, 50),
  ('meal-1261', 'Green Thai Chicken Curry', 'with rice, stir-fried vegetables and sugar snaps', 'https://cloudfront.frive.co.uk/media/7119/opt_upload.png', 565, 52.3, ARRAY['Meat'], true, 51),
  ('meal-1367', 'Spaghetti & Meatballs', 'in a Roasted Tomato Sauce with basil roasted vegetable medley', 'https://cloudfront.frive.co.uk/media/6302/opt_upload.png', 593, 45.2, ARRAY['Meat'], true, 52),
  ('meal-1375', 'Chicken Puttanesca Rigatoni', 'with basil roasted vegetable medley', 'https://cloudfront.frive.co.uk/media/6308/opt_upload.png', 583, 35.1, ARRAY['Meat'], true, 53),
  ('meal-1441', 'Grilled Beef Burger', 'Roast Potatoes, Pepper and Onion Medley, Sweet Corn Salsa and Tomato Relish', 'https://cloudfront.frive.co.uk/media/7679/opt_LP-REC-3144-Beef_Burger_Balanced.png', 574, 32.6, ARRAY['Meat'], true, 54),
  ('meal-1442', 'Turkish Lamb Kofte Balls', 'Aromatic Cabbage Rice, Warm Cabbage with Lemon and Herbs, Light Coconut Curry Sauce and Pepper Salsa', 'https://cloudfront.frive.co.uk/media/7676/opt_LP-REC-3146-Turkish_Lamb_Kofte_Balls_lowe_carb.png', 523, 33.2, ARRAY['Meat'], true, 55),
  ('meal-1452', 'Smoky BBQ Chicken With Spinach Rigatoni', 'With Spinach Rigatoni & Roasted Sweetcorn', 'https://cloudfront.frive.co.uk/media/7716/opt_1452-BBQ_CHICKEN-SWEETCORN_RIGATONI.png', 569, 41.7, ARRAY['Meat'], true, 56),
  ('meal-1455', 'Jerk Chicken With Rice & Peas & Plantain', 'With Rice & Peas, Plantain & Spiced Gravy', 'https://cloudfront.frive.co.uk/media/7760/opt_LP-PRO-1455-Chilli-Jerk-Chicken-V1.png', 649, 49.8, ARRAY['Meat'], true, 57),
  ('meal-1463', 'Chicken Pho with Rice Noodles, Fresh Herbs & Peppers', 'with Rice Noodles, Fresh Herbs and Peppers', 'https://cloudfront.frive.co.uk/media/7762/opt_LP-PRO-1463-Chicken-Pho.png', 484, 44.3, ARRAY['Meat'], true, 58),
  ('meal-1465', 'Thai Coconut Chicken Soup with Lemongrass, Lime & Fresh Herbs', 'with Lemongrass, Lime and Fresh Herbs', 'https://cloudfront.frive.co.uk/media/7764/opt_LP-PRO-1465-Thai-Coconut-Chicken-Curry-Soup.png', 550, 33.5, ARRAY['Meat'], true, 59),
  ('meal-1469', 'Thai Red Chicken, Dressed Green Beans, Curry & Ginger Smashed Sweet Potato', 'Thai Red Chicken, Dressed Green Beans, Curry Ginger Smashed Sweet Potato', 'https://cloudfront.frive.co.uk/media/7769/opt_Thai-Red-Chicken-Breast-with-green-beans-and-crushed-sweet-potato-mash.png', 629, 44.8, ARRAY['Meat'], true, 60)
ON CONFLICT (meal_id) 
DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url,
  calories = EXCLUDED.calories,
  protein = EXCLUDED.protein,
  tags = EXCLUDED.tags,
  is_active = EXCLUDED.is_active,
  display_order = EXCLUDED.display_order,
  updated_at = NOW();

-- Vegan meals
INSERT INTO meals (meal_id, name, description, image_url, calories, protein, tags, is_active, display_order)
VALUES 
  ('meal-646', 'Tom Yum Sweet Potato & Chickpea Curry', 'with pad Thai noodles, roasted peppers and tomatoes', 'https://cloudfront.frive.co.uk/media/7161/opt_upload.png', 508, 10.8, ARRAY['Vegan'], true, 61),
  ('meal-668', 'Satay Tofu', 'with rice and peppers', 'https://cloudfront.frive.co.uk/media/7681/opt_LP-REC-751-Satay_Tofu_Balanced.png', 541, 29.1, ARRAY['Vegan'], true, 62),
  ('meal-672', 'Massaman Sweet Potato Curry', 'with rice and Thai basil carrots', 'https://cloudfront.frive.co.uk/media/6734/opt_upload.png', 545, 12.5, ARRAY['Vegan'], true, 63),
  ('meal-752', 'Red Thai Sweet Potato Curry', 'with jasmine rice and stir-fried vegetables', 'https://cloudfront.frive.co.uk/media/6865/opt_752_Sweet_Potato_Chickpea_Thai_Red_Curry_with_Steamed_Jasmine_Rice_Stir_Fry_Vegetables.jpg', 586, 14.7, ARRAY['Vegan'], true, 64),
  ('meal-887', 'Sweet Potato & Chickpea Rendang', 'with rice, roasted peppers, fresh tomatoes and sambal garnish', 'https://cloudfront.frive.co.uk/media/6750/opt_upload.png', 585, 14.2, ARRAY['Vegan'], true, 65),
  ('meal-1061', 'Chickpea & Potato Jalfrezi', 'with rice and peppers', 'https://cloudfront.frive.co.uk/media/7101/opt_upload.png', 535, 12.8, ARRAY['Vegan'], true, 66),
  ('meal-1086', 'Meatless Massaman Curry', 'with rice, carrots and peppers', 'https://cloudfront.frive.co.uk/media/6767/opt_upload.png', 552, 30.4, ARRAY['Vegan'], true, 67),
  ('meal-1107', 'Sweet Potato & Chickpea Thai Red Curry', 'with jasmine rice and crunchy stir-fried vegetables', 'https://cloudfront.frive.co.uk/media/7105/opt_upload.png', 571, 14.2, ARRAY['Vegan'], true, 68),
  ('meal-1150', 'Coconut Dhal Curry', 'with green beans and basmati rice', 'https://cloudfront.frive.co.uk/media/7109/opt_upload.png', 579, 15.6, ARRAY['Vegan'], true, 69),
  ('meal-1179', 'Citrus & Miso Tofu Poke Bowl', 'with sticky edamame rice and pickled ginger', 'https://cloudfront.frive.co.uk/media/6779/opt_upload.png', 562, 28.5, ARRAY['Vegan'], true, 70),
  ('meal-1181', 'Meatless Thai Basil Aubergine', 'with jasmine rice and green beans', 'https://cloudfront.frive.co.uk/media/6781/opt_upload.png', 561, 21.3, ARRAY['Vegan'], true, 71),
  ('meal-1187', 'Smokey Baharat Mango Tofu', 'with smashed sweet potato and roasted cherry tomatoes', 'https://cloudfront.frive.co.uk/media/6784/opt_upload.png', 519, 23.9, ARRAY['Vegan'], true, 72),
  ('meal-1198', 'Coconut & Lime Leaf Tofu', 'with rice and stir-fried vegetables', 'https://cloudfront.frive.co.uk/media/7114/opt_upload.png', 618, 26.1, ARRAY['Vegan'], true, 73),
  ('meal-1222', 'Sweet Potato, Chickpea & Spinach Korma', 'with Fragrant Pilau Rice and Broccoli', 'https://cloudfront.frive.co.uk/media/6789/opt_upload.png', 597, 15.6, ARRAY['Vegan'], true, 74),
  ('meal-1249', 'Tofu Korma', 'with rice and tandoori roasted cauliflower', 'https://cloudfront.frive.co.uk/media/6792/opt_upload.png', 610, 32.8, ARRAY['Vegan'], true, 75),
  ('meal-1280', 'Lemongrass & Coconut Tofu Curry', 'with brown rice, squash and broccoli', 'https://cloudfront.frive.co.uk/media/6925/opt_1280-Lemongrass_Coconut_Tofu_Curry,-Brown_Rice-Squash_Broccoli.jpg', 568, 28.0, ARRAY['Vegan'], true, 76),
  ('meal-1316', 'Sweet Chilli Tempeh With Jasmine Rice', 'With Jasmine Rice & Roasted Peppers', 'https://cloudfront.frive.co.uk/media/7127/opt_upload.png', 641, 33.0, ARRAY['Vegan'], true, 77),
  ('meal-1377', 'Baked Mushroom Puttanesca Rigatoni', 'with basil roasted vegetable medley', 'https://cloudfront.frive.co.uk/media/6310/opt_upload.png', 590, 12.8, ARRAY['Vegan'], true, 78),
  ('meal-1381', 'Vegan Beef Gyudon Rice Bowl', 'with Japanese vegetables and a soy, sesame sauce', 'https://cloudfront.frive.co.uk/media/6586/opt_Vegan-Gyudon-Rice-Bowl-Vegan-beef-strips,-Jasmine-Rice,-Pickled-Mooli,-&-Shredded-Chinese-Vegetables_Vegan-Balanced.jpg', 577, 28.1, ARRAY['Vegan'], true, 79),
  ('meal-1424', 'Bulgogi Vegan Beef Bowl', 'with korean red pepper sauce and pickled mooli', 'https://cloudfront.frive.co.uk/media/7397/opt_1425-Vegan-beef-strip-Bulgogi-lowcarb.png', 580, 30.2, ARRAY['Vegan'], true, 80),
  ('meal-1426', 'Chimichurri Vegan Steak Strips', 'with Peruvian Potatoes, Sweet Corn and Roasted Peppers', 'https://cloudfront.frive.co.uk/media/7400/opt_1426-Vegan-beef-strip-Chimichurri-balanced.png', 614, 32.6, ARRAY['Vegan'], true, 81)
ON CONFLICT (meal_id) 
DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url,
  calories = EXCLUDED.calories,
  protein = EXCLUDED.protein,
  tags = EXCLUDED.tags,
  is_active = EXCLUDED.is_active,
  display_order = EXCLUDED.display_order,
  updated_at = NOW();

-- Verify the update
SELECT 
  COUNT(*) as total_meals,
  COUNT(*) FILTER (WHERE 'Fish' = ANY(tags)) as fish_meals,
  COUNT(*) FILTER (WHERE 'Meat' = ANY(tags)) as meat_meals,
  COUNT(*) FILTER (WHERE 'Vegan' = ANY(tags)) as vegan_meals
FROM meals 
WHERE is_active = true;

-- Show sample of updated meals
SELECT meal_id, name, calories, protein, tags, is_active
FROM meals
WHERE is_active = true
ORDER BY display_order
LIMIT 10;
