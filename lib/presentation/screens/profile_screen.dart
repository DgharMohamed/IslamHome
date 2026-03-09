import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, l10n),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(l10n.favorites),
                  _buildMenuItem(
                    icon: Icons.favorite_rounded,
                    title: l10n.favorites,
                    onTap: () => context.push('/favorites'),
                  ),
                  _buildMenuItem(
                    icon: Icons.download_rounded,
                    title: l10n.downloads,
                    onTap: () => context.push('/downloads'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(l10n.settings),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    title: l10n.settings,
                    onTap: () => context.push('/settings'),
                  ),
                  _buildMenuItem(
                    icon: Icons.info_rounded,
                    title: l10n.aboutApp,
                    onTap: () async {
                      final packageInfo = await PackageInfo.fromPlatform();
                      if (!context.mounted) return;
                      showAboutDialog(
                        context: context,
                        applicationName: l10n.appTitle,
                        applicationVersion: packageInfo.version,
                        applicationIcon: const Icon(
                          Icons.mosque,
                          color: AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  _buildVersionInfo(l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.guestUser,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[900]?.withValues(alpha: 0.5),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildVersionInfo(AppLocalizations l10n) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '...';
        return Center(
          child: Text(
            l10n.appVersionLabel(version),
            style: const TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
