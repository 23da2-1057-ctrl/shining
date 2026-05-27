import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shining/data/app_data.dart';

/// Uploads AppData.products to Firestore ONLY if the products collection
/// is empty. Safe to call on every app start — skips automatically after
/// first run.
Future<void> migrateProductsToFirestore() async {
  final db = FirebaseFirestore.instance;

  // Check if products already exist — skip if they do
  final existing = await db.collection('products').limit(1).get();
  if (existing.docs.isNotEmpty) {
    debugPrint('Migration skipped — products already in Firestore.');
    // Patch any stale via.placeholder.com URLs left from a previous upload
    await _patchStaleImageUrls(db);
    return;
  }

  final batch = db.batch();

  for (final product in AppData.products) {
    final ref = db.collection('products').doc(product.id);
    batch.set(ref, product.toMap());
    debugPrint('Queuing product: ${product.name} (${product.id})');
  }

  await batch.commit();
  debugPrint('Migration complete — ${AppData.products.length} products uploaded.');
}

/// Patches imageUrls that still point to the defunct via.placeholder.com service.
/// Runs once per product that needs updating; subsequent calls are no-ops.
Future<void> _patchStaleImageUrls(FirebaseFirestore db) async {
  // Build a lookup map: productId -> correct imageUrl from local data
  final urlMap = {for (final p in AppData.products) p.id: p.imageUrl};

  final snapshot = await db.collection('products').get();
  final batch = db.batch();
  int patched = 0;

  for (final doc in snapshot.docs) {
    final currentUrl = (doc.data()['imageUrl'] as String?) ?? '';
    final correctUrl = urlMap[doc.id] ?? '';
    // Patch any URL that is stale, empty, or simply doesn't match the correct one
    if (correctUrl.isNotEmpty && currentUrl != correctUrl) {
      batch.update(doc.reference, {'imageUrl': correctUrl});
      patched++;
    }
  }

  if (patched > 0) {
    await batch.commit();
    debugPrint('Image URL patch complete — $patched product(s) updated.');
  } else {
    debugPrint('Image URL patch skipped — all URLs already up to date.');
  }
}
