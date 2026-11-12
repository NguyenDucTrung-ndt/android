import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';

/// Danh sách đi chợ: tick đã mua, vuốt để xóa, thêm tay.
class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(AppState state) {
    state.addManualShopping(_ctrl.text);
    _ctrl.clear();
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(state),
                    decoration: InputDecoration(
                      hintText: s.t('shopping_add_hint'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () => _submit(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
