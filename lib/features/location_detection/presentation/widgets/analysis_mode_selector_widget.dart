import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget for selecting analysis mode (Quick vs Detailed)
class AnalysisModeSelectorWidget extends StatefulWidget {
  const AnalysisModeSelectorWidget({
    super.key,
    required this.onModeChanged,
    this.initialMode = true, // true = detailed, false = quick
  });

  final Function(bool isDetailed) onModeChanged;
  final bool initialMode;

  @override
  State<AnalysisModeSelectorWidget> createState() =>
      _AnalysisModeSelectorWidgetState();
}

class _AnalysisModeSelectorWidgetState
    extends State<AnalysisModeSelectorWidget> {
  late bool _isDetailedMode;

  @override
  void initState() {
    super.initState();
    _isDetailedMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: AppTheme.primaryBlue,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Analiz Modu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildModeOption(
                  context: context,
                  title: 'Hızlı Analiz',
                  subtitle: 'Daha hızlı, daha ucuz',
                  icon: Icons.flash_on_rounded,
                  isSelected: !_isDetailedMode,
                  onTap: () {
                    setState(() {
                      _isDetailedMode = false;
                    });
                    widget.onModeChanged(false);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildModeOption(
                  context: context,
                  title: 'Detaylı Analiz',
                  subtitle: 'Daha doğru, daha yavaş',
                  icon: Icons.search_rounded,
                  isSelected: _isDetailedMode,
                  onTap: () {
                    setState(() {
                      _isDetailedMode = true;
                    });
                    widget.onModeChanged(true);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _isDetailedMode
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : AppTheme.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  _isDetailedMode ? Icons.info_outline : Icons.speed_rounded,
                  color: _isDetailedMode
                      ? AppTheme.primaryBlue
                      : AppTheme.accentGreen,
                  size: 16.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _isDetailedMode
                        ? 'Detaylı analiz: Yol kesişimleri, mimari özellikler ve çevresel ipuçları detaylı incelenir.'
                        : 'Hızlı analiz: Temel konum bilgileri hızlıca tespit edilir.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _isDetailedMode
                              ? AppTheme.primaryBlue
                              : AppTheme.accentGreen,
                          height: 1.3,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? (_isDetailedMode ? AppTheme.primaryBlue : AppTheme.accentGreen)
                  .withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? (_isDetailedMode
                    ? AppTheme.primaryBlue
                    : AppTheme.accentGreen)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? (_isDetailedMode
                        ? AppTheme.primaryBlue
                        : AppTheme.accentGreen)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 20.w,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? (_isDetailedMode
                            ? AppTheme.primaryBlue
                            : AppTheme.accentGreen)
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
