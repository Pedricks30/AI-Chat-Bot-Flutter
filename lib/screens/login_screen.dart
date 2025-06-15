import 'package:chatbotapp/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:chatbotapp/providers/auth_provider.dart';  
import 'package:chatbotapp/screens/register_screen.dart';  
import 'package:chatbotapp/widgets/custom_auth_button.dart';  
  
class LoginScreen extends StatefulWidget {  
  const LoginScreen({super.key});  
  
  @override  
  _LoginScreenState createState() => _LoginScreenState();  
}  
  
class _LoginScreenState extends State<LoginScreen> {  
  final _formKey = GlobalKey<FormState>();  
  final _emailOrUsernameController = TextEditingController(); // Cambiar nombre 
  final _passwordController = TextEditingController();  
  bool _isLoading = false;  
  bool _isGoogleLoading = false;  
  
  @override  
  void dispose() {  
    _emailOrUsernameController.dispose();  
    _passwordController.dispose();  
    super.dispose();  
  }  
  
  @override
  Widget build(BuildContext context) {  
    return Scaffold( 
      appBar: AppBar(  
        title: const Text('Iniciar Sesión'),  
        centerTitle: true,  
      ),  
      body: SafeArea(  
        child: SingleChildScrollView(  
          padding: const EdgeInsets.all(16.0),  
          child: Form(  
            key: _formKey,  
            child: Column(  
              mainAxisAlignment: MainAxisAlignment.center,  
              children: [  
                // Por tu logo:  
                Container(  
                  height: 120,  
                  width: 120,  
                  child: Image.asset(  
                    'assets/images/airilogo2.png', // Ruta de tu logo  
                    fit: BoxFit.contain,  
                  ),  
                ),
                const SizedBox(height: 16),
                // Campo Email o Username 
                CustomTextFormField(  
                  controller: _emailOrUsernameController,  
                  labelText: 'Email o Nombre de usuario',  
                  prefixIcon: Icons.person,  
                  validator: (value) {  
                    if (value == null || value.trim().isEmpty) {  
                      return 'Por favor ingresa tu email o nombre de usuario';  
                    }  
                    return null;  
                  },  
                ), 
                const SizedBox(height: 16),  
                // Campo Contraseña  
                CustomTextFormField(  
                  controller: _passwordController,  
                  labelText: 'Contraseña',  
                  prefixIcon: Icons.lock,  
                  obscureText: true,  
                  validator: (value) {  
                    if (value == null || value.isEmpty) {  
                      return 'Por favor ingresa tu contraseña';  
                    }  
                    return null;  
                  },  
                ),
                const SizedBox(height: 24),  
                // Botón Iniciar Sesión  
                SizedBox(  
                  width: double.infinity,  
                  child: CustomAuthButton(  
                    text: 'Iniciar Sesión',  
                    onPressed: _signInWithEmail,  
                    isLoading: _isLoading,  
                    icon: Icons.login,  
                  ),  
                ),  
                const SizedBox(height: 16),  
                // Botón Google  
                SizedBox(  
                  width: double.infinity,  
                  child: CustomAuthButton(  
                    text: 'Iniciar con Google',  
                    onPressed: _signInWithGoogle,  
                    isLoading: _isGoogleLoading,  
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
                // Link a Registro  
                Row(  
                  mainAxisAlignment: MainAxisAlignment.center,  
                  children: [  
                    const Text('¿No tienes cuenta? '),  
                    TextButton(  
                      onPressed: () => Navigator.pushReplacement(  
                        context,  
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),  
                      ),  
                      child: const Text('Registrarse'),  
                    ),  
                  ],  
                ),  
              ],  
            ),  
          ),  
        ),  
      ),  
    );  
  }  

  Future<void> _signInWithEmail() async {  
    if (!_formKey.currentState!.validate()) return;  
    
    setState(() => _isLoading = true);  
    try {  
      final input = _emailOrUsernameController.text.trim();  
        
      // Verificar si es email o username  
      if (input.contains('@')) {  
        // Es un email  
        await context.read<AuthProvider>().signInWithEmail(  
          input,  
          _passwordController.text,  
        );  
      } else {  
        // Es un username  
        await context.read<AuthProvider>().signInWithUsername(  
          input,  
          _passwordController.text,  
        );  
      }  
    } catch (e) {  
      if (mounted) {  
        ScaffoldMessenger.of(context).showSnackBar(  
          SnackBar(  
            content: Text('Error: ${e.toString()}'),  
            backgroundColor: Colors.red,  
          ),  
        );  
      }  
    } finally {  
      if (mounted) setState(() => _isLoading = false);  
    }  
  }
  
  Future<void> _signInWithGoogle() async {  
    setState(() => _isGoogleLoading = true);  
    try {  
      await context.read<AuthProvider>().signInWithGoogle();  
    } catch (e) {  
      if (mounted) {  
        ScaffoldMessenger.of(context).showSnackBar(  
          SnackBar(  
            content: Text('Error: ${e.toString()}'),  
            backgroundColor: Colors.red,  
          ),  
        );  
      }  
    } finally {  
      if (mounted) setState(() => _isGoogleLoading = false);  
    }  
  }  
}