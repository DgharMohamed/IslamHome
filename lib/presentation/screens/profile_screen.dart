import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:islam_home/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: authState.when(
        data: (user) => CustomScrollView(
          slivers: [
            _buildAppBar(context, l10n, user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user == null || user.isAnonymous) ...[
                      _buildUpgradeBanner(context, l10n),
                      _buildMenuItem(
                        icon: Icons.login_rounded,
                        title: l10n.login,
                        onTap: () => context.push('/login'),
                      ),
                      const SizedBox(height: 24),
                    ],

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
                      onTap: () => _showAboutDialog(context, l10n),
                    ),
                    const SizedBox(height: 24),
                    if (user != null && !user.isAnonymous) ...[
                      _buildSectionTitle(l10n.myAccount),
                      _buildMenuItem(
                        icon: Icons.edit_rounded,
                        title: l10n.editProfile,
                        onTap: () =>
                            _showEditProfileDialog(context, ref, l10n, user),
                      ),
                    ],
                    if (user != null)
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        title: l10n.logout,
                        color: Colors.redAccent,
                        onTap: () => _showLogoutDialog(context, ref, l10n),
                      ),
                    if (user != null && !user.isAnonymous)
                      _buildMenuItem(
                        icon: Icons.delete_forever_rounded,
                        title: l10n.deleteAccount,
                        color: Colors.redAccent,
                        onTap: () =>
                            _showDeleteAccountDialog(context, ref, l10n),
                      ),
                    const SizedBox(height: 48),
                    _buildVersionInfo(l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_sync_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.upgradeBannerTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.upgradeBannerSubtitle,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.push('/register?upgrade=true'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.createAccountNow,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n, User? user) {
    final isGuest = user == null || user.isAnonymous;
    final name =
        user?.displayName ?? (isGuest ? l10n.guestUser : l10n.unknownName);
    final email = user?.email ?? (isGuest ? l10n.anonymousUsage : '');

    return SliverAppBar(
      expandedHeight: 220,
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white24,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  if (user != null && !user.isAnonymous)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (email.isNotEmpty)
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0),
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
    Color? color,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[900]?.withValues(alpha: 0.5),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          leading: Icon(icon, color: color ?? AppTheme.primaryColor),
          title: Text(title, style: TextStyle(color: color)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              Navigator.pop(context);
            },
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    User user,
  ) {
    final nameController = TextEditingController(text: user.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editProfile),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.updateNameHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await ref.read(authServiceProvider).updateDisplayName(name);
                // Trigger reload to reflect new name
                await user.reload();
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.deleteAccountConfirmTitle,
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(authServiceProvider).deleteAccount();
                if (context.mounted) Navigator.pop(context);
              } on FirebaseAuthException catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  if (e.code == 'requires-recent-login') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.requiresRecentLogin)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message ?? 'Error deleting account'),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(
              l10n.deleteAccount,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAboutDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: packageInfo.version,
      applicationIcon: const Icon(Icons.mosque, color: AppTheme.primaryColor),
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
