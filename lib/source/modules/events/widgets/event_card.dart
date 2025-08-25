import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onToggleFollow;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF5800);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Thumbnail (agora suporta SVG e imagens comuns)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _ThumbImage(event.imageAsset),
            ),
            const SizedBox(width: 12),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'CodeProLC',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'CodeProLC',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF6A6A6A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Botão Seguir/Seguindo
            SizedBox(
              height: 35,
              child: OutlinedButton(
                onPressed: onToggleFollow,
                style: OutlinedButton.styleFrom(
                  backgroundColor: event.isFollowing ? Colors.white : orange,
                  side: BorderSide(
                    color: event.isFollowing ? orange : Colors.transparent,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  event.isFollowing ? 'Seguindo' : 'Seguir',
                  style: TextStyle(
                    fontFamily: 'CodeProLC',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: event.isFollowing ? orange : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget auxiliar para suportar SVG e PNG/JPG
class _ThumbImage extends StatelessWidget {
  final String path;
  const _ThumbImage(this.path);

  @override
  Widget build(BuildContext context) {
    final isSvg = path.toLowerCase().endsWith('.svg');

    return isSvg
        ? SvgPicture.asset(
            path,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          )
        : Image.asset(
            path,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          );
  }
}
