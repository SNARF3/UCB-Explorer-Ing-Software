import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

class CargarPreguntasPage extends StatelessWidget {
  const CargarPreguntasPage({super.key});

  Future<void> cargarPreguntasDesdeJson() async {
    // Leer archivo JSON desde assets
    String data = await rootBundle.loadString('lib/assets/preguntas_ucb_san_pablo_100.json');
    List<dynamic> preguntas = json.decode(data);

    // Referencia a la colección 'preguntas'
    final CollectionReference preguntasRef = FirebaseFirestore.instance.collection('preguntas');

    // Subir preguntas a Firestore
    for (var pregunta in preguntas) {
      await preguntasRef.add({
        'Pregunta': pregunta['Pregunta'],
        'opciones': List<String>.from(pregunta['opciones']),
        'puntos': pregunta['puntos'],
        'respondida': pregunta['respondida'],
        'respuesta': pregunta['respuesta'],
        'tipo': pregunta['tipo'],
      });
    }

    print('Preguntas cargadas correctamente');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargar Preguntas a Firestore')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await cargarPreguntasDesdeJson();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preguntas cargadas a Firestore ✅')),
            );
          },
          child: const Text('Cargar preguntas'),
        ),
      ),
    );
  }
}
