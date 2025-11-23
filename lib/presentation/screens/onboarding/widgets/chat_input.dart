import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

class ChatInput extends StatefulWidget {
  final bool enabled;
  final Function(String) onSend;

  const ChatInput({
    super.key,
    this.enabled = true,
    required this.onSend,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get _canSend => _controller.text.trim().isNotEmpty && widget.enabled;

  void _handleSend() {
    if (!_canSend) return;

    final message = _controller.text.trim();
    _controller.clear();
    widget.onSend(message);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 텍스트 입력
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: AppStrings.messagePlaceholder,
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm + 4,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSizes.sm),

          // 전송 버튼
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              onPressed: _canSend ? _handleSend : null,
              icon: Icon(
                Icons.send_rounded,
                color: _canSend ? AppColors.primary : AppColors.textHint,
              ),
              style: IconButton.styleFrom(
                backgroundColor:
                    _canSend ? AppColors.primary.withOpacity(0.1) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
