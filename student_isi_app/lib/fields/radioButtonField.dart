
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioButtonsField extends StatefulWidget {
  final String title;
  final List<dynamic> options;

  RadioButtonsField({required this.title, required this.options});

  @override
  _RadioButtonsFieldState createState() => _RadioButtonsFieldState();
}

class _RadioButtonsFieldState extends State<RadioButtonsField> {
  String? selectedOption;
  Map<String, dynamic> fieldValues = {}; // This will store the input values

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          Column(
            children: widget.options.map<Widget>((option) {
              return RadioListTile<String>(
                title: Text(option.toString()),
                value: option.toString(),
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                    fieldValues[widget.title] = value; // Store the selected radio option
                    print('Radio Button Field (${widget.title}): $value');
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
