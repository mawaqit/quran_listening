import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:mawaqit_quran_listening/src/providers/audio_player.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../mawaqit_quran_listening.dart';
import '../ui/listening_components/audio_player_v3.dart';
import 'audio_provider.dart';

class RecitersScreenViews {
  final String title;
  final String subtitle;

  const RecitersScreenViews(this.title, this.subtitle);

  static const all = RecitersScreenViews('Al Quran al Kareem', 'Reciters');
  static const liked = RecitersScreenViews('Favorite reciters', 'Favorite reciters');
  static const downloaded = RecitersScreenViews('Surahs downloaded', 'Surahs downloaded');

  String getLocalizedSubtitle(BuildContext context) {
    final tr = context.tr;
    switch (this) {
      case RecitersScreenViews.all:
        return tr.reciters;
      case RecitersScreenViews.liked:
        return tr.favorite_reciters;
      case RecitersScreenViews.downloaded:
        return context.tr.surahs_downloaded;
      default:
        return '';
    }
  }
}

class PlayerScreensController extends ChangeNotifier {
  PlayerScreensController();

  int _currentPage = 0;
  PageController pageController = PageController(initialPage: 0);

  Reciter? _reciter;
  RecitersScreenViews _reciterView = RecitersScreenViews.all;

  String getLocalizedTitle(BuildContext context) {
    final tr = context.tr;
    switch (_reciterView) {
      case RecitersScreenViews.all:
        return tr.al_quran_al_kareem;
      case RecitersScreenViews.liked:
        return tr.favorite_reciters;
      case RecitersScreenViews.downloaded:
        return tr.surahs_downloaded;
      default:
        return '';
    }
  }

  int get currentPage => _currentPage;

  Reciter? get reciter => _reciter;

  RecitersScreenViews get reciterView => _reciterView;

  bool get isRecitersScreen => currentPage == 1;

  String getScreenTitle(BuildContext context) {
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context);
    return _reciter == null
        ? getLocalizedTitle(context)
        : audioPlayerProvider.getCurrentReciter(context: context).reciterName;
  }

  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  set reciterView(RecitersScreenViews value) {
    _reciterView = value;
    notifyListeners();
  }

  /// V3-Player
  void navigateToPlayerScreenV3(
    BuildContext context,
    List<Reciter> reciters,
    SurahModel chapter,
    List<SurahModel> chapters,
    PlayerType playerType, {
    Reciter? reciterFromAllSaved,
  }) {
    final audioPlayerProvider = context.read<AudioPlayerProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.isDark ? const Color(0xff1C1B23) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      builder:
          (context) => SafeArea(
            child: QuranAudioPlayerV3(
              reciters: reciters,
              chapter: chapter,
              chapters: chapters,
              playerType: playerType,
              reciterFromAllSaved: reciterFromAllSaved,
            ),
          ),
    ).then((_) {
      audioPlayerProvider.showHideFloatingPlayer(true, context: context);
    });
  }

  void navigateToPlayerScreen(
    BuildContext context,
    List<Reciter> reciters,
    SurahModel chapter,
    List<SurahModel> chapters,
    PlayerType playerType, {
    Reciter? reciterFromAllSaved,
  }) {
    showBarModalBottomSheet(
      context: context,
      expand: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: QuranAudioPlayer(
              reciters: reciters,
              chapter: chapter,
              chapters: chapters,
              playerType: playerType,
              reciterFromAllSaved: reciterFromAllSaved,
            ),
          ),
    );
  }

  void setRecitor(Reciter reciter) {
    _reciter = reciter;
  }

  void navigateToRecitationsScreen(Reciter reciter) {
    _reciter = reciter;
    pageController.animateToPage(2, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void popScreen(int index) {
    if (index != 2) {
      _reciter = null;
    }
    pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }
}
