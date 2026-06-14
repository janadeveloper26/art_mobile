# S3 Video Upload & CloudFront Streaming Plan

The Flutter app already supports CloudFront video streaming via `S3VideoService` + `VideoPlayerBloc`. This plan covers the **Django backend side** — admin upload → S3 → CloudFront → signed URL delivery.

---

## 1. Django — S3 Storage Setup

### 1.1 Install packages
```
pip install boto3 django-storages[s3]
```

### 1.2 `settings.py` — S3 config
```python
AWS_ACCESS_KEY_ID = config('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = config('AWS_SECRET_ACCESS_KEY')
AWS_STORAGE_BUCKET_NAME = config('AWS_STORAGE_BUCKET_NAME')
AWS_S3_REGION_NAME = config('AWS_S3_REGION_NAME', default='ap-south-1')
AWS_S3_CUSTOM_DOMAIN = config('CLOUDFRONT_DOMAIN')  # e.g. d1234.cloudfront.net
AWS_S3_OBJECT_PARAMETERS = {'CacheControl': 'max-age=86400'}
AWS_DEFAULT_ACL = 'private'
AWS_LOCATION = 'videos'

# Video file storage
from storages.backends.s3boto3 import S3Boto3Storage

class VideoStorage(S3Boto3Storage):
    location = 'videos'
    file_overwrite = False
    default_acl = 'private'
```

### 1.3 IAM Policy (minimum)
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:PutObject", "s3:GetObject"],
            "Resource": "arn:aws:s3:::your-bucket/videos/*"
        }
    ]
}
```

---

## 2. Django — Video Model

```python
from django.db import models

class Video(models.Model):
    title = models.CharField(max_length=255)
    file = models.FileField(storage=VideoStorage(), upload_to='lessons/')
    duration_seconds = models.PositiveIntegerField(null=True, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def cloudfront_url(self):
        """Public CloudFront URL for the video file."""
        return f"https://{settings.AWS_S3_CUSTOM_DOMAIN}/{self.file.name}"

    def __str__(self):
        return self.title
```

### Add to CourseLesson model
```python
class CourseLesson(models.Model):
    # ... existing fields ...
    video = models.ForeignKey(
        Video, on_delete=models.SET_NULL, null=True, blank=True,
        related_name='lessons'
    )
```

---

## 3. Django Admin — Upload UI

### `admin.py`
```python
from django.contrib import admin
from django.utils.html import format_html

class VideoAdmin(admin.ModelAdmin):
    list_display = ('title', 'uploaded_at', 'video_preview')
    search_fields = ('title',)

    def video_preview(self, obj):
        if obj.file:
            return format_html(
                '<video width="320" height="180" controls>'
                '<source src="{}" type="video/mp4"></video>',
                obj.cloudfront_url()
            )
        return "-"
    video_preview.short_description = 'Preview'

admin.site.register(Video, VideoAdmin)
```

### Inline in CourseLesson admin
```python
class CourseLessonInline(admin.TabularInline):
    model = CourseLesson
    extra = 1
    fields = ('title', 'video', 'duration', 'is_preview', 'is_completed')
```

---

## 4. CloudFront — Distribution Setup

1. **Origin:** S3 bucket (`your-bucket.s3.ap-south-1.amazonaws.com`)
2. **Origin Access:** OAC (Origin Access Control) — restricts direct S3 access
3. **Behaviors:**
   - Path pattern: `videos/*`
   - Cache policy: `CachingOptimized` (24h TTL)
   - Allowed HTTP methods: `GET, HEAD, OPTIONS`
   - Viewer protocol policy: `HTTPS only`
4. **Signed URLs** (optional, for private content):
   - Create CloudFront key pair
   - Use `django-cloudfront-sign` or `botocore` to generate signed URLs with expiration

---

## 5. Django API — Signed URL Endpoint

The Flutter app already expects this. Implement it on the Django side:

### `urls.py`
```python
path('api/v1/videos/signed-url', views.get_signed_url, name='signed-url'),
```

### `serializers.py`
```python
from rest_framework import serializers

class SignedUrlRequestSerializer(serializers.Serializer):
    file_name = serializers.CharField(required=True)

class SignedUrlResponseSerializer(serializers.Serializer):
    url = serializers.URLField()
```

### `utils.py` — S3 pre-signed URL helper
```python
import boto3
from django.conf import settings

s3_client = boto3.client(
    's3',
    aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
    aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
    region_name=settings.AWS_S3_REGION_NAME,
)

def generate_s3_presigned_url(file_name: str, expires_in: int = 3600) -> str:
    """Generate a pre-signed S3 URL for direct access (fallback if CloudFront unavailable)."""
    return s3_client.generate_presigned_url(
        'get_object',
        Params={
            'Bucket': settings.AWS_STORAGE_BUCKET_NAME,
            'Key': f'lessons/videos/{file_name}',
        },
        ExpiresIn=expires_in,
    )
```

### `utils.py` — CloudFront signed URL helper (preferred)
```python
from botocore.signers import CloudFrontSigner
from datetime import datetime, timedelta
import rsa

def _cloudfront_rsa_signer(message):
    private_key = settings.CLOUDFRONT_PRIVATE_KEY.encode('ascii')
    return rsa.sign(message, rsa.PrivateKey.load_pkcs1(private_key), 'SHA1')

cloudfront_signer = CloudFrontSigner(settings.CLOUDFRONT_KEY_ID, _cloudfront_rsa_signer)

def generate_cloudfront_signed_url(file_name: str, expires_in: int = 3600) -> str:
    """Generate a CloudFront signed URL with OAC + signed URL for private content."""
    url = f"https://{settings.AWS_S3_CUSTOM_DOMAIN}/lessons/videos/{file_name}"
    return cloudfront_signer.generate_presigned_url(
        url,
        date_less_than=datetime.utcnow() + timedelta(seconds=expires_in),
    )
```

### `views.py` — production endpoint
```python
import logging
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.conf import settings

logger = logging.getLogger(__name__)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def get_signed_url(request):
    serializer = SignedUrlRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response({'error': 'file_name required'}, status=400)

    file_name = serializer.validated_data['file_name']

    try:
        # Strategy 1: CloudFront signed URL (preferred for production)
        if settings.CLOUDFRONT_KEY_ID and settings.CLOUDFRONT_PRIVATE_KEY:
            url = generate_cloudfront_signed_url(file_name)
        # Strategy 2: S3 pre-signed URL (fallback)
        elif settings.AWS_ACCESS_KEY_ID:
            url = generate_s3_presigned_url(file_name)
        else:
            return Response(
                {'error': 'No CDN or S3 credentials configured'},
                status=503,
            )

        return Response({'url': url})

    except Exception as e:
        logger.error(f'Failed to generate signed URL for {file_name}: {e}')
        return Response({'error': 'Failed to generate video URL'}, status=500)
```

### `urls.py`
```python
path('api/v1/videos/signed-url', views.get_signed_url, name='signed-url'),
```

### `.env` configuration
```env
# S3 (required)
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_STORAGE_BUCKET_NAME=gloriousart-videos
AWS_S3_REGION_NAME=ap-south-1

# CloudFront (optional — recommended for production)
CLOUDFRONT_DOMAIN=d1234example.cloudfront.net
CLOUDFRONT_KEY_ID=KX...     # CloudFront trusted key group key pair ID
CLOUDFRONT_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----"
```

---

## 6. Flutter Side — Already Built

### What already exists (no changes needed):
| Component | File | Status |
|-----------|------|--------|
| `S3VideoService` | `lib/features/video_player/data/s3_video_service.dart` | Built — calls `POST /videos/signed-url`, caches URLs, checks expiry |
| `VideoPlayerBloc` | `lib/features/video_player/presentation/bloc/` | Built — resolves URLs, initializes controller, manages state |
| `VideoPlayerPage` | `lib/features/video_player/presentation/pages/` | Built — loads course, picks lesson, renders player |
| URL field fallbacks | `lib/features/courses/data/models/course_model.dart` | Built — accepts `video_url`, `s3_video_url`, `video`, `video_file` etc. |
| `CLOUDFRONT_URL` env | `lib/core/config/environment.dart` | Configurable via `--dart-define=CLOUDFRONT_URL=...` |

### One-time config change:
Pass `CLOUDFRONT_URL` during build:
```bash
flutter run --dart-define=CLOUDFRONT_URL=https://d1234example.cloudfront.net
```

Or set it in `environment.dart` as the default.

---

## 7. Migration & Rollout Order

1. **AWS:** Create S3 bucket + CloudFront distribution → `30 min`
2. **Django:** Install `django-storages`, configure settings, run migrations → `30 min`
3. **Django:** Register VideoAdmin, add video field to CourseLesson → `15 min`
4. **Django:** Implement `/api/v1/videos/signed-url` endpoint → `15 min`
5. **Flutter:** Set `CLOUDFRONT_URL` env var → `5 min`
6. **Test:** Upload video in admin → verify CloudFront URL → play in app → `15 min`

**Total: ~2 hours**

---

## 8. Key Design Decisions

| Decision | Choice | Why |
|----------|--------|-----|
| File storage | S3 + django-storages | Direct upload, no app server bottleneck |
| CDN | CloudFront | Global edge, OAC security, signed URLs |
| Video model | FK on CourseLesson | Reuse videos across lessons, single upload point |
| Signed URLs | Optional (recommended) | Prevents hotlinking, time-bounded access |
| URL resolution | Flutter `S3VideoService` | Caches + deduplicates, handles expiry transparently |
| Admin preview | HTML5 `<video>` tag | Instant preview without downloading |
