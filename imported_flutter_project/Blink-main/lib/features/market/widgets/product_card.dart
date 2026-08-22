import 'package:flutter/material.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/post_model.dart';

enum MarketLayout { grid, list }

class ProductCard extends StatelessWidget {
  final MarketItem item;
  final bool isDark;
  final MarketLayout layout;
  final VoidCallback onTap;
  final VoidCallback onMessageSeller;

  const ProductCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onMessageSeller,
    this.layout = MarketLayout.grid,
  });

  @override
  Widget build(BuildContext context) {
    return layout == MarketLayout.grid ? _buildGrid(context) : _buildList(context);
  }

  Widget _buildGrid(BuildContext context) {
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final cardBg = isDark ? BlinkColors.surfaceDark : Colors.white;
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'market_item_${item.id}',
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(unsplash(item.img), fit: BoxFit.cover),
                  ),
                ),
                if (item.isPromoted) _promotedBadge(),
                if (item.isTrending && !item.isPromoted) _trendingBadge(),
                Positioned(bottom: 8, right: 8, child: _dmButton()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tagChip(),
                  const SizedBox(height: 6),
                  Text(item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt, height: 1.3)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.priceLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: BlinkColors.accent)),
                      _sellerBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final cardBg = isDark ? BlinkColors.surfaceDark : Colors.white;
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: cardBg, border: Border.all(color: border), borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'market_item_${item.id}',
                  child: Image.network(unsplash(item.img), width: 108, height: 108, fit: BoxFit.cover),
                ),
                if (item.isPromoted) Positioned(top: 6, left: 6, child: _miniBadge('AD', BlinkColors.gold)),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tagChip(),
                    const SizedBox(height: 6),
                    Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: txt)),
                    const SizedBox(height: 4),
                    Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: muted)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.priceLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: BlinkColors.accent)),
                        Row(
                          children: [
                            _sellerBadge(),
                            const SizedBox(width: 8),
                            _dmButton(compact: true),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: BlinkColors.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(100)),
      child: Text(item.tag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: BlinkColors.accent, letterSpacing: 0.3)),
    );
  }

  Widget _sellerBadge() {
    if (item.sellerTier == SellerTier.none) return const SizedBox.shrink();
    final color = item.sellerTier == SellerTier.gold ? BlinkColors.gold : BlinkColors.accentBlue;
    return Icon(Icons.verified, size: 13, color: color);
  }

  Widget _promotedBadge() => Positioned(top: 8, left: 8, child: _miniBadge('PROMOTED', BlinkColors.gold));

  Widget _trendingBadge() => Positioned(
        top: 8,
        left: 8,
        child: _miniBadge('🔥 TRENDING', BlinkColors.accentRed),
      );

  Widget _miniBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.3)),
    );
  }

  Widget _dmButton({bool compact = false}) {
    return GestureDetector(
      onTap: onMessageSeller,
      child: Container(
        width: compact ? 28 : 32,
        height: compact ? 28 : 32,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Icon(Icons.chat_bubble_outline, size: compact ? 14 : 16, color: Colors.white),
      ),
    );
  }
}
