import 'package:flutter/material.dart';

import '../config/theme.dart';

class LeaderboardUser {
  final String name;
  final String subtitle;
  final int points;
  final String? avatarUrl;
  final IconData avatarFallbackIcon;

  const LeaderboardUser({
    required this.name,
    required this.subtitle,
    required this.points,
    this.avatarUrl,
    this.avatarFallbackIcon = Icons.person,
  });
}

enum LeaderboardPeriod { thisMonth, lifetime }

extension LeaderboardPeriodLabel on LeaderboardPeriod {
  String get label {
    switch (this) {
      case LeaderboardPeriod.thisMonth:
        return 'This Month';
      case LeaderboardPeriod.lifetime:
        return 'Lifetime';
    }
  }
}

class LeaderboardScreen extends StatefulWidget {
  final bool isDark;
  final List<LeaderboardUser> campusUsers;
  final List<LeaderboardUser> worldUsers;

  const LeaderboardScreen({
    super.key,
    required this.isDark,
    this.campusUsers = const [],
    this.worldUsers = const [],
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.thisMonth;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<LeaderboardUser> get _activeList =>
      _tabController.index == 0 ? widget.campusUsers : widget.worldUsers;

  List<LeaderboardUser> get _filteredList {
    if (_query.isEmpty) return _activeList;
    return _activeList
        .where((user) => user.name.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final mutedColor = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final surfaceColor = isDark ? BlinkColors.surfaceDark : Colors.white;
    final borderColor = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;
    final searchFill = isDark ? const Color(0x1FFFFFFF) : const Color(0xFFF5F4FA);

    final topThree = _activeList.take(3).toList();
    final rest = _filteredList.length > 3 ? _filteredList.sublist(3) : <LeaderboardUser>[];
    final listToShow = _query.isEmpty ? rest : _filteredList;

    return Scaffold(
      backgroundColor: isDark ? BlinkColors.bgDark : BlinkColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark ? BlinkColors.primaryDeep : BlinkColors.primary,
                    isDark ? BlinkColors.primary : BlinkColors.purple,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Leaderboard',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (topThree.length >= 3)
                    _Podium(
                      first: topThree[0],
                      second: topThree[1],
                      third: topThree[2],
                      podiumLight: BlinkColors.accentSoft,
                      podiumMid: BlinkColors.purple,
                      goldColor: BlinkColors.gold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      controller: _tabController,
                      onTap: (_) => setState(() {}),
                      labelColor: BlinkColors.accent,
                      unselectedLabelColor: mutedColor,
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      indicatorColor: BlinkColors.accent,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: 'Campus Rank'),
                        Tab(text: 'World Rank'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: searchFill,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, size: 20, color: mutedColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: const InputDecoration(
                                        hintText: 'Search',
                                        border: InputBorder.none,
                                        isDense: true,
                                        hintStyle: TextStyle(fontSize: 14),
                                      ),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _PeriodDropdown(
                            selected: _selectedPeriod,
                            onChanged: (value) {
                              setState(() => _selectedPeriod = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: listToShow.isEmpty
                          ? Center(
                              child: Text(
                                'No results',
                                style: TextStyle(color: mutedColor),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: listToShow.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: borderColor,
                              ),
                              itemBuilder: (context, index) {
                                final user = listToShow[index];
                                final rank = _query.isEmpty ? index + 4 : index + 1;
                                return _LeaderboardTile(
                                  rank: rank,
                                  user: user,
                                  textColor: textColor,
                                  mutedColor: mutedColor,
                                  accentColor: BlinkColors.accent,
                                );
                              },
                            ),
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
}

class _Podium extends StatelessWidget {
  final LeaderboardUser first;
  final LeaderboardUser second;
  final LeaderboardUser third;
  final Color podiumLight;
  final Color podiumMid;
  final Color goldColor;
  final Color textColor;
  final Color mutedColor;

  const _Podium({
    required this.first,
    required this.second,
    required this.third,
    required this.podiumLight,
    required this.podiumMid,
    required this.goldColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PodiumAvatar(
              user: second,
              size: 56,
              showCrown: false,
              textColor: textColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(width: 8),
            _PodiumAvatar(
              user: first,
              size: 76,
              showCrown: true,
              crownColor: goldColor,
              textColor: textColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(width: 8),
            _PodiumAvatar(
              user: third,
              size: 56,
              showCrown: false,
              textColor: textColor,
              mutedColor: mutedColor,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PodiumBlock(label: '2', height: 70, color: podiumMid, width: 90),
            _PodiumBlock(label: '1', height: 96, color: podiumLight, width: 100),
            _PodiumBlock(label: '3', height: 54, color: podiumMid, width: 90),
          ],
        ),
      ],
    );
  }
}

class _PodiumAvatar extends StatelessWidget {
  final LeaderboardUser user;
  final double size;
  final bool showCrown;
  final Color crownColor;
  final Color textColor;
  final Color mutedColor;

  const _PodiumAvatar({
    required this.user,
    required this.size,
    required this.showCrown,
    this.crownColor = Colors.amber,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: ClipOval(
                child: user.avatarUrl != null
                    ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.white,
                        child: Icon(
                          user.avatarFallbackIcon,
                          size: size * 0.55,
                          color: BlinkColors.primary,
                        ),
                      ),
              ),
            ),
            if (showCrown)
              Positioned(
                top: -18,
                child: Icon(Icons.emoji_events, color: crownColor, size: 26),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: size + 24,
          child: Text(
            user.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          user.subtitle,
          style: TextStyle(color: mutedColor, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${user.points}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PodiumBlock extends StatelessWidget {
  final String label;
  final double height;
  final double width;
  final Color color;

  const _PodiumBlock({
    required this.label,
    required this.height,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  final LeaderboardPeriod selected;
  final ValueChanged<LeaderboardPeriod> onChanged;

  const _PeriodDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: BlinkColors.surfaceLight.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LeaderboardPeriod>(
          value: selected,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: BlinkColors.mutedLight),
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: BlinkColors.textLight,
          ),
          items: LeaderboardPeriod.values
              .map(
                (period) => DropdownMenuItem(
                  value: period,
                  child: Text(period.label),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final LeaderboardUser user;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  const _LeaderboardTile({
    required this.rank,
    required this.user,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: mutedColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: BlinkColors.accentSoft.withOpacity(0.18),
            backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) ? NetworkImage(user.avatarUrl!) : null,
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? Icon(user.avatarFallbackIcon, color: accentColor, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.subtitle,
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
              ],
            ),
          ),
          Text(
            '${user.points}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

const List<LeaderboardUser> sampleCampusUsers = [
  LeaderboardUser(name: 'Muhammad Iqbal', subtitle: 'Bahagian 3', points: 1000),
  LeaderboardUser(name: 'Aisyah Putri', subtitle: 'Bahagian 1', points: 500),
  LeaderboardUser(name: 'Irfan Hakim', subtitle: 'Bahagian 5', points: 490),
  LeaderboardUser(name: 'Alqis Lutfiah', subtitle: 'Bahagian 1', points: 397),
  LeaderboardUser(name: 'Ramadhan', subtitle: 'Bahagian 2', points: 362),
  LeaderboardUser(name: 'Rizky Hidayat', subtitle: 'Bahagian 1', points: 350),
  LeaderboardUser(name: 'Siti Nabila', subtitle: 'Bahagian 4', points: 328),
  LeaderboardUser(name: 'Farid Ashraf', subtitle: 'Bahagian 2', points: 311),
  LeaderboardUser(name: 'Nur Hidayah', subtitle: 'Bahagian 3', points: 277),
  LeaderboardUser(name: 'Zulkifli Anwar', subtitle: 'Bahagian 1', points: 245),
];

const List<LeaderboardUser> sampleWorldUsers = sampleCampusUsers;