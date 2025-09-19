import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'qr_scanner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  _TriviaScreenState createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  List<Map<String, dynamic>> _preguntas = [];
  int _puntosTotales = 0;
  bool _cargando = true;

  // Guarda la opción seleccionada por pregunta
  final Map<int, String> _opcionSeleccionada = {};

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  Future<void> _cargarPreguntas() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    // 1. Obtener preguntas respondidas del usuario en Firestore
    final userRef = FirebaseFirestore.instance.collection('estudiantes').doc(userId);
    final userSnapshot = await userRef.get();
    final respondidas = Map<String, dynamic>.from(userSnapshot.data()?['preguntasRespondidas'] ?? {});

    // 2. Obtener IDs de preguntas seleccionadas de SharedPreferences
    List<String> preguntasSeleccionadas = prefs.getStringList('preguntasSeleccionadas_$userId') ?? [];

    // 3. Si no hay preguntas seleccionadas, elegir 20 al azar y guardar
    if (preguntasSeleccionadas.isEmpty) {
      final snapshot = await FirebaseFirestore.instance.collection('preguntas').get();
      final todasLasPreguntas = snapshot.docs.map((doc) => doc.id).toList();
      todasLasPreguntas.shuffle(Random());
      preguntasSeleccionadas = todasLasPreguntas.take(20).toList();
      await prefs.setStringList('preguntasSeleccionadas_$userId', preguntasSeleccionadas);
    }

    // 4. Cargar los datos de esas preguntas
    final preguntasDocs = await FirebaseFirestore.instance
        .collection('preguntas')
        .where(FieldPath.documentId, whereIn: preguntasSeleccionadas)
        .get();

    final preguntas = preguntasDocs.docs.map((doc) {
      final data = doc.data();
      final id = doc.id;
      return {
        ...data,
        'id': id,
        'respondida': respondidas.containsKey(id),
        'opcionSeleccionada': respondidas[id], // Puede ser null si no respondida
      };
    }).toList();

    // 5. Mantener el orden original de las seleccionadas
    preguntas.sort((a, b) =>
        preguntasSeleccionadas.indexOf(a['id']) - preguntasSeleccionadas.indexOf(b['id']));

    setState(() {
      _preguntas = preguntas;
      _cargando = false;
    });
  }

  Future<void> _escanearQR(Map<String, dynamic> pregunta) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (resultado != null && resultado == pregunta['lugar']) {
      setState(() {
        pregunta['respondida'] = true;
        pregunta['opcionSeleccionada'] = resultado;
        _puntosTotales += (pregunta['puntos'] as num).toInt();
      });
      await _registrarRespuestaUsuario(pregunta['id'], resultado);
      await _sumarPuntosUsuario((pregunta['puntos'] as num).toInt());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Correcto! Ganaste ${pregunta['puntos']} puntos'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _sumarPuntosUsuario(int puntos) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('estudiantes').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentPuntos = (snapshot.data()?['puntos'] ?? 0) as int;
      transaction.update(userRef, {'puntos': currentPuntos + puntos});
    });
  }

  Future<void> _registrarRespuestaUsuario(String preguntaId, String opcionSeleccionada) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('estudiantes').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data();
      final respondidas = Map<String, dynamic>.from(data?['preguntasRespondidas'] ?? {});
      respondidas[preguntaId] = opcionSeleccionada;
      transaction.update(userRef, {'preguntasRespondidas': respondidas});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trivia Universitaria',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004077),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _preguntas.length,
          itemBuilder: (context, index) {
            final pregunta = _preguntas[index];
            final preguntaTexto = pregunta['Pregunta'] ?? 'Pregunta no disponible';
            final tipo = pregunta['tipo'] ?? '';
            final opciones = (pregunta['opciones'] as List?) ?? [];
            final respuesta = pregunta['respuesta'] ?? '';
            final puntos = (pregunta['puntos'] as num?)?.toInt() ?? 0;
            final lugar = pregunta['lugar'] ?? '';

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // NO cambies el color del Card al responder, mantenlo blanco
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preguntaTexto,
                      style: const TextStyle(
                        color: Color(0xFF004077),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (tipo == 'multiple')
                      ...List<Widget>.from(opciones.map((opcion) {
                        final seleccionada = pregunta['respondida']
                            ? pregunta['opcionSeleccionada'] == opcion
                            : _opcionSeleccionada[index] == opcion;
                        final esCorrecta = opcion == respuesta;
                        Color colorBoton = const Color(0xFF004077);

                        if (pregunta['respondida']) {
                          if (seleccionada && esCorrecta) {
                            colorBoton = Colors.green;
                          } else if (seleccionada && !esCorrecta) {
                            colorBoton = Colors.red;
                          } else {
                            colorBoton = const Color(0xFF004077); // Siempre azul para las no seleccionadas
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorBoton,
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            onPressed: () async {
                              if (!pregunta['respondida']) {
                                setState(() {
                                  _opcionSeleccionada[index] = opcion;
                                  pregunta['respondida'] = true;
                                  pregunta['opcionSeleccionada'] = opcion;
                                  if (opcion == respuesta) {
                                    _puntosTotales += puntos;
                                  }
                                });
                                await _registrarRespuestaUsuario(pregunta['id'], opcion);
                                if (opcion == respuesta) {
                                  await _sumarPuntosUsuario(puntos);
                                }
                              }
                            },
                            child: Text(
                              opcion?.toString() ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }))
                    else
                      Column(
                        children: [
                          Text(
                            'Escanea el QR en: $lugar',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Escanear QR',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004077),
                            ),
                            onPressed: pregunta['respondida']
                                ? null
                                : () async {
                                    await _escanearQR(pregunta);
                                    if (pregunta['respondida']) {
                                      await _sumarPuntosUsuario((pregunta['puntos'] as num).toInt());
                                    }
                                  },
                          ),
                        ],
                      ),
                    if (pregunta['respondida'])
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          pregunta['opcionSeleccionada'] == respuesta
                              ? '+$puntos puntos obtenidos'
                              : 'Respuesta incorrecta',
                          style: TextStyle(
                            color: pregunta['opcionSeleccionada'] == respuesta
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, _puntosTotales);
        },
        label: const Text(
          'Reclamar Puntos',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: const Color(0xFF004077),
      ),
    );
  }
}
