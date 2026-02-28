import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/card/card_provider.dart';
import '../../core/network/image_url.dart';
import '../../data/models/business_card_model.dart';
import 'add_card_page.dart';
// import 'company_detail_page.dart';

class CardDetailPage extends StatelessWidget {
  final BusinessCardModel card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    // Check if I am the owner of this card
    final isMyCard = card.cardType == 'my_card';
    final isFriend = card.isFriend;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // QR Code for My Card
          if (isMyCard)
            IconButton(
              icon: const Icon(Icons.qr_code, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "My QR Code",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        // Fallback simple display if qr_flutter not used
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: const Icon(Icons.qr_code_2,
                              size: 150, color: Colors.black),
                        ),
                        const SizedBox(height: 16),
                        Text("ID: ${card.id}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const Text("Scan to add me",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Edit/Delete Menu for My Card
          if (isMyCard) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddCardPage(card: card),
                    ),
                  ).then((updated) {
                    if (!context.mounted) return;
                    if (updated == true) {
                      context.read<CardProvider>().fetchCards();
                      Navigator.pop(context);
                    }
                  });
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Delete Card"),
                      content: const Text(
                          "Are you sure you want to delete this card?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Delete",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    final provider = context.read<CardProvider>();
                    final success = await provider.deleteCard(card.id);
                    if (!context.mounted) return;
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.deleteMessage ?? "Card deleted successfully"),
                          backgroundColor: Colors.redAccent.shade100, // Pale red
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text(provider.deleteMessage ?? "Failed to delete card"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: Colors.black87),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.redAccent),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // Not my card actions
            if (isFriend)
              IconButton(
                icon: const Icon(Icons.person_remove,
                    color: Colors.white), // Fixed color for better contrast
                tooltip: "Remove Friend",
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Remove Friend"),
                      content: const Text(
                          "Are you sure you want to remove this friend?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Remove",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    final success = await context
                        .read<CardProvider>()
                        .removeFriend(card.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Friend removed successfully"),
                            backgroundColor: Colors.orange),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.person_add, color: Colors.white),
                tooltip: "Add Friend",
                onPressed: () async {
                  final success =
                      await context.read<CardProvider>().addFriend(card.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Friend added successfully"),
                          backgroundColor: Colors.green),
                    );
                    // Optional: refresh or update state
                  }
                },
              ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (card.bio != null && card.bio!.isNotEmpty) ...[
                    _buildSectionTitle("Biography"),
                    const SizedBox(height: 12),
                    Text(
                      card.bio!,
                      style: const TextStyle(
                          fontSize: 15, height: 1.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle("Contact Information"),
                  const SizedBox(height: 12),
                  _buildContactList(),
                  const SizedBox(height: 24),
                  if (card.company != null) ...[
                    _buildSectionTitle("Company Information"),
                    const SizedBox(height: 12),
                    _buildCompanyCard(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      // decoration removed to keep transparent as appBar has the gradient background
      // or we can keep it if we want the curve effect below the appbar
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'avatar_${card.id}_${card.fullName}',
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage:
                  (card.profileImage != null && card.profileImage!.isNotEmpty)
                      ? NetworkImage(ImageUrl.resolve(card.profileImage!)!)
                      : null,
              child: (card.profileImage == null || card.profileImage!.isEmpty)
                  ? Text(
                      card.fullName.isNotEmpty
                          ? card.fullName[0].toUpperCase()
                          : "",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            card.fullName,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            card.position,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
    );
  }

  Widget _buildContactList() {
    return Column(
      children: [
        if (card.phones.isNotEmpty)
          for (var p in card.phones) _buildContactItem(Icons.phone, p),
        if (card.emails.isNotEmpty)
          for (var e in card.emails) _buildContactItem(Icons.email, e),
        if (card.addresses.isNotEmpty)
          for (var a in card.addresses) _buildContactItem(Icons.location_on, a),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2A5298), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context) {
    final company = card.company!;
    return InkWell(
      onTap: () {
        // Navigate to company detail?
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E3C72).withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3C72).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3C72).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business, color: Color(0xFF2A5298)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (company.industry != null)
                    Text(
                      company.industry!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
