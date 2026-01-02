import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:mawaqit_quran_listening/src/utils/listening_utils/wear_connector.dart';
import 'package:sizer/sizer.dart';

import '../../extensions/theme_extension.dart';
import '../../utils/helpers/watch_icons.dart';
import '../components/circular_button.dart';

class WatchPlaybackConfirmationBottomSheet extends StatefulWidget {
  final VoidCallback onPlayOnWatch;
  final VoidCallback onPlayOnPhone;
  final String surahName;

  const WatchPlaybackConfirmationBottomSheet({
    super.key,
    required this.onPlayOnWatch,
    required this.onPlayOnPhone,
    required this.surahName,
  });

  @override
  State<WatchPlaybackConfirmationBottomSheet> createState() =>
      _WatchPlaybackConfirmationBottomSheetState();
}

class _WatchPlaybackConfirmationBottomSheetState
    extends State<WatchPlaybackConfirmationBottomSheet> {
  bool _loading = true;
  String? _watchName;

  @override
  void initState() {
    super.initState();
    _loadWatchName();
  }

  Future<void> _loadWatchName() async {
    final watchInfo = await WearConnector.isWatchConnected();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _watchName = watchInfo['deviceName'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('watch_playback_confirmation_bottom_sheet'),
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        color:
            context.isDark
                ? Colors.transparent
                : context.colorScheme.primary.withOpacity(0.04),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Watch Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryFixed.withOpacity(
                          0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Platform.isIOS
                            ? WatchIcons.apple_watch
                            : WatchIcons.android_watch,
                        size: 40,
                        color: context.colorScheme.primaryFixed,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      "${context.tr.connected_watch}: ${_watchName == null || _watchName!.isEmpty ? context.tr.unknown_smartwatch : _watchName}",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.primaryFixed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      "${context.tr.chapter} ${widget.surahName} ${context.tr.ready_play_watch}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colorScheme.primaryFixed.withOpacity(
                          0.7,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: context.colorScheme.primaryFixed.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              context.tr.take_time_appear_watch,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: context.colorScheme.primaryFixed.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Buttons Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          // Play on Watch Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                widget.onPlayOnWatch();
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: context.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Platform.isIOS
                                          ? WatchIcons.apple_watch
                                          : WatchIcons.android_watch,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.tr.play,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Play on Phone Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                widget.onPlayOnPhone();
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: context.colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.colorScheme.primaryFixed
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Platform.isIOS
                                          ? Icons.phone_iphone
                                          : Icons.phone_android,
                                      color: context.colorScheme.primaryFixed,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.tr.cancel,
                                      style: TextStyle(
                                        color: context.colorScheme.primaryFixed,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Close Button
          Padding(
            key: const Key('watch_confirmation_bottom_sheet_close'),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CircularButton(
              icon: Icons.keyboard_arrow_down,
              iconColor: context.colorScheme.primaryFixed,
              size: 32,
              borderColor: context.colorScheme.primaryFixed,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
