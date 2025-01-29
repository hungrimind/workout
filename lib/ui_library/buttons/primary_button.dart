import 'package:demo/ui_library/mixins/loading_state_mixin.dart';
import 'package:demo/ui_library/theme/neutral_colors.dart';
import 'package:demo/ui_library/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;
  final double? width;
  final EdgeInsets? padding;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.padding,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with LoadingStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, loading, child) {
        return MouseRegion(
          cursor: loading ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: Material(
            borderRadius: BorderRadius.circular(4),
            color: theme.colorScheme.primary,
            child: Stack(
              children: [
                InkWell(
                  onTap: loading ? null : () => withLoading(widget.onPressed),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: widget.width,
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                if (loading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: LoadingIndicator(
                          size: 20,
                          strokeWidth: 2.5,
                          color: Theme.of(context)
                              .extension<NeutralColors>()!
                              .neutral50,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
