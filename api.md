# ART-Mobile API Reference

**Base URL:** `http://192.168.29.72:8000/api/v1/` (configurable via `--dart-define=BASE_URL=...`)

**Auth:** All endpoints except auth use `Authorization: Bearer <token>` header. Token is stored in secure storage after login/OTP verification.

**Response envelope:** Successful responses wrap data in `{"success": true, "data": {...}}`. Errors return `{"success": false, "message": "..."}`.

---

## 1. Auth

### `POST auth/send-otp`

Request OTP for phone login.

**Request:**
```json
{
  "phone_number": "+919876543210"
}

**Response:**
```json
{
  "success": true,
  "data": {
    "is_existing_user": false,
    "can_proceed": true
  }
}
```

### `POST auth/otp/verify`

Verify OTP and log in.

**Request:**
```json
{
  "id_token": "<firebase-id-token>",
  "name": "Raman",
  "device": {
    "device_id": "...",
    "device_name": "...",
    "manufacturer": "...",
    "brand": "...",
    "android_version": "...",
    "platform": "android",
    "fcm_token": "..."
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "jwt-access-token",
    "refresh_token": "jwt-refresh-token",
    "is_new_user": false,
    "is_registration_complete": true,
    "user": {
      "id": "user-uuid",
      "name": "Raman",
      "email": null,
      "phone": "+919876543210",
      "avatar": null,
      "role": "student",
      "is_verified": true
    }
  }
}
```

### `POST auth/firebase/login`

Google Sign-In login.

**Request:**
```json
{
  "firebase_token": "<firebase-id-token>",
  "device": { "...": "..." }
}
```

**Response:** Same as OTP verify.

### `GET auth/device/approval-status`

Check if device is approved. Returns `{"success": true, "data": {"is_approved": true}}`.

### `GET users/profile`

Get logged-in user's profile.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user-uuid",
    "name": "Raman",
    "email": "raman@example.com",
    "phone": "+919876543210",
    "avatar": "https://cdn.example.com/avatar.jpg",
    "role": "student",
    "is_verified": true
  }
}
```

### `PUT users/profile`

Update profile fields. Only send fields to update.

**Request:**
```json
{
  "name": "New Name",
  "email": "newemail@example.com"
}
```

**Response:** Same as `GET users/profile`. The updated user object is also persisted to secure storage.

---

## 2. Courses

### `GET courses/home`

Home screen data — banners, continue learning, featured courses, categories, instructors.

**Response:**
```json
{
  "success": true,
  "data": {
    "banners": [
      {
        "title": "Master Aari Embroidery",
        "subtitle": "50+ hours of premium content",
        "badge": "New",
        "image": "https://cdn.example.com/banner1.jpg",
        "colors": [10937386, 11240492]
      }
    ],
    "continue_learning": [
      {
        "id": "course-uuid",
        "title": "Aari Embroidery Masterclass",
        "instructor": "Priya Sharma",
        "category": "Aari",
        "image": "https://cdn.example.com/aari.jpg",
        "progress": 0.65,
        "badge": null,
        "discount": null,
        "rating": 4.8,
        "reviews": 1240,
        "price": 999,
        "original_price": 1999,
        "level": "Intermediate"
      }
    ],
    "featured_courses": [ "...same CourseSummary format..." ],
    "categories": ["All", "Aari", "Tailoring", "Embroidery", "Blouse Design"],
    "instructors": [
      {
        "name": "Priya S.",
        "initial": "P",
        "colors": [10937386, 11240492]
      }
    ]
  }
}
```

### `GET courses`

Explore/courses listing with optional filters.

**Query params:** `?query=aari&category=Tailoring&filter=Beginner`

**Response (list):**
```json
{
  "success": true,
  "data": [
    { "... CourseSummary fields ..." },
    { "... CourseSummary fields ..." }
  ]
}
```

Or alternatively:
```json
{
  "success": true,
  "data": {
    "courses": [ "... list of CourseSummary ..." ],
    "categories": ["All", "Aari", "Tailoring"],
    "filters": ["All", "Beginner", "Intermediate", "Advanced", "Popular", "Paid"]
  }
}
```

### `GET courses/{courseId}`

Full course detail including curriculum and reviews.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "course-uuid",
    "title": "Aari Embroidery Masterclass",
    "description": "Master the ancient art...",
    "instructor": "Priya Sharma",
    "instructor_avatar": "https://cdn.example.com/avatar.png",
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
    "image": "https://cdn.example.com/aari.jpg",
    "is_wishlisted": false,
    "curriculum": [
      {
        "id": "sec-uuid",
        "title": "Section 1: Introduction & Basics",
        "lessons": [
          {
            "id": "lesson-uuid",
            "title": "Welcome to the Masterclass",
            "duration": "05:00",
            "video_url": "https://d3aj7czvezt6jf.cloudfront.net/videos/xxx.mp4",
            "is_completed": true,
            "is_preview": true
          }
        ]
      }
    ],
    "reviews_list": [
      {
        "id": "review-uuid",
        "name": "Anjali Gupta",
        "avatar": "https://cdn.example.com/a.jpg",
        "rating": 5,
        "comment": "Amazing course!",
        "date": "2 days ago"
      }
    ]
  }
}
```

**Flexible field names:** The model accepts `curriculum|sections|modules|lessons`, `reviews_list|reviews|testimonials`, `video_url|video|s3_video_url|video_file|preview_video_url|trailer_url|promo_video_url`. See `course_model.dart:46-78`.

### `GET courses/my-courses`

User's enrolled courses (ongoing + completed).

**Response:**
```json
{
  "success": true,
  "data": {
    "ongoing": [
      { "... CourseSummary with progress ..." }
    ],
    "completed": [
      { "... CourseSummary with progress: 1.0 ..." }
    ],
    "total_enrolled": 3,
    "total_certificates": 1
  }
}
```

---

## 3. Video

### `POST videos/signed-url`

Get a signed CloudFront URL for a video file.

**Request:**
```json
{
  "file_name": "35c08323-15ac-4eba-8efd-c37741ededad.mp4"
}
```

**Response:**
```json
{
  "success": true,
  "url": "https://d3aj7czvezt6jf.cloudfront.net/videos/xxx.mp4?Expires=...&Signature=..."
}
```

The app passes full CDN URLs from course/lesson data directly to `VideoPlayerController.networkUrl` if they're already valid HTTPS URLs. The signed-url endpoint is used when only a file name/key is available.

---

## 4. Subscriptions / Payments

### `GET payments/plans`

Subscription plan listings.

**Response:**
```json
{
  "success": true,
  "data": {
    "header_title": "Unlock Premium",
    "header_subtitle": "Get unlimited access...",
    "highlights": ["100+ Courses", "Live Classes", "Certificates", "Offline Access"],
    "testimonial": {
      "quote": "\"Subscribing was the best decision...\"",
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
        "colors": [4531752, 8289890],
        "features": ["Access to all courses", "HD video quality"],
        "popular": false,
        "savings": null
      }
    ]
  }
}
```

**Icon values:** `"zap"` → flash icon, `"crown"` → premium icon, `"infinity"` → all-inclusive icon.

---

## Data Models Summary

| Model | Fields |
|-------|--------|
| `CourseSummary` | id, title, instructor, category, image, progress?, badge?, discount?, rating, reviews, price, original_price, level |
| `CourseDetail` | id, title, description, instructor, instructor_avatar, instructor_role, level, category, duration, lesson_count, rating, reviews, students, price, original_price, image, video_url, is_wishlisted, curriculum[], reviews_list[] |
| `CurriculumSection` | id, title, lessons[] |
| `CourseLesson` | id, title, duration, video_url, is_completed, is_preview |
| `CourseReview` | id, name, avatar, rating, comment, date |
| `BannerModel` | title, subtitle, badge, image, colors[] |
| `InstructorSummary` | name, initial, colors[] |
| `HomeResponse` | banners[], continue_learning[], featured_courses[], categories[], instructors[] |
| `ExploreResponse` | courses[], categories[], filters[] |
| `MyCoursesResponse` | ongoing[], completed[], total_enrolled, total_certificates |
| `SubscriptionResponse` | header_title, header_subtitle, highlights[], testimonial{}, plans[] |
| `SubscriptionPlan` | id, label, price, original_price, period, icon, colors[], features[], popular, savings |
