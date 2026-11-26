import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/network/failure_mapper.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../quran/domain/surah.dart';
import '../../quran/domain/tafsir.dart';
import '../application/reader_controller.dart';

/// Membuka lembar bawah Tafsir untuk ayat tertentu (docs/03 §2.5, 06 §5).
Future<void> showTafsirSheet(
  BuildContext context, {
  required ReaderController reader,
  required Surah surah,
  required int ayahNumber,
}) {
  return showAppBottomSheet<void>(
    context,
    title: 'Tafsir ${surah.latinName}',
    subtitle: 'Ayat $ayahNumber · Kemenag RI (equran.id)',
    builder: (context, close) => _TafsirSheetBody(
      reader: reader,
      surahNumber: surah.number,
      ayahNumber: ayahNumber,
    ),
  );
}

class _TafsirSheetBody extends StatefulWidget {
  const _TafsirSheetBody({
    required this.reader,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final ReaderController reader;
  final int surahNumber;
  final int ayahNumber;

  @override
  State<_TafsirSheetBody> createState() => _TafsirSheetBodyState();
}

class _TafsirSheetBodyState extends State<_TafsirSheetBody> {
  SurahTafsir? _tafsir;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.reader.loadTafsir(widget.surahNumber);
      if (!mounted) return;
      setState(() {
        _tafsir = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = mapToAppFailure(e).userMessage;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonBox(height: 16, radius: 6),
          SizedBox(height: 10),
          SkeletonBox(height: 16, radius: 6),
          SizedBox(height: 10),
          SkeletonBox(height: 16, width: 220, radius: 6),
        ],
      );
    }

    if (_error != null) {
      return Column(
        children: [
          Text(
            _error!,
            style: AppTextStyles.body.copyWith(color: AppColors.sheetMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Coba lagi',
            style: AppButtonStyle.primary,
            onTap: _load,
          ),
        ],
      );
    }

    final entry = _tafsir?.forAyah(widget.ayahNumber);
    if (entry == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Tafsir tidak tersedia untuk ayat ini.',
          style: AppTextStyles.body.copyWith(color: AppColors.sheetMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Text(
      entry.text,
      style: AppTextStyles.custom(
        size: 14,
        lineHeight: 22,
        color: AppColors.sheetText,
      ),
    );
  }
}
