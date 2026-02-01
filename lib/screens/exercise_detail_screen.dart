import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../theme.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final _db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  bool _showAverage = true; // true = average, false = max

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final history = await _db.getExerciseHistory(widget.exerciseName);
    
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  List<FlSpot> _getChartData() {
    if (_history.isEmpty) return [];

    List<FlSpot> spots = [];
    
    for (int i = 0; i < _history.length; i++) {
      final entry = _history[i];
      final sets = entry['sets'] as List<Map<String, dynamic>>;
      
      if (sets.isEmpty) continue;

      double weight;
      if (_showAverage) {
        // Calculate average weight
        final total = sets.fold<double>(
          0, 
          (sum, set) => sum + (set['weight'] as num).toDouble()
        );
        weight = total / sets.length;
      } else {
        // Get max weight
        weight = sets.fold<double>(
          0,
          (max, set) {
            final w = (set['weight'] as num).toDouble();
            return w > max ? w : max;
          },
        );
      }
      
      spots.add(FlSpot(i.toDouble(), weight));
    }

    return spots;
  }

  Widget _buildChart() {
    final spots = _getChartData();
    
    if (spots.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: TextStyle(color: AppTheme.lightText),
        ),
      );
    }

    final maxY = spots.fold<double>(0, (max, spot) => spot.y > max ? spot.y : max);
    final minY = spots.fold<double>(double.infinity, (min, spot) => spot.y < min ? spot.y : min);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.lightText.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _history.length) return const Text('');
                  
                  final date = DateTime.parse(_history[index]['date']);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d').format(date),
                      style: TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: AppTheme.lightText.withValues(alpha: 0.2)),
              bottom: BorderSide(color: AppTheme.lightText.withValues(alpha: 0.2)),
            ),
          ),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: (minY * 0.9).floorToDouble(),
          maxY: (maxY * 1.1).ceilToDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.pastelPurple,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.pastelPurple,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.pastelPurple.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = DateTime.parse(_history[spot.x.toInt()]['date']);
                  return LineTooltipItem(
                    '${DateFormat('MMM d').format(date)}\n${spot.y.toStringAsFixed(1)} kg',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chart toggle
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SegmentedButton<bool>(
                          selected: {_showAverage},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setState(() {
                              _showAverage = newSelection.first;
                            });
                          },
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Average'),
                              icon: Icon(Icons.show_chart),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Max'),
                              icon: Icon(Icons.trending_up),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Chart
                  SizedBox(
                    height: 250,
                    child: _buildChart(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // History list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'History',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ..._history.map((entry) {
                    final date = DateTime.parse(entry['date']);
                    final sets = entry['sets'] as List<Map<String, dynamic>>;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMMM d, yyyy').format(date),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...sets.map((set) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  'Set ${set['set_number']}: ${set['reps']} reps × ${set['weight']} kg',
                                  style: TextStyle(
                                    color: AppTheme.lightText,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
