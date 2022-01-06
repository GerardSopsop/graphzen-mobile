import 'task.dart';
import 'progress.dart';

class Checklist {
  String id;
  String name;
  String version;
  List<Task> tasks;
  Progress progress;

  Checklist(this.id, this.name, this.version, this.tasks, this.progress);
}
