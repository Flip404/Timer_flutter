import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer/ticker.dart';
import 'package:timer/timer/bloc/timer_bloc.dart';
import 'package:timer/utils.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: const Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Timer')),
      body: Stack(
        children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(child: TimerText()),
              ),
              Actions(),
            ],
          ),
        ],
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final hourStr = ((duration / 60) / 60).floor().toString().padLeft(2, '0');
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TimeButton(time: hourStr, timeState: "Hours"),
        TimeButton(time: minutesStr, timeState: "Minutes"),
        TimeButton(time: secondsStr, timeState: "Seconds"),
      ],
    );
  }
}

class TimeButton extends StatelessWidget {
  final String timeState;
  final String time;

  const TimeButton({Key? key, required this.time, required this.timeState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    const String error = 'The time is not enough to decrease.';
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);

    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Column(
          children: [
            if (state is TimerInitial ||
                state is TimerIncreasedComplete ||
                state is TimerDecreasedComplete ||
                state is TimerRunComplete) ...[
              IconButton(
                  icon: const Icon(Icons.expand_less),
                  onPressed: () {
                    if (timeState == "Hours") {
                      context.read<TimerBloc>().add(TimerIncreasedHours());
                    }
                    if (timeState == "Minutes") {
                      context.read<TimerBloc>().add(TimerIncreasedMinutes());
                    }
                    if (timeState == "Seconds") {
                      context.read<TimerBloc>().add(TimerIncreasedSecond());
                    }
                  }),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: 90,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 50,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              IconButton(
                  icon: const Icon(Icons.expand_more),
                  onPressed: () {
                    if (timeState == "Hours") {
                      if (duration >= 3600){
                        context.read<TimerBloc>().add(TimerDecreasedHours());
                      } else{
                        Utils.showSnackBar(error);
                      }
                    }
                    if (timeState == "Minutes") {
                      if (duration >= 60){
                        context.read<TimerBloc>().add(TimerDecreasedMinutes());
                      } else{
                        Utils.showSnackBar(error);
                      }
                    }
                    if (timeState == "Seconds") {
                      if (duration >= 1){
                        context.read<TimerBloc>().add(TimerDecreasedSecond());
                      } else{
                        Utils.showSnackBar(error);
                      }
                    }
                  }),
              const SizedBox(
                height: 15,
              ),
              Text(
                timeState,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ],
            if (state is TimerRunInProgress || state is TimerRunPause) ...[
              Container(
                width: 90,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 50,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                timeState,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ]
          ],
        );
      },
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (state is TimerInitial ||
                state is TimerIncreasedComplete ||
                state is TimerDecreasedComplete) ...[
              FloatingActionButton(
                child: const Icon(Icons.play_arrow),
                onPressed: () => context
                    .read<TimerBloc>()
                    .add(TimerStarted(duration: state.duration)),
              ),
            ],
            if (state is TimerRunInProgress) ...[
              FloatingActionButton(
                child: const Icon(Icons.pause),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerPaused()),
              ),
              FloatingActionButton(
                child: const Icon(Icons.replay),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerReset()),
              ),
            ],
            if (state is TimerRunPause) ...[
              FloatingActionButton(
                child: const Icon(Icons.play_arrow),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerResumed()),
              ),
              FloatingActionButton(
                child: const Icon(Icons.replay),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerReset()),
              ),
            ],
            if (state is TimerRunComplete) ...[
              FloatingActionButton(
                child: const Icon(Icons.replay),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerReset()),
              ),
            ]
          ],
        );
      },
    );
  }
}

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade500,
            Colors.blue.shade50,
          ],
        ),
      ),
    );
  }
}
