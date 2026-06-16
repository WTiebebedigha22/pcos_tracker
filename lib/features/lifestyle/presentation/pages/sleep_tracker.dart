// lib/features/lifestyle/presentation/pages/sleep_tracker.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  double _sleepHours = 7;
  int _sleepQuality = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Hours of Sleep',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.bed, color: Colors.blue),
                        Expanded(
                          child: Slider(
                            value: _sleepHours,
                            min: 0,
                            max: 12,
                            divisions: 24,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() => _sleepHours = value);
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_sleepHours.toStringAsFixed(1)}h',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Sleep Quality',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (index) {
                        final rating = index + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _sleepQuality = rating),
                          child: Column(
                            children: [
                              Icon(
                                rating <= 2 ? Icons.sentiment_dissatisfied :
                                rating <= 4 ? Icons.sentiment_neutral :
                                Icons.sentiment_very_satisfied,
                                color: _sleepQuality == rating ? AppColors.primary : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rating == 1 ? 'Poor' :
                                rating == 2 ? 'Fair' :
                                rating == 3 ? 'Good' :
                                rating == 4 ? 'Very Good' : 'Excellent',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _sleepQuality == rating ? AppColors.primary : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Sleep Log'),
            ),
          ],
        ),
      ),
    );
  }
}