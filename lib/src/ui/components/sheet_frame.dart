import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Same sheet frame as the host app: the whole sheet, background included,
/// stays inside the safe area on the sides and top (status bar, landscape
/// notch, a foldable's side status column), while the background still
/// reaches the bottom edge and the content pads itself above the home
/// indicator. On large screens the sheet is also centred and at most
/// [kSheetMaxWidth] wide. Phones in portrait have no side insets, so nothing
/// changes there.
const double kSheetMaxWidth = 640;

bool _isLargeScreen(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide >= 600;

/// [constraints] capped at [kSheetMaxWidth] on large screens, keeping any
/// other limits (e.g. maxHeight) the caller passed.
BoxConstraints? _sheetConstraints(
  BuildContext context,
  BoxConstraints? constraints,
) {
  if (!_isLargeScreen(context)) return constraints;
  final base = constraints ?? const BoxConstraints();
  return base.copyWith(maxWidth: math.min(base.maxWidth, kSheetMaxWidth));
}

/// [showModalBottomSheet] with the shared sheet frame.
Future<T?> showFramedModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  ShapeBorder? shape,
  BoxConstraints? constraints,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    backgroundColor: backgroundColor,
    shape: shape,
    constraints: _sheetConstraints(context, constraints),
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
  );
}

/// [showBarModalBottomSheet] with the shared sheet frame: pushes the same
/// route, with the bar sheet wrapped in [_SheetFrame].
Future<T?> showFramedBarModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool expand = false,
}) {
  return Navigator.of(context).push(
    ModalSheetRoute<T>(
      builder: builder,
      expanded: expand,
      bounce: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      modalBarrierColor: Colors.black87,
      containerBuilder:
          (_, __, child) => _SheetFrame(
            child: BarBottomSheet(
              backgroundColor: backgroundColor,
              child: child,
            ),
          ),
    ),
  );
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child:
            _isLargeScreen(context)
                ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kSheetMaxWidth),
                  child: child,
                )
                : child,
      ),
    );
  }
}
