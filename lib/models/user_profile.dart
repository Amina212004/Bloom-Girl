class UserProfile {
  final String name;
  final String email;
  final int age;
  final String avatar;
  final int cycleLength;
  final int periodDuration;
  final DateTime? lastPeriodDate;
  final bool isLoggedIn;
  final bool waterReminder;
  final bool periodReminder;
  /// true si l'utilisatrice a déjà configuré son cycle (date de dernières règles)
  final bool hasSetupCycle;

  UserProfile({
    required this.name,
    required this.email,
    this.age = 19,
    this.avatar = '🌸',
    this.cycleLength = 28,
    this.periodDuration = 5,
    this.lastPeriodDate,
    this.isLoggedIn = false,
    this.waterReminder = true,
    this.periodReminder = true,
    this.hasSetupCycle = false,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    String? avatar,
    int? cycleLength,
    int? periodDuration,
    DateTime? lastPeriodDate,
    bool? isLoggedIn,
    bool? waterReminder,
    bool? periodReminder,
    bool? hasSetupCycle,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      avatar: avatar ?? this.avatar,
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      waterReminder: waterReminder ?? this.waterReminder,
      periodReminder: periodReminder ?? this.periodReminder,
      hasSetupCycle: hasSetupCycle ?? this.hasSetupCycle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'avatar': avatar,
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'lastPeriodDate': lastPeriodDate?.toIso8601String(),
      'isLoggedIn': isLoggedIn,
      'waterReminder': waterReminder,
      'periodReminder': periodReminder,
      'hasSetupCycle': hasSetupCycle,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 19,
      avatar: json['avatar'] ?? '🌸',
      cycleLength: json['cycleLength'] ?? 28,
      periodDuration: json['periodDuration'] ?? 5,
      lastPeriodDate: json['lastPeriodDate'] != null
          ? DateTime.tryParse(json['lastPeriodDate'])
          : null,
      isLoggedIn: json['isLoggedIn'] ?? false,
      waterReminder: json['waterReminder'] ?? true,
      periodReminder: json['periodReminder'] ?? true,
      hasSetupCycle: json['hasSetupCycle'] ?? false,
    );
  }
}
