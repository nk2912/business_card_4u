import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/card/card_provider.dart';
import '../../bloc/company/company_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/business_card_model.dart';
import '../components/card_item.dart';
import '../components/loading_view.dart';
import '../components/theme_toggle_button.dart';
import '../../data/models/company_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<BusinessCardModel> _results = [];
  bool _isLoading = false;
  CompanyModel? _selectedCompany;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final companyProvider = context.read<CompanyProvider>();
      if (companyProvider.companies.isEmpty && !companyProvider.isLoading) {
        companyProvider.fetchCompanies();
      }
    });
  }

  Future<void> _performSearch() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty && _selectedCompany == null) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    
    // Call API
    final results = await context.read<CardProvider>().searchCards(
      query,
      companyId: _selectedCompany?.id,
      cardType: 'user_card',
    );

    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060B16) : const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          'Search Users',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0B1220),
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF060B16) : Colors.white,
        elevation: 0,
        surfaceTintColor: isDark ? const Color(0xFF060B16) : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          ThemeToggleButton(color: isDark ? Colors.white : Colors.black87),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0B1220) : Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by name or position...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? const Color(0xFF98A7C2)
                          : Colors.black45,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark
                          ? const Color(0xFF98A7C2)
                          : Colors.grey,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF10182B) : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: TextStyle(
                    color: isDark ? const Color(0xFFEAF1FF) : Colors.black87,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 12),
                
                // Company Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF10182B) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business, color: isDark ? const Color(0xFF98A7C2) : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            isExpanded: true,
                            value: _selectedCompany?.id,
                            dropdownColor:
                                isDark ? const Color(0xFF10182B) : Colors.white,
                            iconEnabledColor: isDark
                                ? const Color(0xFF98A7C2)
                                : Colors.grey,
                            hint: Text(
                              'Filter by Company',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF98A7C2) : Colors.black54,
                              ),
                            ),
                            items: companyProvider.companies.map(
                              (company) => DropdownMenuItem<int?>(
                                value: company.id,
                                child: Text(
                                  company.name,
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFEAF1FF)
                                        : const Color(0xFF0B1220),
                                  ),
                                ),
                              ),
                            ).toList(),
                            onChanged: companyProvider.isLoading
                                ? null
                                : (companyId) {
                                    setState(() {
                                      _selectedCompany = companyProvider.companies
                                          .cast<CompanyModel?>()
                                          .firstWhere(
                                            (company) => company?.id == companyId,
                                            orElse: () => null,
                                          );
                                    });
                                    _performSearch();
                                  },
                          ),
                        ),
                      ),
                      if (companyProvider.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: LoadingView(size: 20),
                        )
                      else if (_selectedCompany != null)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: isDark
                                ? const Color(0xFF98A7C2)
                                : Colors.black54,
                          ),
                          onPressed: () {
                            setState(() => _selectedCompany = null);
                            _performSearch();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Search', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingView(size: 90))
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _searchCtrl.text.isEmpty && _selectedCompany == null
                                  ? 'Start searching to find users'
                                  : 'No users found',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF98A7C2) : Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          return CardItem(card: _results[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
