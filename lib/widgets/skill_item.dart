import 'package:campusskillexchange_app/models/skill.dart';
import 'package:flutter/material.dart';

import '../screens/skill_detail_screen.dart';

class SkillItem extends StatelessWidget {
  final Skill skill;

  const SkillItem(this.skill, {super.key});

  void _selectSkill(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SkillDetailScreen(
          skillId: skill.id,
          instructorId: skill.instructorId,
          skillName: skill.name,
          category: skill.category,
          instructorName: skill.instructorName,
          instructorPhotoUrl: skill.instructorPhotoUrl,
          instructorCountry: skill.country,
          instructorFlag: skill.flag,
          rating: skill.rating,
          reviews: skill.reviews,
          lessons: skill.lessons,
          yearsExperience: skill.experienceYears,
          pricePerLesson: skill.pricePerLesson,
          bio: skill.bio,
          tags: skill.tags,
          coverImageUrl: skill.coverImageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: FittedBox(child: Text('${skill.userIds.length}')),
          ),
        ),
        title: Text(skill.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          skill.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _selectSkill(context),
      ),
    );
  }
}
