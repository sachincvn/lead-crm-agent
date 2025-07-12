import 'package:equatable/equatable.dart';
import '../../domain/entities/lead.dart';

abstract class LeadState extends Equatable {
  const LeadState();

  @override
  List<Object?> get props => [];
}

class LeadInitial extends LeadState {
  const LeadInitial();
}

class LeadLoading extends LeadState {
  const LeadLoading();
}

class LeadLoaded extends LeadState {
  final List<Lead> leads;

  const LeadLoaded(this.leads);

  @override
  List<Object?> get props => [leads];
}

class LeadError extends LeadState {
  final String message;

  const LeadError(this.message);

  @override
  List<Object?> get props => [message];
}

class LeadOperationSuccess extends LeadState {
  final String message;
  final List<Lead> leads;

  const LeadOperationSuccess(this.message, this.leads);

  @override
  List<Object?> get props => [message, leads];
}
