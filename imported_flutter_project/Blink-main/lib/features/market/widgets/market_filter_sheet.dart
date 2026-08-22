import 'package:flutter/material.dart';
import 'package:blink/config/theme.dart';
import '../market_categories.dart';

class MarketFilters {
  final String? category;
  final RangeValues priceRange;
  final String? stateFilter;
  final bool trendingOnly;
  final MarketSortOrder sortOrder;

  const MarketFilters({
    this.category,
    this.priceRange = const RangeValues(0, 1000),
    this.stateFilter,
    this.trendingOnly = false,
    this.sortOrder = MarketSortOrder.newest,
  });

  MarketFilters copyWith({
    String? category,
    bool clearCategory = false,
    RangeValues? priceRange,
    String? stateFilter,
    bool clearState = false,
    bool? trendingOnly,
    MarketSortOrder? sortOrder,
  }) {
    return MarketFilters(
      category: clearCategory ? null : (category ?? this.category),
      priceRange: priceRange ?? this.priceRange,
      stateFilter: clearState ? null : (stateFilter ?? this.stateFilter),
      trendingOnly: trendingOnly ?? this.trendingOnly,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get isActive => category != null || stateFilter != null || trendingOnly || priceRange.start > 0 || priceRange.end < 1000;
}

enum MarketSortOrder { newest, priceLowHigh, priceHighLow, mostViewed }

extension MarketSortOrderX on MarketSortOrder {
  String get label => switch (this) {
        MarketSortOrder.newest => 'Newest',
        MarketSortOrder.priceLowHigh => 'Price: Low to High',
        MarketSortOrder.priceHighLow => 'Price: High to Low',
        MarketSortOrder.mostViewed => 'Most Viewed',
      };
}

/// Shows the filter sheet and returns the chosen [MarketFilters], or null
/// if the user dismissed it without applying.
Future<MarketFilters?> showMarketFilterSheet(
  BuildContext context, {
  required bool isDark,
  required MarketFilters current,
}) {
  return showModalBottomSheet<MarketFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MarketFilterSheet(isDark: isDark, initial: current),
  );
}

class _MarketFilterSheet extends StatefulWidget {
  final bool isDark;
  final MarketFilters initial;
  const _MarketFilterSheet({required this.isDark, required this.initial});

  @override
  State<_MarketFilterSheet> createState() => _MarketFilterSheetState();
}

class _MarketFilterSheetState extends State<_MarketFilterSheet> {
  late String? _category = widget.initial.category;
  late RangeValues _price = widget.initial.priceRange;
  late String? _state = widget.initial.stateFilter;
  late bool _trending = widget.initial.trendingOnly;
  late MarketSortOrder _sort = widget.initial.sortOrder;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;
    final chipBg = isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: muted.withOpacity(0.4), borderRadius: BorderRadius.circular(100))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: txt)),
                    TextButton(
                      onPressed: () => setState(() {
                        _category = null;
                        _price = const RangeValues(0, 1000);
                        _state = null;
                        _trending = false;
                        _sort = MarketSortOrder.newest;
                      }),
                      child: const Text('Reset', style: TextStyle(color: BlinkColors.accent, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    _label('Category', txt),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kMarketCategories.map((c) {
                        final selected = _category == c.name;
                        return GestureDetector(
                          onTap: () => setState(() => _category = selected ? null : c.name),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: selected ? BlinkColors.accent : chipBg, borderRadius: BorderRadius.circular(100)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(c.icon, size: 13, color: selected ? Colors.white : muted),
                                const SizedBox(width: 6),
                                Text(c.name, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : muted)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    _label('Price range (₵${_price.start.round()} – ₵${_price.end.round()}${_price.end >= 1000 ? '+' : ''})', txt),
                    RangeSlider(
                      values: _price,
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      activeColor: BlinkColors.accent,
                      inactiveColor: muted.withOpacity(0.25),
                      onChanged: (v) => setState(() => _price = v),
                    ),
                    const SizedBox(height: 12),
                    _label('Location', txt),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: kNigerianStates.take(15).map((s) {
                          final selected = _state == s;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _state = selected ? null : s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(color: selected ? BlinkColors.accent : chipBg, borderRadius: BorderRadius.circular(100)),
                                child: Text(s, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : muted)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => setState(() => _trending = !_trending),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Icon(Icons.local_fire_department, color: _trending ? BlinkColors.accentRed : muted),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Trending items only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: txt))),
                            Switch(value: _trending, onChanged: (v) => setState(() => _trending = v), activeColor: BlinkColors.accent),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _label('Sort by', txt),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MarketSortOrder.values.map((s) {
                        final selected = _sort == s;
                        return GestureDetector(
                          onTap: () => setState(() => _sort = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: selected ? BlinkColors.accent : chipBg, borderRadius: BorderRadius.circular(100)),
                            child: Text(s.label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : muted)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(MarketFilters(
                      category: _category,
                      priceRange: _price,
                      stateFilter: _state,
                      trendingOnly: _trending,
                      sortOrder: _sort,
                    )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BlinkColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      elevation: 0,
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text, Color txt) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: txt)),
      );
}