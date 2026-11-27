import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/pressable.dart';

/// Satu pilihan qari. [photo] opsional; tanpa foto, avatar berisi inisial.
class QariOption {
  const QariOption({
    required this.id,
    required this.name,
    required this.origin,
    this.photo,
    this.photoAlignment = Alignment.center,
  });

  final String id;
  final String name;

  /// Mis. "Kuwait · Murattal".
  final String origin;
  final ImageProvider? photo;
  final Alignment photoAlignment;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.length == 1
        ? parts.first[0].toUpperCase()
        : '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Membuka panel "Pilih qari" dan mengembalikan qari yang diketuk
/// (atau `null` bila ditutup).
Future<QariOption?> showQariPicker(
  BuildContext context, {
  required List<QariOption> options,
  required QariOption selected,
}) {
  return showAppBottomSheet<QariOption>(
    context,
    title: 'Pilih qari',
    subtitle: selected.name,
    footerHint: 'Ketuk qari untuk langsung mengganti.',
    builder: (context, close) => Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          QariPickerTile(
            option: options[i],
            selected: options[i].id == selected.id,
            onTap: () => close(options[i]),
          ),
        ],
      ],
    ),
  );
}

/// Baris pilihan qari: avatar, nama, asal dan jenis bacaan.
class QariPickerTile extends StatelessWidget {
  const QariPickerTile({
    super.key,
    required this.option,
    this.selected = false,
    this.onTap,
  });

  final QariOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: '${option.name}, ${option.origin}',
        pressedScale: 0.99,
        child: AppSurface(
          color: AppColors.surfaceCard,
          radius: 12,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              _avatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.custom(
                        size: 12,
                        lineHeight: 17,
                        weight: FontWeight.w600,
                        color: AppColors.sheetText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.origin,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.custom(
                        size: 10,
                        lineHeight: 15,
                        color: AppColors.sheetMuted,
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

  Widget _avatar() {
    if (option.photo == null) {
      return InitialsAvatar(initials: option.initials);
    }
    return ClipOval(
      child: Image(
        image: ResizeImage.resizeIfNeeded(120, null, option.photo!),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        alignment: option.photoAlignment,
        excludeFromSemantics: true,
      ),
    );
  }
}
