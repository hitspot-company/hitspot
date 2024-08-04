enum HSAnnouncementType {
  appUpdate,
  newFeature,
  event,
  maintenance,
  securityAlert,
  survey,
  policyChange,
  holidayNotice,
  other,
  serviceDisruption;

  static HSAnnouncementType deserialize(String text) {
    switch (text) {
      case 'app_update':
        return HSAnnouncementType.appUpdate;
      case 'new_feature':
        return HSAnnouncementType.newFeature;
      case 'event':
        return HSAnnouncementType.event;
      case 'maintenance':
        return HSAnnouncementType.maintenance;
      case 'security_alert':
        return HSAnnouncementType.securityAlert;
      case 'survey':
        return HSAnnouncementType.survey;
      case 'policy_change':
        return HSAnnouncementType.policyChange;
      case 'holiday_notice':
        return HSAnnouncementType.holidayNotice;
      case 'service_disruption':
        return HSAnnouncementType.serviceDisruption;
      default:
        return HSAnnouncementType.other;
    }
  }

  String get serialize {
    switch (this) {
      case HSAnnouncementType.appUpdate:
        return 'app_update';
      case HSAnnouncementType.newFeature:
        return 'new_feature';
      case HSAnnouncementType.event:
        return 'event';
      case HSAnnouncementType.maintenance:
        return 'maintenance';
      case HSAnnouncementType.securityAlert:
        return 'security_alert';
      case HSAnnouncementType.survey:
        return 'survey';
      case HSAnnouncementType.policyChange:
        return 'policy_change';
      case HSAnnouncementType.holidayNotice:
        return 'holiday_notice';
      case HSAnnouncementType.serviceDisruption:
        return 'service_disruption';
      default:
        return 'other';
    }
  }

  String get name {
    switch (this) {
      case HSAnnouncementType.appUpdate:
        return 'Application Update';
      case HSAnnouncementType.newFeature:
        return 'New Feature';
      case HSAnnouncementType.event:
        return 'Upcoming Event';
      case HSAnnouncementType.maintenance:
        return 'Maintenance';
      case HSAnnouncementType.securityAlert:
        return 'Security Alert';
      case HSAnnouncementType.survey:
        return 'Survey';
      case HSAnnouncementType.policyChange:
        return 'Policy Change';
      case HSAnnouncementType.holidayNotice:
        return 'Holiday Notice';
      case HSAnnouncementType.serviceDisruption:
        return 'Service Disruption';
      default:
        return 'Other';
    }
  }
}

class HSAnnouncement {
  final String? id;
  final String? title;
  final String? content;
  final HSAnnouncementType? announcementType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final bool? isActive;
  final String? ctaText;
  final String? ctaLink;

  HSAnnouncement({
    this.id,
    this.title,
    this.content,
    this.announcementType,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.expiresAt,
    this.isActive,
    this.ctaText,
    this.ctaLink,
  });

  factory HSAnnouncement.deserialize(Map<String, dynamic> json) {
    return HSAnnouncement(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      announcementType:
          HSAnnouncementType.deserialize(json['announcement_type']),
      createdAt: DateTime.tryParse(json['created_at']),
      publishedAt: DateTime.tryParse(json['published_at']),
      expiresAt: DateTime.tryParse(json['expires_at']),
      isActive: json['is_active'],
      ctaText: json['cta_text'],
      ctaLink: json['cta_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'announcement_type': announcementType?.serialize,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
      'cta_text': ctaText,
      'cta_link': ctaLink,
    };
  }
}
