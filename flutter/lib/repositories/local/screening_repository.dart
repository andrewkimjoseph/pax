// lib/repositories/screenings/screenings_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pax/models/firestore/screening/screening_model.dart';

class ScreeningsRepository {
  final FirebaseFirestore _firestore;

  // Collection reference for screenings
  late final CollectionReference _screeningsCollection;

  // Constructor
  ScreeningsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _screeningsCollection = _firestore.collection('screenings');
  }

  Stream<Screening?> getScreeningByParticipantAndTask(
    String participantId,
    String taskId,
  ) {
    return _screeningsCollection
        .where('participantId', isEqualTo: participantId)
        .where('taskId', isEqualTo: taskId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }
          return Screening.fromFirestore(snapshot.docs.first);
        });
  }
}
