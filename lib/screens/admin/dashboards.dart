import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardsScreen extends StatelessWidget {
  const DashboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.12),
        child: AppBar(
          backgroundColor: const Color(0xFF004077),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Dashboard de Resultados',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChartCard(
              title: "Limpieza de aulas",
              chart: _buildBarChart(["Excelente", "Buena", "Regular", "Mala"], [8, 6, 3, 1]),
            ),
            _buildChartCard(
              title: "Estado de los baños",
              chart: _buildBarChart(["Excelente", "Buena", "Regular", "Mala"], [5, 7, 4, 3]),
            ),
            _buildChartCard(
              title: "Calidad de los docentes",
              chart: _buildBarChart(["Excelente", "Buena", "Regular", "Mala"], [9, 5, 2, 1]),
            ),
            _buildChartCard(
              title: "Disponibilidad de los docentes",
              chart: _buildBarChart(["Excelente", "Buena", "Regular", "Mala"], [6, 7, 4, 2]),
            ),
            _buildChartCard(
              title: "Atención en secretaría",
              chart: _buildBarChart(["Excelente", "Buena", "Regular", "Mala"], [4, 6, 7, 2]),
            ),
            _buildChartCard(
              title: "Resolución de problemas administrativos",
              chart: _buildBarChart(["Excelente", "Buena", "Regular", "Mala"], [3, 5, 6, 4]),
            ),
            _buildChartCard(
              title: "Actividades extracurriculares",
              chart: _buildPieChart(
                ["Muy satisfecho", "Satisfecho", "Neutral", "Insatisfecho"],
                [40, 30, 20, 10],
              ),
            ),
            _buildChartCard(
              title: "Acceso a internet",
              chart: _buildBarChart(["Excelente", "Buena", "Regular", "Mala"], [5, 6, 5, 4]),
            ),
            _buildChartCard(
              title: "Carrera de interés",
              chart: _buildPieChart(
                ["Ing. Sistemas", "Ing. Civil", "Derecho", "Administración"],
                [35, 25, 20, 20],
              ),
            ),
            _buildChartCard(
              title: "Colegio de procedencia",
              chart: _buildPieChart(
                ["Colegio A", "Colegio B", "Colegio C", "Colegio D"],
                [30, 20, 25, 25],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta con título y gráfico
  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF004077),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  /// Gráfico de barras con valores dinámicos
  Widget _buildBarChart(List<String> labels, List<double> values) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (values.reduce((a, b) => a > b ? a : b)) + 2,
        barGroups: List.generate(
          labels.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: const Color(0xFF004077),
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                return Text(
                  labels[index],
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  /// Gráfico de torta con valores dinámicos
  Widget _buildPieChart(List<String> labels, List<double> values) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(
          labels.length,
          (i) => PieChartSectionData(
            color: [
              const Color(0xFF004077),
              const Color(0xFF0066CC),
              const Color(0xFFFFD700),
              Colors.grey
            ][i % 4],
            value: values[i],
            title: "${labels[i]} (${values[i].toInt()})",
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
