import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard_app/providers/score_provider.dart';

class ScoreInputTile extends StatelessWidget {
  final String activity;
  final int coachCount;

  const ScoreInputTile({
    super.key,
    required this.activity,
    required this.coachCount,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FormProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(activity, style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: coachCount,
            itemBuilder: (_, index) {
              return DropdownButton<int>(
                value: provider.getScore(activity, index) < 0 ? null : provider.getScore(activity, index),
                hint: Text("C${index + 1}"),
                onChanged: (val) {
                  if (val != null) {
                    provider.setScore(activity, index, val);
                  }
                },
                items: List.generate(11, (i) => i)
                    .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                    .toList(),
              );
            },
          ),
        ),
        const Divider()
      ],
    );
  }
}
