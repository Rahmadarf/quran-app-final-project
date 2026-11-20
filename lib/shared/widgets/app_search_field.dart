import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'icon_circle_button.dart';

/// Kolom pencarian kustom (dibangun dari `EditableText`, bukan `TextField`).
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onMicTap,
    this.fillColor = AppColors.surfaceDeep,
    this.borderColor,
    this.iconColor = AppColors.placeholder,
    this.height = 44,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Bila diisi, tombol mikrofon tampil di kanan (pencarian suara).
  final VoidCallback? onMicTap;
  final Color fillColor;
  final Color? borderColor;
  final Color iconColor;
  final double height;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final empty = _controller.text.isEmpty;

    return Semantics(
      textField: true,
      label: widget.hint,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _focus.requestFocus(),
        child: AppSurface(
          color: widget.fillColor,
          borderColor: focused
              ? AppColors.accent
              : (widget.borderColor ?? AppColors.borderAt(0.3)),
          radius: 12,
          height: widget.height,
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Row(
            children: [
              AppIcon(AppIcons.search, size: 16, color: widget.iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    if (empty)
                      IgnorePointer(
                        child: Text(
                          widget.hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.hint,
                        ),
                      ),
                    EditableText(
                      controller: _controller,
                      focusNode: _focus,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textPrimary),
                      cursorColor: AppColors.accentLight,
                      backgroundCursorColor: AppColors.surface,
                      selectionColor: AppColors.accentAt(0.4),
                      textInputAction: TextInputAction.search,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              if (widget.onMicTap != null)
                IconCircleButton(
                  icon: AppIcons.mic,
                  semanticLabel: 'Pencarian suara',
                  size: 32,
                  iconSize: 16,
                  iconColor: AppColors.accentLight,
                  onTap: widget.onMicTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
