import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/company/company_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/company_model.dart';
import '../components/app_primary_button.dart';
import '../components/app_toast.dart';
import '../components/loading_view.dart';
import '../components/theme_toggle_button.dart';

class CompanyFormPage extends StatefulWidget {
  final CompanyModel? company;
  const CompanyFormPage({super.key, this.company});

  @override
  State<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();
  final _businessTypeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    if (c != null) {
      _nameCtrl.text = c.name;
      _industryCtrl.text = c.industry ?? '';
      _businessTypeCtrl.text = c.businessType ?? '';
      _descriptionCtrl.text = c.description ?? '';
      _addressCtrl.text = c.address ?? '';
      _websiteCtrl.text = c.website ?? '';
      _phoneCtrl.text = c.phone ?? '';
      _emailCtrl.text = c.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _industryCtrl.dispose();
    _businessTypeCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _websiteCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<CompanyProvider>();
    
    // Construct payload with required fields always included
    final payload = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'industry': _industryCtrl.text.trim(),
      'business_type': _businessTypeCtrl.text.trim(),
    };

    if (_descriptionCtrl.text.trim().isNotEmpty) {
      payload['description'] = _descriptionCtrl.text.trim();
    }
    if (_addressCtrl.text.trim().isNotEmpty) {
      payload['address'] = _addressCtrl.text.trim();
    }
    if (_websiteCtrl.text.trim().isNotEmpty) {
      payload['website'] = _websiteCtrl.text.trim();
    }
    if (_phoneCtrl.text.trim().isNotEmpty) {
      payload['phone'] = _phoneCtrl.text.trim();
    }
    if (_emailCtrl.text.trim().isNotEmpty) {
      payload['email'] = _emailCtrl.text.trim();
    }

    CompanyModel? result;
    if (widget.company == null) {
      result = await provider.createCompany(payload);
    } else {
      result = await provider.updateCompany(widget.company!.id, payload);
    }

    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(result);
    } else {
      final errorMsg = provider.errorMessage ?? 'Failed to save company details';
      AppToast.show(
        context,
        errorMsg,
        type: AppToastType.error,
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 22),
      labelStyle: TextStyle(
        color: isDark ? const Color(0xFF98A7C2) : Colors.black54,
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF1F2A44) : Colors.grey.withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0D1426) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<CompanyProvider>().isSaving;
    final isEdit = widget.company != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060B16) : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF060B16) : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEdit ? 'Edit Company' : 'New Company',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ThemeToggleButton(color: isDark ? Colors.white : Colors.black87),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Company Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFEAF1FF) : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fill in the details below to create a premium business profile.",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF98A7C2) : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _inputDecoration('Company Name *', Icons.business_rounded),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _industryCtrl,
                          decoration: _inputDecoration('Industry *', Icons.category_rounded),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _businessTypeCtrl,
                          decoration: _inputDecoration('Type *', Icons.work_outline_rounded),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: _inputDecoration('Description', Icons.description_outlined),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Contact Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFEAF1FF) : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: _inputDecoration('Physical Address', Icons.location_on_outlined),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _websiteCtrl,
                    decoration: _inputDecoration('Website URL', Icons.language_rounded),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtrl,
                          decoration: _inputDecoration('Phone', Icons.phone_android_rounded),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _emailCtrl,
                          decoration: _inputDecoration('Email', Icons.email_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  AppPrimaryButton(
                    text: isEdit ? 'UPDATE COMPANY' : 'CREATE COMPANY',
                    loading: saving,
                    onPressed: saving ? null : _save,
                    height: 56,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (saving)
            Container(
              color: Colors.black.withOpacity(0.05),
              child: const Center(child: LoadingView(size: 96)),
            ),
        ],
      ),
    );
  }
}
