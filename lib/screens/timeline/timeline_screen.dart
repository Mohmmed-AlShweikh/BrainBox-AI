import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../providers/notes_provider.dart';
import '../../providers/images_provider.dart';
import '../../providers/voice_notes_provider.dart';
import '../../providers/pdf_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/empty_state.dart';

enum TimelineItemType { note, image, voice, pdf }

class TimelineItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final TimelineItemType type;
  final Object data;

  TimelineItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
    required this.data,
  });
}

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  List<TimelineItem> _buildTimeline(BuildContext context) {
    final items = <TimelineItem>[];

    for (final note in context.read<NotesProvider>().notes) {
      items.add(
        TimelineItem(
          id: note.id,
          title: note.title,
          subtitle: note.content.length > 60
              ? '${note.content.substring(0, 60)}...'
              : note.content,
          date: note.createdAt,
          type: TimelineItemType.note,
          data: note,
        ),
      );
    }
    for (final img in context.read<ImagesProvider>().images) {
      items.add(
        TimelineItem(
          id: img.id,
          title: img.title,
          subtitle: img.description.isNotEmpty
              ? img.description
              : 'Image memory',
          date: img.createdAt,
          type: TimelineItemType.image,
          data: img,
        ),
      );
    }
    for (final v in context.read<VoiceNotesProvider>().voiceNotes) {
      items.add(
        TimelineItem(
          id: v.id,
          title: v.title,
          subtitle: 'Voice note · ${v.formattedDuration}',
          date: v.createdAt,
          type: TimelineItemType.voice,
          data: v,
        ),
      );
    }
    for (final pdf in context.read<PdfProvider>().pdfs) {
      items.add(
        TimelineItem(
          id: pdf.id,
          title: pdf.title,
          subtitle: pdf.description.isNotEmpty
              ? pdf.description
              : 'PDF document',
          date: pdf.createdAt,
          type: TimelineItemType.pdf,
          data: pdf,
        ),
      );
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Map<String, List<TimelineItem>> _groupByDate(
    List<TimelineItem> items,
    AppLocalizations l,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final groups = <String, List<TimelineItem>>{};

    for (final item in items) {
      final itemDate = DateTime(item.date.year, item.date.month, item.date.day);
      String group;
      if (itemDate == today) {
        group = l.translate('today');
      } else if (itemDate == yesterday) {
        group = l.translate('yesterday');
      } else if (itemDate.isAfter(weekAgo)) {
        group = l.translate('thisWeek');
      } else {
        group = '${item.date.day}/${item.date.month}/${item.date.year}';
      }
      groups.putIfAbsent(group, () => []).add(item);
    }
    return groups;
  }

  Color _typeColor(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.note:
        return AppColors.notesColor;
      case TimelineItemType.image:
        return AppColors.imagesColor;
      case TimelineItemType.voice:
        return AppColors.voiceColor;
      case TimelineItemType.pdf:
        return AppColors.pdfColor;
    }
  }

  IconData _typeIcon(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.note:
        return Icons.sticky_note_2_rounded;
      case TimelineItemType.image:
        return Icons.photo_rounded;
      case TimelineItemType.voice:
        return Icons.mic_rounded;
      case TimelineItemType.pdf:
        return Icons.picture_as_pdf_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final items = _buildTimeline(context);
    final groups = _groupByDate(items, l);

    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        title: Text(l.translate('timelineTitle')),
        backgroundColor: AppColors.backgroundFor(context),
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.timeline_rounded,
              title: l.translate('noTimeline'),
              subtitle: l.translate('noTimelineSub'),
              iconColor: AppColors.timelineColor,
            )
          : AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                itemCount: groups.length,
                itemBuilder: (context, groupIndex) {
                  final groupKey = groups.keys.elementAt(groupIndex);
                  final groupItems = groups[groupKey]!;
                  return AnimationConfiguration.staggeredList(
                    position: groupIndex,
                    duration: const Duration(milliseconds: 350),
                    child: SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      groupKey,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.borderFor(context),
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...groupItems.map(
                              (item) => _buildTimelineCard(context, item),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, TimelineItem item) {
    final color = _typeColor(item.type);
    final icon = _typeIcon(item.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                width: 2,
                height: 60,
                color: AppColors.borderFor(context),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardFor(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryFor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondaryFor(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(item.date),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textHintFor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
