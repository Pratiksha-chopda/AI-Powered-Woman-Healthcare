import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;

  int _monthlyUsers = 0;
  int _articlesRead = 0;
  int _videosWatched = 0;
  int _faqsViewed = 0;
  int _storiesRead = 0;
  int _tipsViewed = 0;

  // dummy active‑users trend for one week (Mon..Sun)
  final List<int> _activeUsersTrend = [40, 55, 60, 70, 68, 80, 92];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // TODO: replace with Firebase fetching
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _monthlyUsers = 120;
      _articlesRead = 340;
      _videosWatched = 210;
      _faqsViewed = 75;
      _storiesRead = 95;
      _tipsViewed = 130;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        title: Text(
          "Analytics",
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildSummaryCard(),        // big numbers + line graph
            const SizedBox(height: 18),
            _buildContentPieCard(),     // round chart
            const SizedBox(height: 18),
            _buildDetailGrid(),         // your tiles
          ],
        ),
      ),
    );
  }

  // ========== SUMMARY CARD WITH ACTIVE USER LINE GRAPH ==========

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This month overview",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _bigNumber("Active users", _monthlyUsers.toString(),
                  Colors.indigo),
              const SizedBox(width: 12),
              _bigNumber(
                  "Total reads",
                  (_articlesRead +
                      _videosWatched +
                      _faqsViewed +
                      _storiesRead +
                      _tipsViewed)
                      .toString(),
                  Colors.pink),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            "Active users trend (last 7 days)",
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (_activeUsersTrend.length - 1).toDouble(),
                minY: 0,
                maxY: _activeUsersTrend.reduce((a, b) => a > b ? a : b) + 10,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            labels[index],
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_)=>Colors.black87,
                    getTooltipItems: (spots) {
                      return spots.map((s) {
                        return LineTooltipItem(
                          "${s.y.toInt()} users",
                          GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      _activeUsersTrend.length,
                          (i) => FlSpot(i.toDouble(),
                          _activeUsersTrend[i].toDouble()),
                    ),
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.indigo,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.withOpacity(0.4),
                          Colors.indigo.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigNumber(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== ROUND (PIE) CHART FOR CONTENT USAGE ==========

  Widget _buildContentPieCard() {
    final total = _articlesRead +
        _videosWatched +
        _faqsViewed +
        _storiesRead +
        _tipsViewed;

    return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
          "Content engagement split",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "How users interacted with different content types this month",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
            children: [
            SizedBox(
            height: 200,
            width: 200,
            child: PieChart(
              PieChartData(
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                  sections: [
                  _pieSection(
                  value: _articlesRead.toDouble(),
              total: total.toDouble(),
              color: Colors.indigo,
              title: "Articles",
            ),
                    _pieSection(
                      value: _videosWatched.toDouble(),
                      total: total.toDouble(),
                      color: Colors.pink,
                      title: "Videos",
                    ),
                    _pieSection(
                      value: _faqsViewed.toDouble(),
                      total: total.toDouble(),
                      color: Colors.orange,
                      title: "FAQs",
                    ),
                    _pieSection(
                      value: _storiesRead.toDouble(),
                      total: total.toDouble(),
                      color: Colors.teal,
                      title: "Stories",
                    ),
                    _pieSection(
                      value: _tipsViewed.toDouble(),
                      total: total.toDouble(),
                      color: Colors.purple,
                      title: "Tips",
                    ),
                  ],
              ),
            ),
            ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem("Articles", Colors.indigo, _articlesRead),
                    _legendItem("Videos", Colors.pink, _videosWatched),
                    _legendItem("FAQs", Colors.orange, _faqsViewed),
                    _legendItem("Stories", Colors.teal, _storiesRead),
                    _legendItem("Tips", Colors.purple, _tipsViewed),
                  ],
                ),
              ),
            ],
        ),
          ],
        ),
    );
  }

  PieChartSectionData _pieSection({
    required double value,
    required double total,
    required Color color,
    required String title,
  }) {
    final percentage = total == 0 ? 0 : (value / total) * 100;
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 60,
      title: "${percentage.toStringAsFixed(0)}%",
      titleStyle: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _legendItem(String label, Color color, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            value.toString(),
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ========== EXISTING DETAIL GRID ==========

  Widget _buildDetailGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.2,
      ),
      children: [
        _statTile("Articles read", _articlesRead, Icons.article_outlined,
            Colors.indigo),
        _statTile("Videos watched", _videosWatched,
            Icons.video_collection_outlined, Colors.pink),
        _statTile("FAQs viewed", _faqsViewed, Icons.help_outline,
            Colors.orange),
        _statTile("Stories read", _storiesRead, Icons.book_outlined,
            Colors.teal),
        _statTile("Tips viewed", _tipsViewed,
            Icons.lightbulb_outline, Colors.purple),
      ],
    );
  }

  Widget _statTile(
      String title, int value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const Spacer(),
          Text(
            value.toString(),
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}