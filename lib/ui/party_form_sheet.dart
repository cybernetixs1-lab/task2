import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../domain/waitlist_rules.dart';
import '../models/party.dart';
import '../state/waitlist_controller.dart';

final _digitsOnly = FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩]'));

Future<void> showAddPartySheet(BuildContext context) async {
  final ticket = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const PartyFormSheet(),
  );
  if (ticket == null) return;
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Tell the party their ticket'),
      content: Text(
        '#$ticket',
        textAlign: TextAlign.center,
        style: Theme.of(dialogContext).textTheme.displayMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> showEditPartySheet(BuildContext context, Party party) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => PartyFormSheet(party: party),
  );
}

class PartyFormSheet extends StatefulWidget {
  const PartyFormSheet({super.key, this.party});

  final Party? party;

  @override
  State<PartyFormSheet> createState() => _PartyFormSheetState();
}

class _PartyFormSheetState extends State<PartyFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sizeController;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.party?.name);
    _sizeController = TextEditingController(
      text: widget.party?.size.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<WaitlistController>();
    final editing = widget.party;
    setState(() => _saveError = null);
    try {
      final name = _nameController.text;
      final size = parsePartySize(_sizeController.text);
      if (editing == null) {
        final ticket = await controller.addParty(name: name, size: size);
        if (ticket == null) return;
        if (!mounted) return;
        Navigator.pop(context, ticket);
      } else {
        final saved = await controller.editParty(
          editing.copyWith(name: name, size: size),
        );
        if (!saved) return;
        if (!mounted) return;
        Navigator.pop(context);
      }
    } on Exception {
      if (!mounted) return;
      setState(() => _saveError = "Couldn't save the party. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.select<WaitlistController, bool>((c) => c.isBusy);
    final saveError = _saveError;
    final party = widget.party;
    final title = party == null ? 'Add party' : 'Edit #${party.ticket}';
    final actionLabel = party == null ? 'Add to waitlist' : 'Save changes';
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardHeight),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  errorMessageOf(() => validateName(value ?? '')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(labelText: 'Party size'),
              keyboardType: TextInputType.number,
              inputFormatters: [_digitsOnly],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (value) =>
                  errorMessageOf(() => parsePartySize(value ?? '')),
            ),
            if (saveError != null) ...[
              const SizedBox(height: 12),
              Text(
                saveError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isBusy ? null : _submit,
              child: Text(isBusy ? 'Saving…' : actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
