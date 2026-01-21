import 'package:flutter/material.dart';
import 'package:green_chain_v1/features/disposer/disposer_orders_model.dart';

import '../../../ui/green_theme.dart';

/// Result of splitting the requested weight into size/type inventory entries.
class ProcessAllocation {
  const ProcessAllocation({
    required this.size,
    required this.type,
    required this.weight,
  });

  final String size;
  final String type;
  final double weight;
}

/// Show the "Process request" dialog and return the confirmed allocations.
///
/// Returns:
/// - `List<ProcessAllocation>` if user taps Save
/// - `null` if user cancels
Future<List<ProcessAllocation>?> showProcessRequestDialog({
  required BuildContext context,
  required MarketItem item,
  required double requestedWeight,
}) {
  return showDialog<List<ProcessAllocation>>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) =>
        _ProcessRequestDialog(item: item, requestedWeight: requestedWeight),
  );
}

class _ProcessRequestDialog extends StatefulWidget {
  const _ProcessRequestDialog({
    required this.item,
    required this.requestedWeight,
  });

  final MarketItem item;
  final double requestedWeight;

  @override
  State<_ProcessRequestDialog> createState() => _ProcessRequestDialogState();
}

class _ProcessRequestDialogState extends State<_ProcessRequestDialog> {
  final List<_RowModel> _rows = [];
  final List<String> _typeOptions = ['Organic', 'Non-organic'];
  final List<String> _sizeOptions = ['Big', 'Small'];

  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Start with one row prefilled with full request
    _rows.add(
      _RowModel(
        size: _sizeOptions.first,
        type: _typeOptions.first,
        controller: TextEditingController(
          text: widget.requestedWeight.toStringAsFixed(2),
        ),
      ),
    );
  }

  double _currentTotal() {
    double sum = 0;
    for (final r in _rows) {
      final v = double.tryParse(r.controller.text.trim());
      if (v != null && v > 0) sum += v;
    }
    return sum;
  }

  void _handleSave() {
    double total = 0;
    final List<ProcessAllocation> splits = [];

    for (final r in _rows) {
      final text = r.controller.text.trim();
      if (text.isEmpty) continue;

      final v = double.tryParse(text);
      if (v == null || v <= 0) {
        setState(() {
          _errorText = 'Each row must have a valid positive kg.';
        });
        return;
      }
      total += v;
      splits.add(ProcessAllocation(size: r.size, type: r.type, weight: v));
    }

    if (splits.isEmpty) {
      setState(() {
        _errorText = 'Please enter at least one allocation.';
      });
      return;
    }

    if ((total - widget.requestedWeight).abs() > 0.0001) {
      setState(() {
        _errorText =
            'Total allocated ($total kg) must equal requested ${widget.requestedWeight.toStringAsFixed(2)} kg.';
      });
      return;
    }

    Navigator.of(context).pop<List<ProcessAllocation>>(splits);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the *available* height inside the dialog (after keyboard/insets)
        final maxHeight = constraints.maxHeight * 0.9;

        return AlertDialog(
          backgroundColor: GreenTheme.softBg,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Process request',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: GreenTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested: ${widget.requestedWeight.toStringAsFixed(2)} kg',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Split the requested weight into stall inventory entries:',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  // All rows
                  ...List.generate(_rows.length, (index) {
                    final r = _rows[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Row 1: Size + Type
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: r.size,
                                  decoration: const InputDecoration(
                                    labelText: 'Size',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: _sizeOptions
                                      .map(
                                        (s) => DropdownMenuItem<String>(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      r.size = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: r.type,
                                  decoration: const InputDecoration(
                                    labelText: 'Type',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: _typeOptions
                                      .map(
                                        (t) => DropdownMenuItem<String>(
                                          value: t,
                                          child: Text(t),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      r.type = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 2: Weight + optional delete
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: r.controller,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'kg',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              if (_rows.length > 1) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      _rows.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  // Add row button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _rows.add(
                            _RowModel(
                              size: _sizeOptions.first,
                              type: _typeOptions.first,
                              controller: TextEditingController(),
                            ),
                          );
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add another split'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total allocated: ${_currentTotal().toStringAsFixed(2)} / ${widget.requestedWeight.toStringAsFixed(2)} kg',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          _currentTotal().toStringAsFixed(2) ==
                              widget.requestedWeight.toStringAsFixed(2)
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorText!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop<List<ProcessAllocation>?>(null),
              child: const Text('Cancel'),
            ),
            TextButton(onPressed: _handleSave, child: const Text('Save')),
          ],
        );
      },
    );
  }
}

class _RowModel {
  _RowModel({required this.size, required this.type, required this.controller});

  String size;
  String type;
  TextEditingController controller;
}
