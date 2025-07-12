import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';
import '../datasources/lead_api_service.dart';

class LeadRepositoryImpl implements LeadRepository {
  final LeadApiService _apiService;

  LeadRepositoryImpl(this._apiService);

  @override
  Future<List<Lead>> getLeads() async {
    try {
      return await _apiService.getLeads();
    } catch (e) {
      throw Exception('Failed to fetch leads: $e');
    }
  }

  @override
  Future<Lead> createLead(Lead lead) async {
    try {
      return await _apiService.createLead(lead);
    } catch (e) {
      throw Exception('Failed to create lead: $e');
    }
  }

  @override
  Future<Lead> updateLead(String id, Lead lead) async {
    try {
      return await _apiService.updateLead(id, lead);
    } catch (e) {
      throw Exception('Failed to update lead: $e');
    }
  }

  @override
  Future<void> deleteLead(String id) async {
    try {
      await _apiService.deleteLead(id);
    } catch (e) {
      throw Exception('Failed to delete lead: $e');
    }
  }
}
