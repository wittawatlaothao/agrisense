class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "กรุณากรอกอีเมล";
    }
    if (!value.contains("@")) {
      return "อีเมลไม่ถูกต้อง";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return "กรุณากรอกรหัสผ่าน";
    if (value.length < 6) return "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
    return null;
  }
}
