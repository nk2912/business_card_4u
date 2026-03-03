import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth/auth_provider.dart';
import '../../bloc/company/company_provider.dart';
import '../../data/models/company_model.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company created successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editCompany(CompanyModel company) async {
    final result = await Navigator.of(context).push<CompanyModel>(
      MaterialPageRoute(builder: (_) => CompanyFormPage(company: company)),
    );
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company updated successfully'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteCompany(CompanyModel company) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Company'),
        content: Text('Are you sure you want to delete ${company.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Company deleted successfully'),
          backgroundColor: Colors.red, // Pale red
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Show specific error message from provider
      final errorMsg = provider.errorMessage ?? "Failed to delete company";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Manage Companies',
          style:
              TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Color(0xFF2563EB), size: 28),
            onPressed: _addCompany,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: _addCompany,
        icon: const Icon(Icons.add),
        label: const Text("Add New Company"),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center_outlined,
              size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "No companies found",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add your first company to get started",
            style: TextStyle(color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(CompanyModel company) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isCreator = company.createdBy != null &&
            auth.currentUser != null &&
            company.createdBy == auth.currentUser!.id;

        // The card widget itself (without margin)
        final cardWidget = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company.industry ?? 'General Industry',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    if (isCreator)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editCompany(company);
                          } else if (value == 'delete') {
                            _deleteCompany(company);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('Delete'),
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
