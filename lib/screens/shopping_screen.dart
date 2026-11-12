import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';

/// Danh sách đi chợ: tick đã mua, vuốt để xóa, thêm tay kèm định lượng.
class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  static const List<Bi> _unitPresets = [
    Bi('quả', 'pcs'),
    Bi('cái', 'pcs'),
    Bi('g', 'g'),
    Bi('kg', 'kg'),
    Bi('ml', 'ml'),
    Bi('lít', 'L'),
    Bi('củ', 'pc'),
    Bi('bó', 'bunch'),
    Bi('hộp', 'box'),
    Bi('gói', 'pack'),
    Bi('chai', 'bottle'),
    Bi('muỗng canh', 'tbsp'),
    Bi('muỗng cà phê', 'tsp'),
  ];

  final TextEditingController _ctrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _unitCtrl = TextEditingController();
  Bi? _selectedPresetUnit;

  @override
  void dispose() {
    _ctrl.dispose();
    _amountCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _submit(AppState state, String lang) {
    if (_ctrl.text.trim().isEmpty) return;
    final rawUnit = _unitCtrl.text.trim();
    final Bi? unit;
    if (_selectedPresetUnit != null &&
        _selectedPresetUnit!.get(lang) == rawUnit) {
      unit = _selectedPresetUnit;
    } else if (rawUnit.isNotEmpty) {
      unit = Bi.same(rawUnit);
    } else {
      unit = null;
    }

    state.addManualShopping(
      _ctrl.text,
      amount: _amountCtrl.text,
      unit: unit,
    );
    _ctrl.clear();
    _amountCtrl.clear();
    _unitCtrl.clear();
    _selectedPresetUnit = null;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final items = state.shopping;
    final done = items.where((i) => i.checked).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('shopping_title')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'checked') state.clearCheckedShopping();
              if (v == 'all') state.clearAllShopping();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'checked', child: Text(s.t('clear_checked'))),
              PopupMenuItem(value: 'all', child: Text(s.t('clear_all'))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.f('shopping_progress', [done, items.length])),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: done / items.length),
                ],
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.shopping_basket_outlined,
                    message: s.t('shopping_empty'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Dismissible(
                        key: ValueKey('shop_${item.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => state.removeShopping(item.id),
                        child: CheckboxListTile(
                          value: item.checked,
                          onChanged: (_) => state.toggleShopping(item.id),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            item.name.get(s.lang),
                            style: TextStyle(
                              decoration: item.checked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: item.quantity.get(s.lang).isEmpty
                              ? null
                              : Text(item.quantity.get(s.lang)),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(state, s.lang),
                        decoration: InputDecoration(
                          hintText: s.t('shopping_add_hint'),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.add),
                      onPressed: () => _submit(state, s.lang),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 104,
                      child: TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _submit(state, s.lang),
                        decoration: InputDecoration(
                          hintText: s.t('shopping_amount_hint'),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _unitCtrl,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => _selectedPresetUnit = null,
                        onSubmitted: (_) => _submit(state, s.lang),
                        decoration: InputDecoration(
                          hintText: s.t('shopping_unit_hint'),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                          suffixIcon: PopupMenuButton<Bi>(
                            tooltip: s.t('unit'),
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (unit) {
                              setState(() {
                                _selectedPresetUnit = unit;
                                _unitCtrl.text = unit.get(s.lang);
                              });
                            },
                            itemBuilder: (_) => [
                              for (final unit in _unitPresets)
                                PopupMenuItem<Bi>(
                                  value: unit,
                                  child: Text(unit.get(s.lang)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
