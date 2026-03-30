import 'package:flutter/material.dart';
import 'package:auto_skeleton/auto_skeleton.dart';

void main() {
  runApp(const AutoSkeletonExampleApp());
}

class AutoSkeletonExampleApp extends StatelessWidget {
  const AutoSkeletonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoSkeletonConfig(
      data: const AutoSkeletonConfigData(
        enableSwitchAnimation: true,
      ),
      child: MaterialApp(
        title: 'AutoSkeleton',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A73E8),
            primary: const Color(0xFF1A73E8),
            secondary: const Color(0xFF34A853),
            tertiary: const Color(0xFFFF6D00),
            surface: const Color(0xFFF8F9FA),
            surfaceContainerHighest: const Color(0xFFE8EAED),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        home: const DemoPage(),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  bool _isLoading = true;

  void _toggleLoading() {
    setState(() => _isLoading = !_isLoading);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar.large(
            title: const Text('AutoSkeleton'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.tonalIcon(
                  onPressed: _toggleLoading,
                  icon: Icon(
                    _isLoading ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    size: 18,
                  ),
                  label: Text(_isLoading ? 'Loading' : 'Loaded'),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: [
                // ── Section: User Profile Card ──
                _SectionHeader(
                  title: 'Profile Card',
                  subtitle: 'Auto-detected from widget tree',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 8),
                AutoSkeleton(
                  enabled: _isLoading,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              'VT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vaibhav Tambe',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Flutter Developer',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Section: Social Post ──
                _SectionHeader(
                  title: 'Social Post',
                  subtitle: '.withSkeleton() extension',
                  icon: Icons.article_rounded,
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: colorScheme.tertiaryContainer,
                              child: Icon(
                                Icons.flutter_dash,
                                size: 22,
                                color: colorScheme.onTertiaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Flutter Community',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '2 hours ago',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.more_horiz, color: colorScheme.onSurfaceVariant),
                          ],
                        ),
                      ),
                      // Post image
                      Container(
                        height: 180,
                        width: double.infinity,
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        child: Center(
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 48,
                            color: colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      // Post content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'auto_skeleton v0.1.0 released!',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Auto-generate skeleton loading screens from your actual widget tree. Zero config needed.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.favorite_rounded, size: 18, color: colorScheme.error),
                                const SizedBox(width: 4),
                                Text('248', style: theme.textTheme.bodySmall),
                                const SizedBox(width: 20),
                                Icon(Icons.chat_bubble_outline_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text('42', style: theme.textTheme.bodySmall),
                                const Spacer(),
                                Icon(Icons.bookmark_border_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).withSkeleton(loading: _isLoading),

                const SizedBox(height: 28),

                // ── Section: E-commerce Product ──
                _SectionHeader(
                  title: 'Product Cards',
                  subtitle: 'Pulse effect',
                  icon: Icons.shopping_bag_rounded,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 240,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: [
                      _buildProductCard(
                        context,
                        icon: Icons.headphones_rounded,
                        name: 'Sony WH-1000XM5',
                        price: '₹24,990',
                        rating: '4.8',
                        color: colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: 12),
                      _buildProductCard(
                        context,
                        icon: Icons.watch_rounded,
                        name: 'Apple Watch Ultra',
                        price: '₹89,900',
                        rating: '4.9',
                        color: colorScheme.tertiaryContainer,
                      ),
                      const SizedBox(width: 12),
                      _buildProductCard(
                        context,
                        icon: Icons.phone_iphone_rounded,
                        name: 'Pixel 9 Pro',
                        price: '₹1,09,999',
                        rating: '4.7',
                        color: colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Section: Food Delivery ──
                _SectionHeader(
                  title: 'Food Delivery',
                  subtitle: 'Restaurant cards',
                  icon: Icons.restaurant_rounded,
                ),
                const SizedBox(height: 8),
                ..._buildFoodCards(context),

                const SizedBox(height: 28),

                // ── Section: Settings / Annotations ──
                _SectionHeader(
                  title: 'Annotations',
                  subtitle: 'PlaceholderIgnore & PlaceholderLeaf',
                  icon: Icons.tune_rounded,
                ),
                const SizedBox(height: 8),
                AutoSkeleton(
                  enabled: _isLoading,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: PlaceholderLeaf(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.location_on_rounded,
                                  color: colorScheme.onPrimaryContainer),
                            ),
                          ),
                          title: const Text('Location Services'),
                          subtitle: const Text('Share your location'),
                          trailing: PlaceholderIgnore(
                            child: Switch(
                              value: true,
                              onChanged: (_) {},
                            ),
                          ),
                        ),
                        Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                        ListTile(
                          leading: PlaceholderLeaf(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.notifications_rounded,
                                  color: colorScheme.onTertiaryContainer),
                            ),
                          ),
                          title: const Text('Notifications'),
                          subtitle: const Text('Push & email alerts'),
                          trailing: PlaceholderIgnore(
                            child: Switch(
                              value: false,
                              onChanged: (_) {},
                            ),
                          ),
                        ),
                        Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                        ListTile(
                          leading: PlaceholderLeaf(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.shield_rounded,
                                  color: colorScheme.onErrorContainer),
                            ),
                          ),
                          title: const Text('Privacy'),
                          subtitle: const Text('Data & permissions'),
                          trailing: Icon(Icons.chevron_right_rounded,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String price,
    required String rating,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AutoSkeleton(
      enabled: _isLoading,
      effect: const PulseEffect(duration: Duration(milliseconds: 1200)),
      child: SizedBox(
        width: 160,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(rating, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFoodCards(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final restaurants = [
      _RestaurantData('Mumbai Masala', 'Indian', '25 min', 4.3, '₹250', Icons.lunch_dining_rounded, Colors.orange),
      _RestaurantData('Pizza Express', 'Italian', '35 min', 4.1, '₹400', Icons.local_pizza_rounded, Colors.red),
      _RestaurantData('Sushi House', 'Japanese', '40 min', 4.6, '₹600', Icons.set_meal_rounded, Colors.teal),
    ];

    return restaurants.map((r) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AutoSkeleton(
          enabled: _isLoading,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: r.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(r.icon, color: r.color, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${r.cuisine} \u2022 ${r.time}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 12, color: Colors.green),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${r.rating}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${r.price} for two',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RestaurantData {
  final String name;
  final String cuisine;
  final String time;
  final double rating;
  final String price;
  final IconData icon;
  final Color color;

  const _RestaurantData(
    this.name,
    this.cuisine,
    this.time,
    this.rating,
    this.price,
    this.icon,
    this.color,
  );
}
