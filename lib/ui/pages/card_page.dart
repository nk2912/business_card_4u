import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth/auth_provider.dart';
import '../../bloc/card/card_provider.dart';
import '../components/loading_view.dart';
import '../components/card_item.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {

  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CardProvider>().fetchCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CardProvider>();

    final filteredCards = provider.cards
        .where((card) =>
        card.fullName.toLowerCase().contains(_query.toLowerCase()))
        .toList();

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
        actions: [
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

          /// ================= CARD LIST =================
          Expanded(
            child: Builder(
              builder: (_) {

                if (provider.isLoading) {
                  return const Center(
                    child: LoadingView(size: 90),
                  );
                }

                if (filteredCards.isEmpty) {
                  return const Center(
                    child: Text(
                      "No cards found",
                      style: TextStyle(
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
                    itemCount: filteredCards.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: CardItem(card: filteredCards[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 6,
        onPressed: () {
          // Navigate to add card page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
