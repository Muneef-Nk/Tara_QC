import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tara_qc/features/battery/view/battery_view.dart';
import '../../../app/app_theme.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('TARA QC Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderSummary(),
              const SizedBox(height: 24),
              _buildSectionHeader('System Status'),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _DashboardCard(
                      title: 'Battery',
                      value: '85%',
                      status: 'PASS',
                      icon: Icons.battery_full,
                      gradient: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      delay: 0.1,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BatteryView()),
                        );
                      },
                    ),
                    _DashboardCard(
                      title: 'Temperature',
                      value: '32°C',
                      status: 'PASS',
                      icon: Icons.thermostat,
                      gradient: const [Color(0xFF2196F3), Color(0xFF0D47A1)],
                      delay: 0.2,
                      onTap: () {
                        // TODO: Navigate to Temperature screen
                      },
                    ),
                    _DashboardCard(
                      title: 'Connectivity',
                      value: 'Connected',
                      status: 'PASS',
                      icon: Icons.wifi,
                      gradient: const [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
                      delay: 0.3,
                      onTap: () {
                        // TODO: Navigate to Connectivity screen
                      },
                    ),
                    _DashboardCard(
                      title: 'Camera',
                      value: 'Active',
                      status: 'PASS',
                      icon: Icons.camera_alt,
                      gradient: const [Color(0xFFFF9800), Color(0xFFEF6C00)],
                      delay: 0.4,
                      onTap: () {
                        // TODO: Navigate to Camera screen
                      },
                    ),
                    _DashboardCard(
                      title: 'Navigation',
                      value: 'GPS Error',
                      status: 'FAIL',
                      icon: Icons.alt_route,
                      gradient: const [Color(0xFFF44336), Color(0xFFC62828)],
                      delay: 0.5,
                      onTap: () {
                        // TODO: Navigate to Navigation screen
                      },
                    ),
                    _DashboardCard(
                      title: 'Hand Device',
                      value: 'Normal',
                      status: 'PASS',
                      icon: Icons.precision_manufacturing,
                      gradient: const [Color(0xFF00BCD4), Color(0xFF00838F)],
                      delay: 0.6,
                      onTap: () {
                        // TODO: Navigate to Hand Device screen
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Quick Actions'),
              const SizedBox(height: 16),
              const _ActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------- HEADER SUMMARY -------------------- */

class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SummaryItem(
              label: 'TOTAL TESTS',
              value: '6',
              icon: Icons.checklist_rtl,
              color: Colors.white,
            ),
            _SummaryItem(
              label: 'PASSED',
              value: '5',
              icon: Icons.check_circle,
              color: AppTheme.success,
            ),
            _SummaryItem(label: 'FAILED', value: '1', icon: Icons.error, color: AppTheme.error),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

/* -------------------- DASHBOARD CARD -------------------- */
class _DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final String status;
  final IconData icon;
  final List<Color> gradient;
  final double delay;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    required this.gradient,
    required this.delay,
    this.onTap,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovered = false;
            });
          },
          child: GestureDetector(
            onTap: () {
              Feedback.forTap(context);
              widget.onTap?.call();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradient,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.gradient.last.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: widget.gradient.first.withOpacity(0.3),
                          spreadRadius: -2,
                          blurRadius: 10,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: widget.gradient.last.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              // transform: _isHovered ? Matrix4.identity()translate(0.0, -4.0) : Matrix4.identity(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(widget.icon, size: 28, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------- ACTION BUTTONS -------------------- */

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.description,
            label: 'GENERATE REPORT',
            color: AppTheme.primary,
            onTap: () {
              // TODO: Generate report
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionButton(
            icon: Icons.refresh,
            label: 'RERUN TESTS',
            color: Colors.grey[700]!,
            onTap: () {
              // TODO: Rerun tests
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }
}
