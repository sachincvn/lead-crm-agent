import '../entities/lead.dart';

abstract class LeadRepository {
  Future<List<Lead>> getLeads();
  Future<Lead> createLead(Lead lead);
  Future<Lead> updateLead(String id, Lead lead);
  Future<void> deleteLead(String id);
}
