import 'dart:async';

import 'package:isolates/isolates.dart';

Future<LoadBalancer>? loadBalancer;

void main(List<String> arguments) async {
  createLoadBalancer();
  await testRun();
  await testRunMultiple();
  closeLoadBalancer();
}

/// It's like a complecated computation and do some heavy tasks.
bool startRunning(int targetMeters) {
  for (int i = 0; i < 10000; i++) {
    print("I've ran $i meters");
  }
  return true;
}

/// create()
/// Create isolate pool that has specific count isoaltes.
/// Automatic load balancing.
void createLoadBalancer() {
  loadBalancer = LoadBalancer.create(5, IsolateRunner.spawn);
}

/// close()
/// Stop all runners and release.
void closeLoadBalancer() async {
  if (loadBalancer == null) {
    print("Need to create loadBalancer first!");
    return;
  }

  final LoadBalancer lb = await loadBalancer!;
  lb.close();
  loadBalancer = null;

  print("All runners were released!");
}

/// run()
/// It is like compute(), but it can save some cost because of rebuilding isolate.
Future<void> testRun() async {
  if (loadBalancer == null) {
    print("Need to create loadBalancer first!");
    return;
  }

  print("testRun() - Start");

  final LoadBalancer lb = await loadBalancer!;
  final bool isFinished = await lb.run(startRunning, 10000);
  print(isFinished ? "I am winner!" : "I am loser..");
}

/// runMultiple()
/// Use the isolates which are free more do the same task parallel.
Future<void> testRunMultiple() async {
  if (loadBalancer == null) {
    print("Need to create loadBalancer first!");
    return;
  }

  print("testRunMultiple() - Start");

  final LoadBalancer lb = await loadBalancer!;
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
