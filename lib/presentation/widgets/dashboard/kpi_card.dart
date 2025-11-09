import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// KPI Card Widget
///
/// Reusable card widget for displaying dashboard KPI metrics
class KpiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String? subtitle;

  const KpiCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Adapter les tailles selon la taille de l'écran
    final iconContainerSize = isSmallScreen ? 40.0 : 48.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 11.0 : 13.0;
    final valueFontSize = isSmallScreen ? 20.0 : 24.0;
    final subtitleFontSize = isSmallScreen ? 9.0 : 11.0;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Icon
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
              ),

              SizedBox(height: spacing),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Value
              Text(
                value,
                style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Spacer pour pousser le subtitle vers le bas
              const Spacer(),

              // Subtitle (optional)
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
        ),
      ),
    );
  }
}
