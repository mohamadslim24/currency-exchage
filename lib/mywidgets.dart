import 'package:flutter/material.dart';

class MyDropDownMenu extends StatelessWidget {
  final List<String> list;
  final String initialSelection;
  final Function(String?) action;
  double fontSize;

  MyDropDownMenu({required this.list, required this.initialSelection, required this.action, this.fontSize = 20, super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String item) {
        return DropdownMenuEntry(value: item, label: item);
      }).toList(),
      initialSelection: initialSelection,
      onSelected: action,
      width: 300,
      textStyle: TextStyle(fontSize: fontSize),
    );
  }
}

class MyRadio extends StatelessWidget {
  final Object value;
  final Object groupValue;
  final Function(Object?) onChanged;

  const MyRadio({required this.value, required this.groupValue, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Radio(value: value, groupValue: groupValue, onChanged: onChanged);
  }
}

class MyTextField extends StatelessWidget {
  final InputBorder inputBorder;
  final String hintText;
  final TextInputType textInputType;
  double fontSize;
  String defaultText;
  String userInput;

  late TextEditingController _controller;
  final Function(String?)? onChanged;

  MyTextField({required this.inputBorder, required this.hintText, required this.textInputType, this.fontSize = 18.0, this.defaultText = "", this.onChanged, this.userInput = "", super.key})
  {
    _controller = TextEditingController(text: defaultText);
    _controller.text = userInput == "" ? _controller.text : userInput;
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: inputBorder,
        hintText: hintText,
      ),
      style: TextStyle(fontSize: fontSize),
      keyboardType: textInputType,
      controller: _controller,
      onChanged: onChanged,

    );
  }
}