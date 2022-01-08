enum Type { BASIC, PARENT_UNIVERSAL, PARENT_EXISTENSIAL }

class Task {
  String id;
  final Type type;
  String label;
  List<Task> children;
  Map<String, String> attrs;

  Task(this.id, this.type, this.label, this.children, this.attrs);
}
