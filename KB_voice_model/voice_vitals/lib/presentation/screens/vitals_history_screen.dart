import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/vitals_provider.dart';
import '../../domain/entities/vital_record.dart';

/// Screen displaying saved vitals history with CSV export.
class VitalsHistoryScreen extends ConsumerWidget {
  const VitalsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitalsState = ref.watch(vitalsProvider);
    final records = vitalsState.history;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF94A3B8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vitals History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          if (records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.file_download_outlined,
                  color: Color(0xFF0EA5E9)),
              onPressed: () => _exportCsv(context, ref),
              tooltip: 'Export CSV',
            ),
        ],
      ),
      body: records.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 60,
                    color: Color(0xFF334155),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No records yet',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Saved vitals will appear here',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(vitalsProvider.notifier).refreshHistory(),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _RecordCard(record: records[index]);
                },
              ),
            ),
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    try {
      final csv = await ref.read(vitalsProvider.notifier).exportCsv();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text(
              'CSV Export',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: SelectableText(
                csv,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed')),
        );
      }
    }
  }
}

/// Card displaying a single vital record.
class _RecordCard extends StatelessWidget {
  final VitalRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy — hh:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: Color(0xFF64748B), size: 14),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(record.timestamp.toLocal()),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vitals chips
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (record.bloodPressure != null)
                _VitalChip(
                  icon: Icons.favorite_rounded,
                  label: 'BP',
                  value: '${record.bloodPressure}',
                  color: const Color(0xFFEF4444),
                ),
              if (record.heartRate != null)
                _VitalChip(
                  icon: Icons.monitor_heart_rounded,
                  label: 'HR',
                  value: '${record.heartRate} bpm',
                  color: const Color(0xFF0EA5E9),
                ),
              if (record.temperature != null)
                _VitalChip(
                  icon: Icons.thermostat_rounded,
                  label: 'Temp',
                  value: '${record.temperature}°F',
                  color: const Color(0xFFF59E0B),
                ),
              if (record.spo2 != null)
                _VitalChip(
                  icon: Icons.air_rounded,
                  label: 'SpO2',
                  value: '${record.spo2}%',
                  color: const Color(0xFF8B5CF6),
                ),
              if (record.respirationRate != null)
                _VitalChip(
                  icon: Icons.waves_rounded,
                  label: 'RR',
                  value: '${record.respirationRate} brpm',
                  color: const Color(0xFF06B6D4),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small chip showing a single vital value.
class _VitalChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _VitalChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
