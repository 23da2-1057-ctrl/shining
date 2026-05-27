import 'package:flutter/material.dart';
import 'package:shining/models/cart_item_model.dart';
import 'package:shining/theme/app_theme.dart';
import 'package:shining/utils/constants.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel cartItem;
  final VoidCallback onRemove;
  final Function(int) onQuantityChange;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onRemove,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(kPaddingM),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(kRadiusS),
              ),
              child: Icon(
                Icons.shopping_bag,
                color: kPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartItem.selectedColor} - ${cartItem.selectedSize}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${cartItem.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: kPrimary,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (cartItem.quantity > 1) {
                          onQuantityChange(cartItem.quantity - 1);
                        }
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(color: kTextSecondary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.remove, size: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${cartItem.quantity}'),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        onQuantityChange(cartItem.quantity + 1);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(color: kPrimary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onRemove,
                  child: Text(
                    'Remove',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kError,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
