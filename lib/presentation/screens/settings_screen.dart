import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/financial_summary_provider.dart';
import '../widgets/category_management_dialog.dart';
import '../../data/export/export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    final currentThemeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(themeNotifier.themeModeIcon),
                  title: const Text('Theme'),
                  subtitle: Text(themeNotifier.themeModeName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context, ref),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Data Management Section
          _buildSectionHeader('Data Management'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Manage Categories'),
                  subtitle: const Text('Add, edit, or delete categories'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCategoryManagement(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Refresh Data'),
                  subtitle: const Text('Reload all financial data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _refreshAllData(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Export Data'),
                  subtitle: const Text('Export your financial data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showExportDialog(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showHelpDialog(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics Section
          _buildSectionHeader('Statistics'),
          _buildStatisticsCard(ref),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            categories.when(
              data: (categoryList) {
                final incomeCategories = categoryList.where((c) => c.type == 'income').length;
                final expenseCategories = categoryList.where((c) => c.type == 'expense').length;
                
                return Column(
                  children: [
                    _buildStatRow('Total Categories', '${categoryList.length}'),
                    _buildStatRow('Income Categories', '$incomeCategories'),
                    _buildStatRow('Expense Categories', '$expenseCategories'),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Unable to load statistics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentThemeMode = ref.read(themeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setLightMode();
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setDarkMode();
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setSystemMode();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCategoryManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CategoryManagementDialog(),
    );
  }

  void _refreshAllData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refresh Data'),
        content: const Text('This will reload all financial data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // Invalidate all providers to refresh data
              ref.invalidate(categoriesProvider);
              ref.invalidate(financialSummaryNotifierProvider);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data refreshed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose a format to export your financial data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          // Export Excel
          FilledButton.icon(
            icon: const Icon(Icons.table_view),
            label: const Text('Export Excel'),
            onPressed: () async {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preparing Excel export...'),
                ),
              );

              try {
                final exporter = ExportService();
                final fileName = await exporter.exportAllAsExcel();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export ready: $fileName'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          // Export PDF
          FilledButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            onPressed: () async {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preparing PDF export...'),
                ),
              );

              try {
                final exporter = ExportService();
                final fileName = await exporter.exportAllAsPdf();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export ready: $fileName'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Export JSON'),
            onPressed: () async {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preparing export...'),
                ),
              );

              try {
                final exporter = ExportService();
                final fileName = await exporter.exportAllAsJson();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export ready: $fileName'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Bajetimor is committed to protecting your privacy. '
            'All your financial data is stored locally on your device and is never transmitted to external servers. '
            'We do not collect, store, or share any personal or financial information. '
            'Your data remains completely private and under your control.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Getting Started:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Add categories for your income and expenses'),
              Text('• Record your transactions in the Transactions tab'),
              Text('• Set up budgets to track your spending'),
              Text('• Monitor your investments in the Investments tab'),
              Text('• View your financial overview in the Dashboard'),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Offline-first: All data stored locally'),
              Text('• Dark/Light theme support'),
              Text('• Budget tracking with progress indicators'),
              Text('• Investment portfolio management'),
              Text('• Financial analytics and charts'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}