import 'package:flutter/widgets.dart';

import 'section_header.dart';

/// Rak: [SectionHeader] di atas, baris item yang bisa digeser mendatar di bawah.
class Shelf extends StatelessWidget {
  const Shelf({
    super.key,
    required this.title,
    required this.children,
    this.onSeeAll,
    this.gap = 14,
    this.horizontalPadding = 20,
    this.headerGap = 14,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onSeeAll;
  final double gap;
  final double horizontalPadding;
  final double headerGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onChevronTap: onSeeAll,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        ),
        SizedBox(height: headerGap),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: gap),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
