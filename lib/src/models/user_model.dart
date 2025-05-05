class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phone;
  final String? dateOfBirth;
  final String? idNumber;
  final String? role;

  // Student-specific fields
  final String? studentClass;
  final String? studentSemester;

  // Teacher-specific field
  final String? subject;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.idNumber,
    this.subject,
    this.studentClass,
    this.studentSemester,
    this.phone,
    this.dateOfBirth,
    this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'idNumber': idNumber,
      'studentClass': studentClass,
      'studentSemester': studentSemester,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'subject': subject,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      idNumber: map['idNumber'],
      subject: map['subject'],
      studentClass: map['studentClass'],
      studentSemester: map['studentSemester'],
      phone: map['phone'],
      dateOfBirth: map['dateOfBirth'],
      role: map['role'],
    );
  }

  factory UserModel.fromFirebaseUser(dynamic user) {
    return UserModel(uid: user.uid, email: user.email ?? '');
  }
}
