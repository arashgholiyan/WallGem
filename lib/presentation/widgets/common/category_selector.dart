import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/theme/app_colors.dart';

/// Horizontal category filter chip selector.
class CategorySelector extends StatelessWidget {
  final String activeCategory;
  final ValueChanged<String> onSelectCategory;

  const CategorySelector({
    super.key,
    required this.activeCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: AppKeys.categorySelector,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = AppConstants.categories[index];
          final isSelected = activeCategory == cat;

          return Center(
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: const Color(0xFF1E1B4B),
              backgroundColor: Colors.white.withValues(alpha: 0.03),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFFC7D2FE)
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (val) {
                if (val) {
                  onSelectCategory(cat);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
