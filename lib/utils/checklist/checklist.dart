import 'task.dart';
import 'progress.dart';

class Checklist {
  String id;
  String version;
  List<Task> tasks;
  Progress progress;
  String creator;
  String sign;
  int last_modified;
  bool is_edit_mode;
  String snapshots;
  Map<String, dynamic> metadata;

  Checklist(this.id, this.version, this.tasks, this.progress, this.creator,
      this.sign, this.last_modified, this.is_edit_mode, this.snapshots,
      {this.metadata = const {
        'owner': '',
        'name': '',
        'blacklist': {'key': '', 'since': ''}
      }});
}
