import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/post_model.dart';
import 'become_seller_screen.dart';
import 'post_item_screen.dart';
import 'product_detail_screen.dart';
import 'seller_service.dart';
import 'widgets/market_filter_sheet.dart';
import 'widgets/product_card.dart';

class MarketScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<String> onSnack;

  /// Called with a seller's username when the person taps a chat/DM icon
  /// or the "Message" button on a listing. Wire this in `home_screen.dart`
  /// to switch to the Messages tab and open that specific conversation —
  /// see the integration notes for the exact one-line change needed there.
  final ValueChanged<String> onMessageSeller;

  const MarketScreen({super.key, required this.isDark, required this.onSnack, required this.onMessageSeller});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  MarketLayout _layout = MarketLayout.grid;
  MarketFilters _filters = const MarketFilters();
  String _query = '';
  final _searchController = TextEditingController();

  List<MarketItem> get _filtered {
    var items = marketItems.where((item) {
      if (_query.isNotEmpty && !item.title.toLowerCase().contains(_query.toLowerCase())) return false;
      if (_filters.category != null && item.tag != _filters.category) return false;
      if (_filters.stateFilter != null && item.location != _filters.stateFilter) return false;
      if (_filters.trendingOnly && !item.isTrending) return false;
      if (item.price < _filters.priceRange.start) return false;
      if (_filters.priceRange.end < 1000 && item.price > _filters.priceRange.end) return false;
      return true;
    }).toList();

    switch (_filters.sortOrder) {
      case MarketSortOrder.newest:
        items.sort((a, b) => b.postedAt.compareTo(a.postedAt));
        break;
      case MarketSortOrder.priceLowHigh:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case MarketSortOrder.priceHighLow:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case MarketSortOrder.mostViewed:
        items.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
    }

    // Promoted items always float to the top, regardless of sort.
    items.sort((a, b) => (b.isPromoted ? 1 : 0).compareTo(a.isPromoted ? 1 : 0));
    return items;
  }

  List<MarketItem> get _trending => marketItems.where((i) => i.isTrending).toList();

  Future<void> _openSellerFlow() async {
    final profile = await SellerService.myProfile();
    if (!mounted) return;

    final isActiveSeller = profile != null; // savePendingProfile + activateAfterPayment gate this
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => isActiveSeller
            ? PostItemScreen(isDark: widget.isDark, onSnack: widget.onSnack)
            : BecomeSellerScreen(isDark: widget.isDark, onSnack: widget.onSnack),
      ),
    );

    if (result == true) setState(() {}); // refresh feed after a successful post/registration
  }

  void _openDetail(MarketItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          item: item,
          isDark: widget.isDark,
          onSnack: widget.onSnack,
          onMessageSeller: widget.onMessageSeller,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final items = _filtered;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ALUTA MARKET', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: txt, letterSpacing: 0.2)),
                    ElevatedButton.icon(
                      onPressed: _openSellerFlow,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Sell'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlinkColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _searchRow(isDark, txt, muted),
              ],
            ),
          ),
        ),
        if (_trending.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
            sliver: SliverToBoxAdapter(child: _trendingRow(isDark, txt, muted)),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${items.length} item${items.length == 1 ? '' : 's'}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                Row(
                  children: [
                    _layoutToggleButton(Icons.grid_view_rounded, MarketLayout.grid, isDark, muted),
                    const SizedBox(width: 6),
                    _layoutToggleButton(Icons.view_agenda_outlined, MarketLayout.list, isDark, muted),
                  ],
                ),
              ],
            ),
          ),
        ),
        items.isEmpty
            ? SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                sliver: SliverToBoxAdapter(child: _emptyState(txt, muted)),
              )
            : _layout == MarketLayout.grid
                ? _gridSliver(items, isDark)
                : _listSliver(items, isDark),
      ],
    );
  }

  Widget _searchRow(bool isDark, Color txt, Color muted) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: muted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(color: txt, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search ALUTA MARKET…',
                      hintStyle: TextStyle(color: muted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            final result = await showMarketFilterSheet(context, isDark: isDark, current: _filters);
            if (result != null) setState(() => _filters = result);
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _filters.isActive ? BlinkColors.accent : (isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.tune, size: 18, color: _filters.isActive ? Colors.white : muted),
          ),
        ),
      ],
    );
  }

  Widget _layoutToggleButton(IconData icon, MarketLayout layout, bool isDark, Color muted) {
    final selected = _layout == layout;
    return GestureDetector(
      onTap: () => setState(() => _layout = layout),
      child: AnimatedContainer(
        duration: 180.ms,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? BlinkColors.accent : (isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: selected ? Colors.white : muted),
      ),
    );
  }

  Widget _trendingRow(bool isDark, Color txt, Color muted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, size: 16, color: BlinkColors.accentRed),
              const SizedBox(width: 6),
              Text('Trending Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: txt)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _trending.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = _trending[i];
              return GestureDetector(
                onTap: () => _openDetail(item),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isDark ? BlinkColors.surfaceDark : Colors.white,
                    border: Border.all(color: isDark ? BlinkColors.borderDark : BlinkColors.borderLight),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Image.network(unsplash(item.img), fit: BoxFit.cover, width: double.infinity)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Text(item.priceLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: BlinkColors.accent)),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 250.ms, delay: (i * 40).ms).slideX(begin: 0.1, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _gridSliver(List<MarketItem> items, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final item = items[i];
            return AnimationConfiguration.staggeredGrid(
              position: i,
              columnCount: 2,
              duration: 350.ms,
              child: ScaleAnimation(
                scale: 0.94,
                child: FadeInAnimation(
                  child: ProductCard(
                    item: item,
                    isDark: isDark,
                    layout: MarketLayout.grid,
                    onTap: () => _openDetail(item),
                    onMessageSeller: () => widget.onMessageSeller(item.seller),
                  ),
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _listSliver(List<MarketItem> items, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final item = items[i];
            return AnimationConfiguration.staggeredList(
              position: i,
              duration: 320.ms,
              child: SlideAnimation(
                verticalOffset: 24,
                child: FadeInAnimation(
                  child: ProductCard(
                    item: item,
                    isDark: isDark,
                    layout: MarketLayout.list,
                    onTap: () => _openDetail(item),
                    onMessageSeller: () => widget.onMessageSeller(item.seller),
                  ),
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _emptyState(Color txt, Color muted) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.search_off, size: 44, color: muted),
          const SizedBox(height: 12),
          Text('No items match your filters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
          const SizedBox(height: 4),
          Text('Try widening your search or clearing filters.', style: TextStyle(fontSize: 12, color: muted)),
        ],
      ),
    );
  }
}
