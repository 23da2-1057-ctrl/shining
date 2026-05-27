import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shining/data/app_data.dart';

/// Uploads AppData.products to Firestore ONLY if the products collection
/// is empty. Safe to call on every app start — skips automatically after
/// first run.
Future<void> migrateProductsToFirestore() async {
  final db = FirebaseFirestore.instance;

  // Check if products already exist — skip if they do
  final existing = await db.collection('products').limit(1).get();
  if (existing.docs.isNotEmpty) {
    print('Migration skipped — products already in Firestore.');
    return;
  }

  final batch = db.batch();

  for (final product in AppData.products) {
    final ref = db.collection('products').doc(product.id);
    batch.set(ref, product.toMap());
    print('Queuing product: ${product.name} (${product.id})');
  }

  await batch.commit();
  print('Migration complete — ${AppData.products.length} products uploaded.');
}
