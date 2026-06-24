enum Role { student, employer, administrator }

class RoleHelper {
  static Role fromString(String? value) {
    if (value == null) return Role.student;
    final v = value.toString().trim().toLowerCase();
    if (v == 'company' || v == 'employer') return Role.employer;
    if (v == 'administrator' || v == 'admin') return Role.administrator;
    return Role.student;
  }

  static String toStringValue(Role role) {
    switch (role) {
      case Role.employer:
        return 'employer';
      case Role.administrator:
        return 'administrator';
      case Role.student:
        return 'student';
    }
  }
}
