import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/palette_format_service.dart';
import '../../../domain/entities/wallpaper.dart';

enum ExportFormat {
  pywal('Pywal (.Xresources)'),
  css('CSS Variables'),
  json('JSON Palette'),
  hex('Hex CSV');

  final String label;
  const ExportFormat(this.label);
}

/// Modal dialog for inspecting and exporting extracted wallpaper color palettes
/// to popular ricing and styling formats.
class PaletteExportModal extends StatefulWidget {
  final Wallpaper wallpaper;

  const PaletteExportModal({super.key, required this.wallpaper});

  static Future<void> show(BuildContext context, Wallpaper wallpaper) {
    return showDialog(
      context: context,
      builder: (ctx) => PaletteExportModal(wallpaper: wallpaper),
    );
  }

  @override
  State<PaletteExportModal> createState() => _PaletteExportModalState();
}

class _PaletteExportModalState extends State<PaletteExportModal> {
  ExportFormat _selectedFormat = ExportFormat.pywal;
  bool _copied = false;

  String _getFormattedCode() {
    final colors = widget.wallpaper.dominantColors;
    switch (_selectedFormat) {
      case ExportFormat.pywal:
        return PaletteFormatService.toPywal(colors);
      case ExportFormat.css:
        return PaletteFormatService.toCssVariables(colors);
      case ExportFormat.json:
        return PaletteFormatService.toJson(colors);
      case ExportFormat.hex:
        return PaletteFormatService.toHexCsv(colors);
    }
  }

  void _copyToClipboard() async {
    final text = _getFormattedCode();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.wallpaper.dominantColors.isNotEmpty
        ? widget.wallpaper.dominantColors
        : PaletteFormatService.fallbackPalette;

    return Dialog(
      backgroundColor: const Color(0xFF131722),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('🎨', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dynamic Palette Exporter',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.wallpaper.title,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Swatch Row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((c) {
                  final hex =
                      '#${(c.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hex,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Format Selector Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ExportFormat.values.map((fmt) {
                    final isSelected = _selectedFormat == fmt;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(fmt.label),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: const Color(0xFF1E2235),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        onSelected: (_) {
                          setState(() => _selectedFormat = fmt);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Code Output Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090C14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _getFormattedCode(),
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _copied
                          ? AppColors.like
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(_copied ? Icons.check : Icons.copy, size: 16),
                    label: Text(
                      _copied ? 'Copied to Clipboard!' : 'Copy to Clipboard',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
