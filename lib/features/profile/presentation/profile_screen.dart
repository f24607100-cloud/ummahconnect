import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../../auth/domain/models/user_model.dart';
import '../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final countryController = TextEditingController(text: user.country);
    final cityController = TextEditingController(text: user.city);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUser = user.copyWith(
                  name: nameController.text.trim(),
                  country: countryController.text.trim(),
                  city: cityController.text.trim(),
                );
                await ref.read(authNotifierProvider.notifier).updateUser(updatedUser);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Loading user profile...')),
      );
    }

    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Title
                Text(
                  'My Profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: IslamicDivider(width: 80)),
                const SizedBox(height: 24),

                // Profile Image and Name card
                GlassCard(
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold, width: 2),
                              image: user.photoUrl != null
                                  ? DecorationImage(image: NetworkImage(user.photoUrl!), fit: BoxFit.cover)
                                  : null,
                              color: isDark ? AppColors.darkSurface : Colors.white,
                            ),
                            child: user.photoUrl == null
                                ? const Icon(Icons.person, size: 54, color: AppColors.gold)
                                : null,
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 12, color: Colors.white),
                              onPressed: () {
                                // Dummy upload action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profile picture uploading simulated.')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text(
                            '${user.city}, ${user.country}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _showEditProfileDialog(context, ref, user),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings quick list
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // Dark mode toggle
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined, color: AppColors.gold),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: isDarkMode,
                          activeColor: AppColors.gold,
                          onChanged: (val) {
                            ref.read(themeModeProvider.notifier).toggleTheme(val);
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      
                      // Notification Settings shortcut
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined, color: AppColors.gold),
                        title: const Text('Notification Settings'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        onTap: () => context.push('/settings'),
                      ),
                      const Divider(height: 1, indent: 56),
                      
                      // Privacy shortcut
                      ListTile(
                        leading: const Icon(Icons.security_outlined, color: AppColors.gold),
                        title: const Text('Privacy Policy & Terms'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout button
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
