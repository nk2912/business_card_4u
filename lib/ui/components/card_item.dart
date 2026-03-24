import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/image_url.dart';
import '../../core/theme/app_colors.dart';
import '../../bloc/card/card_provider.dart';
import '../../data/models/business_card_model.dart';
import '../components/app_toast.dart';
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
    AppToast.show(
      context,
      message,
      type: isError ? AppToastType.error : AppToastType.success,
    );
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
    final hasProfileImage =
        widget.card.profileImage != null && widget.card.profileImage!.isNotEmpty;
    final avatarUrl =
        hasProfileImage ? ImageUrl.resolve(widget.card.profileImage!) : null;
    final firstLetter = widget.card.fullName.isNotEmpty
        ? widget.card.fullName[0].toUpperCase()
        : "";
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardGradient = isDark
        ? const [
            Color(0xFF09101D),
            Color(0xFF111B31),
            Color(0xFF1A2744),
            Color(0xFF0A101A),
          ]
        : const [
            Color(0xFF23408C),
            Color(0xFF315CC4),
            Color(0xFF4A8BFF),
            Color(0xFF1C2F68),
          ];
    final highlightColor = isDark
        ? const Color(0x448C7DFF)
        : const Color(0x3358A6FF);
    final infoPanelColor = isDark
        ? Colors.white.withOpacity(.06)
        : Colors.white.withOpacity(.16);
    final mutedText = isDark
        ? const Color(0xFF9EACC7)
        : const Color(0xFFE6EEFF);
    final accentText =
        isDark ? const Color(0xFFB6C8FF) : const Color(0xFFCFE3FF);
    final titleColor = isDark ? Colors.white : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          stops: const [0, .34, .72, 1],
          end: Alignment.bottomRight,
          colors: cardGradient,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.12)
              : const Color(0x8099B8FF),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF122B61))
                .withOpacity(isDark ? .28 : .12),
            blurRadius: isDark ? 28 : 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CardDetailPage(card: widget.card)),
            );
          },
          child: Stack(
            children: [
              Positioned(
                top: -48,
                right: -18,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(.08)
                        : Colors.white.withOpacity(.18),
                  ),
                ),
              ),
              Positioned(
                bottom: -36,
                left: -24,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: highlightColor,
                  ),
                ),
              ),
              Positioned(
                top: 18,
                left: 96,
                right: -30,
                child: Transform.rotate(
                  angle: -.28,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(isDark ? .22 : .26),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'avatar_${widget.card.id}_${widget.card.fullName}',
                          child: Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(isDark ? .85 : 1),
                                  (isDark
                                          ? AppColors.secondary
                                          : const Color(0xFF7DD3FC))
                                      .withOpacity(.55),
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: isDark
                                  ? const Color(0xFF0B1630)
                                  : Colors.white,
                              foregroundImage:
                                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
                              child: Text(
                                firstLetter,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF3156A6),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                          const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _miniChip(
                                    widget.card.cardType == 'saved_card'
                                        ? 'Saved'
                                        : 'Profile',
                                  ),
                                  if (_friendRequestStatus == 'pending')
                                    _miniChip('Pending', accent: true)
                                  else if (_isFriend)
                                    _miniChip('Friend', accent: true),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.card.fullName,
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.card.position.isEmpty
                                    ? 'Professional profile'
                                    : widget.card.position,
                                style: TextStyle(
                                  color: mutedText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canSendRequest)
                          _ActionOrb(
                            icon: Icons.person_add_alt_1,
                            onTap: () async {
                              final success = await context
                                  .read<CardProvider>()
                                  .addFriend(widget.card.id);
                              if (!mounted) return;
                              if (success) {
                                setState(() {
                                  _friendRequestStatus = 'pending';
                                });
                                _showToast("Friend request sent");
                              }
                            },
                          )
                        else ...[
                          const SizedBox(width: 10),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 18,
                            color:
                                Colors.white.withOpacity(isDark ? .52 : .74),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: infoPanelColor,
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(isDark ? .07 : .18),
                            Colors.white.withOpacity(isDark ? .03 : .10),
                          ],
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(.12)
                              : const Color(0x66D8E6FF),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (widget.card.company != null)
                            _infoRow(
                              icon: Icons.business_rounded,
                              text: widget.card.company!.name,
                              iconColor: accentText,
                              textColor: titleColor,
                            ),
                          if (widget.card.phones.isNotEmpty)
                            _contactRow(
                              icon: Icons.phone_rounded,
                              items: widget.card.phones,
                              iconColor: accentText,
                              textColor: titleColor,
                            ),
                          if (widget.card.emails.isNotEmpty)
                            _contactRow(
                              icon: Icons.email_rounded,
                              items: widget.card.emails,
                              iconColor: accentText,
                              textColor: titleColor,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniChip(String label, {bool accent = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent
            ? (isDark ? const Color(0x26C7B8FF) : const Color(0x1F4B83FF))
            : (isDark
                ? Colors.white.withOpacity(.11)
                : Colors.white.withOpacity(.12)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent
              ? (isDark ? const Color(0x5595F3FF) : const Color(0x664B83FF))
              : (isDark
                  ? Colors.white.withOpacity(.12)
                  : Colors.white.withOpacity(.16)),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent
              ? (isDark ? const Color(0xFFE7FBFF) : Colors.white)
              : Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
    required Color iconColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _infoIcon(icon: icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
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
    required Color iconColor,
    required Color textColor,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    final primary = items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          _infoIcon(icon: icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              primary,
              style: TextStyle(
                color: textColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoIcon({
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 28,
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(isDark ? .08 : .16),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? .10 : .18),
        ),
      ),
      child: Icon(icon, color: color, size: 15),
    );
  }
}

class _ActionOrb extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionOrb({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(.12)
              : Colors.white.withOpacity(.18),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(.14)
                : Colors.white.withOpacity(.18),
          ),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
