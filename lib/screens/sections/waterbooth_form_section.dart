import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard_app/providers/score_provider.dart';

class WaterBoothFormSection extends StatelessWidget {
  const WaterBoothFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FormProvider>(context);
    final activities = [
      "Water booth cleanliness",
      "Functioning taps",
      "Drainage condition",
    ];

    return Container(
      color: Colors.grey[400],
      child: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final score = provider.getScore(activity, 0);
      
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: score >= 0 ? score : null,
                    onChanged: (val) {
                      if (val != null) provider.setScore(activity, 0, val);
                    },
                    decoration: const InputDecoration(labelText: "Score (0–10)"),
                    items: List.generate(11, (i) => DropdownMenuItem(value: i, child: Text("$i"))),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: provider.getRemark(activity),
                    onChanged: (text) => provider.setRemark(activity, text),
                    decoration: const InputDecoration(labelText: "Remark"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
