import 'package:flutter/material.dart';
import 'package:mawaqit_quran_listening/src/extensions/device_extensions.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:sizer/sizer.dart';
import '../../../mawaqit_quran_listening.dart';
import 'package:provider/provider.dart';


class RecitorListTile extends StatefulWidget {
  const RecitorListTile({super.key, required this.recitor, required this.listeningTab, required this.index,});

  final Reciter recitor;
  final ListeningTab listeningTab;
  final int index;
  final VoidCallback? onTap;

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

    // this will work only for foldable
    final bool isSelected =
        context.isFoldable &&
        context.watch<AudioPlayerProvider>().reciter == widget.recitor;
    final bool isFavorite = favoriteReciter.favoriteReciterUuids.contains(
      widget.recitor.id.toString(),
    );
    final String favoriteTooltip =
        isFavorite
            ? '${context.tr.remove} ${widget.recitor.reciterName}'
            : '${context.tr.favorite_reciters}: ${widget.recitor.reciterName}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? context.colorScheme.primaryContainer : context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsetsDirectional.only(start: 19, top: 15, bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recitor.reciterName.trim(),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: (context.isFoldable ? 8 : 13).sp,
                      color: isSelected ? context.colorScheme.onPrimaryContainer : context.colorScheme.onPrimaryContainer.withOpacity(.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  DefaultTextStyle(
                    style: TextStyle(
                      color: context.colorScheme.secondary.withOpacity(.70),
                      fontSize: (context.isFoldable ? 6 : 9).sp,
                      fontFamily: context.getFontFamily(),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(widget.recitor.style ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          (widget.listeningTab == ListeningTab.allRecitator)
              ? Padding(
                key: Key('add_favorite_key_${widget.index}'),
                padding: EdgeInsetsDirectional.only(start: 7.0, end: 3),
                child: IconButton(
                  constraints: const BoxConstraints(),
                  tooltip: favoriteTooltip,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _saveReciter();
                    setState(() {});
                  },
                  icon: SvgImageAsset(
                        height: 17,
                        width: 17,
                        isFavorite
                            ? 'assets/icons/heart_filled.svg'
                            : 'assets/icons/heart_outline.svg',
                        color: context.colorScheme.primaryFixed,
                      ).excludeSemantics(),
                ),
              )
              : Padding(
                padding: EdgeInsetsDirectional.only(start: 7.0, end: 3),
                child: IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  tooltip: '${context.tr.remove} ${widget.recitor.reciterName}',
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
        ],
      ),
    );
  }
}
