import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/widgets/faculty_badge.dart';

class MarketItem {
  final String id;
  final String title;
  final double price;
  final String image;
  final String seller;
  final String sellerAvatar;
  final String university;
  final String category;
  final String condition;
  final String description;

  MarketItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.seller,
    required this.sellerAvatar,
    required this.university,
    required this.category,
    required this.condition,
    required this.description,
  });
}

class MarketScreen extends StatefulWidget {
  final bool isDark;
  final Function(String) onSnack;
  final Function(String) onMessageSeller;

  const MarketScreen({
    super.key,
    required this.isDark,
    required this.onSnack,
    required this.onMessageSeller,
  });

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<String> _categories = ["All", "Electronics", "Fashion", "Textbooks", "Services", "Housing"];

  final List<MarketItem> _mockItems = [
    MarketItem(
      id: '1',
      title: 'iPhone 13 Pro - 128GB',
      price: 450000,
      image: 'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=500&fit=crop',
      seller: 'golowosile',
      sellerAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&fit=crop',
      university: 'UNILAG',
      category: 'Electronics',
      condition: 'Used - Like New',
      description: 'Used for only 6 months. Battery health 98%. Comes with original box.',
    ),
    MarketItem(
      id: '2',
      title: 'Vintage College Hoodie',
      price: 12000,
      image: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500&fit=crop',
      seller: 'fashion_hub',
      sellerAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&fit=crop',
      university: 'UNILAG',
      category: 'Fashion',
      condition: 'New',
      description: 'Limited edition UNILAG vintage hoodie. Oversized fit.',
    ),
    MarketItem(
      id: '3',
      title: 'Thermodynamics Textbook',
      price: 5000,
      image: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&fit=crop',
      seller: 'scholar_mike',
      sellerAvatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&fit=crop',
      university: 'UNILAG',
      category: 'Textbooks',
      condition: 'Used',
      description: 'Essential for 300 level engineering students. No torn pages.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _mockItems.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "All" || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategories(),
            Expanded(
              child: filteredItems.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return _buildMarketCard(filteredItems[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Marketplace',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => widget.onSnack('Selling coming soon!'),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BlinkColors.brandPink.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsFill.plus, color: BlinkColors.brandPink, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for gear...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass, color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final selected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? BlinkColors.brandPink : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? Colors.transparent : Colors.white12,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketCard(MarketItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                item.image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₦${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: BlinkColors.brandPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundImage: NetworkImage(item.sellerAvatar),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.seller,
                        maxLines: 1,
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                      ),
                    ),
                    Icon(PhosphorIconsRegular.mapPin, size: 10, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 2),
                    Text(
                      item.university,
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIconsRegular.storefront, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
