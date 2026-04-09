class BulkDownloadSession {
  final String reciterId;
  int totalSurahs;
  final Set<String> chapterIds = <String>{};

  BulkDownloadSession({required this.reciterId, required this.totalSurahs});
}
