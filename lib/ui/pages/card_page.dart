import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth/auth_provider.dart';
import '../../bloc/card/card_provider.dart';
import '../../data/models/business_card_model.dart';
import '../components/loading_view.dart';
import '../components/card_item.dart';
import 'add_card_page.dart';
import 'company_select_page.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";
  String? _selectedCompanyFilter; // null means "All"
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _initTabController();

    Future.microtask(() {
      context.read<CardProvider>().fetchCards();
      // Ensure user profile is loaded if not already
      final auth = context.read<AuthProvider>();
      if (auth.currentUser == null) {
        auth.checkLogin();
      }
    });
  }

  void _initTabController() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<BusinessCardModel> _filterCards(List<BusinessCardModel> cards) {
    var filtered = cards;

    // 1. Company Filter
    if (_selectedCompanyFilter != null) {
      filtered = filtered
          .where((c) => c.company?.name == _selectedCompanyFilter)
          .toList();
    }

    // 2. Search Query
    if (_query.isEmpty) return filtered;
    return filtered
        .where((card) =>
            card.fullName.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  Widget _buildCompanyFilter(List<BusinessCardModel> cards) {
    // Extract unique company names
    final companies = cards
        .where((c) => c.company != null)
        .map((c) => c.company!.name)
        .toSet()
        .toList();
    companies.sort();

    if (companies.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: companies.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" chip
            final isSelected = _selectedCompanyFilter == null;
            return ChoiceChip(
              label: const Text("All"),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedCompanyFilter = null;
                });
              },
              selectedColor: const Color(0xFF2563EB).withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!,
              ),
            );
          }

          final company = companies[index - 1];
          final isSelected = _selectedCompanyFilter == company;
          return ChoiceChip(
            label: Text(company),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedCompanyFilter = isSelected ? null : company;
              });
            },
            selectedColor: const Color(0xFF2563EB).withOpacity(0.1),
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardList(List<BusinessCardModel> cards, bool isLoading) {
    if (isLoading) {
      return const Center(
        child: LoadingView(size: 90),
      );
    }

    final filtered = _filterCards(cards);

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty ? "No cards found" : "No results for '$_query'",
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<CardProvider>().fetchCards();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: CardItem(card: filtered[index]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      _initTabController();
    }

    final provider = context.watch<CardProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser;

    // 1. My Cards: Created by me
    final myCards = provider.cards.where((c) {
      if (currentUser != null && c.user != null) {
        return c.user!.id == currentUser.id;
      }
      return c.cardType == 'my_card';
    }).toList();

    // 2. User Cards: Collected from others
    final userCards = provider.cards.where((c) {
      if (currentUser != null && c.user != null) {
        return c.user!.id != currentUser.id;
      }
      return c.cardType == 'user_card'; // fallback
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            text: "businessCard",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            children: [
              TextSpan(
                text: "4U",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(text: "My Saved Card"),
            Tab(text: "User Card"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.business_rounded, color: Color(0xFF2563EB)),
            tooltip: "Manage Companies",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompanySelectPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// ================= SEARCH =================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, size: 20),
                  hintText: "Search cards...",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// ================= COMPANY FILTER =================
          if (_tabController?.index == 0) _buildCompanyFilter(myCards),

          /// ================= TABS VIEW =================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCardList(myCards, provider.isLoading),
                _buildCardList(userCards, provider.isLoading),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'action_fab',
        backgroundColor: const Color(0xFF2563EB),
        elevation: 6,
        onPressed: () {
          if (_tabController?.index == 0) {
            // My Card Tab -> Add Card
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AddCardPage()))
                .then((created) {
              if (created == true) {
                context.read<CardProvider>().fetchCards();
              }
            });
          } else {
            // User Card Tab -> Scan QR
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("QR Scanner coming soon!")),
            );
          }
        },
        child: Icon((_tabController?.index ?? 0) == 0
            ? Icons.add
            : Icons.qr_code_scanner),
      ),
    );
  }
}
