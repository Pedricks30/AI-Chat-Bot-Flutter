import 'package:chatbotapp/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:chatbotapp/providers/auth_provider.dart';
import 'package:chatbotapp/screens/login_screen.dart';  
import 'package:chatbotapp/widgets/custom_auth_button.dart';  
  
class RegisterScreen extends StatefulWidget {  
  const RegisterScreen({super.key});  
  
  @override  
  State<RegisterScreen> createState() => _RegisterScreenState();  
}  
  
class _RegisterScreenState extends State<RegisterScreen> {  
  final _formKey = GlobalKey<FormState>();  
  final _nameController = TextEditingController();  
  final _usernameController = TextEditingController();  
  final _emailController = TextEditingController();  
  final _passwordController = TextEditingController();  
  final _confirmPasswordController = TextEditingController();  
  
  @override  
  void dispose() {  
    _nameController.dispose();  
    _usernameController.dispose();  
    _emailController.dispose();  
    _passwordController.dispose();  
    _confirmPasswordController.dispose();  
    super.dispose();  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        title: const Text('Crear Cuenta'),  
        centerTitle: true,
      ),  
      body: SafeArea(  
        child: SingleChildScrollView(  
          padding: const EdgeInsets.all(16.0),  
          child: Form(  
            key: _formKey,  
            child: Consumer<AuthProvider>(  
              builder: (context, authProvider, child) {  
                // Mostrar error si existe  
                if (authProvider.errorMessage != null) {  
                  WidgetsBinding.instance.addPostFrameCallback((_) {  
                    ScaffoldMessenger.of(context).showSnackBar(  
                      SnackBar(  
                        content: Text(authProvider.errorMessage!),  
                        backgroundColor: Colors.red,  
                      ),  
                    );  
                    authProvider.clearError();  
                  });  
                }  
  
                return Column(  
                  mainAxisAlignment: MainAxisAlignment.center,  
                  children: [  
                    // Logo  
                    Container(  
                      height: 120,  
                      width: 120,  
                      child: Image.asset(  
                        'assets/images/airilogo2.png',  
                        fit: BoxFit.contain,  
                      ),  
                    ),  
                    const SizedBox(height: 16),  
  
                    // Campos del formulario  
                    _buildFormFields(),  
  
                    const SizedBox(height: 24),  
  
                    // Botón Registrarse  
                    SizedBox(  
                      width: double.infinity,  
                      child: CustomAuthButton(  
                        text: 'Crear Cuenta',  
                        onPressed: () => _register(authProvider),  
                        isLoading: authProvider.isLoading,  
                        icon: Icons.person_add,  
                      ),  
                    ),  
                    const SizedBox(height: 16),  
                    // Botón Google  
                    SizedBox(  
                      width: double.infinity,  
                      child: CustomAuthButton(  
                        text: 'Registrarse con Google',  
                        onPressed: () => _signUpWithGoogle(authProvider),  
                        isLoading: authProvider.isGoogleLoading,  
                        iconWidget: Image.network(
                          'https://img.icons8.com/?size=100&id=17949&format=png&color=000000',
                          height: 24,
                          width: 24,
                        ),
                        backgroundColor: Colors.red,  
                        textColor: Colors.white,
                        isOutlined: true,  
                      ),  
                    ),  
                    const SizedBox(height: 24),  
  
                    // Link a Login  
                    Row(  
                      mainAxisAlignment: MainAxisAlignment.center,  
                      children: [  
                        const Text('¿Ya tienes cuenta? '),  
                        TextButton(  
                          onPressed: () => Navigator.pushReplacement(  
                            context,  
                            MaterialPageRoute(  
                              builder: (context) => const LoginScreen(),  
                            ),  
                          ),  
                          child: const Text('Iniciar Sesión'),  
                        ),  
                      ],  
                    ),  
                  ],  
                );  
              },  
            ),  
          ),  
        ),  
      ),  
    );  
  }  
  
  Widget _buildFormFields() {  
    return Column(  
      children: [  
        // Campo Username  
        CustomTextFormField(  
          controller: _usernameController,  
          labelText: 'Nombre de usuario',  
          prefixIcon: Icons.alternate_email,  
          validator: (value) {  
            if (value == null || value.trim().isEmpty) {  
              return 'Por favor ingresa un nombre de usuario';  
            }  
            if (value.length < 3) {  
              return 'El nombre de usuario debe tener al menos 3 caracteres';  
            }  
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {  
              return 'Solo letras, números y guiones bajos';  
            }  
            return null;  
          },  
        ), 
        const SizedBox(height: 16),  
  
        // Campo Nombre  
        CustomTextFormField(  
          controller: _nameController,    
          labelText: 'Nombre completo',  
          prefixIcon: Icons.person,   
          validator: (value) {  
            if (value == null || value.trim().isEmpty) {  
              return 'Por favor ingresa tu nombre';  
            }  
            return null;  
          },  
        ),  
        const SizedBox(height: 16),  
  
        // Campo Email  
        CustomTextFormField(  
          controller: _emailController,  
          keyboardType: TextInputType.emailAddress, 
          labelText: 'Correo electrónico',  
          prefixIcon: Icons.email,  
          validator: (value) {  
            if (value == null || value.trim().isEmpty) {  
              return 'Por favor ingresa tu correo';  
            }  
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {  
              return 'Por favor ingresa un correo válido';  
            }  
            return null;  
          },  
        ),  
        const SizedBox(height: 16),  
  
        // Campo Contraseña  
        CustomTextFormField(  
          controller: _passwordController,  
          obscureText: true,  
          labelText: 'Contraseña',  
          prefixIcon: Icons.lock,  
          validator: (value) {  
            if (value == null || value.isEmpty) {  
              return 'Por favor ingresa una contraseña';  
            }  
            if (value.length < 6) {  
              return 'La contraseña debe tener al menos 6 caracteres';  
            }  
            return null;  
          },  
        ),  
        const SizedBox(height: 16),  
  
        // Campo Confirmar Contraseña  
        CustomTextFormField(  
          controller: _confirmPasswordController,  
          obscureText: true,  
          labelText: 'Confirmar contraseña',  
          prefixIcon: Icons.lock_outline,   
          validator: (value) {  
            if (value != _passwordController.text) {  
              return 'Las contraseñas no coinciden';  
            }  
            return null;  
          },  
        ),  
      ],  
    );  
  }  
  
  Future<void> _register(AuthProvider authProvider) async {  
    if (!_formKey.currentState!.validate()) return;  
  
    final result = await authProvider.registerWithEmail(  
      email: _emailController.text.trim(),  
      password: _passwordController.text,  
      fullName: _nameController.text.trim(),  
      username: _usernameController.text.trim(),  
    );  
  
    if (result != null && mounted) {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(  
          content: Text('Cuenta creada exitosamente'),  
          backgroundColor: Colors.green,  
        ),  
      );  
      // No navegamos manualmente - AuthWrapper se encarga automáticamente  
    }  
  }  
  
  Future<void> _signUpWithGoogle(AuthProvider authProvider) async {  
    final result = await authProvider.registerWithGoogle();  
  
    if (result != null && mounted) {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(  
          content: Text('Registrado con Google exitosamente'),  
          backgroundColor: Colors.green,  
        ),  
      );  
    }  
  }  
}