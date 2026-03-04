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
import 'scan_page.dart'; // Added import
import 'search_page.dart'; // Added import
import 'card_detail_page.dart'; // Added import
import 'friend_requests_page.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final String _query = "";
  String? _selectedCompanyFilter; // null means "All"
  String? _lastShownMessage;
  TabController? _tabController;
  late final AnimationController _bellController;
  late final Animation<double> _bellRotation;
  int _previousNotificationCount = 0;
  bool _hasSeenInitialNotificationCount = false;

  @override
  void initState() {
    super.initState();
    _initTabController();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bellRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -.12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -.12, end: .12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: .12, end: -.10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -.10, end: .08), weight: 2),
      TweenSequenceItem(tween: Tween(begin: .08, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _bellController, curve: Curves.easeOut),
    );

    Future.microtask(() {
      if (!mounted) return;
      context.read<CardProvider>().fetchCards();
      context.read<CardProvider>().fetchFriendRequests();
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
    _bellController.dispose();
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

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.qr_code_scanner, color: Color(0xFF2563EB)),
                title: const Text('Scan QR Code'),
                subtitle: const Text('Add friend by scanning their QR code'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.search, color: Color(0xFF2563EB)),
                title: const Text('Search Users'),
                subtitle: const Text('Find users by name or company'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFFDCEBFF),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFBFDBFE)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      _initTabController();
    }

    final provider = context.watch<CardProvider>();
    final notificationCount = provider.friendRequests.length;
    if (!_hasSeenInitialNotificationCount) {
      _previousNotificationCount = notificationCount;
      _hasSeenInitialNotificationCount = true;
    } else if (notificationCount > _previousNotificationCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _bellController.forward(from: 0);
        }
      });
      _previousNotificationCount = notificationCount;
    } else if (notificationCount != _previousNotificationCount) {
      _previousNotificationCount = notificationCount;
    }

    final auth = context.watch<AuthProvider>();
    final pendingMessage = auth.pendingMessage;
    if (pendingMessage != null && pendingMessage != _lastShownMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final message = context.read<AuthProvider>().consumePendingMessage();
        if (message == null) return;
        _lastShownMessage = message;
        _showInfoMessage(message);
      });
    } else if (pendingMessage == null) {
      _lastShownMessage = null;
    }

    final currentUser = auth.currentUser;
    BusinessCardModel? myProfileCard;
    try {
      myProfileCard = provider.cards.firstWhere((c) {
        if (currentUser == null) {
          return false;
        }
        if (c.cardType != 'user_card') {
          return false; // Profile is now 'user_card'
        }

        // STRICT MATCH: The card's email must match the user's login email
        return c.emails.contains(currentUser.email);
      });
    } catch (e) {
      myProfileCard = null;
    }

    // 2. My Saved Cards -> Manual entries created by me ('saved_card')
    final mySavedCards = provider.cards.where((c) {
      if (c.cardType != 'saved_card') {
        return false;
      }
      if (currentUser != null && c.user?.id != currentUser.id) {
        return false; // Must be mine
      }
      return true;
    }).toList();

    // 3. My Friend's Cards -> Cards from others that I have collected/friended
    // These are typically 'user_card' created by others, but linked to me
    final myFriendsCards = provider.cards.where((c) {
      if (!c.isFriend) return false;
      if (currentUser != null && c.user?.id == currentUser.id) return false;
      return true;
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
          Consumer<CardProvider>(
            builder: (context, provider, _) {
              final count = provider.friendRequests.length;
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FriendRequestsPage(),
                    ),
                  ).then((_) {
                    if (!context.mounted) return;
                    context.read<CardProvider>().fetchFriendRequests();
                    context.read<CardProvider>().fetchCards();
                  });
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedBuilder(
                      animation: _bellRotation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _bellRotation.value,
                          alignment: Alignment.topCenter,
                          child: child,
                        );
                      },
                      child: const Icon(Icons.notifications_none, color: Colors.black87),
                    ),
                    if (count > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          constraints: const BoxConstraints(minWidth: 18),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
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
                readOnly: true, // Make it read-only to act as a button
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SearchPage()));
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, size: 20),
                  hintText: "Search users...",
                  border: InputBorder.none,
                ),
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
          // Tab 1 (Friends): Scan QR or Search to add friend
          // Tab 2 (Saved): Add manual card
          if (_tabController?.index == 0) {
            _showAddOptions(context); // Scan or Search
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
}
