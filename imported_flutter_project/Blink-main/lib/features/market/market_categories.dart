import 'package:flutter/material.dart';

/// A single browsable/filterable ALUTA MARKET category.
///
/// Uses Material `Icons` rather than `phosphoricons_flutter` on purpose:
/// the rest of the app uses Phosphor icons for nav/UI chrome, but Phosphor's
/// icon-name set varies across package versions and guessing 100+ exact
/// names risks a compile error. Material's `Icons.*` set is stable across
/// Flutter versions, so this file is guaranteed to build. Swap any entry
/// below for a `PhosphorIconsRegular.xxx` if you want visual consistency —
/// just confirm the name exists in your pinned `phosphoricons_flutter`
/// version first.
class MarketCategory {
  final String name;
  final IconData icon;
  const MarketCategory(this.name, this.icon);
}

/// 100+ categories. Used by the filter sheet, the "Post an item" form,
/// and search suggestions. Keep names here in sync with any `tag` values
/// you seed into `marketItems` in `post_model.dart`.
const List<MarketCategory> kMarketCategories = [
  MarketCategory('Phones & Tablets', Icons.smartphone),
  MarketCategory('Laptops & Computers', Icons.laptop_mac),
  MarketCategory('Computer Accessories', Icons.mouse),
  MarketCategory('Electronics', Icons.devices_other),
  MarketCategory('TVs', Icons.tv),
  MarketCategory('Audio & Headphones', Icons.headphones),
  MarketCategory('Cameras & Photography', Icons.camera_alt),
  MarketCategory('Gaming Consoles', Icons.sports_esports),
  MarketCategory('Video Games', Icons.videogame_asset),
  MarketCategory('Drones', Icons.airplanemode_active),
  MarketCategory('Smart Home Devices', Icons.home_max),
  MarketCategory('Wearable Tech', Icons.watch),
  MarketCategory('Power Banks & Chargers', Icons.battery_charging_full),
  MarketCategory('Generators & Power Solutions', Icons.electrical_services),
  MarketCategory('Solar Products', Icons.solar_power),
  MarketCategory('Security & Surveillance', Icons.security),
  MarketCategory('Software & Digital Goods', Icons.apps),
  MarketCategory('E-books', Icons.menu_book),
  MarketCategory('Online Courses & Tutorials', Icons.school),
  MarketCategory('Event Tickets', Icons.confirmation_number),
  MarketCategory("Men's Fashion", Icons.man),
  MarketCategory("Women's Fashion", Icons.woman),
  MarketCategory("Kids' Clothing", Icons.child_care),
  MarketCategory("Kids' Shoes", Icons.child_friendly),
  MarketCategory('Shoes', Icons.hiking),
  MarketCategory('Bags', Icons.shopping_bag),
  MarketCategory('Jewelry', Icons.diamond),
  MarketCategory('Watches', Icons.watch_later),
  MarketCategory('Sunglasses', Icons.remove_red_eye),
  MarketCategory('Suits & Blazers', Icons.checkroom),
  MarketCategory('Native Wear', Icons.style),
  MarketCategory('Traditional Wear (Ankara/Aso-Ebi)', Icons.diversity_3),
  MarketCategory('Bridal Wear', Icons.favorite),
  MarketCategory('Wedding & Events', Icons.celebration),
  MarketCategory('Party Supplies', Icons.cake),
  MarketCategory('Underwear & Lingerie', Icons.dry_cleaning),
  MarketCategory('Sleepwear', Icons.bedtime),
  MarketCategory('Swimwear', Icons.pool),
  MarketCategory('School Bags', Icons.backpack),
  MarketCategory('Beauty & Personal Care', Icons.face_retouching_natural),
  MarketCategory('Makeup', Icons.brush),
  MarketCategory('Skincare', Icons.spa),
  MarketCategory('Hair Products', Icons.content_cut),
  MarketCategory('Wigs & Extensions', Icons.face),
  MarketCategory('Perfumes & Fragrances', Icons.local_florist),
  MarketCategory('Health & Wellness', Icons.health_and_safety),
  MarketCategory('Supplements', Icons.medication),
  MarketCategory('Medical Equipment', Icons.medical_services),
  MarketCategory('Fitness Wear', Icons.checkroom),
  MarketCategory('Fitness Equipment', Icons.fitness_center),
  MarketCategory('Sporting Goods', Icons.sports_soccer),
  MarketCategory('Outdoor & Camping', Icons.terrain),
  MarketCategory('Bicycles', Icons.pedal_bike),
  MarketCategory('Home & Furniture', Icons.chair),
  MarketCategory('Living Room Furniture', Icons.weekend),
  MarketCategory('Bedroom Furniture', Icons.bed),
  MarketCategory('Office Furniture', Icons.chair_alt),
  MarketCategory('Kitchen & Dining', Icons.kitchen),
  MarketCategory('Small Kitchen Appliances', Icons.blender),
  MarketCategory('Large Kitchen Appliances', Icons.microwave),
  MarketCategory('Home Appliances', Icons.local_laundry_service),
  MarketCategory('Cookware', Icons.soup_kitchen),
  MarketCategory('Cutlery', Icons.restaurant),
  MarketCategory('Lighting', Icons.lightbulb),
  MarketCategory('Rugs & Carpets', Icons.texture),
  MarketCategory('Curtains & Blinds', Icons.blinds),
  MarketCategory('Storage & Organization', Icons.inventory_2),
  MarketCategory('Cleaning Supplies', Icons.cleaning_services),
  MarketCategory('Laundry Equipment', Icons.local_laundry_service_outlined),
  MarketCategory('Building Materials', Icons.foundation),
  MarketCategory('Tools & Hardware', Icons.handyman),
  MarketCategory('Automobiles', Icons.directions_car),
  MarketCategory('Auto Parts', Icons.car_repair),
  MarketCategory('Motorcycles', Icons.two_wheeler),
  MarketCategory('Real Estate', Icons.villa),
  MarketCategory('Land', Icons.landscape),
  MarketCategory('Property Rental', Icons.key),
  MarketCategory('Car Rental', Icons.car_rental),
  MarketCategory('Furniture Rental', Icons.event_seat),
  MarketCategory('Books', Icons.menu_book_outlined),
  MarketCategory('Office Supplies', Icons.description),
  MarketCategory('Stationery', Icons.edit_note),
  MarketCategory('Musical Instruments', Icons.music_note),
  MarketCategory('Arts & Crafts', Icons.palette),
  MarketCategory('Art & Paintings', Icons.image),
  MarketCategory('Antiques & Collectibles', Icons.museum),
  MarketCategory('Handmade & Crafts', Icons.handshake),
  MarketCategory('Baby Products', Icons.stroller),
  MarketCategory('Toys & Games', Icons.toys),
  MarketCategory('Pet Supplies', Icons.pets),
  MarketCategory('Groceries', Icons.local_grocery_store),
  MarketCategory('Food & Beverages', Icons.restaurant_menu),
  MarketCategory('Agriculture & Farming', Icons.agriculture),
  MarketCategory('Services — Repairs', Icons.build),
  MarketCategory('Services — Cleaning', Icons.cleaning_services_outlined),
  MarketCategory('Services — Tutoring', Icons.school_outlined),
  MarketCategory('Services — Photography', Icons.photo_camera),
  MarketCategory('Freelance Services', Icons.work),
  MarketCategory('Logistics & Delivery', Icons.local_shipping),
  MarketCategory('Others/Miscellaneous', Icons.category),
];

/// Nigerian states, used for the seller onboarding "State of residence"
/// field and (optionally) as a location filter.
const List<String> kNigerianStates = [
  'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Benue',
  'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu',
  'FCT - Abuja', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina',
  'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo',
  'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara',
];
