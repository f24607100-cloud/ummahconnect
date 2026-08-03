import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/islamic_ornaments.dart';
import '../domain/models/help_request.dart';
import 'providers/help_provider.dart';

class CreateHelpRequestScreen extends ConsumerStatefulWidget {
  const CreateHelpRequestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateHelpRequestScreen> createState() => _CreateHelpRequestScreenState();
}

class _CreateHelpRequestScreenState extends ConsumerState<CreateHelpRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController(text: 'Makkah');

  HelpCategory _selectedCategory = HelpCategory.food;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(helpNotifierProvider.notifier).createRequest(
      category: _selectedCategory,
      title: _titleController.text,
      description: _descriptionController.text,
      city: _cityController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anonymous help request posted safely. Your identity is hidden.'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Request Anonymous Help'),
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
                        const Icon(Icons.security, color: AppColors.gold, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Strict Privacy Shield: Your name, email, and photo will NEVER be displayed. Nearby volunteers will only see your anonymous request.',
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Help Needed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.gold : AppColors.lightPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        selected: _selectedCategory == HelpCategory.food,
                        label: const Text('Food Assistance'),
                        selectedColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = HelpCategory.food);
                        },
                      ),
                      ChoiceChip(
                        selected: _selectedCategory == HelpCategory.advice,
                        label: const Text('Spiritual / Advice'),
                        selectedColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = HelpCategory.advice);
                        },
                      ),
                      ChoiceChip(
                        selected: _selectedCategory == HelpCategory.emergency,
                        label: const Text('Emergency'),
                        selectedColor: isDark ? AppColors.gold : AppColors.lightPrimary,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = HelpCategory.emergency);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Request Title',
                      hintText: 'e.g. "I need food assistance"',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City / Region',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your city' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Describe how nearby volunteers can assist you...',
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please describe your request' : null,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _submitRequest,
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Post Anonymously'),
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
