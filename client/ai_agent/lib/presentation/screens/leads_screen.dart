import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/improved_lead_card.dart';
import 'chat_screen.dart';
import '../../core/enums/lead_enums.dart';
import '../../core/di/injection.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  LeadStatus? _selectedStatusFilter;
  LeadSource? _selectedSourceFilter;

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
      appBar: AppBar(
        title: Text('Leads', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (_selectedStatusFilter != null || _selectedSourceFilter != null)
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedStatusFilter = null;
                  _selectedSourceFilter = null;
                });
              },
              icon: Icon(Icons.clear_all_rounded, color: colorScheme.primary),
              tooltip: 'Clear Filters',
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.tune_rounded, color: colorScheme.onSurfaceVariant),
            tooltip: 'Filter',
            onSelected: _handleFilterSelection,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'status', child: Row(children: [Icon(Icons.label_outline_rounded, size: 20), SizedBox(width: 12), Text('Filter by Status')])),
                  const PopupMenuItem(value: 'source', child: Row(children: [Icon(Icons.source_rounded, size: 20), SizedBox(width: 12), Text('Filter by Source')])),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedStatusFilter != null || _selectedSourceFilter != null) _buildActiveFilters(),
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

                  final filteredLeads = _filterLeads(leads);

                  if (filteredLeads.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<LeadBloc>().add(const RefreshLeads());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filteredLeads.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final lead = filteredLeads[index];
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

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedStatusFilter != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('Status: ${_selectedStatusFilter!.value}'),
                selected: true,
                onSelected: (bool value) {},
                onDeleted: () {
                  setState(() {
                    _selectedStatusFilter = null;
                  });
                },
                deleteIcon: const Icon(Icons.close, size: 16),
              ),
            ),
          if (_selectedSourceFilter != null)
            FilterChip(
              label: Text('Source: ${_selectedSourceFilter!.value}'),
              selected: true,
              onSelected: (bool value) {},
              onDeleted: () {
                setState(() {
                  _selectedSourceFilter = null;
                });
              },
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant), const SizedBox(height: 16), Text('No leads found', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 8), Text('Add your first lead to get started', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))]));
  }

  Widget _buildErrorState(String message) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error), const SizedBox(height: 16), Text('Error', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 8), Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: () => context.read<LeadBloc>().add(const LoadLeads()), child: const Text('Retry'))]));
  }

  List<dynamic> _filterLeads(List<dynamic> leads) {
    return leads.where((lead) {
      // Status filter
      if (_selectedStatusFilter != null && lead.status != _selectedStatusFilter) {
        return false;
      }

      // Source filter
      if (_selectedSourceFilter != null && lead.source != _selectedSourceFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  void _handleFilterSelection(String value) {
    switch (value) {
      case 'status':
        _showStatusFilterDialog();
        break;
      case 'source':
        _showSourceFilterDialog();
        break;
    }
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter by Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  LeadStatus.values.map((status) {
                    return RadioListTile<LeadStatus>(
                      title: Text(status.value),
                      value: status,
                      groupValue: _selectedStatusFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatusFilter = value;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showSourceFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter by Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  LeadSource.values.map((source) {
                    return RadioListTile<LeadSource>(
                      title: Text(source.value),
                      value: source,
                      groupValue: _selectedSourceFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedSourceFilter = value;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
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
