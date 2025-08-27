import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/text_styles.dart';
import 'models/event_model.dart';
import 'widgets/event_card.dart';
import 'widgets/filter_chips.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  EventCategory _selected = EventCategory.all;

  // Mock inicial
  late List<EventModel> _all;
  late List<EventModel> _visible;

  @override
  void initState() {
    super.initState();
    _all = [
      EventModel(
        id: '1',
        title: 'Na praia Brasília 2025',
        category: EventCategory.music,
        subtitle: 'Evento musical',
        imageAsset: 'assets/images/events_logo.png',
      ),
      EventModel(
        id: '2',
        title: 'Recanto Wine',
        category: EventCategory.gastronomy,
        subtitle: 'Evento gastronômico',
        imageAsset: 'assets/images/events_logo.png',
      ),
      EventModel(
        id: '3',
        title: 'Corrida Bob Esponja',
        category: EventCategory.sports,
        subtitle: 'Evento esportivo',
        imageAsset: 'assets/images/events_logo.png',
      ),
      // Adicione mais mocks… eles aparecerão via scroll
      EventModel(
        id: '4',
        title: 'Festival Cidade Viva',
        category: EventCategory.music,
        subtitle: 'Show e food trucks',
        imageAsset: 'assets/images/events_logo.png',
      ),
      EventModel(
        id: '5',
        title: 'Copa Bairro Sul',
        category: EventCategory.sports,
        subtitle: 'Torneio comunitário',
        imageAsset: 'assets/images/events_logo.png',
      ),
    ];
    _visible = List.from(_all);

    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _applyFilters);
  }

  void _applyFilters() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _visible = _all.where((e) {
        final matchesCat =
            _selected == EventCategory.all || e.category == _selected;
        final matchesText = q.isEmpty ||
            e.title.toLowerCase().contains(q) ||
            e.subtitle.toLowerCase().contains(q);
        return matchesCat && matchesText;
      }).toList();
    });
  }

  void _onChangeCategory(EventCategory cat) {
    if (_selected == cat) return; // single-select
    setState(() => _selected = cat);
    _applyFilters();
  }

  void _toggleFollow(EventModel e) {
    setState(() => e.isFollowing = !e.isFollowing);
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF5800);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pushNamed(context, '/home_page'),
            icon: Image.asset('assets/icons/arrow.png', width: 24, height: 24),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: null, // sem função por agora
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                disabledBackgroundColor: orange,
                textStyle: const TextStyle(
                  fontFamily: 'CodeProLC',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + subtítulo (fixos)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prévia dos eventos',
                    style: AppTextStyles.headingLC.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final max = constraints.maxWidth * 0.8;
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: max),
                        child: Text(
                          'Seja o primeiro a saber dos grandes eventos da sua área.',
                          style: AppTextStyles.bodyLC.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF6A6A6A),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Busca (fixo)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: _SearchField(
                controller: _searchCtrl,
                onClear: () {
                  _searchCtrl.clear();
                  _applyFilters();
                },
              ),
            ),

            const SizedBox(height: 12),

            // Chips (fixos)
            EventsFilterChips(
              selected: _selected,
              onChanged: _onChangeCategory,
            ),

            const SizedBox(height: 16),

            // "Recomendações" (fixo)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Recomendações',
                style: AppTextStyles.headingLC.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Lista rolável de eventos (apenas aqui tem scroll)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                physics: const BouncingScrollPhysics(),
                itemCount: _visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final e = _visible[index];
                  return EventCard(
                    event: e,
                    onTap: () {
                      // placeholder de navegação
                      // Navigator.pushNamed(context, '/event-details', arguments: e);
                    },
                    onToggleFollow: () => _toggleFollow(e),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Pesquisar',
            hintStyle: const TextStyle(
              fontFamily: 'CodeProLC',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFB0B0B0),
            ),
            filled: true,
            fillColor: const Color(0xFFF3F3F4),
            prefixIcon:
                const Icon(Icons.search_rounded, color: Color(0xFF8E8E93)),
            suffixIcon: hasText
                ? IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF8E8E93)),
                    tooltip: 'Limpar',
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            // bordas (mesmo radius em todos os estados)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(69),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(69),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(69),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'CodeProLC',
            fontSize: 14,
            color: Color(0xFF8E8E9D),
          ),
        );
      },
    );
  }
}
