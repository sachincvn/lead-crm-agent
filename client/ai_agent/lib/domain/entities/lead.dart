import 'package:json_annotation/json_annotation.dart';
import '../../core/enums/lead_enums.dart';

part 'lead.g.dart';

@JsonSerializable()
class Lead {
  @JsonKey(name: '_id')
  final String? id;
  final String name;
  final String phone;
  final String? email;
  @JsonKey(fromJson: _leadSourceFromJson, toJson: _leadSourceToJson)
  final LeadSource source;
  final EnquiredFor? enquiredFor;
  final Budget? budget;
  final SiteVisit? siteVisit;
  final Meeting? meeting;
  @JsonKey(fromJson: _leadStatusFromJson, toJson: _leadStatusToJson)
  final LeadStatus status;
  final String? notes;
  final String? assignedTo;
  final String? leadRating;
  final DateTime? nextFollowUpDate;
  final DateTime? lastFollowUpDate;
  final DateTime? createdAt;

  const Lead({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.source,
    this.enquiredFor,
    this.budget,
    this.siteVisit,
    this.meeting,
    this.status = LeadStatus.newLead,
    this.notes,
    this.assignedTo,
    this.leadRating,
    this.nextFollowUpDate,
    this.lastFollowUpDate,
    this.createdAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);
  Map<String, dynamic> toJson() => _$LeadToJson(this);

  Lead copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    LeadSource? source,
    EnquiredFor? enquiredFor,
    Budget? budget,
    SiteVisit? siteVisit,
    Meeting? meeting,
    LeadStatus? status,
    String? notes,
    String? assignedTo,
    String? leadRating,
    DateTime? nextFollowUpDate,
    DateTime? lastFollowUpDate,
    DateTime? createdAt,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      source: source ?? this.source,
      enquiredFor: enquiredFor ?? this.enquiredFor,
      budget: budget ?? this.budget,
      siteVisit: siteVisit ?? this.siteVisit,
      meeting: meeting ?? this.meeting,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      assignedTo: assignedTo ?? this.assignedTo,
      leadRating: leadRating ?? this.leadRating,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      lastFollowUpDate: lastFollowUpDate ?? this.lastFollowUpDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static LeadSource _leadSourceFromJson(String value) => LeadSource.fromString(value);
  static String _leadSourceToJson(LeadSource source) => source.value;
  
  static LeadStatus _leadStatusFromJson(String value) => LeadStatus.fromString(value);
  static String _leadStatusToJson(LeadStatus status) => status.value;
}

@JsonSerializable()
class EnquiredFor {
  final String? propertyType;
  final String? location;
  final String? project;
  final String? possession;
  final String? furnishing;

  const EnquiredFor({
    this.propertyType,
    this.location,
    this.project,
    this.possession,
    this.furnishing,
  });

  factory EnquiredFor.fromJson(Map<String, dynamic> json) => _$EnquiredForFromJson(json);
  Map<String, dynamic> toJson() => _$EnquiredForToJson(this);
}

@JsonSerializable()
class Budget {
  final double? min;
  final double? max;

  const Budget({
    this.min,
    this.max,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}

@JsonSerializable()
class SiteVisit {
  final bool isScheduled;
  final DateTime? date;
  final String? location;

  const SiteVisit({
    this.isScheduled = false,
    this.date,
    this.location,
  });

  factory SiteVisit.fromJson(Map<String, dynamic> json) => _$SiteVisitFromJson(json);
  Map<String, dynamic> toJson() => _$SiteVisitToJson(this);
}

@JsonSerializable()
class Meeting {
  final bool isScheduled;
  final DateTime? date;
  final String? mode;

  const Meeting({
    this.isScheduled = false,
    this.date,
    this.mode,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) => _$MeetingFromJson(json);
  Map<String, dynamic> toJson() => _$MeetingToJson(this);
}
