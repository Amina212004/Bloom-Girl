import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CycleAnalyticsChart extends StatelessWidget {
  final int cycleLength;
  final int periodDuration;

  const CycleAnalyticsChart({
    Key? key,
    this.cycleLength = 28,
    this.periodDuration = 5,
  }) : super(key: key);

  static const Color _roseBerry = Color(0xFFA04566);
  static const Color _roseSoft = Color(0xFFF2C7D0);
  static const Color _roseDeep = Color(0xFF7A2B49);
  static const Color _goldGlow = Color(0xFFE5A93B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _roseSoft, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _roseBerry.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _roseSoft.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.analytics_rounded, color: _roseBerry, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Statistiques & Énergie Hormonale',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _roseBerry,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _roseBerry.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$cycleLength jours',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: _roseDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: _roseSoft.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value == 1) return const Text('Faible', style: TextStyle(fontSize: 9, color: _roseDeep));
                        if (value == 3) return const Text('Moyen', style: TextStyle(fontSize: 9, color: _roseDeep));
                        if (value == 5) return const Text('Max', style: TextStyle(fontSize: 9, color: _roseDeep));
                        return Container();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        int day = value.toInt();
                        if (day == 1) return const Text('J1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _roseBerry));
                        if (day == periodDuration) return Text('J$periodDuration', style: const TextStyle(fontSize: 10, color: _roseBerry));
                        if (day == (cycleLength ~/ 2)) return const Text('Ovulation', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _goldGlow));
                        if (day == cycleLength) return Text('J$cycleLength', style: const TextStyle(fontSize: 10, color: _roseBerry));
                        return Container();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: cycleLength.toDouble(),
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateEnergySpots(cycleLength, periodDuration),
                    isCurved: true,
                    color: _roseBerry,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _roseSoft.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('🩸 Règles', _roseBerry),
              _buildLegendItem('🌱 Folliculaire', const Color(0xFF81C784)),
              _buildLegendItem('🥚 Ovulation', _goldGlow),
              _buildLegendItem('🌙 Lutéale', const Color(0xFF90CAF9)),
            ],
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateEnergySpots(int totalDays, int periodDays) {
    List<FlSpot> spots = [];
    for (int i = 1; i <= totalDays; i++) {
      double y;
      if (i <= periodDays) {
        y = 1.5 + (i * 0.2); // Phase menstruelle
      } else if (i < (totalDays ~/ 2) - 2) {
        y = 2.5 + ((i - periodDays) * 0.4); // Phase folliculaire
      } else if (i <= (totalDays ~/ 2) + 2) {
        y = 5.2; // Pic d'ovulation
      } else {
        y = 4.5 - ((i - (totalDays ~/ 2)) * 0.2); // Phase lutéale
      }
      spots.add(FlSpot(i.toDouble(), y.clamp(1.0, 5.5)));
    }
    return spots;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
        ),
      ],
    );
  }
}
