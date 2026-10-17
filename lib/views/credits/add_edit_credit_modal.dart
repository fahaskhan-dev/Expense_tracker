import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/credit_model.dart';
import '../../providers/credit_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';

class AddEditCreditModal extends StatefulWidget {
  final CreditModel? credit;
  final CreditType? initialType;

  const AddEditCreditModal({
    super.key,
    this.credit,
    this.initialType,
  });

  @override
  State<AddEditCreditModal> createState() => _AddEditCreditModalState();
}

class _AddEditCreditModalState extends State<AddEditCreditModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;

  late CreditType _creditType;
  late DateTime _date;
  DateTime? _dueDate;

  bool get _isEditing => widget.credit != null;

  @override
  void initState() {
    super.initState();
    final c = widget.credit;
    _creditType = c?.creditType ?? widget.initialType ?? CreditType.toReceive;
    _nameController = TextEditingController(text: c?.personName ?? '');
    _phoneController = TextEditingController(text: c?.phoneNumber ?? '');
    _amountController = TextEditingController(
      text: c != null
          ? (c.originalAmount == c.originalAmount.roundToDouble()
              ? c.originalAmount.toStringAsFixed(0)
              : c.originalAmount.toStringAsFixed(2))
          : '',
    );
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _date = c?.date ?? DateTime.now();
    _dueDate = c?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({bool isDueDate = false}) async {
    final initial = isDueDate ? (_dueDate ?? DateTime.now()) : _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryPurple,
            onPrimary: Colors.white,
            onSurface: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _date = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _date.hour,
            _date.minute,
          );
        }
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    final provider = context.read<CreditProvider>();

    if (_isEditing) {
      final updated = widget.credit!.copyWith(
        personName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        originalAmount: amount,
        creditType: _creditType,
        date: _date,
        dueDate: _dueDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      provider.updateCredit(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Credit record updated!'),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      final newCredit = CreditModel(
        id: const Uuid().v4(),
        personName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        originalAmount: amount,
        creditType: _creditType,
        date: _date,
        dueDate: _dueDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      provider.addCredit(newCredit);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Credit record added for ${newCredit.personName}'),
          backgroundColor: _creditType == CreditType.toReceive
              ? AppColors.incomeGreen
              : AppColors.expenseRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    final isToReceive = _creditType == CreditType.toReceive;
    final typeColor =
        isToReceive ? AppColors.incomeGreen : AppColors.expenseRed;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white24
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Edit Credit Record' : 'New Credit Record',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Credit Type Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCardBackground
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _creditType = CreditType.toReceive),
                          child: _TypeTab(
                            label: 'Money to Receive',
                            icon: Icons.arrow_downward_rounded,
                            isSelected: isToReceive,
                            color: AppColors.incomeGreen,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _creditType = CreditType.toPay),
                          child: _TypeTab(
                            label: 'Money to Pay',
                            icon: Icons.arrow_upward_rounded,
                            isSelected: !isToReceive,
                            color: AppColors.expenseRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount
                _FieldLabel(text: 'Amount', isDark: isDark),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                    hintText: '0.00',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Person Name
                _FieldLabel(text: "Person's Name", isDark: isDark),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Rahul, Mom, Office Friend',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Please enter the person's name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Phone (optional)
                _FieldLabel(text: 'Phone Number (Optional)', isDark: isDark),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+91 98765 43210',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 18),

                // Description (optional)
                _FieldLabel(
                    text: 'Description / Reason (Optional)',
                    isDark: isDark),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Lent for medical emergency, Borrowed for trip',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 18),

                // Date
                _FieldLabel(text: 'Date', isDark: isDark),
                const SizedBox(height: 6),
                _DatePickerButton(
                  date: _date,
                  isDark: isDark,
                  onTap: () => _pickDate(),
                ),
                const SizedBox(height: 18),

                // Due Date (optional)
                _FieldLabel(text: 'Due Date (Optional)', isDark: isDark),
                const SizedBox(height: 6),
                _DatePickerButton(
                  date: _dueDate,
                  isDark: isDark,
                  placeholder: 'No due date set',
                  onTap: () => _pickDate(isDueDate: true),
                  trailingWidget: _dueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              size: 18, color: Colors.grey),
                          onPressed: () => setState(() => _dueDate = null),
                        )
                      : null,
                ),
                const SizedBox(height: 18),

                // Notes (optional)
                _FieldLabel(text: 'Notes (Optional)', isDark: isDark),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Any additional notes...',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 26),

                // Save Button
                GradientButton(
                  gradient: isToReceive
                      ? AppColors.incomeGradient
                      : AppColors.expenseGradient,
                  onPressed: _save,
                  text: _isEditing
                      ? 'Update Credit Record'
                      : (isToReceive
                          ? 'Save — Money to Receive'
                          : 'Save — Money to Pay'),
                  icon: _isEditing
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _FieldLabel({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding:
          const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final DateTime? date;
  final bool isDark;
  final String placeholder;
  final VoidCallback onTap;
  final Widget? trailingWidget;

  const _DatePickerButton({
    required this.date,
    required this.isDark,
    required this.onTap,
    this.placeholder = 'Select date',
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('EEEE, MMMM dd, yyyy').format(date!)
                    : placeholder,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: date != null
                      ? (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary)
                      : Colors.grey,
                ),
              ),
            ),
            trailingWidget ??
                const Icon(Icons.arrow_drop_down_rounded,
                    color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
