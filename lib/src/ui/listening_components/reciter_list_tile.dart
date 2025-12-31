import 'package:flutter/material.dart';
import 'package:mawaqit_quran_listening/src/extensions/device_extensions.dart';
import 'package:sizer/sizer.dart';
import '../../../mawaqit_quran_listening.dart';
import 'package:provider/provider.dart';
import '../components/svg_image_asset.dart';


class RecitorListTile extends StatefulWidget {
  const RecitorListTile({super.key, required this.recitor, required this.listeningTab, required this.index,});

  final Reciter recitor;
  final ListeningTab listeningTab;
  final int index;

  @override
  State<RecitorListTile> createState() => _RecitorListTileState();
}

class _RecitorListTileState extends State<RecitorListTile> {
  late FavoriteReciter favoriteReciter;

  @override
  void initState() {
    super.initState();
    favoriteReciter = context.read<FavoriteReciter>();
  }

  _saveReciter() async {
    if (favoriteReciter.favoriteReciterUuids.contains(widget.recitor.id.toString())) {
      await favoriteReciter.removeReciterFromFavorite(widget.recitor.id.toString());
    } else {
      await favoriteReciter.addReciterToFavorite(widget.recitor.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    Color tileBackgroundColor = context.colorScheme.surfaceContainerLow;
    if (context.isFoldable && context.watch<AudioPlayerProvider>().reciter == widget.recitor){
      tileBackgroundColor = context.colorScheme.surfaceContainerHigh;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tileBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsetsDirectional.only(start: 19, top: 15, bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recitor.reciterName.trim(),
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: (context.isFoldable ? 9 : 13).sp,
                    color: context.colorScheme.onPrimaryContainer.withOpacity(.9),
                  ),
                ),
                const SizedBox(height: 2),
                DefaultTextStyle(
                  style: TextStyle(
                      color: context.colorScheme.secondary.withOpacity(.70),
                      fontSize: (context.isFoldable ? 7 : 9).sp,
                      fontFamily: context.getFontFamily()),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(widget.recitor.style ?? '', overflow: TextOverflow.ellipsis, maxLines: 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          (widget.listeningTab == ListeningTab.allRecitator)
              ? Padding(
            key: Key('add_favorite_key_${widget.index}'),
            padding: EdgeInsetsDirectional.only(start: 7.0, end: 3,),
            child: IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: () {
                _saveReciter();
                setState(() {});
              },
              icon: SvgImageAsset(
                height: 17,
                width: 17,
                (favoriteReciter.favoriteReciterUuids.contains(widget.recitor.id.toString()))
                    ? 'assets/icons/heart_filled.svg'
                    : 'assets/icons/heart_outline.svg',
                color: context.colorScheme.primaryFixed,
              ),
            ),
          )
              : Padding(
            padding: EdgeInsetsDirectional.only(start: 7.0, end: 3,),
            child: IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: () {
                _saveReciter();
                setState(() {});
              },
              icon: IconButton(
                onPressed: () {
                  _saveReciter();
                  setState(() {});
                },
                icon: Icon(
                  Icons.close,
                  color: context.colorScheme.primaryFixed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}






class ReciterListTile extends StatelessWidget {
  final Reciter reciter;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final int index;

  const ReciterListTile({
    super.key,
    required this.reciter,
    required this.index,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('reciter_tile_key_${index}'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 5, top: 15, bottom: 15, right: 5),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Reciter avatar/icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryFixed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  reciter.reciterName.isNotEmpty
                      ? reciter.reciterName[0].toUpperCase()
                      : 'R',
                  style: TextStyle(
                    color: context.colorScheme.primaryFixed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Reciter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reciter.reciterName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.colorScheme.onPrimaryContainer.withOpacity(.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Style: ${reciter.style ?? 'Unknown'}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onFavoriteToggle != null)
                  IconButton(
                    key: Key('favorite_button_key_${index}'),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorite
                              ? Colors.red
                              : context.colorScheme.primaryFixed,
                      size: 22,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: context.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
