import 'package:cloud_firestore/cloud_firestore.dart';

class IdCollection {
  DocumentReference k;
  IdCollection(String id) : k = Firestore.instance.document('id/$id');

  Stream<bool> get hasId => k.snapshots().map((e) => e.exists);

  Future<void> addId() async {
    await k.setData({});
    await Firestore.instance
        .document('count/count')
        .updateData({'count': FieldValue.increment(1)});
  }
}
