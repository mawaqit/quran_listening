class QueuedDownloadRequest {
  final String reciterId;
  final String chapterId;
  final String url;
  final String downloadCompletedMsg;
  final String downloadFailedMsg;

  const QueuedDownloadRequest({
    required this.reciterId,
    required this.chapterId,
    required this.url,
    required this.downloadCompletedMsg,
    required this.downloadFailedMsg,
  });

  String get downloadKey => '${reciterId}_$chapterId';
}