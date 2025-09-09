import 'package:flutter/cupertino.dart';

class SurahPagePlayPauseIndexProvider extends ChangeNotifier {
  int currentPlayingSurahIndex = -1;
  int currentRecitorId = -1;

  void setCurrentSurahIndex(int newIndex) {
    currentPlayingSurahIndex = newIndex;
    notifyListeners();
  }

  void setCurrentRecitor(int recitorId) {
    currentRecitorId = recitorId;
    notifyListeners();
  }
}


class DownloadedPagePlayPauseIndexProvider extends ChangeNotifier {
  int currentPlayingSurahIndex = -1;

  void setCurrentSurahIndex(int newIndex) {
    currentPlayingSurahIndex = newIndex;
    notifyListeners();
  }
}
