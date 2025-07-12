// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lead _$LeadFromJson(Map<String, dynamic> json) => Lead(
      id: json['_id'] as String?,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      source: Lead._leadSourceFromJson(json['source'] as String),
      enquiredFor: json['enquiredFor'] == null
          ? null
          : EnquiredFor.fromJson(json['enquiredFor'] as Map<String, dynamic>),
      budget: json['budget'] == null
          ? null
          : Budget.fromJson(json['budget'] as Map<String, dynamic>),
      siteVisit: json['siteVisit'] == null
          ? null
          : SiteVisit.fromJson(json['siteVisit'] as Map<String, dynamic>),
      meeting: json['meeting'] == null
          ? null
          : Meeting.fromJson(json['meeting'] as Map<String, dynamic>),
      status: json['status'] == null
          ? LeadStatus.newLead
          : Lead._leadStatusFromJson(json['status'] as String),
      notes: json['notes'] as String?,
      assignedTo: json['assignedTo'] as String?,
      leadRating: json['leadRating'] as String?,
      nextFollowUpDate: json['nextFollowUpDate'] == null
          ? null
          : DateTime.parse(json['nextFollowUpDate'] as String),
      lastFollowUpDate: json['lastFollowUpDate'] == null
          ? null
          : DateTime.parse(json['lastFollowUpDate'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LeadToJson(Lead instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'source': Lead._leadSourceToJson(instance.source),
      'enquiredFor': instance.enquiredFor,
      'budget': instance.budget,
      'siteVisit': instance.siteVisit,
      'meeting': instance.meeting,
      'status': Lead._leadStatusToJson(instance.status),
      'notes': instance.notes,
      'assignedTo': instance.assignedTo,
      'leadRating': instance.leadRating,
      'nextFollowUpDate': instance.nextFollowUpDate?.toIso8601String(),
      'lastFollowUpDate': instance.lastFollowUpDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

EnquiredFor _$EnquiredForFromJson(Map<String, dynamic> json) => EnquiredFor(
      propertyType: json['propertyType'] as String?,
      location: json['location'] as String?,
      project: json['project'] as String?,
      possession: json['possession'] as String?,
      furnishing: json['furnishing'] as String?,
    );

Map<String, dynamic> _$EnquiredForToJson(EnquiredFor instance) =>
    <String, dynamic>{
      'propertyType': instance.propertyType,
      'location': instance.location,
      'project': instance.project,
      'possession': instance.possession,
      'furnishing': instance.furnishing,
    };

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };

SiteVisit _$SiteVisitFromJson(Map<String, dynamic> json) => SiteVisit(
      isScheduled: json['isScheduled'] as bool? ?? false,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      location: json['location'] as String?,
    );

Map<String, dynamic> _$SiteVisitToJson(SiteVisit instance) => <String, dynamic>{
      'isScheduled': instance.isScheduled,
      'date': instance.date?.toIso8601String(),
      'location': instance.location,
    };

Meeting _$MeetingFromJson(Map<String, dynamic> json) => Meeting(
      isScheduled: json['isScheduled'] as bool? ?? false,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      mode: json['mode'] as String?,
    );

Map<String, dynamic> _$MeetingToJson(Meeting instance) => <String, dynamic>{
      'isScheduled': instance.isScheduled,
      'date': instance.date?.toIso8601String(),
      'mode': instance.mode,
    };
