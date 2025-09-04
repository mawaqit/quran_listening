import 'package:flutter/material.dart';

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
      decoration: InputDecoration(
        fillColor: Theme.of(context).colorScheme.surface,
        filled: true,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(context).disabledColor,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 12.0,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 15, top: 1),
          child: Icon(Icons.search, color: Theme.of(context).disabledColor),
        ),
        suffixIcon:
            hasSuffix
                ? IconButton(
                  onPressed: onSuffixPressed,
                  icon: Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                )
                : null,
        hintText: hint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
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
    );
  }
}
