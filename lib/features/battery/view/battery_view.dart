import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import '../../../app/app_theme.dart';
import '../viewmodel/battery_viewmodel.dart';

class BatteryView extends StatefulWidget {
  const BatteryView({super.key});

  @override
  State<BatteryView> createState() => _BatteryViewState();
}

class _BatteryViewState extends State<BatteryView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BatteryViewModel()..loadBattery(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Battery Test'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Consumer<BatteryViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return _buildLoadingScreen();
            }

            if (vm.error != null) {
              return _buildErrorScreen(vm.error!);
            }

            final percentage = vm.batteryPercentage ?? 0;
            final isPass = percentage >= 30;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _BatteryIndicator(percentage: percentage),
                    const SizedBox(height: 24),

                    _buildSectionHeader('Battery Details'),
                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _InfoCard(
                          title: 'Battery Percentage',
                          value: '$percentage%',
                          icon: Icons.percent,
                          color: _getPercentageColor(percentage),
                        ),
                        _InfoCard(
                          title: 'Voltage',
                          value: '12.4 V',
                          icon: Icons.flash_on,
                          color: Colors.amber.shade700,
                        ),
                        _InfoCard(
                          title: 'Charging Status',
                          value: vm.isCharging ?? false ? 'Charging' : 'Not Charging',
                          icon: Icons.power,
                          color: vm.isCharging ?? false ? Colors.green : Colors.grey,
                        ),
                        _InfoCard(
                          title: 'Battery Health',
                          value: 'Good',
                          icon: Icons.favorite,
                          color: Colors.red.shade400,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader('Test Result'),
                    const SizedBox(height: 12),

                    _ResultCard(isPass: isPass, percentage: percentage),

                    const SizedBox(height: 24),

                    _ActionButtons(
                      onRetest: () => vm.loadBattery(),
                      onGenerateReport: () {
                        // TODO: Generate battery report
                      },
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

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Testing Battery...', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              'Battery Test Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BatteryViewModel>().loadBattery();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
        ),
      ],
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 60) return Colors.green.shade600;
    if (percentage >= 30) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}

/* -------------------- BATTERY INDICATOR -------------------- */

class _BatteryIndicator extends StatelessWidget {
  final int percentage;

  const _BatteryIndicator({required this.percentage});

  Color _getBatteryColor() {
    if (percentage >= 60) return Colors.green;
    if (percentage >= 30) return Colors.orange;
    return Colors.red;
  }

  String _getBatteryStatus() {
    if (percentage >= 75) return 'Excellent';
    if (percentage >= 50) return 'Good';
    if (percentage >= 30) return 'Low';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Battery outline
                Container(
                  width: 120,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Battery fill
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeInOut,
                          width: 110,
                          height: (percentage / 100) * 192,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [_getBatteryColor().withOpacity(0.8), _getBatteryColor()],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                              topLeft: const Radius.circular(4),
                              topRight: const Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Battery tip
                Positioned(
                  top: 0,
                  child: Container(
                    width: 40,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Percentage text
                Positioned(
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              _getBatteryStatus(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getBatteryColor(),
              ),
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: _getBatteryColor(),
              borderRadius: BorderRadius.circular(6),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('100%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- INFO CARD -------------------- */

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- RESULT CARD -------------------- */

class _ResultCard extends StatelessWidget {
  final bool isPass;
  final int percentage;

  const _ResultCard({required this.isPass, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: isPass ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isPass ? Colors.green.shade200 : Colors.red.shade200, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPass ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(isPass ? Icons.check : Icons.close, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPass ? 'BATTERY TEST PASSED' : 'BATTERY TEST FAILED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPass ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPass
                        ? 'Battery capacity is sufficient ($percentage%)'
                        : 'Battery capacity is below minimum requirement ($percentage%)',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- ACTION BUTTONS -------------------- */

class _ActionButtons extends StatelessWidget {
  final VoidCallback onRetest;
  final VoidCallback onGenerateReport;

  const _ActionButtons({required this.onRetest, required this.onGenerateReport});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRetest,
            icon: const Icon(Icons.refresh),
            label: const Text('RE-TEST'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onGenerateReport,
            icon: const Icon(Icons.download),
            label: const Text('REPORT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
