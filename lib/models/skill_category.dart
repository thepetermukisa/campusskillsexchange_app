// Represents main categories: Programming, IT, Design, etc.
class SkillCategory {
  final String id;
  final String name;
  final String icon;
  final int expertCount;

  const SkillCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.expertCount = 0,
  });

  SkillCategory copyWith({int? expertCount}) {
    return SkillCategory(
      id: id,
      name: name,
      icon: icon,
      expertCount: expertCount ?? this.expertCount,
    );
  }
}
