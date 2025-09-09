import 'package:flutter/material.dart';
import '../../extensions/theme_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:mawaqit/modules/common/shared/widgets/svg_image.dart';
import 'package:sizer/sizer.dart';

class PlayerBottomSheetWidget extends StatelessWidget {
  const PlayerBottomSheetWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withOpacity(0.05),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '2 - Surah al Baqarah',
                style: context.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp, color: context.colorScheme.primary),
              ),
              Text(
                'Mishary al Afassy',
                style: context.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 11.sp, color: context.colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                    color: context.colorScheme.primary.withOpacity(0.09), borderRadius: BorderRadius.circular(10)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('2:50', style: context.textTheme.bodySmall),
                  Text('4:13', style: context.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    size: 20,
                    CupertinoIcons.shuffle_medium,
                    color: context.colorScheme.primary,
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        size: 36,
                        Icons.fast_rewind_rounded,
                        color: context.colorScheme.primary,
                      )),
                  const SizedBox(width: 6),
                  Container(
                    width: 60,
                    height: 60,
                    // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colorScheme.primary.withOpacity(0.09),
                    ),
                    child: Icon(
                      Icons.pause,
                      color: context.colorScheme.primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        size: 36,
                        Icons.fast_forward_rounded,
                        color: context.colorScheme.primary,
                      )),
                  const Spacer(),
                  SvgImageAsset(
                    height: 15,
                    width: 15,
                    'assets/icons/loop.svg',
                    color: context.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.primary.withOpacity(0.09),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_outlined,
                color: context.colorScheme.primary,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

