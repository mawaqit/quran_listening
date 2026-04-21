import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';

/// Accessibility / Semantics extensions on [Widget].
extension SemanticsX on Widget {
  /// Wraps the widget in a [Semantics] node.
  ///
  /// Pass [context] when the semantics node should announce in the current app
  /// locale. This avoids depending on a global navigator key.
  Widget semantic({
    BuildContext? context,
    String? label,
    String? hint,
    String? value,
    Locale? localeForSubtree,
    bool? button,
    bool? selected,
    bool? header,
    bool? image,
    bool? liveRegion,
    bool? focusable,
    bool? focused,
    bool? enabled,
    bool? checked,
    bool? toggled,
    bool? readOnly,
    bool? obscured,
    bool? multiline,
    bool? scopesRoute,
    bool? namesRoute,
    bool? hidden,
    bool? mixed,
    bool? expanded,
    bool? textField,
    bool? inMutuallyExclusiveGroup,
    SemanticsSortKey? sortKey,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onScrollUp,
    VoidCallback? onScrollDown,
    VoidCallback? onScrollLeft,
    VoidCallback? onScrollRight,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
    VoidCallback? onDismiss,
  }) {
    final effectiveLocale =
        localeForSubtree ??
        (context != null ? Localizations.maybeLocaleOf(context) : null);

    return Semantics(
      container: effectiveLocale != null,
      label: label,
      hint: hint,
      value: value,
      // localeForSubtree: effectiveLocale
      button: button,
      textField: textField,
      selected: selected,
      header: header,
      image: image,
      liveRegion: liveRegion,
      focusable: focusable,
      focused: focused,
      enabled: enabled,
      checked: checked,
      toggled: toggled,
      readOnly: readOnly,
      obscured: obscured,
      multiline: multiline,
      scopesRoute: scopesRoute,
      namesRoute: namesRoute,
      hidden: hidden,
      mixed: mixed,
      expanded: expanded,
      inMutuallyExclusiveGroup: inMutuallyExclusiveGroup,
      sortKey: sortKey,
      onTap: onTap,
      onLongPress: onLongPress,
      onScrollUp: onScrollUp,
      onScrollDown: onScrollDown,
      onScrollLeft: onScrollLeft,
      onScrollRight: onScrollRight,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      onDismiss: onDismiss,
      child: this,
    );
  }

  /// Merges all descendant semantic nodes into a single announcement.
  Widget mergeSemantics() => MergeSemantics(child: this);

  /// Hides this widget and all its children from the accessibility tree.
  Widget excludeSemantics({bool excluding = true}) =>
      ExcludeSemantics(excluding: excluding, child: this);

  /// Blocks semantics of widgets painted behind this one.
  Widget blockSemantics({bool blocking = true}) =>
      BlockSemantics(blocking: blocking, child: this);

  /// Controls focus traversal order via [OrdinalSortKey].
  Widget semanticSortKey(SemanticsSortKey sortKey) =>
      Semantics(sortKey: sortKey, child: this);

  /// Announces a custom tappable widget as a single button.
  Widget semanticAction({
    required BuildContext context,
    required String label,
    String? hint,
    bool enabled = true,
    bool excludeChildNodes = true,
  }) {
    final target = excludeChildNodes ? excludeSemantics() : this;
    return target.semantic(
      context: context,
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
    );
  }

  /// Semantic label for a tappable reciter row.
  Widget semanticReciter({
    required BuildContext context,
    required String reciterName,
    String? style,
    String? hint,
    bool selected = false,
  }) {
    final parts = <String>[
      reciterName,
      if (style != null && style.trim().isNotEmpty) style.trim(),
    ];

    return excludeSemantics().semantic(
      context: context,
      label: parts.join(', '),
      hint: hint,
      button: true,
      selected: selected,
    );
  }

  /// Semantic label for a tappable surah row.
  Widget semanticSurah({
    required BuildContext context,
    required String surahName,
    required String reciterName,
    String? hint,
  }) {
    return excludeSemantics().semantic(
      context: context,
      label: '$surahName, $reciterName',
      hint: hint,
      button: true,
    );
  }

}
