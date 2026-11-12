import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../l10n/strings.dart';

/// Chế độ nấu: hiển thị từng bước (PageView) và đồng hồ hẹn giờ đếm ngược.
class CookingModeScreen extends StatefulWidget {
  const CookingModeScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  final PageController _pageCtrl = PageController();
  int _index = 0;

  Timer? _timer;
  int _totalSeconds = 300;
  int _remaining = 300;

  bool get _running => _timer?.isActive ?? false;

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  void _adjust(int deltaMinutes) {
    if (_running) return;
    setState(() {
      _totalSeconds = (_totalSeconds + deltaMinutes * 60).clamp(60, 7200).toInt();
      _remaining = _totalSeconds;
    });
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() {});
      return;
    }
    if (_remaining <= 0) _remaining = _totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        setState(() => _remaining = 0);
        _onTimerDone();
      } else {
        setState(() => _remaining--);
      }
    });
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() => _remaining = _totalSeconds);
  }

  void _onTimerDone() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    final s = S.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s.t('timer_done'))));
  }

  Future<void> _finish() async {
    final s = S.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Text('🎉', style: TextStyle(fontSize: 40)),
        title: Text(s.t('cooking_done_title')),
        content: Text(s.t('cooking_done_body')),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.t('close')),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final recipe = state.byId(widget.recipeId);
    if (recipe == null) return const Scaffold();

    final steps = recipe.steps;
    final isLast = _index == steps.length - 1;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${s.t('cooking_mode')} - ${recipe.name.get(s.lang)}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_index + 1) / steps.length),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                s.f('step_of', [_index + 1, steps.length]),
                style: theme.textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: steps.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                steps[i].get(s.lang),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                margin: EdgeInsets.zero,
                color: theme.colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(s.t('timer'), style: theme.textTheme.labelLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _running ? null : () => _adjust(-1),
                          ),
                          Text(
                            _format(_remaining),
                            style: theme.textTheme.displaySmall,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _running ? null : () => _adjust(1),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                            label: Text(
                                _running ? s.t('pause') : s.t('start')),
                            onPressed: _toggleTimer,
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.replay),
                            label: Text(s.t('reset')),
                            onPressed: _resetTimer,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: Text(s.t('prev')),
                      onPressed: _index == 0
                          ? null
                          : () => _pageCtrl.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                      label: Text(isLast ? s.t('finish') : s.t('next')),
                      onPressed: isLast
                          ? _finish
                          : () => _pageCtrl.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
