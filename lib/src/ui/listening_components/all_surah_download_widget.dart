import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

class AllSurahDownloadWidget extends StatelessWidget {
  final BulkDownloadStatus? bulkStatus;
  final bool isEnabled;
  final Future<void> Function() onDownloadAll;
  final Future<void> Function(String reciterId) onCancel;

  const AllSurahDownloadWidget({
    super.key,
    required this.bulkStatus,
    required this.isEnabled,
    required this.onDownloadAll,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: bulkStatus == null
              ? SizedBox(
                key: const ValueKey('bulk_download_button'),
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isEnabled ? () => _confirmAndDownload(context) : null,
                  icon: const Icon(Icons.cloud_download_rounded),
                  label: Text(context.tr.download_all_surahs),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: context.colorScheme.primaryContainer,
                    foregroundColor: context.colorScheme.onPrimaryContainer,
                  ),
                ),
              )
              : Container(
                key: const ValueKey('bulk_download_progress'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      context.tr.download_all_surahs,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onPrimaryContainer.withValues(
                          alpha: .9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: bulkStatus!.progress,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${bulkStatus!.downloadedCount}/${bulkStatus!.totalSurahs} ${context.tr.surahs}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => onCancel(bulkStatus!.reciterId),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: context.colorScheme.primaryContainer,

                          ),
                          child: Text(context.tr.cancel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Future<void> _confirmAndDownload(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      barrierColor: Colors.black.withValues(alpha: .3),
      context: context,
      builder: (dialogContext) => MawaqitDialog(
            title: '${context.tr.download_all_surahs}${context.isRtl ? "؟" : "?"}',
            content: context.tr.this_will_download_all_surahs_for_offline,
            cancelText: context.tr.cancel,
            okText: context.tr.download,
            onCancelPressed: () {
              Navigator.pop(dialogContext, false);
            },
            onOkPressed: () {
              Navigator.pop(dialogContext, true);
            },
          ),
    );

    if (confirmed == true && context.mounted) {
      await onDownloadAll();
    }
  }
}
