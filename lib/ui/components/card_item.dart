import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/image_url.dart';
import '../../bloc/card/card_provider.dart';
import '../../data/models/business_card_model.dart';
import '../pages/card_detail_page.dart';

class CardItem extends StatelessWidget {
  final BusinessCardModel card;

  const CardItem({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    // Check if it's a "User Card" (not my card, and not yet a friend)
    // We can infer this if cardType == 'user_card' and !isFriend
    final showAddFriend = !card.isFriend && card.cardType == 'user_card';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3C72),
            Color(0xFF2A5298),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CardDetailPage(card: card)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= HEADER =================
                Row(
                  children: [
                    Hero(
                      tag:
                          'avatar_${card.id}_${card.fullName}', // More unique tag
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withOpacity(.15),
                        backgroundImage: (card.profileImage != null &&
                                card.profileImage!.isNotEmpty)
                            ? NetworkImage(
                                ImageUrl.resolve(card.profileImage!)!)
                            : null,
                        child: (card.profileImage == null ||
                                card.profileImage!.isEmpty)
                            ? Text(
                                card.fullName.isNotEmpty
                                    ? card.fullName[0].toUpperCase()
                                    : "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            card.position,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showAddFriend)
                      IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        tooltip: "Add Friend",
                        onPressed: () async {
                          final success = await context
                              .read<CardProvider>()
                              .addFriend(card.id);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Friend added successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                /// Divider
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.white.withOpacity(.15),
                ),

                const SizedBox(height: 14),

                /// ================= COMPANY =================
                if (card.company != null)
                  _infoRow(
                    icon: Icons.business_rounded,
                    text: card.company!.name,
                  ),

                // Show raw company name if no company object but has company string?
                // (Not in current model, assuming company object handles it)

                /// ================= PHONE =================
                if (card.phones.isNotEmpty)
                  _contactRow(
                    icon: Icons.phone_rounded,
                    items: card.phones,
                  ),

                /// ================= EMAIL =================
                if (card.emails.isNotEmpty)
                  _contactRow(
                    icon: Icons.email_rounded,
                    items: card.emails,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required List<String>
        items, // Changed parameter name to items for clarity but using items internally
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    final primary = items.first;
    // final remaining = items.length - 1; // Unused for now

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              primary,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Removed the "+remaining" badge as per potential design cleanup or user preference inferred
          // if (remaining > 0) ...
        ],
      ),
    );
  }
}
