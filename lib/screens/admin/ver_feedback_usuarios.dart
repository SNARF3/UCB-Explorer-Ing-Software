import 'package:flutter/material.dart';

class VerFeedbackUsuarios extends StatelessWidget {
  const VerFeedbackUsuarios({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo coherentes con DashboardsScreen
    final feedbackNumerico = {
      "Limpieza de aulas": {"Excelente": 8, "Buena": 6, "Regular": 3, "Mala": 1},
      "Estado de los baños": {"Excelente": 5, "Buena": 7, "Regular": 4, "Mala": 3},
      "Calidad de los docentes": {"Excelente": 9, "Buena": 5, "Regular": 2, "Mala": 1},
      "Disponibilidad de los docentes": {"Excelente": 6, "Buena": 7, "Regular": 4, "Mala": 2},
      "Atención en secretaría": {"Excelente": 4, "Buena": 6, "Regular": 7, "Mala": 2},
      "Resolución de problemas administrativos": {"Excelente": 3, "Buena": 5, "Regular": 6, "Mala": 4},
      "Acceso a internet": {"Excelente": 5, "Buena": 6, "Regular": 5, "Mala": 4},
    };

    // Comentarios abiertos
    final comentarios = [
      "Me gustó la organización del evento.",
      "Los baños podrían estar más limpios.",
      "Los docentes fueron muy amables y claros.",
      "La señal de internet es débil en algunas aulas.",
      "Recomiendo más actividades extracurriculares."
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Feedback de Usuarios",
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        backgroundColor: const Color(0xFF004077),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resultados en números",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004077),
              ),
            ),
            const SizedBox(height: 12),

            // Generar tarjetas para cada feedback numérico
            ...feedbackNumerico.entries.map((entry) => _buildSummaryCard(entry.key, entry.value)),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            const Text(
              "Comentarios de usuarios",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004077),
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comentarios.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.comment, color: Color(0xFF004077)),
                    title: Text(
                      comentarios[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta de resumen de respuestas numéricas
  Widget _buildSummaryCard(String title, Map<String, int> data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF004077),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Mostrar valores en formato “Excelente: 8, Buena: 6...”
            ...data.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "${entry.key}: ${entry.value}",
                    style: const TextStyle(fontSize: 14),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
