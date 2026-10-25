part of '../library_screen.dart';

/** Section header plus the five guided sessions, then "See all", leading Library. */
List<Widget> _guidedInquirySlivers(BuildContext context, PointerColors colors) {
  return [
    SliverToBoxAdapter(
      child: Padding(
        key: const ValueKey('library-guided-inquiry'),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Semantics(
          header: true,
          // Section labels are tracked caps everywhere (DESIGN_SYSTEM.md, sectionHeader).
          child: Text('GUIDED INQUIRY', style: AppTextStyles.sectionHeader(context)),
        ),
      ),
    ),
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: GroupedSection(
          separatorIndent: 24,
          itemCount: inquirySessions.length + 1,
          itemBuilder: (context, index) {
            if (index == inquirySessions.length) {
              return _GuidedRow(
                title: 'See all ${inquiries.length}',
                subtitle: 'Every inquiry question',
                trailing: null,
                onTap: () => context.push('/inquiries'),
              );
            }
            final session = inquirySessions[index];
            return _GuidedRow(
              title: session.title,
              subtitle: session.description,
              trailing: session.duration,
              onTap: () => context.push('/inquiry/${session.inquiryId}'),
            );
          },
        ),
      ),
    ),
    // Traditions and Recently Read moved here from Settings.
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      sliver: SliverToBoxAdapter(
        child: GroupedSection(
          separatorIndent: 24,
          itemCount: 2,
          itemBuilder: (context, index) => index == 0
              ? _GuidedRow(title: 'Traditions', subtitle: 'Choose which schools you see', trailing: null, onTap: () => context.push('/lineages'))
              : _GuidedRow(title: 'Recently Read', subtitle: 'Pointings you have seen', trailing: null, onTap: () => context.push('/history')),
        ),
      ),
    ),
  ];
}

class _GuidedRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _GuidedRow({required this.title, required this.subtitle, required this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: trailing == null ? '$title. $subtitle.' : '$title. $subtitle. $trailing.',
      excludeSemantics: true,
      child: GroupedRow(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null) Text(trailing!, style: TextStyle(fontSize: 13, color: colors.textMuted)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
