import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../viewmodel/temperature_viewmodel.dart';

class TemperatureView extends StatelessWidget {
  const TemperatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TemperatureViewModel()..loadTemperature(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Temperature Monitor', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          actions: [
            Consumer<TemperatureViewModel>(
              builder: (context, vm, _) {
                if (vm.temperatureHistory.isNotEmpty) {
                  return IconButton(
                    icon: Badge(
                      label: Text(vm.temperatureHistory.length.toString()),
                      child: const Icon(Icons.history),
                    ),
                    onPressed: () => _showHistoryDialog(context, vm),
                  );
                }
                return const IconButton(icon: Icon(Icons.history), onPressed: null);
              },
            ),
          ],
        ),
        body: Consumer<TemperatureViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading && !vm.isRetesting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      vm.error!,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => vm.loadTemperature(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final temp = vm.temperature;
            final isPass = temp <= TemperatureRanges.highMax;

            return RefreshIndicator(
              onRefresh: () async => vm.loadTemperature(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TemperatureIndicator(temperature: temp),
                    const SizedBox(height: 24),

                    if (vm.temperatureHistory.isNotEmpty) ...[
                      _TemperatureHistory(temperatures: vm.temperatureHistory),
                      const SizedBox(height: 24),
                    ],

                    _ResultCard(isPass: isPass, temperature: temp),
                    const SizedBox(height: 24),

                    _ActionButtons(
                      onRetest: () => vm.retestTemperature(),
                      onGenerateReport: () => _generateReport(context, vm),
                      viewModel: vm,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, TemperatureViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temperature History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vm.temperatureHistory.length,
            itemBuilder: (context, index) {
              final temp = vm.temperatureHistory[index];
              final time = vm.temperatureTimestamps[index];
              return ListTile(
                leading: Icon(Icons.thermostat, color: TemperatureRanges.getColor(temp)),
                title: Text('${temp.toStringAsFixed(1)}°C'),
                subtitle: Text(TemperatureRanges.getStatus(temp)),
                trailing: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(
            onPressed: () {
              vm.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear History', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateReport(BuildContext context, TemperatureViewModel vm) async {
    final result = await vm.generateReport();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? 'Report generated successfully' : 'Failed to generate report'),
        backgroundColor: result ? Colors.green : Colors.red,
        action: SnackBarAction(
          label: result ? 'View' : 'Retry',
          onPressed: () {
            if (result) {
              // Navigate to report view
            } else {
              _generateReport(context, vm);
            }
          },
        ),
      ),
    );
  }
}

class _TemperatureIndicator extends StatefulWidget {
  final double temperature;

  const _TemperatureIndicator({required this.temperature});

  @override
  State<_TemperatureIndicator> createState() => _TemperatureIndicatorState();
}

class _TemperatureIndicatorState extends State<_TemperatureIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)
      ..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: TemperatureRanges.getColor(widget.temperature),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + (_animation.value * 0.05),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.thermostat, size: 80, color: _colorAnimation.value),
                  const SizedBox(height: 16),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '${widget.temperature.toStringAsFixed(1)} °C',
                      key: ValueKey(widget.temperature),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _colorAnimation.value,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    TemperatureRanges.getStatus(widget.temperature),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _colorAnimation.value,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widget.temperature / 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _colorAnimation.value,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0°C', style: TextStyle(color: Colors.grey.shade600)),
                      Text('60°C', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TemperatureHistory extends StatelessWidget {
  final List<double> temperatures;

  const _TemperatureHistory({required this.temperatures});

  @override
  Widget build(BuildContext context) {
    if (temperatures.isEmpty) return const SizedBox();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Readings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Chip(
                  label: Text('${temperatures.length} readings'),
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: temperatures.length,
                itemBuilder: (context, index) {
                  final temp = temperatures[index];
                  final isLatest = index == temperatures.length - 1;

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isLatest
                                ? TemperatureRanges.getColor(temp).withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            '${temp.toStringAsFixed(1)}°',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                              color: TemperatureRanges.getColor(temp),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: (temp / 60) * 70,
                          width: 40,
                          decoration: BoxDecoration(
                            color: TemperatureRanges.getColor(temp),
                            borderRadius: BorderRadius.circular(6),
                            border: isLatest ? Border.all(color: Colors.black54, width: 2) : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${index + 1}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final bool isPass;
  final double temperature;

  const _ResultCard({required this.isPass, required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: isPass ? Colors.green.shade50 : Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isPass ? Colors.green : Colors.red, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPass ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(isPass ? Icons.check : Icons.warning, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPass ? 'SAFE' : 'ALERT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isPass ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPass
                        ? 'Temperature is within safe limits'
                        : 'Temperature exceeds safe threshold',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPass ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onRetest;
  final VoidCallback onGenerateReport;
  final TemperatureViewModel viewModel;

  const _ActionButtons({
    required this.onRetest,
    required this.onGenerateReport,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer<TemperatureViewModel>(
            builder: (context, vm, _) {
              return OutlinedButton.icon(
                onPressed: vm.isRetesting ? null : onRetest,
                icon: vm.isRetesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(vm.isRetesting ? 'TESTING...' : 'RE-TEST'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.primary),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onGenerateReport,
            icon: const Icon(Icons.assignment),
            label: const Text('GENERATE REPORT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class TemperatureRanges {
  static const double normalMax = 35.0;
  static const double highMax = 45.0;
  static const double criticalMin = 45.1;

  static Color getColor(double temperature) {
    if (temperature <= normalMax) return Colors.green;
    if (temperature <= highMax) return Colors.orange;
    return Colors.red;
  }

  static String getStatus(double temperature) {
    if (temperature <= normalMax) return 'Normal';
    if (temperature <= highMax) return 'High';
    return 'Critical';
  }

  static String getDescription(double temperature) {
    if (temperature <= normalMax) return 'Within safe operating range';
    if (temperature <= highMax) return 'Monitor closely';
    return 'Immediate action required';
  }
}
