import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/focus_session.dart';
import '../trackers/focus_session_tracker.dart';
import 'focus_session_page.dart';

class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeFilter _filter = DateTimeFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: DateTimeFilter.values.length, vsync: this);
    _tabController.addListener(() {
      setState(() { _filter = DateTimeFilter.values[_tabController.index]; });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<FocusSession> _getFilteredSessions(List<FocusSession> all) {
    final now = DateTime.now();
    return all.where((s) {
      final date = s.startTime;
      switch (_filter) {
        case DateTimeFilter.today:
          return date.year == now.year && date.month == now.month && date.day == now.day;
        case DateTimeFilter.thisWeek:
          final diff = now.difference(date).inDays;
          return diff >= 0 && diff < 7;
        case DateTimeFilter.all:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: DateTimeFilter.values.map((f) => Tab(text: f.label)).toList(),
          indicatorColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          labelColor: theme.colorScheme.primary,
        ),
      ),
      body: Consumer<FocusSessionTracker>(
        builder: (context, tracker, _) {
          if (!tracker.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          final filtered = _getFilteredSessions(List<FocusSession>.from(tracker.sessions));
          final stats = _computeStats(filtered);
          return RefreshIndicator(
            onRefresh: () => tracker.initialize(),
            child: filtered.isEmpty ? _buildEmptyState(theme) : _buildList(filtered, stats, theme),
          );
        },
      ),
    );
  }

  ({int count, int totalMinutes, double avgMinutes}) _computeStats(List<FocusSession> sessions) {
    if (sessions.isEmpty) return (count: 0, totalMinutes: 0, avgMinutes: 0.0);
    final count = sessions.length;
    final totalMinutes = sessions.fold<int>(0, (s, e) => s + e.durationMinutes);
    return (count: count, totalMinutes: totalMinutes, avgMinutes: totalMinutes / count);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No sessions yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Start a focus session to begin tracking your productivity.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FocusSessionPage())),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Start Focus Session'),
          ),
        ]),
      ),
    );
  }

  Widget _buildList(List<FocusSession> sessions, ({int count, int totalMinutes, double avgMinutes}) stats, ThemeData theme) {
    final isFiltered = _filter != DateTimeFilter.all;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          _StatChip(label: 'Sessions', value: stats.count.toString(), color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          _StatChip(label: 'Total Time', value: _formatMinutes(stats.totalMinutes), color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          _StatChip(label: 'Avg / Session', value: _formatAvg(stats.avgMinutes), color: theme.colorScheme.tertiary),
          if (isFiltered) ...[const SizedBox(width: 12), _FilterBadge(filter: _filter)],
        ]),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _SessionHistoryTile(session: sessions[index]),
        ),
      ),
    ]);
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '$h hr $m min' : '$h hr';
  }

  String _formatAvg(double avg) => '${avg.toStringAsFixed(1)} min';
}

class _SessionHistoryTile extends StatelessWidget {
  const _SessionHistoryTile({required this.session});
  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.timer_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${session.formattedDate} at ${session.formattedTime}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            session.durationLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

enum DateTimeFilter {
  all(label: 'All Time'),
  today(label: 'Today'),
  thisWeek(label: 'This Week');
  const DateTimeFilter({required this.label});
  final String label;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w500)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  const _FilterBadge({required this.filter});
  final DateTimeFilter filter;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(filter.label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
    );
  }
}
