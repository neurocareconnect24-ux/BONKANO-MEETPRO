class Prescription {
  int id;
  int encounterId;
  int userId;
  String name;
  String frequency;
  String duration;
  String instruction;

  Prescription({
    this.id = -1,
    this.encounterId = -1,
    this.userId = -1,
    this.name = "",
    this.frequency = "",
    this.duration = "",
    this.instruction = "",
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] is int ? json['id'] : -1,
      encounterId: json['encounter_id'] is int ? json['encounter_id'] : -1,
      userId: json['user_id'] is int ? json['user_id'] : -1,
      name: json['name'] is String ? json['name'] : "",
      frequency: json['frequency'] is String ? json['frequency'] : "",
      duration: json['duration'] is String ? json['duration'] : "",
      instruction: json['instruction'] is String ? json['instruction'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'encounter_id': encounterId,
      'user_id': userId,
      'name': name,
      'frequency': frequency,
      'duration': duration,
      'instruction': instruction,
    };
  }
}
