import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/lead.dart';
import '../../core/enums/lead_enums.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LeadCard({super.key, required this.lead, this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: colorScheme.surface, border: Border.all(color: _getStatusColor().withOpacity(0.2), width: 1)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Status dot
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: _getStatusColor(), borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 12),

                    // Name and phone
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(lead.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)), Text(lead.phone, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant))])),

                    // Status and menu
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(lead.status.value, style: theme.textTheme.labelSmall?.copyWith(color: _getStatusColor(), fontWeight: FontWeight.w600)),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_horiz, color: colorScheme.onSurfaceVariant, size: 16),
                          onSelected: (value) {
                            if (value == 'edit' && onEdit != null) onEdit!();
                            if (value == 'delete' && onDelete != null) onDelete!();
                          },
                          itemBuilder: (context) => [if (onEdit != null) const PopupMenuItem(value: 'edit', child: Text('Edit')), if (onDelete != null) const PopupMenuItem(value: 'delete', child: Text('Delete'))],
                        ),
                      ],
                    ),
                  ],
                ),

                // Additional info (if available)
                if (lead.enquiredFor?.location != null || lead.budget != null || lead.siteVisit?.isScheduled == true || lead.meeting?.isScheduled == true) ...[const SizedBox(height: 12), _buildCompactInfo(context)],

                // Footer
                const SizedBox(height: 8),
                Row(children: [Text(lead.source.value, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)), const Spacer(), if (lead.createdAt != null) Text(DateFormat('MMM dd').format(lead.createdAt!), style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant))]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (lead.status) {
      case LeadStatus.newLead:
        return Colors.blue;
      case LeadStatus.followUp:
        return Colors.orange;
      case LeadStatus.meetingScheduled:
      case LeadStatus.siteVisitScheduled:
        return Colors.purple;
      case LeadStatus.negotiation:
        return Colors.amber;
      case LeadStatus.closed:
        return Colors.green;
      case LeadStatus.notInterested:
      case LeadStatus.dropped:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusIndicatorColor() {
    switch (lead.status) {
      case LeadStatus.newLead:
        return Colors.blue.shade600;
      case LeadStatus.followUp:
        return Colors.orange.shade600;
      case LeadStatus.meetingScheduled:
      case LeadStatus.siteVisitScheduled:
        return Colors.purple.shade600;
      case LeadStatus.negotiation:
        return Colors.amber.shade600;
      case LeadStatus.closed:
        return Colors.green.shade600;
      case LeadStatus.notInterested:
      case LeadStatus.dropped:
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildCompactInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    List<String> info = [];

    // Add location if available
    if (lead.enquiredFor?.location != null) {
      info.add(lead.enquiredFor!.location!);
    }

    // Add budget if available
    if (lead.budget != null) {
      info.add(_getBudgetText());
    }

    // Add scheduled activities
    if (lead.siteVisit?.isScheduled == true) {
      info.add('Site Visit');
    }
    if (lead.meeting?.isScheduled == true) {
      info.add('Meeting');
    }

    return Text(info.join(' • '), style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  String _getBudgetText() {
    if (lead.budget?.min != null && lead.budget?.max != null) {
      return '₹${_formatCurrency(lead.budget!.min!)} - ₹${_formatCurrency(lead.budget!.max!)}';
    } else if (lead.budget?.min != null) {
      return 'Min: ₹${_formatCurrency(lead.budget!.min!)}';
    } else if (lead.budget?.max != null) {
      return 'Max: ₹${_formatCurrency(lead.budget!.max!)}';
    }
    return '';
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
