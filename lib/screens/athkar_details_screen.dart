import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/athkar_model.dart';
import '../models/category_model.dart';
import '../services/database_service.dart';

class AthkarDetailsScreen extends StatefulWidget {
  final CategoryModel category;

  const AthkarDetailsScreen({super.key, required this.category});

  @override
  State<AthkarDetailsScreen> createState() => _AthkarDetailsScreenState();
}

class _AthkarDetailsScreenState extends State<AthkarDetailsScreen> {
  late final PageController _pageController;

  // Keyed by dhikr id so StreamBuilder rebuilds don't reset progress.
  final Map<String, int> _remainingCounts = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Seeds [_remainingCounts] for any athkar not yet tracked.
  void _initCounts(List<AthkarModel> athkarList) {
    for (final athkar in athkarList) {
      _remainingCounts.putIfAbsent(athkar.id, () => athkar.count);
    }
  }

  void _handleCounterTap(List<AthkarModel> athkarList, int index) {
    final athkar = athkarList[index];
    final remaining = _remainingCounts[athkar.id] ?? athkar.count;
    if (remaining <= 0) return;

    HapticFeedback.lightImpact();

    setState(() {
      _remainingCounts[athkar.id] = remaining - 1;
    });

    // Auto-advance to the next dhikr after a short celebration pause.
    if (remaining - 1 == 0 && index < athkarList.length - 1) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<AthkarModel>>(
        stream: db.getAthkar(widget.category.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'خطأ في التحميل\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final athkarList = snapshot.data ?? [];
          if (athkarList.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد أذكار في هذا القسم',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          _initCounts(athkarList);

          final completedCount = athkarList
              .where((a) => (_remainingCounts[a.id] ?? a.count) == 0)
              .length;
          final progress = completedCount / athkarList.length;

          return Column(
            children: [
              _ProgressHeader(
                progress: progress,
                completed: completedCount,
                total: athkarList.length,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: athkarList.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final athkar = athkarList[index];
                    return _AthkarCard(
                      athkar: athkar,
                      remaining:
                          _remainingCounts[athkar.id] ?? athkar.count,
                      onCounterTap: () =>
                          _handleCounterTap(athkarList, index),
                    );
                  },
                ),
              ),
              _PageLabel(
                current: _currentPage + 1,
                total: athkarList.length,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ProgressHeader extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;

  const _ProgressHeader({
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B5E20),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإنجاز',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                '$completed / $total',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF81C784),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageLabel extends StatelessWidget {
  final int current;
  final int total;

  const _PageLabel({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Text(
        '$current / $total',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AthkarCard extends StatelessWidget {
  final AthkarModel athkar;
  final int remaining;
  final VoidCallback onCounterTap;

  const _AthkarCard({
    required this.athkar,
    required this.remaining,
    required this.onCounterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = remaining == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              // ── Dhikr text + virtue + reference ──────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        athkar.text,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 2.0,
                        ),
                      ),
                      if (athkar.virtue.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            athkar.virtue,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green[800],
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                      if (athkar.reference.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          athkar.reference,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Counter button ────────────────────────────────────────────
              const SizedBox(height: 20),
              _CounterButton(
                remaining: remaining,
                isDone: isDone,
                onTap: onCounterTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final int remaining;
  final bool isDone;
  final VoidCallback onTap;

  const _CounterButton({
    required this.remaining,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone ? const Color(0xFF388E3C) : const Color(0xFF1B5E20),
          boxShadow: [
            BoxShadow(
              color: (isDone
                      ? const Color(0xFF388E3C)
                      : const Color(0xFF1B5E20))
                  .withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 38)
              : Text(
                  '$remaining',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
