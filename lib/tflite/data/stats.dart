
class Stats {
  int totalTime;
  int preProcessingTime;
  int inferenceTime;
  int postProcessingTime;

  Stats(
      {this.totalTime = -1,
      this.preProcessingTime = -1,
      this.inferenceTime = -1,
      this.postProcessingTime = -1});

  @override
  String toString() {
    return 'Stats{totalPredictTime: $totalTime,  preProcessingTime: $preProcessingTime,  inferenceTime: $inferenceTime, postProcessingTime: $postProcessingTime}';
  }
}
