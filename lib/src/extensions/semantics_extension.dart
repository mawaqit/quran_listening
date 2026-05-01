import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:mawaqit_mobile_i18n/gen_l10n/app_localizations.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';

// ── SEMANTIC LOCALE FALLBACK ────────────────────────────────────────────────
// Maps app locale codes to their English fallback for screen reader output.
// Key:   app locale language code
// Value: map of platform → fallback locale code, or null if supported.
//        null means the locale IS supported on that platform — no fallback.
const _kSemanticFallback = <String, Map<String, String?>>{
  'ug': {'android': 'en', 'ios': 'en'},
  'ur': {'android': null, 'ios': 'en'},
  'fa': {'android': 'en', 'ios': null},
  'sq': {'android': null, 'ios': 'en'},
  'bs': {'android': null, 'ios': 'en'},
  'ku': {'android': null, 'ios': 'en'},
};
// ────────────────────────────────────────────────────────────────────────────

/// Resolves the effective locale to use for semantic label TTS output.
///
/// If the given [appLocale] is not supported by the screen reader on the
/// current platform, returns [Locale('en', 'GB')] as the universal fallback.
///
///
/// Otherwise returns [appLocale] unchanged.
///
/// [isAndroid] must be passed explicitly so this class is unit-testable
/// without a real device.
class SemanticLocaleResolver {
  const SemanticLocaleResolver._();

  static Locale resolve(Locale appLocale, {required bool isAndroid}) {
    final platformKey = isAndroid ? 'android' : 'ios';
    final fallbackCode =
    _kSemanticFallback[appLocale.languageCode]?[platformKey];

    if (fallbackCode == null) return appLocale;
    return const Locale('en', 'GB');
  }
}

/// Returns the [AppLocalizations] instance for [locale].
///
/// Falls back to English if the delegate cannot load the requested locale.
AppLocalizations _lookupSemanticTr(Locale locale) {
  try {
    return lookupAppLocalizations(locale);
  } catch (_) {
    return lookupAppLocalizations(const Locale('en', 'GB'));
  }
}

AppLocalizations semanticTrForLocale(Locale appLocale,
    {required bool isAndroid}) {
  final resolved = SemanticLocaleResolver.resolve(
    appLocale,
    isAndroid: isAndroid,
  );
  return _lookupSemanticTr(resolved);
}

/// Returns [AppLocalizations] for the resolved semantic locale synchronously.
///
/// For supported locales, returns [context.tr] directly (zero cost).
/// For unsupported locales, returns English localizations immediately.
AppLocalizations _resolveSemanticTr(BuildContext context) {
  final appLocale = Localizations.localeOf(context);
  final resolved = SemanticLocaleResolver.resolve(
    appLocale,
    isAndroid: Platform.isAndroid,
  );

  if (resolved == appLocale) return context.tr;

  return _lookupSemanticTr(resolved);
}

extension SemanticLocalizationsX on BuildContext {
  AppLocalizations get semanticTr => _resolveSemanticTr(this);

  bool get usesSemanticLocaleFallback {
    final appLocale = Localizations.localeOf(this);
    return SemanticLocaleResolver.resolve(
      appLocale,
      isAndroid: Platform.isAndroid,
    ) !=
        appLocale;
  }
}

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
      localeForSubtree: localeForSubtree ??
        SemanticLocaleResolver.resolve(
        Localizations.localeOf(context!),
        isAndroid: Platform.isAndroid,
        ),
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
