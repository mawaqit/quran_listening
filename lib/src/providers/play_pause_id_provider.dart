import 'package:flutter/cupertino.dart';

class DownloadedPagePlayPauseIndexProvider extends ChangeNotifier {
  int currentPlayingSurahIndex = -1;

  void setCurrentSurahIndex(int newIndex) {
    currentPlayingSurahIndex = newIndex;
    notifyListeners();
  }
}
