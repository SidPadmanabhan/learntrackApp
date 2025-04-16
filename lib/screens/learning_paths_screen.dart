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
                        const SizedBox(height: 16),
                        ExpansionTile(
                          title: Text(
                            'View Modules',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                          children: modules.map<Widget>((module) {
                            return ListTile(
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
                                // Show module details
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
                                        final lessons = module['lessons']
                                                as List<dynamic>? ??
                                            [];
                                        final resources = module['resources']
                                                as List<dynamic>? ??
                                            [];

                                        return SingleChildScrollView(
                                          controller: scrollController,
                                          child: Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  module['title'] ??
                                                      'Untitled Module',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xFF1F2937),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  module['description'] ??
                                                      'No description',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color:
                                                        const Color(0xFF6B7280),
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Text(
                                                  'Lessons',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xFF1F2937),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                ...lessons
                                                    .map<Widget>((lesson) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 12),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFF3F4F6),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            lesson['title'] ??
                                                                'Untitled Lesson',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: const Color(
                                                                  0xFF1F2937),
                                                            ),
                                                          ),
                                                          if (lesson[
                                                                  'description'] !=
                                                              null)
                                                            Text(
                                                              lesson[
                                                                  'description'],
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 12,
                                                                color: const Color(
                                                                    0xFF6B7280),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                if (resources.isNotEmpty) ...[
                                                  const SizedBox(height: 24),
                                                  Text(
                                                    'Resources',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF1F2937),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  ...resources
                                                      .map<Widget>((resource) =>
                                                          ResourceItem(
                                                              resource:
                                                                  resource))
                                                      .toList(),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
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
}
