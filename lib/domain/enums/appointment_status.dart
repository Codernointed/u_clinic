enum AppointmentStatus {
  scheduled('scheduled'),
  confirmed('confirmed'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled'),
  rescheduled('rescheduled');

  const AppointmentStatus(this.value);
  final String value;

  static AppointmentStatus fromString(String value) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AppointmentStatus.scheduled,
    );
  }

  bool get isActive => [scheduled, confirmed, inProgress].contains(this);
  bool get isCompleted => [completed, cancelled].contains(this);
}
