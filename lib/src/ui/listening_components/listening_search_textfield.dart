import 'package:flutter/material.dart';
import 'package:mawaqit_quran_listening/src/extensions/semantics_extension.dart';
import '../../extensions/theme_extension.dart';
import '../components/svg_image_asset.dart';

class ListeningSearchTextField extends StatelessWidget {
  const ListeningSearchTextField({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.onSuffixPressed,
    required this.controller,
    required this.hasSuffix,
    required this.onSubmittedPressed,
  });

  final String hint;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmittedPressed;
  final TextEditingController controller;
  final VoidCallback onSuffixPressed;
  final bool hasSuffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmittedPressed,
      contextMenuBuilder: _selectionToolbar,
      decoration: InputDecoration(
        fillColor: context.colorScheme.surfaceContainer,
        filled: true,
        hintText: hint,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(context).disabledColor,
          fontFamily: context.getFontFamily(),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 15, top: 1),
          child: SvgImageAsset('assets/icons/ic_search.svg',
              color: Theme.of(context).disabledColor,
              height: 24,
              width: 24,
          ),
        ),
        suffixIcon:
            hasSuffix
                ? IconButton(
                  onPressed: onSuffixPressed,
                  icon: Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 16),
                  ),
                )
                : null,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide.none,
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide.none,
        ),
      ),
    ).excludeSemantics().semantic(textField: true,context: context,label: hint);
  }

  /// Material's toolbar paints with `colorScheme.surface` / `onSurface`, which
  /// the host theme doesn't pair for contrast (white on near-white in light,
  /// purple on near-black in dark).
  Widget _selectionToolbar(BuildContext context, EditableTextState state) {
    final scheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: scheme.copyWith(
          // Reads as a raised sheet in both themes.
          surface: scheme.surfaceContainerHighest,
          // Near-black in light, near-white in dark.
          onSurface: scheme.secondary,
        ),
      ),
      child: AdaptiveTextSelectionToolbar.editableText(editableTextState: state),
    );
  }
}
