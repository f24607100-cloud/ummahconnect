import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import 'providers/scholar_provider.dart';

class AskScholarScreen extends ConsumerStatefulWidget {
  const AskScholarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AskScholarScreen> createState() => _AskScholarScreenState();
}

class _AskScholarScreenState extends ConsumerState<AskScholarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submitQuestion() {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authNotifierProvider).user;
    final authorName = user?.name ?? 'Ummah Member';

    ref.read(scholarNotifierProvider.notifier).askQuestion(
      _titleController.text,
      _bodyController.text,
      authorName,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question submitted to Verified Scholars! You will be notified when answered.'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ask a Verified Scholar'),
      ),
      body: IslamicPatternDecoration(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.gold, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Questions submitted here are reviewed by accredited Islamic Fiqh scholars. Answers are grounded in the Quran and authentic Sunnah.',
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Question Title',
                      hintText: 'e.g. Ruling on missed Rak\'ahs in prayer',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _bodyController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Detailed Question Context',
                      alignLabelWithHint: true,
                      hintText: 'Provide any background context for the scholar to give an accurate answer...',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please describe your question' : null,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _submitQuestion,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Submit Question'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
