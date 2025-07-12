import 'package:equatable/equatable.dart';
import '../../domain/entities/lead.dart';

abstract class LeadEvent extends Equatable {
  const LeadEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeads extends LeadEvent {
  const LoadLeads();
}

class CreateLead extends LeadEvent {
  final Lead lead;

  const CreateLead(this.lead);

  @override
  List<Object?> get props => [lead];
}

class UpdateLead extends LeadEvent {
  final String id;
  final Lead lead;

  const UpdateLead(this.id, this.lead);

  @override
  List<Object?> get props => [id, lead];
}

class DeleteLead extends LeadEvent {
  final String id;

  const DeleteLead(this.id);

  @override
  List<Object?> get props => [id];
}

class RefreshLeads extends LeadEvent {
  const RefreshLeads();
}
