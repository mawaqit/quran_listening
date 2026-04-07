class BulkDownloadStatus {
  final String reciterId;
  final int totalSurahs;
  final int downloadedCount;

  const BulkDownloadStatus({
    required this.reciterId,
    required this.totalSurahs,
    required this.downloadedCount,
  });

  double get progress =>
      totalSurahs == 0 ? 0 : (downloadedCount / totalSurahs).clamp(0.0, 1.0);
  bool get isCompleted => downloadedCount >= totalSurahs && totalSurahs > 0;
}