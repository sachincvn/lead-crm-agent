import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/lead_repository.dart';
import 'lead_event.dart';
import 'lead_state.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final LeadRepository _repository;

  LeadBloc(this._repository) : super(const LeadInitial()) {
    on<LoadLeads>(_onLoadLeads);
    on<CreateLead>(_onCreateLead);
    on<UpdateLead>(_onUpdateLead);
    on<DeleteLead>(_onDeleteLead);
    on<RefreshLeads>(_onRefreshLeads);
  }

  Future<void> _onLoadLeads(LoadLeads event, Emitter<LeadState> emit) async {
    emit(const LeadLoading());
    try {
      final leads = await _repository.getLeads();
      emit(LeadLoaded(leads));
    } catch (e) {
      emit(LeadError('Failed to load leads: ${e.toString()}'));
    }
  }

  Future<void> _onCreateLead(CreateLead event, Emitter<LeadState> emit) async {
    try {
      await _repository.createLead(event.lead);
      final leads = await _repository.getLeads();
      emit(LeadOperationSuccess('Lead created successfully', leads));
    } catch (e) {
      emit(LeadError('Failed to create lead: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateLead(UpdateLead event, Emitter<LeadState> emit) async {
    try {
      await _repository.updateLead(event.id, event.lead);
      final leads = await _repository.getLeads();
      emit(LeadOperationSuccess('Lead updated successfully', leads));
    } catch (e) {
      emit(LeadError('Failed to update lead: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteLead(DeleteLead event, Emitter<LeadState> emit) async {
    try {
      await _repository.deleteLead(event.id);
      final leads = await _repository.getLeads();
      emit(LeadOperationSuccess('Lead deleted successfully', leads));
    } catch (e) {
      emit(LeadError('Failed to delete lead: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshLeads(RefreshLeads event, Emitter<LeadState> emit) async {
    try {
      final leads = await _repository.getLeads();
      emit(LeadLoaded(leads));
    } catch (e) {
      emit(LeadError('Failed to refresh leads: ${e.toString()}'));
    }
  }
}
