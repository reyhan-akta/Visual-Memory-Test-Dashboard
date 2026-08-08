import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DateFilterDropdownWidget extends StatefulWidget {
  final ValueChanged<String?>? onChanged;

  const DateFilterDropdownWidget({
    super.key,
    this.onChanged,
  });

  @override
  State<DateFilterDropdownWidget> createState() => _DateFilterDropdownWidgetState();
}

class _DateFilterDropdownWidgetState extends State<DateFilterDropdownWidget> {
  String selectedValue = 'Tarihe göre';

  final List<String> filterOptions = [
    'Tarihe göre',
    'En yeni',
    'En eski',
    'A-Z İsim',
    'Boyuta göre',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLine),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryText,
            size: 18,
          ),
          dropdownColor: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedValue = newValue;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(newValue);
              }
            }
          },
          items: filterOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  color: selectedValue == value
                      ? AppColors.primaryAccent
                      : AppColors.primaryText,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}