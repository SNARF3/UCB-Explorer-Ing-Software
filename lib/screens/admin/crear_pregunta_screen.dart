import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrearPreguntaScreen extends StatefulWidget {
  const CrearPreguntaScreen({super.key});

  @override
  State<CrearPreguntaScreen> createState() => _CrearPreguntaScreenState();
}

class _CrearPreguntaScreenState extends State<CrearPreguntaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _preguntaController = TextEditingController();
  final List<TextEditingController> _opcionesControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final TextEditingController _respuestaController = TextEditingController();
  final TextEditingController _puntosController = TextEditingController(
    text: '1000',
  );
  String tipo = 'multiple';

  void _guardarPregunta() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('preguntas').add({
          'Pregunta': _preguntaController.text.trim(),
          'opciones': _opcionesControllers.map((c) => c.text.trim()).toList(),
          'respuesta': _respuestaController.text.trim(),
          'puntos': int.parse(_puntosController.text.trim()),
          'respondida': false,
          'tipo': tipo,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pregunta registrada correctamente')),
        );

        // Limpia los campos
        _preguntaController.clear();
        _respuestaController.clear();
        _puntosController.text = '1000';
        for (final c in _opcionesControllers) {
          c.clear();
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  @override
  void dispose() {
    _preguntaController.dispose();
    _respuestaController.dispose();
    _puntosController.dispose();
    for (final c in _opcionesControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004077),
      appBar: AppBar(
        title: const Text(
          'Registrar Pregunta',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_preguntaController, 'Pregunta'),
              const SizedBox(height: 20),
              ...List.generate(4, (i) {
                return Column(
                  children: [
                    _buildField(_opcionesControllers[i], 'Opción ${i + 1}'),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              _buildField(_respuestaController, 'Respuesta Correcta'),
              _buildField(_puntosController, 'Puntos', isNumber: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarPregunta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'GUARDAR',
                  style: TextStyle(
                    color: Color(0xFF004077),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Campo obligatorio' : null,
    );
  }
}
