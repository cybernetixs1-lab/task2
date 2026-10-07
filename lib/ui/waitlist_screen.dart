import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/waitlist_rules.dart';
import '../models/party.dart';
import '../state/waitlist_controller.dart';
import 'add_party_sheet.dart';

class WaitlistScreen extends StatelessWidget {
  const WaitlistScreen({super.key});

  Future<void> _addParty(BuildContext context) async {
    final party = await showModalBottomSheet<Party>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddPartySheet(),
    );
    if (!context.mounted || party == null) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ticket #${party.ticket}'),
        content: const Text('Tell the party their ticket number.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeParty(
    BuildContext context,
    WaitlistController controller,
    int ticket,
  ) async {
    final removed = await controller.removeParty(ticket);
    if (!context.mounted || removed) {
      return;
    }
    final error = controller.lastError;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waitlist')),
      body: Consumer<WaitlistController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.loadError != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.loadError!),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: controller.load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (controller.entries.isEmpty) {
            return const Center(child: Text('No parties waiting'));
          }
          return ListView.builder(
            itemCount: controller.entries.length,
            itemBuilder: (context, index) {
              final entry = controller.entries[index];
              final party = entry.party;
              return ListTile(
                key: ValueKey(party.ticket),
                leading: CircleAvatar(child: Text('#${party.ticket}')),
                title: Text(
                  party.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${party.size} ${party.size == 1 ? 'person' : 'people'} - '
                  '${partiesAheadLabel(entry.partiesAhead)}',
                ),
                trailing: IconButton(
                  tooltip: 'Remove party',
                  onPressed: () =>
                      _removeParty(context, controller, party.ticket),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addParty(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add party'),
      ),
    );
  }
}
