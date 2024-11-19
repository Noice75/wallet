import 'package:flutter/material.dart';

class CategorySelectionModal extends StatelessWidget {
  const CategorySelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Choose category',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildCategoryChip(
                    icon: Icons.restaurant,
                    label: 'Food & Drinks',
                    color: const Color(0xFF00D8A5),
                    onTap: () => Navigator.pop(context, 'Food & Drinks'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.receipt,
                    label: 'Bills & Fees',
                    color: Colors.pink,
                    onTap: () => Navigator.pop(context, 'Bills & Fees'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.directions_bus,
                    label: 'Transport',
                    color: Colors.amber,
                    onTap: () => Navigator.pop(context, 'Transport'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.shopping_basket,
                    label: 'Groceries',
                    color: const Color(0xFF00D8A5),
                    onTap: () => Navigator.pop(context, 'Groceries'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.movie,
                    label: 'Entertainment',
                    color: Colors.orange,
                    onTap: () => Navigator.pop(context, 'Entertainment'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.shopping_bag,
                    label: 'Shopping',
                    color: Colors.purple,
                    onTap: () => Navigator.pop(context, 'Shopping'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.card_giftcard,
                    label: 'Gifts',
                    color: Colors.pink[200]!,
                    onTap: () => Navigator.pop(context, 'Gifts'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.favorite,
                    label: 'Health',
                    color: Colors.blue,
                    onTap: () => Navigator.pop(context, 'Health'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.trending_up,
                    label: 'Investments',
                    color: Colors.indigo,
                    onTap: () => Navigator.pop(context, 'Investments'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.account_balance,
                    label: 'Loans',
                    color: Colors.teal,
                    onTap: () => Navigator.pop(context, 'Loans'),
                  ),
                  _buildCategoryChip(
                    icon: Icons.add,
                    label: 'Add new',
                    color: Colors.grey[800]!,
                    onTap: () => Navigator.pop(context, 'Add new'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
