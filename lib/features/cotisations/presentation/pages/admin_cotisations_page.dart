import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'admin_add_cotisation_page.dart';
import 'admin_payment_requests_page.dart';
import 'admin_qr_scanner_page.dart';
import 'admin_cotisation_details_page.dart';

class AdminCotisationsPage extends StatefulWidget {
  const AdminCotisationsPage({super.key});

  @override
  State<AdminCotisationsPage> createState() => _AdminCotisationsPageState();
}

class _AdminCotisationsPageState extends State<AdminCotisationsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Toutes';

  final List<Map<String, dynamic>> _cotisations = [
    {
      'id': 1,
      'title': 'Nouvelle école',
      'dateDebut': '2 Fév 2025',
      'dateFin': '31 Déc 2025',
      'montantTotal': 50000,
      'montantPaye': 30000,
      'montantPersonnel': 2000,
      'personnesPaye': 15,
      'totalPersonnes': 25,
      'icon': Icons.school,
      'color': const Color(0xFF3B82F6),
      'pendingRequests': 3,
    },
    {
      'id': 2,
      'title': 'Festival annuel',
      'dateDebut': '15 Jan 2025',
      'dateFin': '20 Fév 2025',
      'montantTotal': 30000,
      'montantPaye': 18000,
      'montantPersonnel': 1500,
      'personnesPaye': 12,
      'totalPersonnes': 20,
      'icon': Icons.celebration,
      'color': const Color(0xFF8B5CF6),
      'pendingRequests': 1,
    },
    {
      'id': 3,
      'title': 'Obsèque Famille Allain',
      'dateDebut': '28 Jan 2025',
      'dateFin': '15 Fév 2025',
      'montantTotal': 100000,
      'montantPaye': 85000,
      'montantPersonnel': 5000,
      'personnesPaye': 17,
      'totalPersonnes': 20,
      'icon': Icons.group,
      'color': const Color(0xFFEC4899),
      'pendingRequests': 0,
    },
    {
      'id': 4,
      'title': 'Rénovation mosquée',
      'dateDebut': '10 Jan 2025',
      'dateFin': '30 Juin 2025',
      'montantTotal': 150000,
      'montantPaye': 45000,
      'montantPersonnel': 3000,
      'personnesPaye': 15,
      'totalPersonnes': 50,
      'icon': Icons.mosque,
      'color': const Color(0xFF10B981),
      'pendingRequests': 5,
    },
  ];

  List<Map<String, dynamic>> get filteredCotisations {
    List<Map<String, dynamic>> filtered = _cotisations;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cotisation) {
        return cotisation['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    switch (_selectedFilter) {
      case 'En cours':
        filtered = filtered.where((cotisation) {
          final isComplete = cotisation['montantPaye'] >= cotisation['montantTotal'];
          return !isComplete;
        }).toList();
        break;
      case 'Terminées':
        filtered = filtered.where((cotisation) {
          return cotisation['montantPaye'] >= cotisation['montantTotal'];
        }).toList();
        break;
      case 'Avec demandes':
        filtered = filtered.where((cotisation) {
          return cotisation['pendingRequests'] > 0;
        }).toList();
        break;
      default:
        break;
    }
    
    return filtered;
  }

  int get totalPendingRequests {
    return _cotisations.fold(0, (sum, cotisation) => sum + (cotisation['pendingRequests'] as int));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestion des cotisations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Rechercher une cotisation',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF6B7280),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminAddCotisationPage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          tooltip: 'Ajouter une cotisation',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionCard(
                          'Demandes en attente',
                          '$totalPendingRequests',
                          Icons.pending_actions,
                          const Color(0xFFF59E0B),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminPaymentRequestsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionCard(
                          'Scanner QR',
                          'Paiement',
                          Icons.qr_code_scanner,
                          const Color(0xFF10B981),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminQrScannerPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionCard(
                          'Total cotisations',
                          '${_cotisations.length}',
                          Icons.receipt_long,
                          const Color(0xFF4F46E5),
                          null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Toutes'),
                        const SizedBox(width: 8),
                        _buildFilterChip('En cours'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Terminées'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Avec demandes'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: filteredCotisations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune cotisation trouvée',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCotisations.length,
                      itemBuilder: (context, index) {
                        final cotisation = filteredCotisations[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCotisationCard(cotisation),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildCotisationCard(Map<String, dynamic> cotisation) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminCotisationDetailsPage(
              cotisation: cotisation,
            ),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (cotisation['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    cotisation['icon'] as IconData,
                    color: cotisation['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cotisation['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Début : ${cotisation['dateDebut']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Fin : ${cotisation['dateFin']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (cotisation['pendingRequests'] > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pending,
                          size: 12,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${cotisation['pendingRequests']}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Montant collecté',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${cotisation['montantPaye']}/${cotisation['montantTotal']} F',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Participants',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${cotisation['personnesPaye']}/${cotisation['totalPersonnes']} pers.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progression',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      '${((cotisation['montantPaye'] / cotisation['montantTotal']) * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cotisation['color'] as Color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width - 64) * 
                               (cotisation['montantPaye'] / cotisation['montantTotal']),
                        height: 6,
                        decoration: BoxDecoration(
                          color: cotisation['color'] as Color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}