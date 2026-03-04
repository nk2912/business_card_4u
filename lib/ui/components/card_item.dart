import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/image_url.dart';
import '../../bloc/card/card_provider.dart';
import '../../data/models/business_card_model.dart';
import '../pages/card_detail_page.dart';

class CardItem extends StatefulWidget {
  final BusinessCardModel card;

  const CardItem({super.key, required this.card});

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  late bool _isFriend;
  late String _friendRequestStatus;

  void _showToast(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _FriendRequestToast(
        message: message,
        isError: isError,
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isFriend = widget.card.isFriend;
    _friendRequestStatus = widget.card.friendRequestStatus ?? 'none';
  }

  @override
  void didUpdateWidget(covariant CardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id ||
        oldWidget.card.isFriend != widget.card.isFriend ||
        oldWidget.card.friendRequestStatus != widget.card.friendRequestStatus) {
      _isFriend = widget.card.isFriend;
      _friendRequestStatus = widget.card.friendRequestStatus ?? 'none';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSendRequest =
        widget.card.cardType == 'user_card' && !_isFriend && _friendRequestStatus == 'none';

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
              MaterialPageRoute(builder: (_) => CardDetailPage(card: widget.card)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'avatar_${widget.card.id}_${widget.card.fullName}',
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withOpacity(.15),
                        backgroundImage: (widget.card.profileImage != null &&
                                widget.card.profileImage!.isNotEmpty)
                            ? NetworkImage(ImageUrl.resolve(widget.card.profileImage!)!)
                            : null,
                        child: (widget.card.profileImage == null ||
                                widget.card.profileImage!.isEmpty)
                            ? Text(
                                widget.card.fullName.isNotEmpty
                                    ? widget.card.fullName[0].toUpperCase()
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
                            widget.card.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.card.position,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canSendRequest)
                      IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        tooltip: "Add Friend",
                        onPressed: () async {
                          final success =
                              await context.read<CardProvider>().addFriend(widget.card.id);
                          if (!mounted) return;
                          if (success) {
                            setState(() {
                              _friendRequestStatus = 'pending';
                            });
                            _showToast("Friend request sent");
                          }
                        },
                      )
                    else if (_friendRequestStatus == 'pending')
                      _buildStatusChip('Pending', Colors.orange)
                    else if (_isFriend)
                      _buildStatusChip('Friend', Colors.green),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.white.withOpacity(.15),
                ),
                const SizedBox(height: 14),
                if (widget.card.company != null)
                  _infoRow(
                    icon: Icons.business_rounded,
                    text: widget.card.company!.name,
                  ),
                if (widget.card.phones.isNotEmpty)
                  _contactRow(
                    icon: Icons.phone_rounded,
                    items: widget.card.phones,
                  ),
                if (widget.card.emails.isNotEmpty)
                  _contactRow(
                    icon: Icons.email_rounded,
                    items: widget.card.emails,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
    required List<String> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    final primary = items.first;

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
        ],
      ),
    );
  }
}

class _FriendRequestToast extends StatelessWidget {
  final String message;
  final bool isError;

  const _FriendRequestToast({
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    const successBg = Color(0xFFDCEBFF);
    const successText = Color(0xFF1E3A8A);
    const errorBg = Color(0xFFFEE2E2);
    const errorText = Color(0xFFB42318);

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isError ? errorBg : successBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isError ? errorText : successText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
