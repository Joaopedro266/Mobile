import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/planet.dart';

class FirestoreService {
  final CollectionReference planetsCollection =
      FirebaseFirestore.instance.collection('planets');

  Future<void> savePlanet(Planet planet) async {
    if (planet.id == null) {
      await planetsCollection.add(planet.toMap());
    } else {
      await planetsCollection.doc(planet.id).update(planet.toMap());
    }
  }

  Stream<List<Planet>> getPlanetsStream() {
    return planetsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Planet.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> deletePlanet(String id) async {
    await planetsCollection.doc(id).delete();
  }
}
