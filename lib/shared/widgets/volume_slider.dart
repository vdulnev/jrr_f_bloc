import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class VolumeSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback? onMuteToggle;
  final bool isMuted;

  const VolumeSlider({
    required this.value,
    required this.onChanged,
    this.onMuteToggle,
    this.isMuted = false,
    super.key,
  });

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  bool _dragging = false;

  double _calcValue(Offset localPosition, double width) {
    return (localPosition.dx / width).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // MCWS returns Volume = -1 for sources where software volume is
    // bypassed (DSD bitstream). Hide the control rather than render a
    // misleading 0%.
    if (!widget.value.isFinite || widget.value < 0) {
      return const SizedBox.shrink();
    }

    final color = widget.isMuted ? AppColors.text3 : AppColors.accent;

    return Row(
      children: [
        IconButton(
          onPressed: widget.onMuteToggle,
          icon: Icon(
            widget.isMuted || widget.value == 0
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded,
            size: 20,
            color: widget.isMuted ? AppColors.accent : AppColors.text2,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        Expanded(
          child: GestureDetector(
            onPanStart: (d) {
              setState(() => _dragging = true);
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                widget.onChanged(_calcValue(d.localPosition, box.size.width));
              }
            },
            onPanUpdate: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                widget.onChanged(_calcValue(d.localPosition, box.size.width));
              }
            },
            onPanEnd: (_) => setState(() => _dragging = false),
            onTapDown: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                widget.onChanged(_calcValue(d.localPosition, box.size.width));
              }
            },
            child: SizedBox(
              height: 32,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth.clamp(
                    0.0,
                    double.infinity,
                  );
                  final value = widget.value.isFinite
                      ? widget.value.clamp(0.0, 1.0)
                      : 0.0;
                  final width = maxWidth * value;
                  final knobSize = 16 * (_dragging ? 1.2 : 1.0);
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 14,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.bg4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 14,
                        width: width,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        left: width - knobSize / 2,
                        top: (32 - knobSize) / 2,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: knobSize,
                          height: knobSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.text,
                            border: Border.all(color: AppColors.bg1, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            '${(widget.value * 100).round()}',
            style: AppTextStyles.monoLabel,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
