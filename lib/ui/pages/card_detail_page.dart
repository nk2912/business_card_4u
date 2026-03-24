import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth/auth_provider.dart';
import '../../bloc/card/card_provider.dart';
import '../../core/network/image_url.dart';
import '../../data/models/business_card_model.dart';
import '../../data/models/company_model.dart';
import '../components/app_toast.dart';
import 'add_card_page.dart';
import 'deactivate_account_page.dart';

class CardDetailPage extends StatelessWidget {
  final BusinessCardModel card;

  const CardDetailPage({super.key, required this.card});

  static const _bg = Color(0xFFF4F7FB);
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF667085);
  static const _primary = Color(0xFF1D4ED8);
  static const _deep = Color(0xFF0F1C3F);

  AlertDialog _buildActionDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    bool destructive = false,
    Widget? extraContent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF0D1426) : Colors.white,
      surfaceTintColor: isDark ? const Color(0xFF0D1426) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? const Color(0xFFEAF1FF) : _ink,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: TextStyle(
              color: isDark ? const Color(0xFF98A7C2) : _muted,
              height: 1.45,
            ),
          ),
          if (extraContent != null) ...[
            const SizedBox(height: 16),
            extraContent,
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? const Color(0xFF98A7C2) : _muted,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: TextStyle(
              color: destructive ? Colors.redAccent : _primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  void _showToast(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isDestructiveSoft = false,
  }) {
    AppToast.show(
      context,
      message,
      type: isError
          ? AppToastType.error
          : isDestructiveSoft
              ? AppToastType.destructiveSoft
              : AppToastType.success,
    );
  }

  Future<void> _showDeactivateAccountFlow(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DeactivateAccountPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = context.read<AuthProvider>().currentUser;
    final isMyCard = currentUser != null && card.user?.id == currentUser.id;
    final isSavedCard = card.cardType == 'saved_card';
    final isUserCard = card.cardType == 'user_card';
    final isMyProfileCard = isMyCard && isUserCard;

    final avatarUrl =
        (card.profileImage != null && card.profileImage!.isNotEmpty)
            ? ImageUrl.resolve(card.profileImage!)
            : null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060B16) : _bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _GlassActionButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          if (isUserCard && !isMyCard)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Consumer<CardProvider>(
                builder: (_, __, ___) {
                  final isFriend = card.isFriend;

                  return _HeroPillButton(
                    label: isFriend ? 'Unfriend' : 'Connect',
                    icon: isFriend
                        ? Icons.person_remove_alt_1
                        : Icons.person_add_alt_1,
                    onPressed: () async {
                      if (isFriend) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => _buildActionDialog(
                            ctx,
                            title: 'Unfriend',
                            content:
                                'Are you sure you want to remove this friend?',
                            confirmText: 'Unfriend',
                            destructive: true,
                            onConfirm: () => Navigator.pop(ctx, true),
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          final success = await context
                              .read<CardProvider>()
                              .removeFriend(card.id);

                          if (success && context.mounted) {
                            _showToast(
                              context,
                              'Friend removed successfully',
                              isDestructiveSoft: true,
                            );
                            Navigator.pop(context);
                          } else if (context.mounted) {
                            _showToast(
                              context,
                              'Failed to remove friend',
                              isError: true,
                            );
                          }
                        }
                      } else {
                        final success = await context
                            .read<CardProvider>()
                            .addFriend(card.id);
                        if (success && context.mounted) {
                          _showToast(context, 'Friend request sent');
                        } else if (context.mounted) {
                          _showToast(
                            context,
                            'Failed to send request',
                            isError: true,
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          if (isSavedCard || isMyCard)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: isDark ? const Color(0xFF121A2C) : Colors.white,
                surfaceTintColor:
                    isDark ? const Color(0xFF121A2C) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddCardPage(card: card)),
                    ).then((updated) async {
                      if (!context.mounted) return;
                      if (updated == true) {
                        final provider = context.read<CardProvider>();
                        await provider.fetchCards();
                        if (!context.mounted) return;

                        final updatedIndex =
                            provider.cards.indexWhere((c) => c.id == card.id);

                        if (updatedIndex != -1) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                              pageBuilder: (_, __, ___) => CardDetailPage(
                                card: provider.cards[updatedIndex],
                              ),
                            ),
                          );
                        }
                      }
                    });
                  }

                    if (value == 'delete') {
                    if (isMyProfileCard) {
                      await _showDeactivateAccountFlow(context);
                      return;
                    }

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => _buildActionDialog(
                        ctx,
                        title: 'Delete Card',
                        content: 'Are you sure you want to delete this card?',
                        confirmText: 'Delete',
                        destructive: true,
                        onConfirm: () => Navigator.pop(ctx, true),
                      ),
                    );

                      if (confirm == true && context.mounted) {
                        final provider = context.read<CardProvider>();
                      final success = await provider.deleteCard(card.id);

                        if (!context.mounted) return;

                        if (success) {
                          _showToast(
                            context,
                            provider.deleteMessage ??
                                'Card deleted successfully',
                            isDestructiveSoft: true,
                          );
                          Navigator.pop(context);
                        } else {
                          _showToast(
                            context,
                            provider.deleteMessage ?? 'Failed to delete card',
                            isError: true,
                          );
                        }
                      }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            color: isDark
                                ? const Color(0xFFEAF1FF)
                                : Colors.black87),
                        const SizedBox(width: 12),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFEAF1FF)
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.redAccent),
                        SizedBox(width: 12),
                        Text(
                          isMyProfileCard ? 'Deactivate Account' : 'Delete',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark ? const Color(0xFF050A15) : const Color(0xFF09152E),
                    isDark ? const Color(0xFF0D1730) : const Color(0xFF173B82),
                    isDark ? const Color(0xFF060B16) : _bg,
                    isDark ? const Color(0xFF060B16) : _bg,
                  ],
                  stops: const [0, .30, .30, 1],
                ),
              ),
            ),
          ),
          const Positioned(
            top: -30,
            right: -10,
            child: _GlowOrb(size: 180, color: Color(0x33FFFFFF)),
          ),
          const Positioned(
            top: 180,
            left: -50,
            child: _GlowOrb(size: 160, color: Color(0x26C6A55C)),
          ),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                const SizedBox(height: 28),
                _PremiumHeroCard(
                  card: card,
                  avatarUrl: avatarUrl,
                  cardTypeLabel: _formatCardType(card.cardType),
                  isMyCard: isMyCard,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                if ((card.bio ?? '').trim().isNotEmpty) ...[
                  _SectionCard(
                    title: 'Biography',
                    icon: Icons.auto_stories_rounded,
                    subtitle: 'Professional summary',
                    child: Text(
                      card.bio!.trim(),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        height: 1.75,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                _SectionCard(
                  title: 'Contact Information',
                  icon: Icons.contact_page_outlined,
                  subtitle: 'Direct channels and location details',
                  child: _ContactList(card: card),
                ),
                const SizedBox(height: 14),
                if (card.company != null)
                  _SectionCard(
                    title: 'Company Information',
                    icon: Icons.apartment_rounded,
                    subtitle: 'Business identity and details',
                    child: _CompanyInfo(company: card.company!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCardType(String type) {
    if (type == 'saved_card') return 'Saved Card';
    if (type == 'user_card') return 'Profile Card';
    return type
        .split('_')
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }
}

class _PremiumHeroCard extends StatelessWidget {
  final BusinessCardModel card;
  final String? avatarUrl;
  final String cardTypeLabel;
  final bool isMyCard;
  final bool isDark;

  const _PremiumHeroCard({
    required this.card,
    required this.avatarUrl,
    required this.cardTypeLabel,
    required this.isMyCard,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = card.fullName.trim().isNotEmpty
        ? card.fullName.trim()[0].toUpperCase()
        : '?';
    final pending = (card.friendRequestStatus ?? '').toLowerCase() == 'pending';
    final contactCount =
        card.phones.length + card.emails.length + card.addresses.length;
    final companyName = card.company?.name.trim();
    final statusLabel = card.isFriend
        ? 'Friend'
        : pending
            ? 'Pending'
            : isMyCard
                ? 'Owner'
                : 'Open';
    final heroGradient = isDark
        ? const [
            Color(0xFF070D19),
            Color(0xFF0D1630),
            Color(0xFF172443),
            Color(0xFF0A1020),
          ]
        : const [
            Color(0xFF23408C),
            Color(0xFF315CC4),
            Color(0xFF4A8BFF),
            Color(0xFF1C2F68),
          ];
    final roleColor = isDark ? const Color(0xFFA9B6D1) : const Color(0xFFE6EEFF);
    final companyColor =
        isDark ? const Color(0xFFD8E4FF) : Colors.white;
    final titleColor = Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0, .3, .68, 1],
          colors: heroGradient,
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF25304B) : const Color(0x8099B8FF),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0D224A))
                .withOpacity(isDark ? .34 : .12),
            blurRadius: isDark ? 26 : 20,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -35,
            right: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(.08)
                    : Colors.white.withOpacity(.18),
              ),
            ),
          ),
          Positioned(
            bottom: -58,
            left: -26,
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x335EF3FF), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            left: 96,
            right: -30,
            child: Transform.rotate(
              angle: -.3,
              child: Container(
                height: 72,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'avatar_${card.id}_${card.fullName}',
                    child: Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(isDark ? .95 : 1),
                              (isDark
                                      ? const Color(0xFF6D7BFF)
                                      : const Color(0xFF7DD3FC))
                                  .withOpacity(.55),
                            ],
                          ),
                        ),
                      child: ClipOval(
                        child: avatarUrl == null
                            ? DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark
                                        ? const [
                                            Color(0xFF162544),
                                            Color(0xFF0D1630),
                                          ]
                                        : const [
                                            Color(0xFF58D7FF),
                                            Color(0xFF2454E8),
                                          ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    firstLetter,
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFDDE9FF)
                                          : Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28,
                                    ),
                                  ),
                                ),
                              )
                            : Image.network(
                                avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDark
                                            ? const [
                                                Color(0xFF162544),
                                                Color(0xFF0D1630),
                                              ]
                                            : const [
                                                Color(0xFF58D7FF),
                                                Color(0xFF2454E8),
                                              ],
                                      ),
                                    ),
                                  child: Center(
                                    child: Text(
                                      firstLetter,
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFFDDE9FF)
                                            : Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _HeroBadge(
                              text: isMyCard ? 'My Card' : cardTypeLabel,
                              icon: isMyCard
                                  ? Icons.verified_user_outlined
                                  : Icons.workspace_premium_outlined,
                            ),
                            if (card.isFriend)
                              const _HeroBadge(
                                text: 'Friend',
                                icon: Icons.people_alt_outlined,
                                accent: true,
                              ),
                            if (!card.isFriend && pending)
                              const _HeroBadge(
                                text: 'Pending',
                                icon: Icons.schedule_rounded,
                                accent: true,
                              ),
                            if ((card.tag ?? '').trim().isNotEmpty)
                              _HeroBadge(
                                text: card.tag!.trim(),
                                icon: Icons.sell_outlined,
                                accent: true,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          card.fullName,
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          card.position.trim().isEmpty
                              ? 'Professional profile'
                              : card.position,
                            style: TextStyle(
                              color: roleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.45,
                          ),
                        ),
                        if (companyName != null && companyName.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.business_center_outlined,
                                size: 17,
                                color: companyColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  companyName,
                                  style: TextStyle(
                                    color: companyColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10192C).withOpacity(.94)
                      : Colors.white.withOpacity(.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF27324D)
                        : Colors.white.withOpacity(.14),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _HeroMetric(
                        label: 'Contacts',
                        value: '$contactCount',
                      ),
                    ),
                    _MetricDivider(),
                    Expanded(
                      child: _HeroMetric(
                        label: 'Status',
                        value: statusLabel,
                      ),
                    ),
                    _MetricDivider(),
                    Expanded(
                      child: _HeroMetric(
                        label: 'Member',
                        value: card.createdAt?.year.toString() ?? 'N/A',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassActionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 56,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 22,
        icon: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _HeroPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _HeroPillButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(.12),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: Colors.white.withOpacity(.12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool accent;

  const _HeroBadge({
    required this.text,
    required this.icon,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accent
            ? (isDark ? const Color(0x223AA9FF) : const Color(0x22C6A55C))
            : (isDark
                ? const Color(0xFF11192C).withOpacity(.92)
                : Colors.white.withOpacity(.10)),
        gradient: accent
            ? null
            : LinearGradient(
                colors: [
                  isDark
                      ? const Color(0xFF202B45).withOpacity(.95)
                      : Colors.white.withOpacity(.16),
                  isDark
                      ? const Color(0xFF121A2F).withOpacity(.95)
                      : Colors.white.withOpacity(.08),
                ],
              ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent
              ? (isDark ? const Color(0x665ED7FF) : const Color(0x44E4C486))
              : (isDark
                  ? const Color(0xFF2B3754)
                  : Colors.white.withOpacity(.12)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: accent
                ? (isDark ? const Color(0xFFB8EEFF) : const Color(0xFFFFE2A8))
                : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: accent
                  ? (isDark ? const Color(0xFFE2F8FF) : const Color(0xFFFFF4DB))
                  : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(.70),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withOpacity(.12),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1426) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2A44) : const Color(0xFFE7ECF5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [Color(0xFF18243E), Color(0xFF213056)]
                        : const [Color(0xFFEEF4FF), Color(0xFFDCE8FF)],
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      isDark ? const Color(0xFF8FB6FF) : CardDetailPage._primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFEAF1FF)
                            : CardDetailPage._ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF98A7C2)
                              : CardDetailPage._muted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ContactList extends StatelessWidget {
  final BusinessCardModel card;
  const _ContactList({required this.card});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (final p in card.phones)
        _ContactTile(icon: Icons.phone_rounded, label: 'Phone', value: p),
      for (final e in card.emails)
        _ContactTile(icon: Icons.email_rounded, label: 'Email', value: e),
      for (final a in card.addresses)
        _ContactTile(
            icon: Icons.location_on_rounded, label: 'Address', value: a),
    ];

    if (items.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF10182B) : const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF1E2943) : const Color(0xFFE6EBF3),
          ),
        ),
        child: Text(
          'No contact details available.',
          style: TextStyle(
            color: isDark ? const Color(0xFF98A7C2) : CardDetailPage._muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(children: items);
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10182B) : const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2943) : const Color(0xFFE7ECF5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [Color(0xFF1B2A50), Color(0xFF355CBE)]
                      : const [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                ),
              ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF98A7C2)
                        : CardDetailPage._muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: .9,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFEAF1FF)
                        : CardDetailPage._ink,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyInfo extends StatelessWidget {
  final CompanyModel company;
  const _CompanyInfo({required this.company});

  bool _has(String? v) => v != null && v.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF10192C), Color(0xFF0D1426)]
              : const [Color(0xFFF9FBFF), Color(0xFFF2F6FE)],
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2A44) : const Color(0xFFDDE6F4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF102247), Color(0xFF2453B7)],
                  ),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFEAF1FF)
                            : CardDetailPage._ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_has(company.industry))
                          _InfoChip(text: company.industry!),
                        if (_has(company.businessType))
                          _InfoChip(text: company.businessType!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_has(company.website))
            _CompanyRow(
              icon: Icons.public_rounded,
              label: 'Website',
              value: company.website!.trim(),
            ),
          if (_has(company.phone))
            _CompanyRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: company.phone!.trim(),
            ),
          if (_has(company.email))
            _CompanyRow(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: company.email!.trim(),
            ),
          if (_has(company.address))
            _CompanyRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: company.address!.trim(),
            ),
          if (_has(company.description))
            _CompanyRow(
              icon: Icons.description_outlined,
              label: 'About',
              value: company.description!.trim(),
            ),
        ],
      ),
    );
  }
}

class _CompanyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CompanyRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon,
              size: 18,
              color: isDark
                  ? const Color(0xFF8FB6FF)
                  : CardDetailPage._primary,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF98A7C2)
                    : CardDetailPage._muted,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFEAF1FF)
                    : CardDetailPage._ink,
                fontWeight: FontWeight.w700,
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF24304B) : const Color(0xFFD8E2F2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? const Color(0xFFD8E4FF) : CardDetailPage._deep,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
