import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../domain/waitlist_rules.dart';
import '../state/waitlist_controller.dart';

class AddPartySheet extends StatefulWidget {
  const AddPartySheet({super.key});

  @override
  State<AddPartySheet> createState() => _AddPartySheetState();
}

class _AddPartySheetState extends State<AddPartySheet> {
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  bool _showValidation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _showValidation = true);
    if (validateName(_nameController.text) != null ||
        validatePartySizeInput(_sizeController.text) != null) {
      return;
    }

    final controller = context.read<WaitlistController>();
    final party = await controller.addParty(
      name: _nameController.text,
      size: _sizeController.text,
    );
    if (!mounted) {
      return;
    }
    if (party == null) {
      final error = controller.lastError;
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }
    Navigator.of(context).pop(party);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add party', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: _showValidation
                    ? validateName(_nameController.text)
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_showValidation) setState(() {});
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sizeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9\u0660-\u0669]'),
                ),
              ],
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Party size',
                errorText: _showValidation
                    ? validatePartySizeInput(_sizeController.text)
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_showValidation) setState(() {});
              },
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            Consumer<WaitlistController>(
              builder: (context, controller, child) {
                return FilledButton.icon(
                  onPressed: controller.isSaving ? null : _submit,
                  icon: controller.isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: const Text('Add to waitlist'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
