import 'package:art_mobile/features/courses/data/models/course_model.dart';
import 'package:art_mobile/features/courses/data/models/explore_model.dart';
import 'package:art_mobile/features/my_courses/data/models/my_courses_model.dart';

abstract class ICourseRepository {
  Future<CourseDetail> getCourseDetail(String courseId);
  Future<HomeResponse> getHomeData();
  Future<ExploreResponse> getExploreData(
      {String? query, String? category, String? filter});
  Future<MyCoursesResponse> getMyCourses();
}

class MockCourseRepository implements ICourseRepository {
  @override
  Future<CourseDetail> getCourseDetail(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return CourseDetail(
      id: courseId,
      title: 'Aari Embroidery Masterclass',
      description:
          'Master the ancient art of Aari embroidery with this comprehensive masterclass. We cover everything from setting up your frame to executing complex bridal designs with precision. You will learn the signature "Atelier Flow" that ensures consistent tension and speed.',
      instructor: 'Priya Sharma',
      instructorAvatar: 'assets/images/profile_avatar.png',
      instructorRole: 'Expert Instructor · 5 years exp',
      level: 'INTERMEDIATE',
      category: 'Aari Embroidery',
      duration: '12H 45M',
      lessonCount: 24,
      rating: 4.8,
      reviews: 1240,
      students: 3720,
      price: 999,
      originalPrice: 1999,
      image: 'assets/images/aari_hero.png',
      isWishlisted: false,
      curriculum: [
        CurriculumSection(
          id: 's1',
          title: 'Section 1: Introduction & Basics',
          lessons: [
            CourseLesson(
                id: 'l1',
                title: 'Welcome to the Masterclass',
                duration: '05:00',
                videoUrl:
                    'https://d3aj7czvezt6jf.cloudfront.net/videos/35c08323-15ac-4eba-8efd-c37741ededad.mp4',
                isPreview: true,
                isCompleted: true),
            CourseLesson(
                id: 'l2',
                title: 'Essential Tools & Materials',
                duration: '12:45',
                videoUrl:
                    'https://d3aj7czvezt6jf.cloudfront.net/videos/35c08323-15ac-4eba-8efd-c37741ededad.mp4',
                isCompleted: true),
            CourseLesson(
                id: 'l3',
                title: 'Setting up your Embroidery Frame',
                duration: '15:30',
                videoUrl:
                    'https://d3aj7czvezt6jf.cloudfront.net/videos/35c08323-15ac-4eba-8efd-c37741ededad.mp4'),
          ],
        ),
        CurriculumSection(
          id: 's2',
          title: 'Section 2: Hook Techniques',
          lessons: [
            CourseLesson(
                id: 'l4',
                title: 'Holding the Aari Hook',
                duration: '10:15',
                videoUrl:
                    'https://d3aj7czvezt6jf.cloudfront.net/videos/35c08323-15ac-4eba-8efd-c37741ededad.mp4'),
            CourseLesson(
                id: 'l5',
                title: 'The Basic Chain Stitch',
                duration: '20:45',
                videoUrl:
                    'https://d3aj7czvezt6jf.cloudfront.net/videos/35c08323-15ac-4eba-8efd-c37741ededad.mp4'),
            CourseLesson(
                id: 'l6',
                title: 'Turning Curves & Corners',
                duration: '18:20',
                videoUrl:
                    'https://d3aj7czvezt6jf.cloudfront.net/videos/35c08323-15ac-4eba-8efd-c37741ededad.mp4'),
          ],
        ),
      ],
      reviewsList: [
        CourseReview(
          id: 'r1',
          name: 'Anjali Gupta',
          avatar: 'A',
          rating: 5,
          comment:
              'This course is amazing! The instructions are so clear and easy to follow. I already started making my own designs.',
          date: '2 days ago',
        ),
        CourseReview(
          id: 'r2',
          name: 'Rekha Singh',
          avatar: 'R',
          rating: 4,
          comment:
              'Very detailed and professional. Only wish there were more advanced motifs included.',
          date: '1 week ago',
        ),
      ],
    );
  }

  @override
  Future<HomeResponse> getHomeData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return HomeResponse(
      categories: ['All', 'Aari', 'Tailoring', 'Embroidery', 'Blouse Design'],
      banners: [
        BannerModel(
          title: 'Master Aari Embroidery',
          subtitle: '50+ hours of premium content',
          badge: 'New',
          image: 'assets/images/aari_hero.png',
          colors: [0xFF6A1B9A, 0xFFAB47BC],
        ),
        BannerModel(
          title: 'Tailoring Masterclass',
          subtitle: 'From beginner to pro',
          badge: 'Popular',
          image: 'assets/images/silk_course.png',
          colors: [0xFF4527A0, 0xFF7E57C2],
        ),
      ],
      continueLearning: [
        CourseSummary(
          id: '1',
          title: 'Aari Embroidery Masterclass',
          instructor: 'Priya Sharma',
          category: 'Aari',
          image: 'assets/images/aari_hero.png',
          progress: 0.65,
          rating: 4.8,
          reviews: 1240,
          price: 999,
          originalPrice: 1999,
        ),
        CourseSummary(
          id: '2',
          title: 'Complete Tailoring for Beginners',
          instructor: 'Meena Lakshmi',
          category: 'Tailoring',
          image: 'assets/images/silk_course.png',
          progress: 0.30,
          rating: 4.5,
          reviews: 850,
          price: 1499,
          originalPrice: 2499,
        ),
      ],
      featuredCourses: [
        CourseSummary(
          id: '3',
          title: 'Modern Zardosi Art',
          instructor: 'Elena Rose',
          category: 'Design',
          image: 'assets/images/zardosi_activity.png',
          badge: 'Beginner',
          discount: '-48%',
          rating: 4.9,
          reviews: 520,
          price: 799,
          originalPrice: 1599,
        ),
        CourseSummary(
          id: '4',
          title: 'Bridal Blouse Masterclass',
          instructor: 'Kavitha R.',
          category: 'Design',
          image: 'assets/images/theory_activity.png',
          badge: 'Advanced',
          discount: '-50%',
          rating: 4.7,
          reviews: 430,
          price: 1299,
          originalPrice: 2599,
        ),
      ],
      instructors: [
        InstructorSummary(
            name: 'Priya S.', initial: 'P', colors: [0xFF6A1B9A, 0xFFAB47BC]),
        InstructorSummary(
            name: 'Meena L.', initial: 'M', colors: [0xFF4527A0, 0xFF7E57C2]),
        InstructorSummary(
            name: 'Kavitha R.', initial: 'K', colors: [0xFF880E4F, 0xFFAD1457]),
        InstructorSummary(
            name: 'Sudha M.', initial: 'S', colors: [0xFF1565C0, 0xFF42A5F5]),
        InstructorSummary(
            name: 'Anita K.', initial: 'A', colors: [0xFF2E7D32, 0xFF66BB6A]),
      ],
    );
  }

  @override
  Future<ExploreResponse> getExploreData(
      {String? query, String? category, String? filter}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    List<CourseSummary> allCourses = [
      CourseSummary(
        id: '1',
        title: 'Aari Embroidery Masterclass',
        instructor: 'Priya Sharma',
        category: 'Aari',
        image: 'assets/images/aari_hero.png',
        rating: 4.8,
        reviews: 1240,
        price: 999,
        originalPrice: 1999,
        level: 'Intermediate',
      ),
      CourseSummary(
        id: '2',
        title: 'Complete Tailoring for Beginners',
        instructor: 'Meena Lakshmi',
        category: 'Tailoring',
        image: 'assets/images/silk_course.png',
        rating: 4.5,
        reviews: 850,
        price: 1499,
        originalPrice: 2499,
        level: 'Beginner',
      ),
      CourseSummary(
        id: '3',
        title: 'Modern Zardosi Art',
        instructor: 'Elena Rose',
        category: 'Embroidery',
        image: 'assets/images/zardosi_activity.png',
        rating: 4.9,
        reviews: 520,
        price: 799,
        originalPrice: 1599,
        level: 'Advanced',
      ),
      CourseSummary(
        id: '4',
        title: 'Bridal Blouse Masterclass',
        instructor: 'Kavitha R.',
        category: 'Blouse Design',
        image: 'assets/images/theory_activity.png',
        rating: 4.7,
        reviews: 430,
        price: 1299,
        originalPrice: 2599,
        level: 'Advanced',
      ),
    ];

    // Simple filtering logic
    var filtered = allCourses.where((c) {
      final matchesQuery =
          query == null || c.title.toLowerCase().contains(query.toLowerCase());
      final matchesCategory =
          category == null || category == 'All' || c.category == category;
      final matchesFilter =
          filter == null || filter == 'All' || c.level == filter;
      return matchesQuery && matchesCategory && matchesFilter;
    }).toList();

    return ExploreResponse(
      courses: filtered,
      categories: ['All', 'Aari', 'Tailoring', 'Embroidery', 'Blouse Design'],
      filters: [
        'All',
        'Beginner',
        'Intermediate',
        'Advanced',
        'Popular',
        'Paid'
      ],
    );
  }

  @override
  Future<MyCoursesResponse> getMyCourses() async {
    await Future.delayed(const Duration(milliseconds: 700));

    final ongoing = [
      CourseSummary(
        id: '1',
        title: 'Aari Embroidery Masterclass',
        instructor: 'Priya Sharma',
        category: 'Aari',
        image: 'assets/images/aari_hero.png',
        progress: 0.65,
      ),
      CourseSummary(
        id: '3',
        title: 'Modern Zardosi Art',
        instructor: 'Elena Rose',
        category: 'Design',
        image: 'assets/images/zardosi_activity.png',
        progress: 0.25,
      ),
    ];

    final completed = [
      CourseSummary(
        id: '4',
        title: 'Bridal Blouse Masterclass',
        instructor: 'Kavitha R.',
        category: 'Design',
        image: 'assets/images/theory_activity.png',
        progress: 1.0,
      ),
    ];

    return MyCoursesResponse(
      ongoing: ongoing,
      completed: completed,
      totalEnrolled: ongoing.length + completed.length,
      totalCertificates: completed.length,
    );
  }
}
