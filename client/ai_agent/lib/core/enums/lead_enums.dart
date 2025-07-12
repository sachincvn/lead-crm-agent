enum LeadStatus {
  newLead('New'),
  followUp('Follow-Up'),
  meetingScheduled('Meeting Scheduled'),
  siteVisitScheduled('Site Visit Scheduled'),
  siteVisited('Site Visited'),
  negotiation('Negotiation'),
  notInterested('Not Interested'),
  dropped('Dropped'),
  closed('Closed');

  const LeadStatus(this.value);
  final String value;

  static LeadStatus fromString(String value) {
    return LeadStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => LeadStatus.newLead,
    );
  }
}

enum LeadSource {
  justDial('JustDial'),
  magicBricks('MagicBricks'),
  acres99('99acres'),
  facebook('Facebook'),
  walkIn('Walk-in'),
  referral('Referral'),
  instagram('Instagram'),
  website('Website'),
  other('Other');

  const LeadSource(this.value);
  final String value;

  static LeadSource fromString(String value) {
    return LeadSource.values.firstWhere(
      (source) => source.value == value,
      orElse: () => LeadSource.other,
    );
  }
}
