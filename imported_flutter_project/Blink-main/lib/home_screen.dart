import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

// Absolute package imports prevent "cannot find path" errors
import 'package:blink/config/theme.dart';
import 'package:blink/features/feed_screen.dart';
import 'package:blink/features/search_screen.dart';
import 'package:blink/features/leaderboard_screen.dart';
import 'package:blink/features/market/market_screen.dart';
import 'package:blink/features/messages_screen.dart';
import 'package:blink/features/profile/guest_profile_screen.dart';
import 'package:blink/features/profile/my_profile_screen.dart';
import 'package:blink/features/profile/user_profile_model.dart';
import 'package:blink/services/auth_service.dart';
import 'package:blink/services/profile_service.dart';
import 'package:blink/widgets/blink_snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  // Figma defaulted to dark mode. Flip this (or wire it to a settings
  // screen / DarkModeToggle widget) if you want light mode by default.
  bool _isDark = true;

  final _snack = BlinkSnackController();

  static const _items = <_NavItem>[
    _NavItem(icon: PhosphorIconsRegular.house, filledIcon: PhosphorIconsFill.house, label: 'Home'),
    _NavItem(icon: PhosphorIconsRegular.magnifyingGlass, filledIcon: PhosphorIconsFill.magnifyingGlass, label: 'Search'),
    _NavItem(icon: PhosphorIconsRegular.trophy, filledIcon: PhosphorIconsFill.trophy, label: 'Leaderboard'),
    _NavItem(icon: PhosphorIconsRegular.storefront, filledIcon: PhosphorIconsFill.storefront, label: 'Market'),
    _NavItem(icon: PhosphorIconsRegular.chatCircle, filledIcon: PhosphorIconsFill.chatCircle, label: 'Message'),
  ];

  void _showSnack(String msg) => _snack.show(msg);
  UserProfile? _currentProfile;

  // Set by the Market tab's DM icon (via [_openChatWithSeller]) so the
  // Messages tab opens directly into that seller's conversation instead of
  // the chat list. Cleared whenever the user switches tabs manually so a
  // stale seller doesn't keep popping open.
  String? _pendingChatUsername;

  // Tracks whether the Messages tab currently has an open conversation.
  // When true, the bottom navigation bar is hidden so the chat UI can use
  // the full screen.
  bool _isConversationOpen = false;

  void _openChatWithSeller(String username) {
    setState(() {
      _pendingChatUsername = username;
      _index = 4; // Messages tab
    });
  }

  UserProfile get _signedInUserProfile => _currentProfile ?? kDemoMyProfile.clone();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await ProfileService.fetchCurrent();
    if (!mounted) return;
    setState(() => _currentProfile = p);
  }

  void _openProfile(String username) {
    final current = _signedInUserProfile;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          if (username == 'you' || username == current.username) {
            return MyProfileScreen(profile: current, isDark: _isDark, onSnack: _showSnack);
          }

          final guestProfile = kDemoMyProfile.clone()
            ..fullName = username[0].toUpperCase() + username.substring(1)
            ..username = username
            ..avatar = 'photo-1509631179647-0177331693ae?w=176&h=176&fit=crop'
            ..coverPhoto = 'photo-1519389950473-47ba0277781c?w=800&h=300&fit=crop'
            ..professionalHeadline = 'Creative storyteller • Student leader'
            ..currentJobTitle = 'Community builder'
            ..university = 'University of Lagos'
            ..faculty = 'Arts'
            ..countryOfOrigin = '🇳🇬 Nigeria'
            ..currentCityState = 'Lagos, Nigeria'
            ..bio = 'Sharing a campus perspective with the world.'
            ..followerCount = 1820
            ..followingCount = 220
            ..profileViewsThisWeek = 54
            ..onlineNow = false;

          return GuestProfileScreen(profile: guestProfile, isDark: _isDark, onSnack: _showSnack);
        },
      ),
    );
  }

  @override
  void dispose() {
    _snack.dispose();
    super.dispose();
  }

  List<Widget> get _screens {
    final current = _signedInUserProfile;
    return [
      FeedScreen(
        isDark: _isDark,
        onSnack: _showSnack,
        onProfile: _openProfile,
        profileAvatarUrl: current.avatarUrl,
        profileUsername: current.username,
      ),
      SearchScreen(isDark: _isDark),
      LeaderboardScreen(isDark: _isDark),
      MarketScreen(isDark: _isDark, onSnack: _showSnack, onMessageSeller: _openChatWithSeller),
      MessagesScreen(
        isDark: _isDark,
        onSnack: _showSnack,
        openWithUsername: _pendingChatUsername,
        onConversationChanged: (isOpen) {
          if (mounted) {
            setState(() => _isConversationOpen = isOpen);
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _screens;
    return Scaffold(
      body: Container(
        decoration: blinkBackgroundDecoration(_isDark),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: 300.ms,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_index),
                  child: screens[_index],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 110,
              child: BlinkSnackbar(controller: _snack),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: _isConversationOpen && _index == 4
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: _isDark ? const Color(0xE6141018) : Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: _isDark ? const Color(0x33FFFFFF) : BlinkColors.lightBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_items.length, (i) {
                      final item = _items[i];
                      final selected = i == _index;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() {
                          _index = i;
                          _pendingChatUsername = null;
                        }),
                        child: AnimatedContainer(
                          duration: 220.ms,
                          curve: Curves.easeOutCubic,
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: selected ? BlinkColors.brandPink : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: PhosphorIcon(
                              selected ? item.filledIcon : item.icon,
                              size: 22,
                              color: selected
                                  ? Colors.white
                                  : (_isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  const _NavItem({required this.icon, required this.filledIcon, required this.label});
}