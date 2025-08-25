import 'package:flutter/material.dart';
import 'package:joinfy/source/modules/pages/auth/login/login_page.dart';
import '../../../components/map/map.dart';
import 'add_event_modal.dart';
import 'package:joinfy/utils/string_utils.dart';

// Imports Firebase (assumindo que você já tem no projeto)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// HomePage
/// - Fundo: preto (placeholder para o Mapa futuramente)
/// - Topo: botão redondo de Menu (esq.) e Pesquisa (dir.) com ícone laranja #FF5800
/// - Abaixo: "opções deslizantes" pequenas (chips/cards) em uma faixa superior;
///   o restante da tela fica livre para o mapa.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    // Quase colado no topo, mas respeitando o notch/status bar
    final double topBarY = mq.viewPadding.top + 4;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _SideMenu(), // <<-- removido const porque virou StatefulWidget
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const MapBackground(),

          // Camada de UI sobre o mapa
          SafeArea(
            top: false, // não adiciona padding no topo
            child: Stack(
              children: [
                // ===== Botão redondo: MENU (esquerda) =====
                Positioned(
                  left: 16,
                  top: topBarY,
                  child: _RoundIconButton(
                    icon: Icons.menu,
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    tooltip: 'Abrir menu',
                    bgColor: Colors.white,
                    size: 56,
                    iconSize: 28,
                  ),
                ),

                // ===== Botão redondo: PESQUISA (direita) =====
                Positioned(
                  right: 16,
                  top: topBarY,
                  child: _RoundIconButton(
                    icon: Icons.search,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pesquisar…')),
                      );
                    },
                    tooltip: 'Pesquisar',
                    bgColor: Colors.white,
                    size: 56,
                    iconSize: 28,
                  ),
                ),

                // ===== Faixa superior com "opções deslizantes" (chips/cards pequenos) =====
                Positioned(
                  left: 0,
                  right: 0,
                  top: topBarY + 68,
                  child: SizedBox(
                    height: 50,
                    child: _QuickActionsBar(
                      actions: _quickActions,
                      onTap: (item) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Abrir: ${item.label}')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF5800),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _openAddEventModal(context),
        tooltip: 'Adicionar Evento',
      ),
    );
  }
}

void _openAddEventModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AddEventModal(onEventAdded: () {
        Navigator.of(context).pop();
        // Pode adicionar feedback aqui
      }),
    ),
  );
}

/// Botão redondo padrão
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color bgColor;
  final Color iconColor;

  /// diâmetro total do botão (largura = altura)
  final double size;

  /// tamanho do ícone dentro do botão
  final double iconSize;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.bgColor = Colors.white,
    this.iconColor = const Color(0xFFFF5800),
    this.size = 48, // padrão
    this.iconSize = 24, // padrão
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: bgColor,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: child) : child;
  }
}

/// ======================
/// Side Menu (branco) — agora Stateful para carregar nome do banco
/// ======================
class _SideMenu extends StatefulWidget {
  const _SideMenu({
    this.onSelect,
    this.avatarAsset,
    this.notificationsCount = 0,
  });

  final ValueChanged<String>? onSelect;
  final String? avatarAsset;
  final int notificationsCount;

  @override
  State<_SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<_SideMenu> {
  static const Color _brandBlue = Color(0xFF000080);
  static const Color _brandOrange = Color(0xFFFF5800);

  String? _userName; // nome pronto para exibir (primeiro + último)
  bool _loadingName = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String display = 'Usuário';

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (doc.exists) {
          // tenta vários campos comuns: 'nome', 'name', 'fullName'
          final raw = (doc.data()?['nome'] ??
                  doc.data()?['name'] ??
                  doc.data()?['fullName'] ??
                  '')
              .toString()
              .trim();

          if (raw.isNotEmpty) {
            display = formatName(raw); // usa seu util para 1º + último
          } else {
            // fallback: tenta exibir parte local do e-mail
            final email = FirebaseAuth.instance.currentUser?.email ?? '';
            if (email.isNotEmpty) {
              final local = email.split('@').first;
              display = formatName(local.replaceAll('.', ' '));
            }
          }
        }
      }
    } catch (_) {
      // mantém 'Usuário' se der erro
    }

    if (!mounted) return;
    setState(() {
      _userName = display;
      _loadingName = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // 78% da tela, com limites (mín 360, máx 95%)
    final double drawerWidth = (w * 0.78).clamp(360.0, w * 0.95);

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Sem SafeArea: ocupa toda a altura do Drawer, inclusive sob a status bar
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1) Botão Fechar fixo no topo
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: 'Fechar',
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // 2) Conteúdo que deve "descer": avatar, nome, itens e botão Sair
              Expanded(
                child: SingleChildScrollView(
                  // evita overflow em telas menores
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50), // ajuste a altura
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 180,
                          height: 180,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEFEFEF),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget.avatarAsset != null
                              ? Image.asset(
                                  widget.avatarAsset!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Colors.black45,
                                  ),
                                )
                              : const Icon(Icons.person,
                                  size: 48, color: Colors.black45),
                        ),
                        const SizedBox(height: 20),

                        // Nome
                        Text(
                          _loadingName
                              ? 'Carregando...'
                              : (_userName ?? 'Usuário'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _brandBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            fontFamily: 'CodeProLC',
                          ),
                        ),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.only(
                              top: 40, bottom: 70), // Itens
                          child: Column(
                            children: [
                              _MenuTile(
                                icon: Icons.history,
                                label: 'Histórico de Pedidos',
                                onTap: () => _tap(context, 'historico'),
                              ),
                              _MenuTile(
                                icon: Icons.notifications_none_rounded,
                                label: 'Notificações',
                                badge: widget.notificationsCount,
                                badgeColor: _brandOrange,
                                onTap: () => _tap(context, 'notificacoes'),
                              ),
                              _MenuTile(
                                icon: Icons.local_offer_outlined,
                                label: 'Promoções',
                                onTap: () => _tap(context, 'promocoes'),
                              ),
                              _MenuTile(
                                icon: Icons.attach_money,
                                label: 'Indique & Ganhe',
                                onTap: () => _tap(context, 'indique'),
                              ),
                              _MenuTile(
                                icon: Icons.settings_outlined,
                                label: 'Configurações',
                                onTap: () => _tap(context, 'configuracoes'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Empurra o botão "Sair" pro final do scroll
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                                (route) => false, // limpa todo o histórico
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              backgroundColor: _brandOrange,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(20),
                              shape: const StadiumBorder(),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Sair',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: 'CodeProLC',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tap(BuildContext context, String key) {
    Navigator.of(context).pop();
    widget.onSelect?.call(key);
  }
}

/// Item do menu com ícone, label e badge opcional (para Notificações)
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.badge = 0,
    this.badgeColor = const Color(0xFFFF5800),
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Ícone + badge
            SizedBox(
              width: 28,
              height: 28,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.circle, size: 0),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Icon(icon, size: 22, color: Colors.black87),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '$badge',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'CodeProLC', // remova se não usar
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder para o fundo (depois vira o widget do mapa)
class MapBackground extends StatelessWidget {
  const MapBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return const MapaPage();
  }
}

// =============================
// Quick Actions (chips/cards)
// =============================

/// Agora cada ação recebe o caminho do ícone local (asset)
class _QuickActionItem {
  final String assetPath;
  final String label;
  const _QuickActionItem(this.assetPath, this.label);
}

/// Edite os caminhos conforme seus arquivos reais
const List<_QuickActionItem> _quickActions = [
  _QuickActionItem('assets/icons/basketball.png', 'Esportes'),
  _QuickActionItem('assets/icons/music.png', 'Músicas'),
  _QuickActionItem('assets/icons/food.png', 'Comida'),
  _QuickActionItem('assets/icons/food.png', 'Teste'),
  _QuickActionItem('assets/icons/food.png', 'Teste2'),
  _QuickActionItem('assets/icons/food.png', 'Teste3'),
];

class _QuickActionsBar extends StatelessWidget {
  final List<_QuickActionItem> actions;
  final ValueChanged<_QuickActionItem>? onTap;
  const _QuickActionsBar({required this.actions, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: actions.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, i) => _QuickActionCard(
        item: actions[i],
        onTap: () => onTap?.call(actions[i]),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _QuickActionItem item;
  final VoidCallback? onTap;
  const _QuickActionCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 50,
          width: 130,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Image.asset(
                  item.assetPath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8E8E9D),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'CodeProLC',
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
