import 'dart:math';

import 'package:flutter/material.dart';

import 'game_content.dart';

void main() {
  runApp(const ImposterApp());
}

class ImposterApp extends StatelessWidget {
  const ImposterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF10121C);
    const accent = Color(0xFFB8F34A);

    return MaterialApp(
      title: 'Imposter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
        fontFamily: 'sans',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const _ContentLoader(),
    );
  }
}

class _ContentLoader extends StatefulWidget {
  const _ContentLoader();

  @override
  State<_ContentLoader> createState() => _ContentLoaderState();
}

class _ContentLoaderState extends State<_ContentLoader> {
  late final Future<Map<String, GameContent>> _contentFuture;

  @override
  void initState() {
    super.initState();
    _contentFuture = loadGameContent();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, GameContent>>(
      future: _contentFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ContentError(error: snapshot.error!);
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return SetupPage(content: snapshot.data!);
      },
    );
  }
}

class _ContentError extends StatelessWidget {
  const _ContentError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Die Spielinhalte konnten nicht geladen werden.\n\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class SetupPage extends StatefulWidget {
  const SetupPage({super.key, required this.content});

  final Map<String, GameContent> content;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int _playerCount = 5;
  int _imposterCount = 1;
  String _category = 'Alle';
  late final List<TextEditingController> _nameControllers;

  @override
  void initState() {
    super.initState();
    _nameControllers = List.generate(
      12,
      (index) => TextEditingController(text: 'Spieler ${index + 1}'),
    );
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    final names = _nameControllers.take(_playerCount).map((controller) {
      final name = controller.text.trim();
      return name.isEmpty ? 'Spieler' : name;
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameStartedPage(
          playerCount: _playerCount,
          imposterCount: _imposterCount,
          category: _category,
          playerNames: names,
          content: widget.content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/app_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.visibility_off_rounded,
                            color: Color(0xFF10121C),
                            size: 28,
                          );
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    tooltip: 'Einstellungen',
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                'IMPOSTER',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Einer von euch kennt die Wahrheit nicht.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              _SectionTitle(icon: Icons.groups_rounded, title: 'Spieler'),
              const SizedBox(height: 12),
              _ValueCard(
                label: 'Anzahl Spieler',
                value: '$_playerCount',
                child: Slider(
                  value: _playerCount.toDouble(),
                  min: 3,
                  max: 12,
                  divisions: 9,
                  label: '$_playerCount',
                  onChanged: (value) {
                    setState(() => _playerCount = value.round());
                    if (_imposterCount >= _playerCount) {
                      setState(() => _imposterCount = _playerCount - 1);
                    }
                  },
                ),
              ),
              const SizedBox(height: 28),
              _SectionTitle(icon: Icons.badge_outlined, title: 'Namen'),
              const SizedBox(height: 12),
              ...List.generate(
                _playerCount,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _nameControllers[index],
                    textCapitalization: TextCapitalization.words,
                    onTap: () {
                      if (_nameControllers[index].text ==
                          'Spieler ${index + 1}') {
                        _nameControllers[index].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _nameControllers[index].text.length,
                        );
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      labelText: 'Spieler ${index + 1}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _SectionTitle(
                icon: Icons.person_search_rounded,
                title: 'Imposter',
              ),
              const SizedBox(height: 12),
              _ValueCard(
                label: 'Anzahl Imposter',
                value: '$_imposterCount',
                child: Slider(
                  value: _imposterCount.toDouble(),
                  min: 1,
                  max: (_playerCount - 1).toDouble(),
                  divisions: _playerCount - 2,
                  label: '$_imposterCount',
                  onChanged: (value) {
                    setState(() => _imposterCount = value.round());
                  },
                ),
              ),
              const SizedBox(height: 28),
              _SectionTitle(icon: Icons.category_rounded, title: 'Kategorie'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.style_outlined),
                  labelText: 'Wörter aus',
                ),
                items: widget.content.keys
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('SPIEL STARTEN'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: const Color(0xFF10121C),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Pass-and-Play • Keine Anmeldung nötig',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.label,
    required this.value,
    required this.child,
  });

  final String label;
  final String value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class GameStartedPage extends StatelessWidget {
  const GameStartedPage({
    super.key,
    required this.playerCount,
    required this.imposterCount,
    required this.category,
    required this.playerNames,
    required this.content,
  });

  final int playerCount;
  final int imposterCount;
  final String category;
  final List<String> playerNames;
  final Map<String, GameContent> content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neue Runde')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 72),
              const SizedBox(height: 24),
              Text(
                'Bereit für die Runde?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$playerCount Spieler • $imposterCount Imposter • $category',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'Als Nächstes bekommt jeder Spieler nacheinander geheim seine Rolle.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RoleRevealPage(
                        playerCount: playerCount,
                        imposterCount: imposterCount,
                        category: category,
                        playerNames: playerNames,
                        content: content,
                      ),
                    ),
                  );
                },
                child: const Text('ROLLEN VERTEILEN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleRevealPage extends StatefulWidget {
  const RoleRevealPage({
    super.key,
    required this.playerCount,
    required this.imposterCount,
    required this.category,
    required this.playerNames,
    required this.content,
  });

  final int playerCount;
  final int imposterCount;
  final String category;
  final List<String> playerNames;
  final Map<String, GameContent> content;

  @override
  State<RoleRevealPage> createState() => _RoleRevealPageState();
}

class _RoleRevealPageState extends State<RoleRevealPage> {
  late final List<bool> _isImposter;
  late final GameWord _selectedWord;
  int _playerIndex = 0;
  bool _isRoleVisible = false;
  bool _hasRevealedRole = false;

  @override
  void initState() {
    super.initState();
    _isImposter = List<bool>.filled(widget.playerCount, false);
    final random = Random();
    var assigned = 0;
    while (assigned < widget.imposterCount) {
      final index = random.nextInt(widget.playerCount);
      if (!_isImposter[index]) {
        _isImposter[index] = true;
        assigned++;
      }
    }

    final categoryContent = widget.content[widget.category];
    if (categoryContent == null) {
      throw StateError(
        'Keine Inhalte für Kategorie "${widget.category}" gefunden.',
      );
    }
    _selectedWord =
        categoryContent.entries[random.nextInt(categoryContent.entries.length)];
  }

  void _showNextPlayer() {
    if (_playerIndex == widget.playerCount - 1) {
      final random = Random();
      final starter = widget.playerNames[random.nextInt(widget.playerCount)];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => StarterPage(playerName: starter),
        ),
      );
      return;
    }
    setState(() {
      _playerIndex++;
      _isRoleVisible = false;
      _hasRevealedRole = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLastPlayer = _playerIndex == widget.playerCount - 1;
    final isImposter = _isImposter[_playerIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.playerNames[_playerIndex]} '
          '(${_playerIndex + 1} von ${widget.playerCount})',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRoleVisible
                  ? (isImposter
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded)
                  : Icons.lock_outline_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 28),
            Text(
              _isRoleVisible
                  ? (isImposter ? 'DU BIST DER IMPOSTER' : 'DEIN WORT')
                  : widget.playerNames[_playerIndex],
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 150),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isRoleVisible
                    ? Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isRoleVisible
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white24,
                ),
              ),
              child: Center(
                child: Text(
                  _isRoleVisible
                      ? (isImposter
                            ? 'Tipp: „${_selectedWord.tip}“'
                            : _selectedWord.word)
                      : 'Deine Rolle ist verborgen',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _isRoleVisible ? Colors.white : Colors.white70,
                    fontWeight: _isRoleVisible ? FontWeight.w700 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _isRoleVisible = !_isRoleVisible;
                    _hasRevealedRole = true;
                  });
                },
                icon: Icon(
                  _isRoleVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
                label: Text(
                  _isRoleVisible ? 'ROLLE VERBERGEN' : 'ROLLE ANZEIGEN',
                ),
              ),
            ),
            if (_hasRevealedRole) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _showNextPlayer,
                  icon: Icon(
                    isLastPlayer
                        ? Icons.play_arrow_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(isLastPlayer ? 'RUNDE BEGINNEN' : 'WEITERGEBEN'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StarterPage extends StatelessWidget {
  const StarterPage({super.key, required this.playerName});

  final String playerName;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Runde beginnt')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 88, color: accent),
              const SizedBox(height: 28),
              Text(
                'Du fängst an!',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                playerName,
                style: Theme.of(context).textTheme.displaySmall
                    ?.copyWith(color: accent, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Die App hat zufällig bestimmt, wer den ersten Hinweis gibt.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('ZURÜCK ZUM START'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
