import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _usuarioCtrl = TextEditingController(); // Correo
  final _contrasenaCtrl = TextEditingController();
  bool _registrando = false;

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _registrando = true);

    try {
      final usuario = _usuarioCtrl.text.trim();

      // Verificamos si ya existe un usuario con ese correo
      final existe = await FirebaseFirestore.instance
          .collection('usuario')
          .where('usuario', isEqualTo: usuario)
          .get();

      if (existe.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ese usuario ya existe')),
        );
        setState(() => _registrando = false);
        return;
      }

      // Guardar nuevo usuario
      await FirebaseFirestore.instance.collection('usuario').add({
        'nombre': _nombreCtrl.text.trim(),
        'telefono': int.parse(_telefonoCtrl.text.trim()),
        'usuario': usuario,
        'contrasena': _contrasenaCtrl.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado exitosamente')),
      );
      Navigator.pop(context); // Volver al login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      setState(() => _registrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese su nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese su teléfono' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usuarioCtrl,
                decoration:
                    const InputDecoration(labelText: 'Correo electrónico'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese su correo' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contrasenaCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese una contraseña' : null,
              ),
              const SizedBox(height: 24),
              _registrando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registrarUsuario,
                      child: const Text('Registrarse'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
