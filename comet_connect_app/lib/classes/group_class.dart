class Group {
  final String oid;
  final String name;
  final String description;
  final String sessionId;
  final List<dynamic> users;

  Group({
    required this.oid,
    required this.name,
    required this.description,
    required this.sessionId,
    required this.users,
  });
}