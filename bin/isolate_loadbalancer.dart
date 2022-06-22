import 'dart:async';

import 'package:isolates/isolates.dart';

/// Create isolate pool that has specific count isoaltes.
/// Automatic load balancing.
Future<LoadBalancer> loadBalancer = LoadBalancer.create(5, IsolateRunner.spawn);

void main(List<String> arguments) async {
  // testRun();
  // testRunMultiple();
}

/// It's like a complecated computation and do some heavy tasks.
bool startRunning(int targetMeters) {
  for (int i = 0; i < 10000; i++) {
    print("I've ran $i meters");
  }
  return true;
}

/// run()
/// It is like compute(), but it can save some cost because of rebuilding isolate.
void testRun() async {
  print("testRun() - Start");

  final LoadBalancer lb = await loadBalancer;
  final bool isFinished = await lb.run(startRunning, 10000);
  print(isFinished ? "I am winner!" : "I am loser..");
}

/// runMultiple()
/// Use the isolates which are free more do the same task parallel.
void testRunMultiple() async {
  print("testRunMultiple() - Start");

  final LoadBalancer lb = await loadBalancer;
  final List<FutureOr<bool?>> result = lb.runMultiple(3, startRunning, 10000);
  for (FutureOr<bool?> isFinishedFuture in result) {
    bool isFinished = false;
    if (isFinishedFuture is Future) {
      isFinished = (await isFinishedFuture) ?? false;
    } else {
      isFinished = isFinishedFuture ?? false;
    }
    print(isFinished ? "I am winner!" : "I am loser..");
  }
}
