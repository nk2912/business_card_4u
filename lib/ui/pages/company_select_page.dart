import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth/auth_provider.dart';
import '../../bloc/company/company_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/company_model.dart';
import '../components/app_toast.dart';
import '../components/loading_view.dart';
import '../components/theme_toggle_button.dart';
import 'company_detail_page.dart'; // Uncommented
import 'company_form_page.dart';

class CompanySelectPage extends StatefulWidget {
  final bool isSelectionMode;

  const CompanySelectPage({
    super.key,
    this.isSelectionMode =
        true, // Default to true for backward compatibility with AddCardPage
  });

  @override
  State<CompanySelectPage> createState() => _CompanySelectPageState();
}

class _CompanySelectPageState extends State<CompanySelectPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<CompanyProvider>().fetchCompanies();
    });
  }

  Future<void> _addCompany() async {
    final result = await Navigator.of(context).push<CompanyModel>(
      MaterialPageRoute(builder: (_) => const CompanyFormPage()),
    );
    if (!mounted) return;
    if (result != null) {
      AppToast.show(
        context,
        'Company created successfully',
        type: AppToastType.success,
      );
    }
  }

  Future<void> _editCompany(CompanyModel company) async {
    final result = await Navigator.of(context).push<CompanyModel>(
      MaterialPageRoute(builder: (_) => CompanyFormPage(company: company)),
    );
    if (!mounted) return;
    if (result != null) {
      AppToast.show(
        context,
        'Company updated successfully',
        type: AppToastType.success,
      );
    }
  }

  Future<void> _deleteCompany(CompanyModel company) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0D1426) : Colors.white,
        surfaceTintColor: isDark ? const Color(0xFF0D1426) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Company',
          style: TextStyle(
            color: isDark ? const Color(0xFFEAF1FF) : const Color(0xFF0B1220),
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${company.name}?',
          style: TextStyle(
            color: isDark ? const Color(0xFF98A7C2) : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? const Color(0xFF98A7C2) : Colors.grey,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok != true) return;
    final provider = context.read<CompanyProvider>();
    final success = await provider.deleteCompany(company.id);

    if (!mounted) return;

    if (success) {
      AppToast.show(
        context,
        'Company deleted successfully',
        type: AppToastType.destructiveSoft,
      );
    } else {
      final errorMsg = provider.errorMessage ?? "Failed to delete company";
      AppToast.show(
        context,
        errorMsg,
        type: AppToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060B16) : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF060B16) : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Manage Companies',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ThemeToggleButton(color: isDark ? Colors.white : Colors.black87),
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primary, size: 28),
            onPressed: _addCompany,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _addCompany,
        icon: const Icon(Icons.add),
        label: const Text("Add New Company"),
      ),
      body: provider.isLoading
          ? const Center(child: LoadingView(size: 90))
          : provider.companies.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.fetchCompanies(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: provider.companies.length,
                    itemBuilder: (_, i) {
                      final c = provider.companies[i];
                      return _buildCompanyCard(c);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center_outlined,
              size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "No companies found",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFEAF1FF) : Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first company to get started",
            style: TextStyle(
              color: isDark ? const Color(0xFF98A7C2) : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(CompanyModel company) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isCreator = company.createdBy != null &&
            auth.currentUser != null &&
            company.createdBy == auth.currentUser!.id;

        // The card widget itself (without margin)
        final cardWidget = Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1426) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1F2A44)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // If selection mode, return the company
                if (widget.isSelectionMode) {
                  Navigator.of(context).pop<CompanyModel>(company);
                } else {
                  // If management mode, navigate to detail page (Read-Only)
                  // Creator can edit via the 3-dot menu
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompanyDetailPage(company: company),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF18243E)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business,
                        color: isDark
                            ? const Color(0xFF8FB6FF)
                            : AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFEAF1FF)
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company.industry ?? 'General Industry',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF98A7C2)
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCreator)
                      PopupMenuButton<String>(
                        color: isDark ? const Color(0xFF121A2C) : Colors.white,
                        surfaceTintColor:
                            isDark ? const Color(0xFF121A2C) : Colors.white,
                        icon: Icon(
                          Icons.more_vert,
                          color: isDark
                              ? const Color(0xFF98A7C2)
                              : Colors.grey,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editCompany(company);
                          } else if (value == 'delete') {
                            _deleteCompany(company);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFEAF1FF)
                                        : const Color(0xFF0B1220),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, color: Colors.redAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFEAF1FF)
                                        : const Color(0xFF0B1220),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: cardWidget,
        );
      },
    );
  }
}
