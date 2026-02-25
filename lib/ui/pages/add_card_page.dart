import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/card/card_provider.dart';
import '../../data/models/company_model.dart';
import 'company_select_page.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();

  final _positionCtrl = TextEditingController();
  final _phonesCtrl = TextEditingController();
  final _emailsCtrl = TextEditingController();
  final _addressesCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _profileImageCtrl = TextEditingController();
  int? _selectedCompanyId;
  String? _selectedCompanyName;

  @override
  void dispose() {
    _positionCtrl.dispose();
    _phonesCtrl.dispose();
    _emailsCtrl.dispose();
    _addressesCtrl.dispose();
    _bioCtrl.dispose();
    _profileImageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCompany() async {
    final result = await Navigator.of(context).push<CompanyModel>(
      MaterialPageRoute(builder: (_) => const CompanySelectPage()),
    );
    if (result != null) {
      setState(() {
        _selectedCompanyId = result.id;
        _selectedCompanyName = result.name;
      });
    }
  }

  List<String> _splitToList(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? _validateEmails(String? value) {
    final emails = _splitToList(value ?? '');
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    for (final e in emails) {
      if (!emailRegex.hasMatch(e)) {
        return 'Invalid email: $e';
      }
    }
    return null;
  }

  String? _validatePhones(String? value) {
    final phones = _splitToList(value ?? '');
    for (final p in phones) {
      if (p.length < 6) return 'Each phone must be at least 6 characters';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CardProvider>();
    final companyId = _selectedCompanyId;
    final position = _positionCtrl.text.trim();
    final phones = _splitToList(_phonesCtrl.text);
    final emails = _splitToList(_emailsCtrl.text);
    final addresses = _splitToList(_addressesCtrl.text);
    final bio = _bioCtrl.text.trim();
    final profileImage = _profileImageCtrl.text.trim();

    final ok = await provider.createCard(
      companyId: companyId,
      position: position.isEmpty ? null : position,
      phones: phones.isEmpty ? null : phones,
      emails: emails.isEmpty ? null : emails,
      addresses: addresses.isEmpty ? null : addresses,
      bio: bio.isEmpty ? null : bio,
      profileImage: profileImage.isEmpty ? null : profileImage,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business card created successfully')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create card')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = context.watch<CardProvider>().isCreating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Business Card'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Company'),
                    subtitle: Text(_selectedCompanyName ?? 'No company selected'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedCompanyId != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedCompanyId = null;
                                _selectedCompanyName = null;
                              });
                            },
                          ),
                        ElevatedButton(
                          onPressed: _pickCompany,
                          child: Text(_selectedCompanyId == null ? 'Select' : 'Change'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _positionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Position (optional)',
                      hintText: 'e.g. Software Engineer',
                    ),
                    maxLength: 255,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phonesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phones (comma-separated)',
                      hintText: 'e.g. 998991112233, 998770001122',
                    ),
                    validator: _validatePhones,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Emails (comma-separated)',
                      hintText: 'e.g. jane@company.com, doe@mail.com',
                    ),
                    validator: _validateEmails,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Addresses (comma-separated)',
                      hintText: 'e.g. 123 Main St, Downtown',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Bio (optional)',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _profileImageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Profile Image URL (optional)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isCreating ? null : _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Create Card'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCreating)
            Container(
              color: Colors.black.withOpacity(0.05),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
