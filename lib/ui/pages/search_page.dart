import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/card/card_provider.dart';
import '../../bloc/company/company_provider.dart';
import '../../data/models/business_card_model.dart';
import '../components/card_item.dart';
import '../components/loading_view.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text('Search Users'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by name or position...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 12),
                
                // Company Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.business, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            isExpanded: true,
                            value: _selectedCompany?.id,
                            hint: const Text('Filter by Company'),
                            items: companyProvider.companies.map(
                              (company) => DropdownMenuItem<int?>(
                                value: company.id,
                                child: Text(company.name),
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
                          icon: const Icon(Icons.close, size: 20),
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
                      backgroundColor: const Color(0xFF2563EB),
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
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
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
