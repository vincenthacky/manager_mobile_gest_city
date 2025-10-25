import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminPaymentRequestsPage extends StatefulWidget {
  const AdminPaymentRequestsPage({super.key});

  @override
  State<AdminPaymentRequestsPage> createState() => _AdminPaymentRequestsPageState();
}

class _AdminPaymentRequestsPageState extends State<AdminPaymentRequestsPage> {
  String _selectedFilter = 'En attente';

  final List<Map<String, dynamic>> _paymentRequests = [
    {
      'id': 1,
      'userName': 'Marie Kouamé',
      'userPhone': '+225 0701234567',
      'cotisationTitle': 'Nouvelle école',
      'montant': 2000,
      'paymentMethod': 'Orange Money',
      'proofImages': ['proof1.jpg', 'proof2.jpg'],
      'dateSubmitted': '2025-01-20 14:30',
      'status': 'pending', // pending, approved, rejected
      'userAvatar': 'M',
      'cotisationColor': const Color(0xFF3B82F6),
    },
    {
      'id': 2,
      'userName': 'Jean Baptiste',
      'userPhone': '+225 0789123456',
      'cotisationTitle': 'Festival annuel',
      'montant': 1500,
      'paymentMethod': 'MTN Money',
      'proofImages': ['proof3.jpg'],
      'dateSubmitted': '2025-01-19 09:15',
      'status': 'pending',
      'userAvatar': 'J',
      'cotisationColor': const Color(0xFF8B5CF6),
    },
    {
      'id': 3,
      'userName': 'Fatou Diallo',
      'userPhone': '+225 0567891234',
      'cotisationTitle': 'Obsèque Famille Allain',
      'montant': 5000,
      'paymentMethod': 'Wave',
      'proofImages': ['proof4.jpg'],
      'dateSubmitted': '2025-01-18 16:45',
      'status': 'approved',
      'userAvatar': 'F',
      'cotisationColor': const Color(0xFFEC4899),
    },
    {
      'id': 4,
      'userName': 'Ahmed Traoré',
      'userPhone': '+225 0654321987',
      'cotisationTitle': 'Rénovation mosquée',
      'montant': 3000,
      'paymentMethod': 'Orange Money',
      'proofImages': ['proof5.jpg', 'proof6.jpg'],
      'dateSubmitted': '2025-01-17 11:20',
      'status': 'rejected',
      'userAvatar': 'A',
      'cotisationColor': const Color(0xFF10B981),
    },
  ];

  List<Map<String, dynamic>> get filteredRequests {
    switch (_selectedFilter) {
      case 'Approuvées':
        return _paymentRequests.where((request) => request['status'] == 'approved').toList();
      case 'Rejetées':
        return _paymentRequests.where((request) => request['status'] == 'rejected').toList();
      default: // En attente
        return _paymentRequests.where((request) => request['status'] == 'pending').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF6B7280),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Demandes de paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildFilterChip('En attente'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Approuvées'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejetées'),
                ],
              ),
            ),

            Expanded(
              child: filteredRequests.isEmpty
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
                            'Aucune demande ${_selectedFilter.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = filteredRequests[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRequestCard(request),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    Color chipColor;
    
    switch (filter) {
      case 'Approuvées':
        chipColor = const Color(0xFF10B981);
        break;
      case 'Rejetées':
        chipColor = const Color(0xFFEF4444);
        break;
      default:
        chipColor = const Color(0xFF4F46E5);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : const Color(0xFFE5E7EB),
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

  Widget _buildRequestCard(Map<String, dynamic> request) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: request['cotisationColor'].withValues(alpha: 0.2),
                child: Text(
                  request['userAvatar'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: request['cotisationColor'],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['userName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      request['userPhone'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(request['status']),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: request['cotisationColor'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['cotisationTitle'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request['montant']} FCFA via ${request['paymentMethod']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: request['cotisationColor'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                'Soumis le ${request['dateSubmitted']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showProofImages(request),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library,
                        size: 14,
                        color: Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${request['proofImages'].length} preuve(s)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (request['status'] == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectRequest(request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Rejeter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveRequest(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Approuver',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'approved':
        color = const Color(0xFF10B981);
        text = 'Approuvée';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = const Color(0xFFEF4444);
        text = 'Rejetée';
        icon = Icons.cancel;
        break;
      default:
        color = const Color(0xFFF59E0B);
        text = 'En attente';
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showProofImages(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preuves de paiement - ${request['userName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...request['proofImages'].map<Widget>((image) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(image)),
                  const Icon(Icons.download, color: Color(0xFF4F46E5)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _approveRequest(Map<String, dynamic> request) {
    setState(() {
      request['status'] = 'approved';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paiement de ${request['userName']} approuvé !'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _rejectRequest(Map<String, dynamic> request) {
    setState(() {
      request['status'] = 'rejected';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paiement de ${request['userName']} rejeté'),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
}