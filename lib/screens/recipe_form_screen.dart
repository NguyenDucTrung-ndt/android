import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';

/// Một dòng nhập nguyên liệu (3 ô nhập).
class _IngredientRow {
  _IngredientRow({String name = '', String amount = '', String unit = ''})
      : name = TextEditingController(text: name),
        amount = TextEditingController(text: amount),
        unit = TextEditingController(text: unit);

  final TextEditingController name;
  final TextEditingController amount;
  final TextEditingController unit;

  void dispose() {
    name.dispose();
    amount.dispose();
    unit.dispose();
  }
}

/// Biểu mẫu thêm mới hoặc sửa công thức (có kiểm tra dữ liệu nhập).
class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key, this.recipe});

  /// null: thêm mới; khác null: chỉnh sửa công thức này.
  final Recipe? recipe;

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  static const List<String> _emojiChoices = [
    '🍲', '🍜', '🥗', '🍛', '🍰', '🥤', '🍳', '🥘', '🍚', '🥞', '🍤', '🍮',
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final List<_IngredientRow> _ingredients = [];
  final List<TextEditingController> _steps = [];

  String _emoji = '🍲';
  Category _category = Category.main;
  Difficulty _difficulty = Difficulty.easy;
  double _minutes = 30;
  int _servings = 2;
  bool _initialized = false;

  bool get _isEdit => widget.recipe != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final lang = AppScope.of(context).lang;
    final r = widget.recipe;
    if (r == null) {
      _ingredients.add(_IngredientRow());
      _steps.add(TextEditingController());
      return;
    }
    _name.text = r.name.get(lang);
    _desc.text = r.description.get(lang);
    _emoji = r.emoji;
    _category = r.category;
    _difficulty = r.difficulty;
    _minutes = r.minutes.toDouble().clamp(5, 240).toDouble();
    _servings = r.servings;
    for (final i in r.ingredients) {
      _ingredients.add(_IngredientRow(
        name: i.name.get(lang),
        amount: formatAmount(i.amount),
        unit: i.unit.get(lang),
      ));
    }
    for (final st in r.steps) {
      _steps.add(TextEditingController(text: st.get(lang)));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    for (final r in _ingredients) {
      r.dispose();
    }
    for (final c in _steps) {
      c.dispose();
    }
    super.dispose();
  }

  void _removeIngredient(int index) {
    final row = _ingredients[index];
    setState(() => _ingredients.removeAt(index));
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  void _removeStep(int index) {
    final c = _steps[index];
    setState(() => _steps.removeAt(index));
    WidgetsBinding.instance.addPostFrameCallback((_) => c.dispose());
  }

  double? _parseAmount(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _save() {
    final s = S.of(context);
    final state = AppScope.of(context);
    if (!_formKey.currentState!.validate()) return;

    final filledIngredients =
        _ingredients.where((r) => r.name.text.trim().isNotEmpty).toList();
    final filledSteps =
        _steps.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (filledIngredients.isEmpty) {
      _showError(s.t('err_need_ingredient'));
      return;
    }
    if (filledSteps.isEmpty) {
      _showError(s.t('err_need_step'));
      return;
    }

    final recipe = Recipe(
      id: widget.recipe?.id ?? state.newId(),
      name: Bi.same(_name.text.trim()),
      description: Bi.same(_desc.text.trim()),
      emoji: _emoji,
      category: _category,
      difficulty: _difficulty,
      minutes: _minutes.round(),
      servings: _servings,
      ingredients: [
        for (final r in filledIngredients)
          Ingredient(
            Bi.same(r.name.text.trim()),
            _parseAmount(r.amount.text) ?? 1,
            Bi.same(r.unit.text.trim()),
          ),
      ],
      steps: [for (final t in filledSteps) Bi.same(t)],
      isFavorite: widget.recipe?.isFavorite ?? false,
      isCustom: true,
    );

    if (_isEdit) {
      state.updateRecipe(recipe);
    } else {
      state.addRecipe(recipe);
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(s.t('saved'))));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? s.t('edit_recipe') : s.t('new_recipe')),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(s.t('save')),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.t('field_name'),
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? s.t('err_required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _desc,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: s.t('field_desc'),
                border: const OutlineInputBorder(),
              ),
            ),
            SectionTitle(s.t('field_emoji')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in _emojiChoices)
                  ChoiceChip(
                    label: Text(e, style: const TextStyle(fontSize: 22)),
                    selected: _emoji == e,
                    onSelected: (_) => setState(() => _emoji = e),
                  ),
              ],
            ),
            SectionTitle(s.t('field_category')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in Category.values)
                  ChoiceChip(
                    label: Text(s.category(c)),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            SectionTitle(s.t('field_difficulty')),
            SegmentedButton<Difficulty>(
              segments: [
                for (final d in Difficulty.values)
                  ButtonSegment(value: d, label: Text(s.difficulty(d))),
              ],
              selected: {_difficulty},
              onSelectionChanged: (set) =>
                  setState(() => _difficulty = set.first),
            ),
            SectionTitle(s.f('field_time', [_minutes.round()])),
            Slider(
              value: _minutes,
              min: 5,
              max: 240,
              divisions: 47,
              label: '${_minutes.round()}',
              onChanged: (v) => setState(() => _minutes = v),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(s.t('field_servings'),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _servings > 1
                      ? () => setState(() => _servings--)
                      : null,
                ),
                Text('$_servings', style: theme.textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _servings < 20
                      ? () => setState(() => _servings++)
                      : null,
                ),
              ],
            ),
            SectionTitle(s.t('ingredients')),
            for (var i = 0; i < _ingredients.length; i++)
              Padding(
                key: ObjectKey(_ingredients[i]),
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _ingredients[i].name,
                        decoration: InputDecoration(
                          labelText: s.t('ingredient_name'),
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _ingredients[i].amount,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: s.t('amount'),
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final n = _parseAmount(v);
                          return (n == null || n <= 0)
                              ? s.t('err_number')
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _ingredients[i].unit,
                        decoration: InputDecoration(
                          labelText: s.t('unit'),
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _ingredients.length > 1
                          ? () => _removeIngredient(i)
                          : null,
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: Text(s.t('add_ingredient')),
                onPressed: () =>
                    setState(() => _ingredients.add(_IngredientRow())),
              ),
            ),
            SectionTitle(s.t('steps')),
            for (var i = 0; i < _steps.length; i++)
              Padding(
                key: ObjectKey(_steps[i]),
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, right: 8),
                      child: CircleAvatar(
                        radius: 14,
                        child: Text('${i + 1}',
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _steps[i],
                        minLines: 2,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: s.t('step_hint'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed:
                          _steps.length > 1 ? () => _removeStep(i) : null,
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: Text(s.t('add_step')),
                onPressed: () =>
                    setState(() => _steps.add(TextEditingController())),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(s.t('save')),
            ),
          ],
        ),
      ),
    );
  }
}
