import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth/auth_provider.dart';
import '../../bloc/card/card_provider.dart';
import '../../core/network/image_url.dart';
import '../../data/models/business_card_model.dart';
import '../components/loading_view.dart';
import '../components/card_item.dart';
import 'add_card_page.dart';
import 'company_select_page.dart';
import 'scan_page.dart';
import 'card_detail_page.dart'; // Added import

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
      if (!mounted) return;
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
    BusinessCardModel? myProfileCard;
    try {
      myProfileCard = provider.cards.firstWhere((c) {
        if (currentUser == null) return false;
        if (c.cardType != 'my_card') return false;

        // STRICT MATCH: The card's email must match the user's login email
        return c.emails.contains(currentUser.email);
      });
    } catch (e) {
      myProfileCard = null;
    }

    // 2. My Saved Cards -> 'my_card' (Manual entries)
    // EXCLUDE the profile card found above.
    final mySavedCards = provider.cards.where((c) {
      // Must be 'my_card'
      if (c.cardType != 'my_card') return false;

      // Exclude if it is the profile card (by ID)
      if (myProfileCard != null && c.id == myProfileCard.id) return false;

      // Ensure we only show cards created by the current user
      if (currentUser != null &&
          c.user != null &&
          c.user!.id != currentUser.id) {
        return false;
      }

      return true;
    }).toList();

    // 3. My Friend's Cards (Other users) -> 'user_card'
    final myFriendsCards = provider.cards.where((c) {
      return c.cardType == 'user_card';
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                currentUser?.name ?? "User",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(currentUser?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (myProfileCard?.profileImage != null &&
                        myProfileCard!.profileImage!.isNotEmpty)
                    ? NetworkImage(
                        ImageUrl.resolve(myProfileCard.profileImage!)!,
                      )
                    : null,
                child: (myProfileCard?.profileImage == null ||
                        myProfileCard!.profileImage!.isEmpty)
                    ? Text(
                        (currentUser?.name ?? "U")
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3C72)),
                      )
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF1E3C72)),
              title: const Text('My Profile Card'),
              onTap: () {
                Navigator.pop(context); // Close drawer

                if (myProfileCard != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardDetailPage(card: myProfileCard!),
                    ),
                  );
                } else {
                  // If no card, prompt to create
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCardPage()),
                  ).then((_) {
                    if (!context.mounted) return;
                    context.read<CardProvider>().fetchCards();
                  });
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.business_rounded, color: Color(0xFF1E3C72)),
              title: const Text('Manage Companies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CompanySelectPage(isSelectionMode: false),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.black87), // Hamburger color
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
            Tab(text: "My Friend's Cards"), // user_card
            Tab(text: "My Saved Cards"), // my_card
          ],
        ),
        actions: [
          // Moved actions to Drawer, keeping AppBar clean
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
          if (_tabController?.index == 0)
            _buildCompanyFilter(myFriendsCards), // Filter friends by company
          if (_tabController?.index == 1)
            _buildCompanyFilter(mySavedCards), // Filter saved cards by company

          /// ================= TABS VIEW =================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCardList(myFriendsCards,
                    provider.isLoading), // Tab 1: My Friend's Cards (user_card)
                _buildCardList(mySavedCards,
                    provider.isLoading), // Tab 2: My Saved Cards (my_card)
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
          // Both tabs allow adding something
          // Tab 1 (Friends): Scan QR to add friend
          // Tab 2 (Saved): Add manual card
          if (_tabController?.index == 0) {
            _showAddOptions(context); // Scan or Manual
          } else {
            // Directly add manual card
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AddCardPage()))
                .then((created) {
              if (created == true) {
                if (!context.mounted) return;
                context.read<CardProvider>().fetchCards();
              }
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scan QR Code'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanPage()),
              );
            },
          ),
          // For Friend's card, maybe searching by email/ID is also an option later
        ],
      ),
    );
  }
}
