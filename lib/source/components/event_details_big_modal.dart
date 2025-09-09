import 'package:flutter/material.dart';

class EventDetailsBigModal extends StatelessWidget {
  final Map<String, dynamic> eventData;
  const EventDetailsBigModal({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    // Exemplo de imagens do projeto (substitua pelos caminhos reais se necessário)
    final List<String> fotos = [
      'assets/images/events_logo.png',
      'assets/images/events_logo.png',
      'assets/images/events_logo.png',
      'assets/images/events_logo.png',
      'assets/images/events_logo.png',
    ];

    // Menu para eventos de comida
    final List<Map<String, dynamic>> menu = [
      {'nome': 'Hambúrguer Especial', 'valor': '25.90'},
      {'nome': 'Pizza Margherita', 'valor': '32.50'},
      {'nome': 'Lasanha Bolonhesa', 'valor': '28.90'},
    ];
    final String pratoPrincipal = 'Hambúrguer Especial';

    // --- UI ---
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Modal grande principal
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // Conteúdo principal com scroll
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(36, 18, 36, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 23),
                          // Título e nota juntos
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  eventData['name'] ?? 'Evento sem nome',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'CodeProLC',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Color.fromARGB(255, 0, 0, 80),
                                      size: 22),
                                  const SizedBox(width: 4),
                                  Text(
                                    (eventData['nota']?.toString() ?? '4.7'),
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 80),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Endereço
                          Row(
                            children: [
                              SizedBox(
                                width: 196,
                                child: Text(
                                  eventData['location'] ??
                                      eventData['endereco'] ??
                                      'Endereço não informado',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Valor
                          Row(
                            children: [
                              const Text(
                                'R\$',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 196,
                                child: Text(
                                  eventData['valor'] != null
                                      ? '${eventData['valor']}'
                                      : 'Valor não informado',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Tipo
                          Row(
                            children: [
                              SizedBox(
                                width: 196,
                                child: Text(
                                  _getEventTypeLabel(eventData['type'] ?? ''),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Galeria de fotos estilo mosaico
                          if (fotos.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: _buildMosaicGallery(fotos),
                            ),
                          if (fotos.isNotEmpty) const SizedBox(height: 18),
                          // Menu/Cardápio para todos os eventos
                          if (menu.isNotEmpty) ...[
                            const Row(
                              children: [
                                Expanded(
                                  child: Text('Menu',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Icon(Icons.list_alt,
                                    color: Colors.black, size: 18),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Comidas favoritas',
                              style: TextStyle(
                                color: Color(0xFF000080),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 17),
                            ...menu.map<Widget>((item) {
                              final isPrincipal =
                                  item['nome'] == pratoPrincipal;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            item['nome'] ?? '',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (isPrincipal) ...[
                                            const SizedBox(width: 4),
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 18),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item['valor'] != null
                                          ? 'R\$ ${item['valor']}'
                                          : '',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Botões fixos na parte inferior
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 68,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(28),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Ligue agora',
                              style: TextStyle(
                                color: Color(0xFF0A1973),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 68,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6600),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Agendar reserva',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bolinha com seta para cima, igual ao modal pequeno (agora por último para ficar por cima)
          Positioned(
            top: -22.5, // metade da altura da bolinha (45/2)
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF0A1973),
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTypeLabel(String type) {
    switch (type) {
      case 'musica':
        return 'Musical';
      case 'comida':
        return 'Gastronômico';
      case 'lazer':
      default:
        return 'Lazer';
    }
  }

  Widget _buildMosaicGallery(List<String> fotos) {
    final int total = fotos.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        // proporção aproximada do layout antigo
        final double leftWidth = totalWidth * 0.65;
        final double rightWidth =
            totalWidth - leftWidth - 15; // 15 é o espaçamento
        return SizedBox(
          height: 157,
          child: Row(
            children: [
              // Imagem grande à esquerda
              SizedBox(
                width: leftWidth,
                height: 157,
                child: _buildImage(fotos[0]),
              ),
              const SizedBox(width: 15),
              // Coluna da direita com 2 imagens pequenas
              SizedBox(
                width: rightWidth,
                child: Column(
                  children: [
                    SizedBox(
                      width: rightWidth,
                      height: 78.5,
                      child: fotos.length > 1
                          ? _buildImage(fotos[1])
                          : const SizedBox(),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: rightWidth,
                      height: 62.8,
                      child: fotos.length > 2
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildImage(fotos[2]),
                                if (total > 3)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.6),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '+${total - 3} imagens',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(String path) {
    final isNetwork = path.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: isNetwork
          ? Image.network(path, fit: BoxFit.cover)
          : Image.asset(path, fit: BoxFit.cover),
    );
  }
}

void showEventDetailsBigModal(
    BuildContext context, Map<String, dynamic> eventData) {
  debugPrint('showEventDetailsBigModal chamado');
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EventDetailsBigModal(eventData: eventData),
  );
}
