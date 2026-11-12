import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';

class RecipeFilterResult {
  const RecipeFilterResult({
    required this.category,
    required this.cuisine,
    required this.difficulty,
    required this.presetIds,
    required this.customIngredients,
  });

  final Category? category;
  final Cuisine? cuisine;
  final Difficulty? difficulty;
  final Set<String> presetIds;
  final Set<String> customIngredients;
}

Future<RecipeFilterResult?> showRecipeFilterSheet({
  required BuildContext context,
  required Category? initialCategory,
  required Cuisine? initialCuisine,
  required Difficulty? initialDifficulty,
  required Set<String> initialPresetIds,
  required Set<String> initialCustom,
}) {
  return showModalBottomSheet<RecipeFilterResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _RecipeFilterSheet(
      initialCategory: initialCategory,
      initialCuisine: initialCuisine,
      initialDifficulty: initialDifficulty,
      initialPresetIds: initialPresetIds,
      initialCustom: initialCustom,
    ),
  );
}

class _RecipeFilterSheet extends StatefulWidget {
  const _RecipeFilterSheet({
    required this.initialCategory,
    required this.initialCuisine,
    required this.initialDifficulty,
    required this.initialPresetIds,
    required this.initialCustom,
  });

  final Category? initialCategory;
  final Cuisine? initialCuisine;
  final Difficulty? initialDifficulty;
  final Set<String> initialPresetIds;
  final Set<String> initialCustom;

  @override
  State<_RecipeFilterSheet> createState() => _RecipeFilterSheetState();
}

class _RecipeFilterSheetState extends State<_RecipeFilterSheet> {
  final TextEditingController _ctrl = TextEditingController();
  late Category? _category = widget.initialCategory;
  late Cuisine? _cuisine = widget.initialCuisine;
  late Difficulty? _difficulty = widget.initialDifficulty;
  late final Set<String> _presetIds = Set<String>.from(widget.initialPresetIds);
  late final Set<String> _custom = Set<String>.from(widget.initialCustom);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addCustom() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      for (final part in text.split(',')) {
        final clean = part.trim();
        if (clean.isNotEmpty) _custom.add(clean);
      }
      _ctrl.clear();
    });
  }

  bool get _hasAny =>
      _category != null ||
      _cuisine != null ||
      _difficulty != null ||
      _presetIds.isNotEmpty ||
      _custom.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s.t('filters_title'),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_hasAny)
                    TextButton(
                      onPressed: () => setState(() {
                        _category = null;
                        _cuisine = null;
                        _difficulty = null;
                        _presetIds.clear();
                        _custom.clear();
                      }),
                      child: Text(s.t('clear_filters')),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addCustom(),
                      decoration: InputDecoration(
                        hintText: s.t('filter_ingredients_hint'),
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _addCustom,
                    child: Text(s.t('add_filter_ingredient')),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_custom.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final item in _custom)
                              InputChip(
                                label: Text(item),
                                onDeleted: () =>
                                    setState(() => _custom.remove(item)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        s.t('filter_cuisine'),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: Text(s.t('cuisine_all')),
                            selected: _cuisine == null,
                            onSelected: (_) => setState(() => _cuisine = null),
                          ),
                          for (final c in Cuisine.values)
                            ChoiceChip(
                              label: Text(s.cuisine(c)),
                              selected: _cuisine == c,
                              onSelected: (_) => setState(
                                () => _cuisine = _cuisine == c ? null : c,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.t('filter_category'),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: Text(s.t('all')),
                            selected: _category == null,
                            onSelected: (_) => setState(() => _category = null),
                          ),
                          for (final cat in Category.values)
                            ChoiceChip(
                              label: Text(s.category(cat)),
                              selected: _category == cat,
                              onSelected: (_) => setState(
                                () =>
                                    _category = _category == cat ? null : cat,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.t('filter_difficulty'),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: Text(s.t('difficulty_all')),
                            selected: _difficulty == null,
                            onSelected: (_) =>
                                setState(() => _difficulty = null),
                          ),
                          for (final d in Difficulty.values)
                            ChoiceChip(
                              label: Text(s.difficulty(d)),
                              selected: _difficulty == d,
                              onSelected: (_) => setState(
                                () => _difficulty = _difficulty == d ? null : d,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.t('filter_ingredients'),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final preset in AppState.ingredientPresets)
                            FilterChip(
                              label: Text(preset.label.get(s.lang)),
                              selected: _presetIds.contains(preset.id),
                              onSelected: (selected) => setState(() {
                                if (selected) {
                                  _presetIds.add(preset.id);
                                } else {
                                  _presetIds.remove(preset.id);
                                }
                              }),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    RecipeFilterResult(
                      category: _category,
                      cuisine: _cuisine,
                      difficulty: _difficulty,
                      presetIds: _presetIds,
                      customIngredients: _custom,
                    ),
                  ),
                  child: Text(s.t('apply')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

