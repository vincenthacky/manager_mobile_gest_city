import 'package:flutter/material.dart';
import 'package:manager_gest_city/features/cotisations/presentation/pages/try_scan.dart';
import 'package:provider/provider.dart';
import '../../controllers/add_cotisation_controller.dart';
// using HomeController for admin cotisations data
import 'package:manager_gest_city/features/admin/controller/home_controller.dart';
import 'admin_payment_requests_page.dart';
// admin_qr_scanner_page is not used here; using try_scan's QrScannerPage instead
import 'admin_cotisation_details_page.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AdminCotisationsPage extends StatefulWidget {
  const AdminCotisationsPage({super.key});

  @override
  State<AdminCotisationsPage> createState() => _AdminCotisationsPageState();
}

class _AdminCotisationsPageState extends State<AdminCotisationsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Toutes';
  // Use HomeController (provided by Provider) instead of a separate CotisationsController
  bool _dateFormattingInitialized = false;
  final ScrollController _scrollController = ScrollController();

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
        return cotisation['title'].toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
      }).toList();
    }

    switch (_selectedFilter) {
      case 'En cours':
        filtered = filtered.where((cotisation) {
          final isComplete =
              cotisation['montantPaye'] >= cotisation['montantTotal'];
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
    return _cotisations.fold(
      0,
      (sum, cotisation) => sum + (cotisation['pendingRequests'] as int),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize locale data for date formatting (used with fr_FR)
    initializeDateFormatting('fr_FR').then((_) {
      if (mounted) {
        setState(() {
          _dateFormattingInitialized = true;
        });
      }
    });
    // fetch initial contributions after first frame using root-provided HomeController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final homeCtrl = Provider.of<HomeController>(context, listen: false);
        homeCtrl.initializeContributions(filter: _selectedFilter, search: _searchQuery, perPage: 10);
      }
    });

    // attach scroll listener for infinite scroll
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      if (_scrollController.position.atEdge) {
        final isBottom = _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
        if (isBottom) {
          final homeCtrl = Provider.of<HomeController>(context, listen: false);
          if (homeCtrl.hasMore && !homeCtrl.isLoadingMore) {
            homeCtrl.fetchNextPage(filter: _selectedFilter, search: _searchQuery);
          }
        }
      }
    });
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    // If locale data hasn't been initialized yet, return a safe fallback string (ISO date or original)
    if (!_dateFormattingInitialized) {
      if (value is DateTime) {
        return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
      }
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
        }
        return value;
      }
      return value.toString();
    }

    // If already a DateTime, format with localized month names
    if (value is DateTime) {
      return DateFormat("d MMMM yyyy", "fr_FR").format(value);
    }
    // If it's a string, try ISO parse; if parse fails, return original string
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return DateFormat("d MMMM yyyy", "fr_FR").format(parsed);
      }
      return value;
    }
    // Fallback
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Only provide controllers local to this page; HomeController is provided at app root
        ChangeNotifierProvider(create: (_) => AddCotisationController()),
      ],
      child: Scaffold(
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
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                                // trigger search via HomeController (reset list)
                                Provider.of<HomeController>(
                                  context,
                                  listen: false,
                                ).initializeContributions(
                                  filter: _selectedFilter,
                                  search: value,
                                  perPage: 10,
                                );
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
                            onPressed: () => _showAddCotisationForm(context),
                            icon: const Icon(Icons.add, color: Colors.white),
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
                          Consumer<HomeController>(
                            builder: (ctx, cotCtrl, _) {
                              final home = cotCtrl;
                              // prefer the admin summary data when available
                              final pending = home.getAdminData?.nbPendingPayments ?? 0;
                              return _buildActionCard(
                                'Demandes en attente',
                                '$pending',
                                Icons.pending_actions,
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
                                  builder: (context) => const QrScannerPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Consumer<HomeController>(
                            builder: (ctx, home, _) {
                              final total = home.getAdminData?.nbContributions ?? home.contributions.length;
                              return _buildActionCard(
                                'Total cotisations',
                                '$total',
                                Icons.receipt_long,
                                const Color(0xFF4F46E5),
                                null,
                              );
                            },
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
                child: Consumer<HomeController>(
                  builder: (ctx, cotCtrl, _) {
                    final home = cotCtrl;
                    if (home.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final source = home.contributions.map((contrib) {
                      return {
                        'id': contrib.id,
                        'title': contrib.name,
                        'dateDebut': contrib.beginDate.split('T').first,
                        'dateFin': contrib.endDate.split('T').first,
                        'montantTotal': contrib.amount,
                        'montantPaye': contrib.amountReachedTotal ?? 0,
                        'montantPersonnel': contrib.amountBy,
                        // ContributionModel doesn't expose participant counts in current model
                        'personnesPaye': 0,
                        'totalPersonnes': 0,
                        'icon': Icons.receipt_long,
                        'color': const Color(0xFF4F46E5),
                        'pendingRequests': 0,
                      };
                    }).toList();

                    if (source.isEmpty) {
                      return Center(
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
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: source.length + (home.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < source.length) {
                          final cotisation = source[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCotisationCard(cotisation),
                          );
                        }
                        // loading indicator at the bottom while fetching more
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCotisationForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final _formKey = GlobalKey<FormState>();
        final TextEditingController nameCtrl = TextEditingController();
        final TextEditingController descCtrl = TextEditingController();
        final TextEditingController amountCtrl = TextEditingController();
        final TextEditingController amountByCtrl = TextEditingController();
        String periodicity = 'MONTHLY';
        DateTime? beginDate;
        DateTime? endDate;
        bool isDefault = false;

        Future<void> pickBeginDate() async {
          final picked = await showDatePicker(
            context: ctx,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            beginDate = picked;
          }
        }

        Future<void> pickEndDate() async {
          final picked = await showDatePicker(
            context: ctx,
            initialDate: beginDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            endDate = picked;
          }
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Nouvelle cotisation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Nom'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Le nom est requis'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: descCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Description (optionnel)',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: amountCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Montant total (FCFA)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Le montant est requis';
                            final parsed = double.tryParse(
                              v.replaceAll(' ', '').replaceAll(',', '.'),
                            );
                            if (parsed == null) return 'Montant invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: amountByCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Montant par personne (FCFA)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Le montant par personne est requis';
                            final parsed = double.tryParse(
                              v.replaceAll(' ', '').replaceAll(',', '.'),
                            );
                            if (parsed == null) return 'Montant invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: periodicity,
                          items:
                              const [
                                    'DAILY',
                                    'WEEKLY',
                                    'MONTHLY',
                                    'QUARTERLY',
                                    'SEMI-ANNUAL',
                                    'ANNUAL',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) =>
                              setState(() => periodicity = v ?? 'MONTHLY'),
                          decoration: const InputDecoration(
                            labelText: 'Périodicité',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await pickBeginDate();
                                  setState(() {});
                                },
                                child: Text(
                                  beginDate == null
                                      ? 'Début'
                                      : 'Début: ${beginDate!.toLocal().toIso8601String().split('T').first}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await pickEndDate();
                                  setState(() {});
                                },
                                child: Text(
                                  endDate == null
                                      ? 'Fin'
                                      : 'Fin: ${endDate!.toLocal().toIso8601String().split('T').first}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Définie par défaut'),
                            Switch(
                              value: isDefault,
                              onChanged: (v) => setState(() => isDefault = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Consumer<AddCotisationController>(
                          builder: (ctx, c, _) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: c.isLoading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!.validate())
                                          return;
                                        if (beginDate == null ||
                                            endDate == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Veuillez choisir les dates de début et de fin',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final payload = {
                                          'name': nameCtrl.text.trim(),
                                          'description':
                                              descCtrl.text.trim().isEmpty
                                              ? null
                                              : descCtrl.text.trim(),
                                          'amount': double.parse(
                                            amountCtrl.text
                                                .replaceAll(' ', '')
                                                .replaceAll(',', '.'),
                                          ),
                                          'amount_by': double.parse(
                                            amountByCtrl.text
                                                .replaceAll(' ', '')
                                                .replaceAll(',', '.'),
                                          ),
                                          'periodicity': periodicity,
                                          'begin_date': beginDate!
                                              .toIso8601String(),
                                          'end_date': endDate!
                                              .toIso8601String(),
                                          'is_default': isDefault,
                                        };

                                        try {
                                          await c.createContribution(payload);
                                          if (mounted) {
                                            Navigator.of(ctx).pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Cotisation créée avec succès',
                                                ),
                                              ),
                                            );
                                            // refresh list via HomeController (reset to page 1)
                                            Provider.of<HomeController>(
                                              ctx,
                                              listen: false,
                                            ).initializeContributions(
                                              filter: _selectedFilter,
                                              search: _searchQuery,
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erreur: ${e.toString()}',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                child: c.isLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Créer'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
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
            Icon(icon, color: color, size: 24),
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
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
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
        // trigger fetch for new filter
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            Provider.of<HomeController>(
              context,
              listen: false,
            ).initializeContributions(
              filter: _selectedFilter,
              search: _searchQuery,
              perPage: 10,
            );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : const Color(0xFFE5E7EB),
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
            builder: (context) =>
                AdminCotisationDetailsPage(cotisation: cotisation),
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
                    color: (cotisation['color'] as Color).withValues(
                      alpha: 0.1,
                    ),
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
                      Column(
                        children: [
                          Text(
                            'Début : ${_formatDate(cotisation['dateDebut'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            'Fin : ${_formatDate(cotisation['dateFin'])}',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         'Participants',
                //         style: TextStyle(
                //           fontSize: 11,
                //           color: Color(0xFF6B7280),
                //         ),
                //       ),
                //       const SizedBox(height: 3),
                //       Text(
                //         '${cotisation['personnesPaye']}/${cotisation['totalPersonnes']} pers.',
                //         style: const TextStyle(
                //           fontSize: 13,
                //           fontWeight: FontWeight.w600,
                //           color: Color(0xFF1F2937),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
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
                        width:
                            (MediaQuery.of(context).size.width - 64) *
                            (cotisation['montantPaye'] /
                                cotisation['montantTotal']),
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
