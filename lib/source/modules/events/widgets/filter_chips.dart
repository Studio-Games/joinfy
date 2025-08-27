import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventsFilterChips extends StatelessWidget {
  final EventCategory selected;
  final ValueChanged<EventCategory> onChanged;

  const EventsFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = EventCategory.values; // [all, music, sports, gastronomy]
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        children: [
          for (final cat in items) ...[
            _ChipItem(
              label: categoryLabel(cat),
              selected: selected == cat,
              onTap: () => onChanged(cat),
              icon: _iconForCategory(cat),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  IconData _iconForCategory(EventCategory cat) {
    switch (cat) {
      case EventCategory.all:
        return Icons.event; // “Todos eventos”
      case EventCategory.music:
        return Icons.music_note;
      case EventCategory.sports:
        return Icons.sports_soccer;
      case EventCategory.gastronomy:
        return Icons.restaurant_menu;
    }
  }
}

class _ChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;

  const _ChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF5800);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? orange.withOpacity(0.12) : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? orange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? orange : const Color(0xFF8E8E93),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'CodeProLC',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF3A3A3C),
              ).copyWith(
                color: selected ? orange : const Color(0xFF3A3A3C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
