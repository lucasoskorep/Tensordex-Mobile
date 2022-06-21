
/// Represents the recognition output from the model
class Recognition {
  /// Index of the result
  final int _id;
  /// Label of the result
  final String _label;
  /// Confidence [0.0, 1.0]
  final double _score;

  Recognition(this._id, this._label, this._score);

  int get id => _id;
  String get label => _label;
  double get score => _score;

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, score: $score)';
  }
}
