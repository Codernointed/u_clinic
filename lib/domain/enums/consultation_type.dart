enum ConsultationType {
  video('video'),
  voice('voice'),
  text('text'),
  inPerson('in_person');

  const ConsultationType(this.value);
  final String value;

  static ConsultationType fromString(String value) {
    return ConsultationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ConsultationType.inPerson,
    );
  }

  bool get isRemote => [video, voice, text].contains(this);
  bool get requiresRealTime => [video, voice].contains(this);
}
