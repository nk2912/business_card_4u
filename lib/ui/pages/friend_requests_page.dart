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
  bool _isLoading = true;
  final Set<int> _acceptedIds = <int>{};
  final Set<int> _processingIds = <int>{};
  List<BusinessCardModel> _requests = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadRequests);
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    await context.read<CardProvider>().fetchFriendRequests();

    if (!mounted) return;

    final requests = context.read<CardProvider>().friendRequests;
    setState(() {
      _requests = List<BusinessCardModel>.from(requests);
      _acceptedIds.removeWhere((id) => !_requests.any((card) => card.id == id));
      _isLoading = false;
    });
  }

  Future<void> _acceptRequest(int cardId) async {
    setState(() => _processingIds.add(cardId));

    final ok = await context.read<CardProvider>().acceptFriendRequest(cardId);

    if (!mounted) return;

    setState(() {
      _processingIds.remove(cardId);
      if (ok) {
        _acceptedIds.add(cardId);
      }
    });
  }

  Future<void> _rejectRequest(int cardId) async {
    setState(() => _processingIds.add(cardId));

    final ok = await context.read<CardProvider>().rejectFriendRequest(cardId);

    if (!mounted) return;

    setState(() {
      _processingIds.remove(cardId);
      if (ok) {
        _acceptedIds.remove(cardId);
        _requests.removeWhere((card) => card.id == cardId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text(
          'Friend Requests',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Text(
                    'No pending friend requests',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black.withOpacity(.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final card = _requests[index];
                      return _FriendRequestCard(
                        card: card,
                        isAccepted: _acceptedIds.contains(card.id),
                        isBusy: _processingIds.contains(card.id),
                        onAccept: () => _acceptRequest(card.id),
                        onReject: () => _rejectRequest(card.id),
                      );
                    },
                  ),
                ),
    );
  }
}

class _FriendRequestCard extends StatelessWidget {
  final BusinessCardModel card;
  final bool isAccepted;
  final bool isBusy;
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;

  const _FriendRequestCard({
    required this.card,
    required this.isAccepted,
    required this.isBusy,
    required this.onAccept,
    required this.onReject,
  });

  String _relativeTime(DateTime? createdAt) {
    if (createdAt == null) return '';

    const myanmarOffset = Duration(hours: 6, minutes: 30);
    final now = DateTime.now().toUtc().add(myanmarOffset);
    final requestTime = createdAt.isUtc
        ? createdAt.add(myanmarOffset)
        : createdAt;
    final difference = now.difference(requestTime);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    }
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    final days = difference.inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = card.profileImage != null && card.profileImage!.isNotEmpty;
    final avatarUrl = hasImage ? ImageUrl.resolve(card.profileImage!) : null;
    final requestedAt = _relativeTime(card.createdAt);

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
        border: Border.all(color: Colors.black.withOpacity(.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE9EDF4),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                        card.fullName.isNotEmpty ? card.fullName[0].toUpperCase() : '',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B1220),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.position.isEmpty ? 'Requested to add you' : card.position,
                      style: TextStyle(
                        color: Colors.black.withOpacity(.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (requestedAt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        requestedAt,
                        style: TextStyle(
                          color: Colors.black.withOpacity(.42),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isAccepted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEBFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Text(
                'You are now friends',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0B1220),
                      side: BorderSide(color: Colors.black.withOpacity(.15)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isBusy ? null : onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Accept',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
