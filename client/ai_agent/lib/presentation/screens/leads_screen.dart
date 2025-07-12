import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/improved_lead_card.dart';
import 'chat_screen.dart';
import '../../core/di/injection.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeadBloc>().add(const LoadLeads());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Lead Management', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)), backgroundColor: colorScheme.surface, elevation: 0, scrolledUnderElevation: 0),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<LeadBloc, LeadState>(
              listener: (context, state) {
                if (state is LeadError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: colorScheme.error));
                } else if (state is LeadOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: colorScheme.primary));
                }
              },
              builder: (context, state) {
                if (state is LeadLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LeadLoaded || state is LeadOperationSuccess) {
                  final leads = state is LeadLoaded ? state.leads : (state as LeadOperationSuccess).leads;

                  if (leads.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<LeadBloc>().add(const RefreshLeads());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: leads.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return LeadCard(lead: lead, onTap: () => _showLeadDetails(lead), onEdit: () => _editLead(lead), onDelete: () => _deleteLead(lead));
                      },
                    ),
                  );
                } else if (state is LeadError) {
                  return _buildErrorState(state.message);
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _openChatAssistant, icon: const Icon(Icons.smart_toy_rounded), label: const Text('AI Assistant'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant), const SizedBox(height: 16), Text('No leads found', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 8), Text('Add your first lead to get started', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))]));
  }

  Widget _buildErrorState(String message) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error), const SizedBox(height: 16), Text('Error', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 8), Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: () => context.read<LeadBloc>().add(const LoadLeads()), child: const Text('Retry'))]));
  }

  void _showLeadDetails(dynamic lead) {
    // TODO: Navigate to lead details screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Show details for ${lead.name}')));
  }

  void _editLead(dynamic lead) {
    // TODO: Navigate to edit lead screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit ${lead.name}')));
  }

  void _deleteLead(dynamic lead) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Lead'),
            content: Text('Are you sure you want to delete ${lead.name}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (lead.id != null) {
                    context.read<LeadBloc>().add(DeleteLead(lead.id!));
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _openChatAssistant() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => BlocProvider(create: (context) => getIt<ChatBloc>(), child: const ChatScreen()), fullscreenDialog: true));

    // Refresh leads when returning from chat
    if (mounted) {
      context.read<LeadBloc>().add(const RefreshLeads());
    }
  }
}
