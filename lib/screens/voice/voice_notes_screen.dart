import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../providers/voice_notes_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/voice_note_card.dart';
import '../../widgets/empty_state.dart';

class VoiceNotesScreen extends StatefulWidget {
  const VoiceNotesScreen({super.key});

  @override
  State<VoiceNotesScreen> createState() => _VoiceNotesScreenState();
}

class _VoiceNotesScreenState extends State<VoiceNotesScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  int _recordingSeconds = 0;
  Timer? _timer;
  String? _recordingPath;
  String? _playingId;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording(BuildContext context) async {
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.translate('permissionRequired')),
          content: Text(l.translate('microphonePermission')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.translate('ok')),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(ctx);
              },
              child: Text(l.translate('settings')),
            ),
          ],
        ),
      );
      return;
    }

    if (!context.mounted) return;
    final path = await context.read<VoiceNotesProvider>().getRecordingPath();
    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _recordingPath = path;
      _recordingSeconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingSeconds++);
    });
  }

  Future<void> _stopRecording(BuildContext context) async {
    _timer?.cancel();
    await _recorder.stop();
    setState(() => _isRecording = false);

    if (_recordingPath != null && _recordingSeconds > 0) {
      _showSaveDialog(context);
    }
  }

  void _showSaveDialog(BuildContext context) {
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.translate('newVoiceNote'),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l.translate('voiceTitleHint'),
                labelText: l.translate('voiceNoteTitle'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  Navigator.pop(ctx);
                  await context.read<VoiceNotesProvider>().saveVoiceNote(
                        title: title.isEmpty
                            ? 'Voice Note ${DateTime.now().millisecondsSinceEpoch}'
                            : title,
                        filePath: _recordingPath!,
                        durationSeconds: _recordingSeconds,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(l.translate('voiceNoteSaved'))),
                    );
                  }
                },
                child: Text(l.translate('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playNote(String id, String path) async {
    if (_isPlaying && _playingId == id) {
      await _player.stop();
      setState(() {
        _isPlaying = false;
        _playingId = null;
      });
    } else {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      setState(() {
        _isPlaying = true;
        _playingId = id;
      });
      _player.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _playingId = null;
          });
        }
      });
    }
  }

  String _formatRecordingTime() {
    final m = _recordingSeconds ~/ 60;
    final s = _recordingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteVoiceNote(BuildContext context, String id) async {
    final l = AppLocalizations(context.read<LanguageProvider>().locale);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.translate('delete')),
        content: Text(l.translate('deleteConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l.translate('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<VoiceNotesProvider>().deleteVoiceNote(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final voiceNotes = context.watch<VoiceNotesProvider>().voiceNotes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.translate('voice')),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Recording UI
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isRecording
                  ? AppColors.voiceColor.withOpacity(0.1)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isRecording
                    ? AppColors.voiceColor.withOpacity(0.5)
                    : AppColors.border,
                width: _isRecording ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                if (_isRecording) ...[
                  Text(
                    l.translate('recording'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.voiceColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatRecordingTime(),
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Text(
                    l.translate('tapToRecord'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                GestureDetector(
                  onTap: () => _isRecording
                      ? _stopRecording(context)
                      : _startRecording(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? AppColors.error
                          : AppColors.voiceColor,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? AppColors.error
                                  : AppColors.voiceColor)
                              .withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Voice notes list
          Expanded(
            child: voiceNotes.isEmpty
                ? EmptyState(
                    icon: Icons.mic_none_rounded,
                    title: l.translate('noVoiceNotes'),
                    subtitle: l.translate('noVoiceNotesSub'),
                    iconColor: AppColors.voiceColor,
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: voiceNotes.length,
                      itemBuilder: (context, index) {
                        final note = voiceNotes[index];
                        final isThisPlaying =
                            _isPlaying && _playingId == note.id;
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 350),
                          child: SlideAnimation(
                            verticalOffset: 30,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Dismissible(
                                  key: Key(note.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.error),
                                  ),
                                  confirmDismiss: (_) async {
                                    await _deleteVoiceNote(context, note.id);
                                    return false;
                                  },
                                  child: GestureDetector(
                                    onTap: () =>
                                        _playNote(note.id, note.filePath),
                                    child: Stack(
                                      children: [
                                        VoiceNoteCard(
                                          voiceNote: note,
                                          onTap: () => _playNote(
                                              note.id, note.filePath),
                                          onFavorite: () => context
                                              .read<VoiceNotesProvider>()
                                              .toggleFavorite(note),
                                        ),
                                        if (isThisPlaying)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.voiceColor,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.equalizer_rounded,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
