import 'dart:developer';
import 'dart:io';
import 'package:chatbotapp/hive/boxes.dart'; // Solo si se usa para UserModel
import 'package:chatbotapp/hive/settings.dart';
import 'package:chatbotapp/providers/auth_provider.dart';
import 'package:chatbotapp/providers/settings_provider.dart';
import 'package:chatbotapp/screens/login_screen.dart';
import 'package:chatbotapp/widgets/build_display_image.dart';
import 'package:chatbotapp/widgets/custom_auth_button.dart';
import 'package:chatbotapp/widgets/settings_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
  
class ProfileScreen extends StatefulWidget {  
  const ProfileScreen({super.key});  
  
  @override  
  State<ProfileScreen> createState() => _ProfileScreenState();  
}  
  
class _ProfileScreenState extends State<ProfileScreen> {  
  Map<String, dynamic>? userData;  
  bool isLoading = true;  
  // Agregar estas variables para manejo de imágenes  
  File? file;  
  late String userName;
  String userImage = '';  
  final ImagePicker _picker = ImagePicker();

  // pick an image  
  void pickImage() async {  
    try {  
      final pickedImage = await _picker.pickImage(  
        source: ImageSource.gallery,  
        maxHeight: 800,  
        maxWidth: 800,  
        imageQuality: 95,  
      );  
      if (pickedImage != null) {  
        setState(() {  
          file = File(pickedImage.path);  
        });  
        // Opcional: guardar la ruta en Hive para persistencia  
        await _saveImagePath(pickedImage.path);  
      }  
    } catch (e) {  
      log('error : $e');  
    }  
  }



// Método actualizado para guardar imagen localmente sin Hive UserModel  
  Future<void> _saveImagePath(String imagePath) async {  
    try {  
      // Guardar solo en el estado local o usar SharedPreferences  
      setState(() {  
        userImage = imagePath;  
      });  
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_image_path', imagePath);
    } catch (e) {  
      log('Error guardando imagen: $e');  
    }  
  }

  @override  
  void initState() {  
    super.initState();  
    // Cargar datos del usuario al iniciar
    _loadUserData();  
  }  

  Future<void> _loadUserData() async {    
  try {    
    final authProvider = context.read<AuthProvider>();    
    final data = await authProvider.getUserData();    
  
    setState(() {    
      userData = data;    
      isLoading = false;    
      // Actualizar userName directamente aquí  
      userName = data?['nombreCompleto'] ?? 'Usuario';  
    });    
  
    // Cargar imagen guardada localmente    
    final prefs = await SharedPreferences.getInstance();    
    final savedImagePath = prefs.getString('user_image_path');    
    if (savedImagePath != null) {    
      setState(() {    
        userImage = savedImagePath;    
      });    
    }  
  } catch (e) {    
    log('Error cargando datos del usuario: $e');    
    setState(() {    
      isLoading = false;    
    });    
  }    
  
}
  Future<void> _deleteAccount() async {  
    // Mostrar diálogo de confirmación  
    final confirmed = await showDialog<bool>(  
      context: context,  
      builder: (context) => AlertDialog(  
        title: const Text('Eliminar Cuenta'),  
        content: const Text(  
          '¿Estás seguro de que quieres eliminar tu cuenta? '  
          'Esta acción no se puede deshacer y perderás todos tus datos.',  
        ),  
        actions: [  
          TextButton(  
            onPressed: () => Navigator.of(context).pop(false),  
            child: const Text('Cancelar'),  
          ),  
          TextButton(  
            onPressed: () => Navigator.of(context).pop(true),  
            style: TextButton.styleFrom(foregroundColor: Colors.red),  
            child: const Text('Eliminar'),  
          ),  
        ],  
      ),  
    );  
    
    if (confirmed != true) return;  
    
    try {  
      final success = await context.read<AuthProvider>().deleteUserAccount();  
        
      if (success && mounted) {  
        ScaffoldMessenger.of(context).showSnackBar(  
          const SnackBar(  
            content: Text('Cuenta eliminada exitosamente'),  
            backgroundColor: Colors.green,  
          ),  
        );  
        // Redirigir a LoginScreen después de eliminar la cuenta
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
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
    }  
  }
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        title: const Text('Perfil'),  
        centerTitle: true,  
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,  
      ),  
      body: Padding(  
        padding: const EdgeInsets.symmetric(  
          horizontal: 20.0,  
          vertical: 20.0,  
        ),  
        child: SingleChildScrollView(  
          child: Column(  
            children: [  
              // Información del Usuario  
              if (isLoading)  
                const Center(child: CircularProgressIndicator())  
              else  
                _buildUserInfo(),  
  
              const SizedBox(height: 40.0),  
  
              // Configuraciones  
              ValueListenableBuilder<Box<Settings>>(  
                valueListenable: Boxes.getSettings().listenable(),  
                builder: (context, box, child) {  
                  if (box.isEmpty) {  
                    return _buildSettingsEmpty();  
                  } else {  
                    final settings = box.getAt(0);  
                    return _buildSettingsWithData(settings!);  
                  }  
                },  
              ),  
  
              const SizedBox(height: 40.0),  
  
              // Botón Cerrar Sesión  
              SizedBox(  
                width: double.infinity,  
                child: CustomAuthButton(  
                  text: 'Cerrar Sesión',  
                  onPressed: _signOut,  
                  icon: Icons.logout,  
                  backgroundColor: Colors.red,  
                  textColor: Colors.white,  
                ),  
              ),  
              const SizedBox(height: 16.0),
              // Botón Eliminar Cuenta
              SizedBox(  
                width: double.infinity,  
                child: CustomAuthButton(  
                  text: 'Eliminar Cuenta',  
                  onPressed: _deleteAccount,  
                  icon: Icons.delete_forever,  
                  backgroundColor: Colors.red.shade800,  
                  textColor: Colors.white,  
                ),  
              ),
            ],  
          ),  
        ),  
      ),  
    );  
  }  
  
  Widget _buildUserInfo() {
    // Usar valores por defecto si no hay datos
    final tipoCliente = userData?['tipoCliente'] ?? 'Usuario';
    final nombreCompleto = userData?['nombreCompleto'] ?? 'Usuario';
    final email = userData?['email'] ?? 'Sin email';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto de perfil
            BuildDisplayImage(
              file: file,
              userImage: userImage,
              onPressed: pickImage,
            ),
            const SizedBox(height: 16),

            // Nombre
            Text(
              nombreCompleto,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Email
            if (email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),

            // Tipo de cliente
            if (userData != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tipoCliente == 'ClienteNativo'
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: tipoCliente == 'ClienteNativo'
                        ? Colors.blue
                        : Colors.green,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    tipoCliente == 'ClienteNativo'
                        ? const Icon(
                            Icons.email,
                            size: 16,
                            color: Colors.blue,
                          )
                        : Image.network(
                            'https://img.icons8.com/?size=100&id=17949&format=png&color=000000',
                            height: 16,
                            width: 16,
                          ),
                    const SizedBox(width: 4),
                    Text(
                      tipoCliente == 'ClienteNativo'
                          ? 'Cuenta Email'
                          : 'Cuenta Google',
                      style: TextStyle(
                        color: tipoCliente == 'ClienteNativo'
                            ? Colors.blue
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsEmpty() {  
    return Column(  
      children: [  
        SettingsTile(  
          icon: CupertinoIcons.mic,  
            title: 'Activar voz de IA',  
          value: false,  
          onChanged: (value) {  
            final settingProvider = context.read<SettingsProvider>();  
            settingProvider.toggleSpeak(value: value);  
          },  
        ),  
        const SizedBox(height: 10.0),  
        SettingsTile(  
          icon: CupertinoIcons.sun_max,  
            title: 'Tema',
          value: false,  
          onChanged: (value) {  
            final settingProvider = context.read<SettingsProvider>();  
            settingProvider.toggleDarkMode(value: value);  
          },  
        ),  
      ],  
    );  
  }  
  
  Widget _buildSettingsWithData(Settings settings) {  
    return Column(  
      children: [  
        SettingsTile(  
          icon: CupertinoIcons.mic,  
          title: 'Activar voz de IA',  
          value: settings.shouldSpeak,  
          onChanged: (value) {  
            final settingProvider = context.read<SettingsProvider>();  
            settingProvider.toggleSpeak(value: value);  
          },  
        ),  
        const SizedBox(height: 10.0),  
        SettingsTile(  
          icon: settings.isDarkTheme  
              ? CupertinoIcons.moon_fill  
              : CupertinoIcons.sun_max_fill,  
          title: 'Tema',  
          value: settings.isDarkTheme,  
          onChanged: (value) {  
            final settingProvider = context.read<SettingsProvider>();  
            settingProvider.toggleDarkMode(value: value);  
          },  
        ),  
      ],  
    );  
  }  
  
  Future<void> _signOut() async {  
    try {  
      await context.read<AuthProvider>().signOut();  
      if (mounted) {  
        ScaffoldMessenger.of(context).showSnackBar(  
          const SnackBar(  
            content: Text('Sesión cerrada exitosamente'),  
            backgroundColor: Colors.green,  
          ),  
        );  
      }  
    } catch (e) {  
      if (mounted) {  
        ScaffoldMessenger.of(context).showSnackBar(  
          SnackBar(  
            content: Text('Error al cerrar sesión: $e'),  
            backgroundColor: Colors.red,  
          ),  
        );  
      }  
    }  
  }  
}