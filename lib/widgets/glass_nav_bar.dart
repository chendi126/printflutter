import 'dart:ui';
import 'package:flutter/cupertino.dart';

class GlassNavBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final Widget? leading;
  final Widget? middle;
  final Widget? trailing;
  final double blurSigma;
  final EdgeInsetsGeometry contentPadding;
  final bool autoBack;
  final double middleOffsetX;

  const GlassNavBar({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.blurSigma = 20,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.autoBack = true,
    this.middleOffsetX = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final barHeight = top + 44;
    final tint = CupertinoColors.white.withValues(alpha: 0.12);
    final canPop = Navigator.of(context).canPop();
    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && autoBack && canPop) {
      resolvedLeading = CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        minSize: 36,
        onPressed: () => Navigator.maybePop(context),
        child: const Icon(CupertinoIcons.back, size: 24),
      );
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          height: barHeight,
          padding: EdgeInsets.only(top: top),
          decoration: BoxDecoration(
            color: tint,
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.white.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CupertinoColors.white.withValues(alpha: 0.18),
                CupertinoColors.white.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Padding(
            padding: contentPadding,
            child: Row(
              children: [
                SizedBox(width: 56, child: Align(alignment: Alignment.centerLeft, child: resolvedLeading)),
                Expanded(
                  child: DefaultTextStyle(
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: Transform.translate(
                      offset: Offset(middleOffsetX, 0),
                      child: Center(child: middle ?? const SizedBox.shrink()),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: trailing == null
                      ? const SizedBox(width: 56)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: trailing!,
                            )
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
