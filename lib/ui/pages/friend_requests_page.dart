import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../bloc/card/card_provider.dart';
import '../../core/network/image_url.dart';
import '../../data/models/business_card_model.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<CardProvider>().fetchFriendRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CardProvider>();
    final requests = provider.friendRequests;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text('Friend Requests'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoadingRequests
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(
                  child: Text(
                    'No pending friend requests',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<CardProvider>().fetchFriendRequests(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return _FriendRequestCard(card: requests[index]);
                    },
                  ),
                ),
    );
  }
}

class _FriendRequestCard extends StatelessWidget {
  final BusinessCardModel card;

  const _FriendRequestCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: (card.profileImage != null && card.profileImage!.isNotEmpty)
                    ? NetworkImage(ImageUrl.resolve(card.profileImage!)!)
                    : null,
                child: (card.profileImage == null || card.profileImage!.isEmpty)
                    ? Text(card.fullName.isNotEmpty ? card.fullName[0].toUpperCase() : '')
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.fullName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.position.isEmpty ? 'Requested to add you' : card.position,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final success =
                        await context.read<CardProvider>().rejectFriendRequest(card.id);
                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Friend request rejected')),
                      );
                    }
                  },
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final success =
                        await context.read<CardProvider>().acceptFriendRequest(card.id);
                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Friend request accepted')),
                      );
                    }
                  },
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
