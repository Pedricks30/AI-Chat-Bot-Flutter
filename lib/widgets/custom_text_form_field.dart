import 'package:flutter/material.dart';  
  
class CustomTextFormField extends StatelessWidget {  
  final TextEditingController controller;  
  final String labelText;  
  final IconData prefixIcon;  
  final bool obscureText;  
  final TextInputType? keyboardType;  
  final String? Function(String?)? validator;  
  
  const CustomTextFormField({  
    super.key,  
    required this.controller,  
    required this.labelText,  
    required this.prefixIcon,  
    this.obscureText = false,  
    this.keyboardType,  
    this.validator,  
  });  
  
  @override  
  Widget build(BuildContext context) {  
    return TextFormField(  
      controller: controller,  
      obscureText: obscureText,  
      keyboardType: keyboardType,  
      style: TextStyle(  
        color: Theme.of(context).colorScheme.onSurface, // Usa el color del tema  
      ),  
      decoration: InputDecoration(  
        labelText: labelText,  
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(  
          borderRadius: BorderRadius.circular(10),  
          borderSide: BorderSide(  
            color: Theme.of(context).colorScheme.primary, // Usa el color primario del tema  
          ),  
        ),
        filled: true,  
        fillColor: Theme.of(context).cardColor, // Usa el cardColor del tema  
      ),  
      validator: validator,  
    );  
  }  
}