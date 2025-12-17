import 'package:flutter/material.dart';
import '../data/pointings.dart';
import '../data/teachers.dart';
import '../models/teacher.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Shows a modal bottom sheet with teacher information
void showTeacherSheet(BuildContext context, Teacher teacher) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TeacherSheet(teacher: teacher),
  );
}

/// Modal sheet showing teacher biography and other pointings
class TeacherSheet extends StatelessWidget {
  final Teacher teacher;

  const TeacherSheet({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    final otherPointings = getPointingsByTeacher(teacher.name);
    final colors = context.colors;
    final traditionInfo = traditions[teacher.tradition]!;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colors.textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Teacher name
              Text(
                teacher.name,
                style: AppTextStyles.heading(context),
                textAlign: TextAlign.center,
              ),

              // Dates
              if (teacher.dates != null) ...[
                const SizedBox(height: 8),
                Text(
                  teacher.dates!,
                  style: AppTextStyles.footerText(context),
                  textAlign: TextAlign.center,
                ),
              ],

              // Tradition badge
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${traditionInfo.icon} ${traditionInfo.name}',
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Biography
              if (teacher.bio != null) ...[
                const SizedBox(height: 24),
                Text(
                  teacher.bio!,
                  style: AppTextStyles.bodyText(context),
                  textAlign: TextAlign.center,
                ),
              ],

              // Tags
              if (teacher.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: teacher.tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.glassBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],

              // More from this teacher
              if (otherPointings.length > 1) ...[
                const SizedBox(height: 32),
                Text(
                  'More from ${teacher.name}',
                  style: AppTextStyles.sectionHeader(context),
                ),
                const SizedBox(height: 12),
                ...otherPointings
                    .take(5)
                    .map((pointing) => _PointingTile(pointing: pointing)),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _PointingTile extends StatelessWidget {
  final Pointing pointing;

  const _PointingTile({required this.pointing});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Text(
          pointing.content.length > 120
              ? '${pointing.content.substring(0, 120)}...'
              : pointing.content,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
