import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitspot/constants/constants.dart';
import 'package:hs_database_repository/hs_database_repository.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HSAnnouncementDetailDialog extends StatelessWidget {
  final HSAnnouncement announcement;

  const HSAnnouncementDetailDialog({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement.title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appTheme.mainColor,
                    ),
              ),
              const SizedBox(height: 24),
              _buildInfoRow(
                  'Type', announcement.announcementType!.name, context),
              _buildInfoRow(
                  'Created', _formatDate(announcement.createdAt!), context),
              const SizedBox(height: 24),
              Text(
                'Message',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appTheme.mainColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(announcement.content!),
              if (announcement.ctaText != null &&
                  announcement.ctaLink != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: screenWidth,
                  child: CupertinoButton(
                    onPressed: () => _launchURL(announcement.ctaLink!),
                    color: appTheme.mainColor,
                    child: Text(announcement.ctaText!),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy HH:mm').format(date);
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not launch $url');
    }
  }
}
