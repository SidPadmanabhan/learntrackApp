import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/learning_provider.dart';
import '../widgets/resource_item.dart';

class LearningPathsScreen extends StatelessWidget {
  const LearningPathsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Paths',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: const Color(0xFF1F2937),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF6B7280),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Consumer<LearningProvider>(
          builder: (context, learningProvider, _) {
            if (learningProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4F46E5),
                ),
              );
            }

            final paths = learningProvider.learningPaths;

            if (paths.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Color(0xFFD1D5DB),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No learning paths yet',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search for a topic to create a path',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: paths.length,
              itemBuilder: (context, index) {
                final path = paths[index];
                final modules = path['modules'] as List<dynamic>;
                final totalHours = path['estimatedHours'] as int? ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          path['title'] ?? 'Untitled Path',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          path['description'] ?? 'No description',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$totalHours hours',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.bookmark_border,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${modules.length} modules',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ExpansionTile(
                          title: Text(
                            'View Modules',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                          children:
                              List.generate(modules.length, (moduleIndex) {
                            final module = modules[moduleIndex];
                            final bool isCompleted =
                                module['completed'] as bool? ?? false;

                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    module['title'] ?? 'Untitled Module',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${module['estimatedHours'] ?? 0} hours',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  onTap: () {
                                    _showModuleDetails(
                                        context, module, moduleIndex, index);
                                  },
                                ),
                                // Add checkbox at the bottom of each module tile
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, left: 16, right: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Mark as completed',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                      Checkbox(
                                        value: isCompleted,
                                        activeColor: const Color(0xFF4F46E5),
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            Provider.of<LearningProvider>(
                                                    context,
                                                    listen: false)
                                                .completeModule(
                                                    index, moduleIndex, value);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showModuleDetails(BuildContext context, Map<String, dynamic> module,
      int moduleIndex, int pathIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final lessons = module['lessons'] as List<dynamic>? ?? [];

            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['title'] ?? 'Untitled Module',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      module['description'] ?? 'No description',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add module completion checkbox
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mark module as completed',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                          Consumer<LearningProvider>(
                            builder: (context, provider, _) {
                              // Get the latest module data in case it was updated
                              final path = provider.learningPaths[pathIndex];
                              final modules = path['modules'] as List<dynamic>;
                              final currentModule = modules[moduleIndex];
                              final bool isCompleted =
                                  currentModule['completed'] as bool? ?? false;

                              return Checkbox(
                                value: isCompleted,
                                activeColor: const Color(0xFF4F46E5),
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    provider.completeModule(
                                        pathIndex, moduleIndex, value);
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Lessons',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...lessons.map<Widget>((lesson) {
                      // Get lesson-specific resources
                      final lessonResources =
                          lesson['resources'] as List<dynamic>? ?? [];
                      final bool hasResources = lessonResources.isNotEmpty;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson['title'] ?? 'Untitled Lesson',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              if (lesson['description'] != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  lesson['description'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                              // Display resources for this specific lesson
                              if (hasResources) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Lesson Resources',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF4F46E5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...lessonResources
                                    .map<Widget>((resource) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child:
                                              ResourceItem(resource: resource),
                                        ))
                                    .toList(),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
