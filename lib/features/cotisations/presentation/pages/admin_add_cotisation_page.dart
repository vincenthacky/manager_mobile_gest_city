import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/add_cotisation_controller.dart';

class AdminAddCotisationPage extends StatefulWidget {
  const AdminAddCotisationPage({super.key});

  @override
  State<AdminAddCotisationPage> createState() => _AdminAddCotisationPageState();
}

class _AdminAddCotisationPageState extends State<AdminAddCotisationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _montantTotalController = TextEditingController();
  final _montantPersonnelController = TextEditingController();
  final _dateDebutController = TextEditingController();
  final _dateFinController = TextEditingController();

  IconData _selectedIcon = Icons.school;
  Color _selectedColor = const Color(0xFF3B82F6);
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String _periodicity = 'MONTHLY';
  bool _isDefault = false;
  bool _submitting = false;

  final List<Map<String, dynamic>> _iconOptions = [
    {'icon': Icons.school, 'label': 'École'},
    {'icon': Icons.celebration, 'label': 'Festival'},
    {'icon': Icons.group, 'label': 'Communauté'},
    {'icon': Icons.mosque, 'label': 'Mosquée'},
    {'icon': Icons.water_drop, 'label': 'Eau'},
    {'icon': Icons.construction, 'label': 'Construction'},
    {'icon': Icons.health_and_safety, 'label': 'Santé'},
    {'icon': Icons.sports_soccer, 'label': 'Sport'},
  ];

  final List<Color> _colorOptions = [
    const Color(0xFF3B82F6),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF10B981),
    const Color(0xFF06B6D4),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF6366F1),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _montantTotalController.dispose();
    _montantPersonnelController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddCotisationController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF6B7280),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Nouvelle cotisation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          label: 'Titre de la cotisation',
                          hint: 'Ex: Nouvelle école primaire',
                          icon: Icons.title,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le titre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Décrivez le projet...',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _montantTotalController,
                                label: 'Montant total (FCFA)',
                                hint: '100000',
                                icon: Icons.monetization_on,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Montant requis';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _montantPersonnelController,
                                label: 'Montant par personne',
                                hint: '2000',
                                icon: Icons.person,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Montant requis';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _periodicity,
                          items:
                              const [
                                    'DAILY',
                                    'WEEKLY',
                                    'MONTHLY',
                                    'QUARTERLY',
                                    'SEMI-ANNUAL',
                                    'ANNUAL',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) =>
                              setState(() => _periodicity = v ?? 'MONTHLY'),
                          decoration: const InputDecoration(
                            labelText: 'Périodicité',
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                controller: _dateDebutController,
                                label: 'Date de début',
                                selectedDate: _dateDebut,
                                onDateSelected: (date) {
                                  setState(() {
                                    _dateDebut = date;
                                    _dateDebutController.text =
                                        '${date.day}/${date.month}/${date.year}';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDateField(
                                controller: _dateFinController,
                                label: 'Date de fin',
                                selectedDate: _dateFin,
                                onDateSelected: (date) {
                                  setState(() {
                                    _dateFin = date;
                                    _dateFinController.text =
                                        '${date.day}/${date.month}/${date.year}';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Icône du projet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _iconOptions.map((option) {
                            final isSelected = _selectedIcon == option['icon'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIcon = option['icon'];
                                });
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _selectedColor.withValues(alpha: 0.2)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? _selectedColor
                                        : const Color(0xFFE5E7EB),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  option['icon'],
                                  color: isSelected
                                      ? _selectedColor
                                      : const Color(0xFF6B7280),
                                  size: 24,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Couleur du projet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _colorOptions.map((color) {
                            final isSelected = _selectedColor == color;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1F2937)
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Définie par défaut'),
                            Switch(
                              value: _isDefault,
                              onChanged: (v) => setState(() => _isDefault = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<AddCotisationController>(
                  builder: (ctx, c, _) {
                    final isBusy = c.isLoading || _submitting;
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isBusy ? null : () => _createCotisation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F2937),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: isBusy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Créer la cotisation',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  controller.text.isEmpty ? 'Sélectionner' : controller.text,
                  style: TextStyle(
                    color: controller.text.isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF1F2937),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createCotisation(BuildContext context) async {
    final controller = context.read<AddCotisationController>();

    if (!_formKey.currentState!.validate()) return;

    if (_dateDebut == null || _dateFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les dates de début et de fin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_dateFin!.isBefore(_dateDebut!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(
      _montantTotalController.text.replaceAll(' ', '').replaceAll(',', '.'),
    );
    final amountBy = double.tryParse(
      _montantPersonnelController.text.replaceAll(' ', '').replaceAll(',', '.'),
    );

    if (amount == null || amountBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer des montants valides'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final payload = {
      'name': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'amount': amount,
      'amount_by': amountBy,
      'periodicity': _periodicity,
      'begin_date': _dateDebut!.toIso8601String(),
      'end_date': _dateFin!.toIso8601String(),
      'is_default': _isDefault,
    };

    try {
      if (mounted) setState(() => _submitting = true);
      await controller.createContribution(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cotisation créée avec succès !'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        // Use GoRouter to navigate to the cotisations page
        context.go('/cotisations');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
