class User {
  final String username;
  final String password;
  final String nama;
  final String email;
  final String noHp;
  final List<int>? photoBytes;

  User({
    required this.username,
    required this.password,
    required this.nama,
    required this.email,
    required this.noHp,
    this.photoBytes,
  });
}
