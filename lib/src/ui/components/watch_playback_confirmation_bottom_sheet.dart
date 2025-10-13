import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:sizer/sizer.dart';
import '../../extensions/theme_extension.dart';
import '../components/circular_button.dart';

class WatchPlaybackConfirmationBottomSheet extends StatelessWidget {
  final VoidCallback onPlayOnWatch;
  final VoidCallback onPlayOnPhone;

  const WatchPlaybackConfirmationBottomSheet({
    super.key,
    required this.onPlayOnWatch,
    required this.onPlayOnPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('watch_playback_confirmation_bottom_sheet'),
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.transparent
            : context.colorScheme.primary.withOpacity(0.04),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
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
                      color: context.colorScheme.primaryFixed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.watch,
                      size: 40,
                      color: context.colorScheme.primaryFixed,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    "You have a watch connected",
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
                    "Where would you like to play?",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.colorScheme.primaryFixed.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
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
                              onPlayOnWatch();
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: context.colorScheme.primaryFixed,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.watch,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Play on watch",
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
                              onPlayOnPhone();
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: context.colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.colorScheme.primaryFixed.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_android,
                                    color: context.colorScheme.primaryFixed,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Play on Phone",
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
