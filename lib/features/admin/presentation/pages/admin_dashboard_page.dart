import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_gest_city/features/admin/models/contribution_model.dart';
import 'package:manager_gest_city/features/authentication/controller/auth_controller.dart';
import 'package:manager_gest_city/features/cotisations/presentation/pages/try_scan.dart';
import 'package:provider/provider.dart';
import 'package:manager_gest_city/core/widgets/skeleton_placeholder.dart';
import '../../../cotisations/presentation/pages/admin_add_cotisation_page.dart';
import '../../../cotisations/presentation/pages/admin_payment_requests_page.dart';
import '../../../cotisations/presentation/pages/admin_qr_scanner_page.dart';
import '../../controller/home_controller.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeController = context.read<HomeController>();
      if (homeController.status == HomeStatus.initial) {
        homeController.loadHomeData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthController, HomeController>(
      builder: (context, authController, homeController, child) {
        if (!authController.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tableau de bord',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Administration et gestion des cotisations',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 32),

                  if (homeController.isLoading)
                    const SkeletonPlaceholder(padding: EdgeInsets.all(12))
                  else if (homeController.hasError)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur de chargement',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            homeController.errorMessage ??
                                'Une erreur est survenue',
                            style: TextStyle(color: Colors.red.shade600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => homeController.loadHomeData(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    )
                  else if (homeController.getAdminData != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total cotisations',
                            homeController.getAdminData!.nbContributions
                                .toString(),
                            Icons.receipt_long,
                            const Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Demandes en attente',
                            homeController.getAdminData!.nbPendingPayments
                                .toString(),
                            Icons.pending_actions,
                            const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Expanded(
                        //   child: _buildStatCard(
                        //     'Montant collecté',
                        //     '2.5M F',
                        //     Icons.monetization_on,
                        //     const Color(0xFF10B981),
                        //   ),
                        // ),
                        // const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Participants actifs',
                            homeController.getAdminData!.nbUsers.toString(),
                            Icons.group,
                            const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  const Text(
                    'Actions rapides',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildActionCard(
                    'Nouvelle cotisation',
                    'Créer une nouvelle campagne de cotisation',
                    Icons.add_circle_outline,
                    const Color(0xFF4F46E5),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminAddCotisationPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildActionCard(
                    'Demandes de paiement',
                    'Valider les preuves de paiement soumises',
                    Icons.approval,
                    const Color(0xFFF59E0B),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminPaymentRequestsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildActionCard(
                    'Scanner QR',
                    'Enregistrer un paiement en scannant le QR d\'un utilisateur',
                    Icons.qr_code_scanner,
                    const Color(0xFF10B981),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QrScannerPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Cotisations récentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recent contributions: use loaded contributions when available,
                  // otherwise fall back to sample data.
                  ...((homeController.contributions.isNotEmpty
                          ? homeController.contributions
                          : _getRecentCotisations())
                      .map(
                        (cotisation) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRecentCotisationCard(cotisation),
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCotisationCard(ContributionModel cotisation) {
    // Determine icon & color heuristically from the contribution name.
    final name = cotisation.name.toLowerCase();
    IconData icon;
    Color color;

    if (name.contains('école') || name.contains('ecole')) {
      icon = Icons.school;
      color = const Color(0xFF3B82F6);
    } else if (name.contains('festival') || name.contains('fête')) {
      icon = Icons.celebration;
      color = const Color(0xFF8B5CF6);
    } else if (name.contains('mosquée') || name.contains('mosque')) {
      icon = Icons.mosque;
      color = const Color(0xFF10B981);
    } else {
      // Fallback default
      icon = Icons.receipt_long;
      // Use a color derived from id to vary cards visually
      final colors = [
        const Color(0xFF4F46E5),
        const Color(0xFFF59E0B),
        const Color(0xFF10B981),
        const Color(0xFF8B5CF6),
      ];
      color = colors[cotisation.id % colors.length];
    }

    final amountTotal = cotisation.amount > 0 ? cotisation.amount : 1;
    final percent = ((cotisation.amountReachedTotal! / amountTotal) * 100)
        .round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cotisation.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cotisation.amountReachedTotal}/${cotisation.amount} FCFA • ${percent}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ContributionModel> _getRecentCotisations() {
    // Sample contributions used as fallback when the backend didn't return any.
    return [
      ContributionModel(
        id: 1,
        name: 'Nouvelle école',
        description: 'Campagne pour construire une école',
        amount: 50000,
        amountBy: 0,
        periodicity: 'ONE_TIME',
        beginDate: DateTime.now().toIso8601String(),
        endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        isDefault: false,
        amountReachedByPeriodicity: 30000,
        amountReachedTotal: 30000,
        alreadyPaid: 'not_paid',
      ),
      ContributionModel(
        id: 2,
        name: 'Festival annuel',
        description: 'Organisation du festival communautaire',
        amount: 30000,
        amountBy: 0,
        periodicity: 'YEARLY',
        beginDate: DateTime.now().toIso8601String(),
        endDate: DateTime.now().add(const Duration(days: 60)).toIso8601String(),
        isDefault: false,
        amountReachedByPeriodicity: 18000,
        amountReachedTotal: 18000,
        alreadyPaid: 'not_paid',
      ),
      ContributionModel(
        id: 3,
        name: 'Rénovation mosquée',
        description: 'Travaux de rénovation',
        amount: 150000,
        amountBy: 0,
        periodicity: 'ONE_TIME',
        beginDate: DateTime.now().toIso8601String(),
        endDate: DateTime.now()
            .add(const Duration(days: 120))
            .toIso8601String(),
        isDefault: false,
        amountReachedByPeriodicity: 45000,
        amountReachedTotal: 45000,
        alreadyPaid: 'not_paid',
      ),
    ];
  }
}
