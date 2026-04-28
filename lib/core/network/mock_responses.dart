/// [MockResponses] centralizes all mock API data and responses for the application.
/// This single file serves as the source of truth for all mock data across all features.
class MockResponses {
  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------
  
  static const Map<String, dynamic> loginResponse = {
    "status": "success",
    "message": "OTP sent successfully",
    "data": {
      "phone_number": "8248628437",
      "session_id": "sess_8248628437",
      "is_existing_user": false
    }
  };

  static const Map<String, dynamic> verifyOtpResponse = {
    "status": "success",
    "message": "Login successful",
    "data": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "d9823kjsd89...",
      "is_new_user": true,
      "is_registration_complete": false,
      "user": {
        "id": "u1",
        "name": "",
        "email": "",
        "phone": "8248628437",
        "avatar": "",
        "role": "user",
        "is_verified": true
      }
    }
  };

  static const Map<String, dynamic> googleSignInResponse = {
    "status": "success",
    "message": "Google sign-in successful",
    "data": {
      "access_token": "google_jwt_token_...",
      "refresh_token": "google_refresh_...",
      "is_new_user": true,
      "is_registration_complete": false,
      "user": {
        "id": "u2",
        "name": "John Doe",
        "email": "john.doe@gmail.com",
        "avatar": "https://lh3.googleusercontent.com/a/ACg8ocL...",
        "role": "user"
     }
    }
  };

  // ---------------------------------------------------------------------------
  // HOME & COURSES
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> homeDataResponse = {
    "categories": ["All", "Aari", "Tailoring", "Embroidery", "Blouse Design"],
    "banners": [
      {
        "title": "Master Aari Embroidery",
        "subtitle": "50+ hours of premium content",
        "badge": "New",
        "image": "assets/images/aari_hero.png",
        "colors": [0xFF6A1B9A, 0xFFAB47BC]
      },
      {
        "title": "Tailoring Masterclass",
        "subtitle": "From beginner to pro",
        "badge": "Popular",
        "image": "assets/images/silk_course.png",
        "colors": [0xFF4527A0, 0xFF7E57C2]
      }
    ],
    "continue_learning": [
      {
        "id": "1",
        "title": "Aari Embroidery Masterclass",
        "instructor": "Priya Sharma",
        "category": "Aari",
        "image": "assets/images/aari_hero.png",
        "progress": 0.65,
        "rating": 4.8,
        "reviews": 1240,
        "price": 999,
        "original_price": 1999
      }
    ],
    "featured_courses": [
      {
        "id": "3",
        "title": "Modern Zardosi Art",
        "instructor": "Elena Rose",
        "category": "Design",
        "image": "assets/images/zardosi_activity.png",
        "badge": "Beginner",
        "discount": "-48%",
        "rating": 4.9,
        "reviews": 520,
        "price": 799,
        "original_price": 1599
      }
    ]
  };

  static Map<String, dynamic> getCourseDetail(String id) => {
    "id": id,
    "title": "Aari Embroidery Masterclass",
    "description": "Master the ancient art of Aari embroidery with this comprehensive masterclass. We cover everything from setting up your frame to executing complex bridal designs with precision.",
    "instructor": "Priya Sharma",
    "instructor_avatar": "assets/images/profile_avatar.png",
    "instructor_role": "Expert Instructor · 5 years exp",
    "level": "INTERMEDIATE",
    "category": "Aari Embroidery",
    "duration": "12H 45M",
    "lesson_count": 24,
    "rating": 4.8,
    "reviews": 1240,
    "students": 3720,
    "price": 999,
    "original_price": 1999,
    "image": "assets/images/aari_hero.png",
    "is_wishlisted": false,
    "curriculum": [
      {
        "id": "s1",
        "title": "Section 1: Introduction & Basics",
        "lessons": [
          {
            "id": "l1", 
            "title": "Welcome to the Masterclass", 
            "duration": "05:00", 
            "video_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", 
            "is_preview": true, 
            "is_completed": true
          }
        ]
      }
    ]
  };

  // ---------------------------------------------------------------------------
  // NOTIFICATIONS
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> notificationsResponse = {
    "notifications": [
      {
        "id": "n1",
        "type": "lesson",
        "title": "New Lesson Available",
        "body": "\"Chain Stitch Basics\" in Aari Embroidery Masterclass is now live!",
        "time": "Just now",
        "read": false,
        "icon_type": "play"
      },
      {
        "id": "n2",
        "type": "promo",
        "title": "Special Offer!",
        "body": "Get 50% off on Bridal Embroidery Masterclass for the next 24 hours.",
        "time": "2 hours ago",
        "read": true,
        "icon_type": "gift"
      }
    ]
  };

  // ---------------------------------------------------------------------------
  // PROFILE & SETTINGS
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> userProfileResponse = {
    "id": "u1",
    "name": "Priya Sharma",
    "email": "priya.sharma@email.com",
    "phone": "+91 9876543210",
    "avatar": "assets/images/profile_avatar.png",
    "bio": "Passionate about traditional Indian embroidery and tailoring.",
    "membership": "Premium",
    "stats": {
      "courses_completed": 12,
      "certificates_earned": 8,
      "learning_hours": 145
    },
    "settings": {
      "push_notifications": true,
      "email_updates": false,
      "dark_mode": true
    }
  };

  // ---------------------------------------------------------------------------
  // SUBSCRIPTIONS
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> subscriptionPlansResponse = {
    "header_title": "Unlock Premium",
    "header_subtitle": "Get unlimited access to all Aari & Tailoring courses and learn from expert instructors",
    "highlights": ["100+ Courses", "Live Classes", "Certificates", "Offline Access"],
    "testimonial": {
      "quote": "\"Subscribing to the yearly plan was the best decision. I completed 8 courses and now run my own embroidery business!\"",
      "author": "Sunitha Rao",
      "role": "Yearly subscriber",
      "initial": "S"
    },
    "plans": [
      {
        "id": "monthly",
        "label": "Monthly",
        "price": 299,
        "original_price": 499,
        "period": "/month",
        "icon": "zap",
        "colors": [0xFF4527A0, 0xFF7E57C2],
        "features": [
          "Access to all courses",
          "HD video quality",
          "Download for offline",
          "Chat support"
        ]
      },
      {
        "id": "yearly",
        "label": "Yearly",
        "price": 1999,
        "original_price": 3588,
        "period": "/year",
        "icon": "crown",
        "popular": true,
        "savings": "Save ₹1,589",
        "colors": [0xFF6A1B9A, 0xFFAB47BC],
        "features": [
          "Everything in Monthly",
          "Priority support",
          "Certificate of completion",
          "Exclusive live sessions",
          "Early access to new courses"
        ]
      },
      {
        "id": "lifetime",
        "label": "Lifetime",
        "price": 4999,
        "original_price": 12000,
        "period": " one-time",
        "icon": "infinity",
        "savings": "Best Value",
        "colors": [0xFF880E4F, 0xFFAD1457],
        "features": [
          "Everything in Yearly",
          "Lifetime access",
          "All future courses",
          "1-on-1 mentorship sessions",
          "Physical kit delivery"
        ]
      }
    ]
  };

  // ---------------------------------------------------------------------------
  // ADMIN DASHBOARD
  // ---------------------------------------------------------------------------

  };
}
