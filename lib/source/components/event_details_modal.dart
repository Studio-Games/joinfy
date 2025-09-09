import 'package:flutter/material.dart';
import 'event_details_big_modal.dart';

class EventDetailsModal extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailsModal({
    super.key,
    required this.eventData,
  });

  @override
  State<EventDetailsModal> createState() => _EventDetailsModalState();
}

class _EventDetailsModalState extends State<EventDetailsModal> {
  String _getEventTypeLabel(String type) {
    switch (type) {
      case 'musica':
        return 'Evento Musical';
      case 'comida':
        return 'Evento Gastronômico';
      case 'lazer':
      default:
        return 'Evento de Lazer';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('EventDetailsModal build chamado');
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Modal principal
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            debugPrint(
                'onVerticalDragUpdate chamado: delta.dy = \\${details.delta.dy}');
            if (details.delta.dy < -3) {
              debugPrint('Arrasto para cima detectado, abrindo modal grande');
              showEventDetailsBigModal(context, widget.eventData);
            }
          },
          onTap: () {
            debugPrint('onTap chamado: abrindo modal grande');
            showEventDetailsBigModal(context, widget.eventData);
          },
          onTapDown: (details) {
            debugPrint('onTapDown chamado');
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                      height: 20), // espaço para a bolinha sobreposta
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            //titulo do evento
                            widget.eventData['name'] ?? 'Evento sem nome',
                            style: const TextStyle(
                              fontFamily: 'CodeProLC',
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 26, color: Colors.black54),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Fechar',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Conteúdo básico (sempre visível)
                  _buildBasicInfo(),
                  const SizedBox(height: 20), // Margem inferior
                ],
              ),
            ),
          ),
        ),
        // Bolinha com seta para cima, sobreposta ao topo da modal (depois do modal para garantir que fique por cima)
        Positioned(
          // metade da altura da bolinha
          top: 8,
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
                    Icons.keyboard_arrow_up,
                    color: Color(0xFF0A1973),
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Coluna esquerda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nota e estrelas
                Row(
                  children: [
                    const Text(
                      '4.7',
                      style: TextStyle(
                        fontFamily: 'CodeProLC',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 22, 22, 22),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      children: List.generate(
                          5,
                          (i) => Icon(
                                i < 4 ? Icons.star : Icons.star_half,
                                size: 18,
                                color: Colors.black,
                              )),
                    ),
                  ],
                ),
                // Tipo do evento
                Text(
                  _getEventTypeLabel(widget.eventData['type'] ?? 'lazer'),
                  style: const TextStyle(
                    fontFamily: 'CodeProLC',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                // Status e horário
                Row(
                  children: [
                    Text(
                      'Aberto',
                      style: TextStyle(
                        fontFamily: 'CodeProLC',
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('•',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(width: 6),
                    const Text(
                      'Fecha às 22:00',
                      style: TextStyle(
                        fontFamily: 'CodeProLC',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Botão "Ir agora"
                SizedBox(
                  width: 110,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.navigation,
                        size: 19, color: Colors.white),
                    label: const Text(
                      'Ir agora',
                      style: TextStyle(
                        fontFamily: 'CodeProLC',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF5800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          // Coluna direita: imagem quadrada com bordas arredondadas alinhada com a parte debaixo do botão
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 150,
              height: 110,
              color: Colors.grey[200],
              child: widget.eventData['imageUrl'] != null
                  ? Image.network(
                      widget.eventData['imageUrl'],
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/events_logo.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Função helper para mostrar o modal
void showEventDetailsModal(
    BuildContext context, Map<String, dynamic> eventData) {
  debugPrint('showEventDetailsModal chamado');
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EventDetailsModal(eventData: eventData),
  );
}
