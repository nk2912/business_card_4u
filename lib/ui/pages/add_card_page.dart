import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/card/card_provider.dart';
import '../../data/models/business_card_model.dart';
import '../../data/models/company_model.dart';
import 'company_select_page.dart';

class AddCardPage extends StatefulWidget {
  final BusinessCardModel? card; // Pass card for edit mode

  const AddCardPage({super.key, this.card});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _phonesCtrl = TextEditingController();
  final _emailsCtrl = TextEditingController();
  final _addressesCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _profileImageCtrl = TextEditingController();
  int? _selectedCompanyId;
  String? _selectedCompanyName;
  File? _pickedImage; // New

  bool get isEditing => widget.card != null;

  void _showToast(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _CardStatusToast(
        message: message,
        isError: isError,
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final c = widget.card!;
      _nameCtrl.text = c.fullName;
      _positionCtrl.text = c.position;
      _phonesCtrl.text = c.phones.join(', ');
      _emailsCtrl.text = c.emails.join(', ');
      _addressesCtrl.text = c.addresses.join(', ');
      _bioCtrl.text = c.bio ?? '';
      _profileImageCtrl.text = c.profileImage ?? '';
      if (c.company != null) {
        _selectedCompanyId = c.company!.id;
        _selectedCompanyName = c.company!.name;
      }
    }
  }

  Future<void> _pickImage() async {
    debugPrint("Picking image...");
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        debugPrint("Image picked: ${pickedFile.path}");
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      } else {
        debugPrint("No image picked");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _positionCtrl.dispose();
    _phonesCtrl.dispose();
    _emailsCtrl.dispose();
    _addressesCtrl.dispose();
    _bioCtrl.dispose();
    _profileImageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCompany() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CompanySelectPage()),
    );
    if (result != null && result is CompanyModel) {
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
    final name = _nameCtrl.text.trim();
    final position = _positionCtrl.text.trim();
    final phones = _splitToList(_phonesCtrl.text);
    final emails = _splitToList(_emailsCtrl.text);
    final addresses = _splitToList(_addressesCtrl.text);
    final bio = _bioCtrl.text.trim();
    final profileImage = _profileImageCtrl.text.trim();

    bool ok;
    if (isEditing) {
      ok = await provider.updateCard(
        widget.card!.id,
        name: name.isEmpty ? null : name,
        companyId: companyId,
        position: position.isEmpty ? null : position,
        phones: phones.isEmpty ? null : phones,
        emails: emails.isEmpty ? null : emails,
        addresses: addresses.isEmpty ? null : addresses,
        bio: bio.isEmpty ? null : bio,
        profileImage: profileImage.isEmpty ? null : profileImage,
        imageFile: _pickedImage, // Pass image file
      );
    } else {
      ok = await provider.createCard(
        name: name.isEmpty ? null : name,
        companyId: companyId,
        position: position.isEmpty ? null : position,
        phones: phones.isEmpty ? null : phones,
        emails: emails.isEmpty ? null : emails,
        addresses: addresses.isEmpty ? null : addresses,
        bio: bio.isEmpty ? null : bio,
        profileImage: profileImage.isEmpty ? null : profileImage,
        imageFile: _pickedImage, // Pass image file
        cardType: 'saved_card', // Manual entries are 'saved_card'
      );
    }

    if (!mounted) return;
    if (ok) {
      _showToast(
        isEditing
            ? 'Business card updated successfully'
            : 'Business card created successfully',
      );
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      _showToast(
        isEditing ? 'Failed to update card' : 'Failed to create card',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = context.watch<CardProvider>().isCreating;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Business Card' : 'Add Business Card',
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: isEditing
            ? [
                IconButton(
                  onPressed: isCreating ? null : _submit,
                  icon: Icon(
                    Icons.save_outlined,
                    color: isCreating
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 8),
              ]
            : null,
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
                  _buildSectionTitle("Personal Info"),
                  const SizedBox(height: 16),

                  // Profile Image Picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(
                                  color: Colors.grey[300]!, width: 2),
                              image: _pickedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_pickedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (_profileImageCtrl.text.isNotEmpty &&
                                          Uri.tryParse(_profileImageCtrl.text)
                                                  ?.isAbsolute ==
                                              true
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              _profileImageCtrl.text),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                            child: (_pickedImage == null &&
                                    (_profileImageCtrl.text.isEmpty ||
                                        Uri.tryParse(_profileImageCtrl.text)
                                                ?.isAbsolute !=
                                            true))
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildPremiumTextField(
                    controller: _nameCtrl,
                    label: "Full Name",
                    hint: "e.g. John Doe",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumTextField(
                    controller: _positionCtrl,
                    label: "Position",
                    hint: "e.g. Software Engineer",
                    icon: Icons.work_outline,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Company"),
                  const SizedBox(height: 16),
                  _buildCompanySelector(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Contact Details"),
                  const SizedBox(height: 16),
                  _buildPremiumTextField(
                    controller: _phonesCtrl,
                    label: "Phones",
                    hint: "e.g. 998991112233, ...",
                    icon: Icons.phone_outlined,
                    validator: _validatePhones,
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumTextField(
                    controller: _emailsCtrl,
                    label: "Emails",
                    hint: "e.g. mail@example.com, ...",
                    icon: Icons.email_outlined,
                    validator: _validateEmails,
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumTextField(
                    controller: _addressesCtrl,
                    label: "Addresses",
                    hint: "e.g. 123 Main St, ...",
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("More"),
                  const SizedBox(height: 16),
                  _buildPremiumTextField(
                    controller: _bioCtrl,
                    label: "Bio",
                    hint: "Short description...",
                    icon: Icons.info_outline,
                    maxLines: 3,
                  ),
                  // const SizedBox(height: 16),
                  // _buildPremiumTextField(
                  //   controller: _profileImageCtrl,
                  //   label: "Profile Image URL",
                  //   hint: "https://...",
                  //   icon: Icons.image_outlined,
                  // ),
                  const SizedBox(height: 32),
                  if (!isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isCreating ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                        ),
                        child: const Text(
                          'Create Card',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (isCreating)
            Container(
              color: Colors.white.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCompanySelector() {
    return InkWell(
      onTap: _pickCompany,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.business, color: Color(0xFF2563EB)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected Company",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedCompanyName ?? "None",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedCompanyName != null
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _CardStatusToast extends StatelessWidget {
  final String message;
  final bool isError;

  const _CardStatusToast({
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    const successBg = Color(0xFFDCEBFF);
    const successText = Color(0xFF1E3A8A);
    const errorBg = Color(0xFFFEE2E2);
    const errorText = Color(0xFFB42318);

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isError ? errorBg : successBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isError ? errorText : successText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
