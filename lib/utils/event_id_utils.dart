import 'package:cloud_firestore/cloud_firestore.dart';

/// Função utilitária para adicionar IDs aos eventos existentes que não possuem
Future<void> addMissingEventIds() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final eventsCollection = firestore.collection('events');

    // Buscar todos os eventos
    final snapshot = await eventsCollection.get();

    List<Future<void>> updates = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Verificar se o evento já tem ID
      if (data['id'] == null || data['id'] != doc.id) {
        // Adicionar ou corrigir o ID
        updates.add(doc.reference.update({'id': doc.id}));
        print(
            'Adicionando ID ${doc.id} ao evento: ${data['name'] ?? 'Sem nome'}');
      }
    }

    // Executar todas as atualizações
    await Future.wait(updates);

    print('Concluído! ${updates.length} eventos foram atualizados com IDs.');
  } catch (e) {
    print('Erro ao adicionar IDs aos eventos: $e');
  }
}

/// Função para validar que todos os eventos têm IDs
Future<void> validateEventIds() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final eventsCollection = firestore.collection('events');

    final snapshot = await eventsCollection.get();

    int validCount = 0;
    int invalidCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final hasValidId = data['id'] != null && data['id'] == doc.id;

      if (hasValidId) {
        validCount++;
      } else {
        invalidCount++;
        print(
            'Evento sem ID válido: ${doc.id} - ${data['name'] ?? 'Sem nome'}');
      }
    }

    print('Validação completa:');
    print('- Eventos com ID válido: $validCount');
    print('- Eventos sem ID válido: $invalidCount');
    print('- Total de eventos: ${snapshot.docs.length}');
  } catch (e) {
    print('Erro na validação: $e');
  }
}
