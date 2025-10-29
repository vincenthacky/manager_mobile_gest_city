class AdminData {
  final int nbContributions;
  final int nbPendingPayments;
  final int nbUsers;

  AdminData({
    required this.nbContributions,
    required this.nbPendingPayments,
    required this.nbUsers,
  });

  factory AdminData.fromJson(Map<String, dynamic> json) {
    return AdminData(
      nbContributions: (json['nb_contributions'] as num?)?.toInt() ?? 0,
      nbPendingPayments: (json['nb_pending_payments'] as num?)?.toInt() ?? 0,
      nbUsers: (json['nb_users'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nb_contributions': nbContributions,
      'nb_pending_payments': nbPendingPayments,
      'nb_users': nbUsers,
    };
  }

  AdminData copyWith({
    int? nbContributions,
    int? nbPendingPayments,
    int? nbUsers,
  }) {
    return AdminData(
      nbContributions: nbContributions ?? this.nbContributions,
      nbPendingPayments: nbPendingPayments ?? this.nbPendingPayments,
      nbUsers: nbUsers ?? this.nbUsers,
    );
  }

  @override
  String toString() {
    return 'AdminData(nbContributions: $nbContributions, nbPendingPayments: $nbPendingPayments, nbUsers: $nbUsers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminData &&
        other.nbContributions == nbContributions &&
        other.nbPendingPayments == nbPendingPayments &&
        other.nbUsers == nbUsers;
  }

  @override
  int get hashCode =>
      nbContributions.hashCode ^ nbPendingPayments.hashCode ^ nbUsers.hashCode;
}
