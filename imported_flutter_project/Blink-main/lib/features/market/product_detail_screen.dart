import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/post_model.dart';
import 'package:blink/features/profile/guest_profile_screen.dart';
import 'package:blink/features/profile/user_profile_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final MarketItem item;
  final bool isDark;
  final ValueChanged<String> onSnack;
  final ValueChanged<String> onMessageSeller; // called with the seller's username

  const ProductDetailScreen({
    super.key,
    required this.item,
    required this.isDark,
    required this.onSnack,
    required this.onMessageSeller,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _galleryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: bg,
            pinned: true,
            elevation: 0,
            iconTheme: IconThemeData(color: txt),
            expandedHeight: 340,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'market_item_${item.id}',
                    child: Image.network(unsplash(item.gallery[_galleryIndex]), fit: BoxFit.cover),
                  ),
                  if (item.gallery.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(item.gallery.length, (i) {
                          final active = i == _galleryIndex;
                          return GestureDetector(
                            onTap: () => setState(() => _galleryIndex = i),
                            child: AnimatedContainer(
                              duration: 180.ms,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: active ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: active ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  if (item.isPromoted)
                    Positioned(
                      top: 60,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: BlinkColors.gold, borderRadius: BorderRadius.circular(100)),
                        child: const Text('PROMOTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: txt, height: 1.3)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(item.priceLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: BlinkColors.accent)),
                    if (item.negotiable) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: muted.withOpacity(0.15), borderRadius: BorderRadius.circular(100)),
                        child: Text('Negotiable', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: muted)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text('${item.condition.label} · ${item.location}', style: TextStyle(fontSize: 12.5, color: muted)),
                const SizedBox(height: 16),
                if (item.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(color: BlinkColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                              child: Text('#$t', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: BlinkColors.accent)),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 20),
                Text('Description', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: txt)),
                const SizedBox(height: 8),
                Text(item.description.isEmpty ? 'No description provided.' : item.description,
                    style: TextStyle(fontSize: 13, color: muted, height: 1.6)),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    final guestProfile = UserProfile(
                      fullName: item.seller, // Will be replaced when GuestProfileScreen loads
                      username: item.seller,
                      avatar: item.sellerAvatar.isEmpty ? item.img : item.sellerAvatar,
                      coverPhoto: '',
                      verification: VerificationBadge.none,
                      professionalHeadline: '',
                      accentColorValue: BlinkColors.accent.value,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GuestProfileScreen(
                          profile: guestProfile,
                          isDark: widget.isDark,
                          onSnack: widget.onSnack,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 22, backgroundImage: NetworkImage(unsplash(item.sellerAvatar.isEmpty ? item.img : item.sellerAvatar))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: Text(item.seller, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: txt), overflow: TextOverflow.ellipsis)),
                                  if (item.sellerTier != SellerTier.none) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.verified, size: 14, color: item.sellerTier == SellerTier.gold ? BlinkColors.gold : BlinkColors.accentBlue),
                                  ],
                                ],
                              ),
                              Text(item.sellerTier.label, style: TextStyle(fontSize: 11, color: muted)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => widget.onMessageSeller(item.seller),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(color: BlinkColors.accent, borderRadius: BorderRadius.circular(100)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white),
                                SizedBox(width: 6),
                                Text('Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => widget.onMessageSeller(item.seller),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BlinkColors.accent),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Chat Seller', style: TextStyle(color: BlinkColors.accent, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => widget.onSnack('Added to cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BlinkColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
