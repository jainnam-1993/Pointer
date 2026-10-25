import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/inquiries.dart';
import '../../layout/adaptive.dart';
import '../../theme/app_theme.dart';
import '../../widgets/grouped_section.dart';
import '../../widgets/pointer_scaffold.dart';

/** Every inquiry question, from Library > Guided Inquiry > See all. */
class AllInquiriesScreen extends StatelessWidget {
  const AllInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final list = CustomScrollView(
      slivers: [
        SliverAppBar(pinned: true, backgroundColor: Colors.transparent, title: const Text('All Inquiries')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
          sliver: SliverToBoxAdapter(
            child: GroupedSection(
              separatorIndent: 24,
              itemCount: inquiries.length,
              itemBuilder: (context, index) {
                final inquiry = inquiries[index];
                return GroupedRow(
                  onTap: () => context.push('/inquiry/${inquiry.id}'),
                  child: Text(inquiry.question, style: TextStyle(fontSize: 16, color: colors.textPrimary)),
                );
              },
            ),
          ),
        ),
      ],
    );
    return PointerScaffold(body: WindowLayout.of(context).sizeClass == WindowSizeClass.compact ? list : ContentWidth(child: list));
  }
}
