import 'dart:io';
import 'package:flutter/material.dart';
import '../models/disease_analysis.dart';

class ResultScreen extends StatefulWidget {
  final DiseaseAnalysis analysis;

  const ResultScreen({super.key, required this.analysis});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.analysis;
    final statusColor = analysis.statusColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: statusColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image or placeholder
                  if (analysis.imagePath != null)
                    Image.file(
                      File(analysis.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(statusColor),
                    )
                  else
                    _buildImagePlaceholder(statusColor),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Plant name overlay
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.plantName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildStatusBadge(analysis),
                            const SizedBox(width: 8),
                            _buildConfidenceBadge(analysis.confidenceScore),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Disease Name Card (if diseased)
                if (!analysis.isHealthy && analysis.diseaseName != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child:
                              const Center(child: Text('🦠', style: TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                analysis.diseaseName!,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                ),
                              ),
                              if (analysis.severity != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Severity: ${analysis.severity}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: statusColor.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Description
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analysis Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        analysis.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tabs
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF2D6A4F),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF2D6A4F),
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(text: 'Symptoms'),
                          Tab(text: 'Treatment'),
                          Tab(text: 'Prevention'),
                        ],
                      ),
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSymptomsTab(analysis),
                            _buildTreatmentTab(analysis),
                            _buildPreventionTab(analysis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Scan Another', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color color) {
    return Container(
      color: color.withValues(alpha: 0.3),
      child: Center(
        child: Text(
          widget.analysis.isHealthy ? '🌿' : '🍂',
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DiseaseAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: analysis.statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            analysis.isHealthy ? Icons.check_circle : Icons.warning_rounded,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            analysis.healthStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${(confidence * 100).toStringAsFixed(0)}% confidence',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSymptomsTab(DiseaseAnalysis analysis) {
    if (analysis.symptoms.isEmpty) {
      return _buildEmptyState('No symptoms detected', analysis.isHealthy ? '✅' : '🔍');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: analysis.symptoms.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFE63946).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('•', style: TextStyle(color: Color(0xFFE63946), fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                analysis.symptoms[index],
                style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF2D3436)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTab(DiseaseAnalysis analysis) {
    if (analysis.treatments.isEmpty) {
      return _buildEmptyState(
        analysis.isHealthy ? 'Your plant is healthy!' : 'No treatments found',
        analysis.isHealthy ? '🎉' : '💊',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analysis.treatments.length,
      itemBuilder: (context, index) {
        final treatment = analysis.treatments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (treatment.isOrganic
                    ? const Color(0xFF2D6A4F)
                    : const Color(0xFF4361EE))
                .withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (treatment.isOrganic
                      ? const Color(0xFF2D6A4F)
                      : const Color(0xFF4361EE))
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeChip(treatment.type, treatment.isOrganic),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      treatment.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                treatment.description,
                style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
              ),
              if (treatment.howToApply.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📋 ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        treatment.howToApply,
                        style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF2D3436)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreventionTab(DiseaseAnalysis analysis) {
    if (analysis.preventionTips.isEmpty) {
      return _buildEmptyState('No prevention tips available', '🛡️');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analysis.preventionTips.length,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2D6A4F).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF2D6A4F).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF2D6A4F),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                analysis.preventionTips[index],
                style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF2D3436)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, bool isOrganic) {
    final color = isOrganic ? const Color(0xFF2D6A4F) : const Color(0xFF4361EE);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildEmptyState(String message, String emoji) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}