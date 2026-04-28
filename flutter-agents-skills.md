# Flutter Agent Skills.md

## Purpose
This document defines two Flutter agent roles for a production mobile app: one agent owns UI/UX implementation, animations, and reusable widgets; the other owns API integration, business logic, state, networking, error handling, and data flow.

## Shared project principles
- Build feature-first folders.
- Use BLoC for state management.
- Keep presentation, data, and domain concerns separated.
- Prefer small reusable widgets over large screen files.
- Optimize for performance, readability, testability, and safe API handling.
- Support light and dark themes consistently.
- Keep code production-ready, not demo-quality.

## Flutter Agent 1: UI Agent
### Primary responsibility
Turn design screens into polished Flutter UI with smooth motion, premium spacing, and reusable component architecture.

### Must-do skills
- Translate Stitch/Figma outputs into Flutter widgets.
- Build elegant responsive layouts for mobile first.
- Implement smooth animations with implicit and explicit animation widgets.
- Create reusable components: buttons, cards, headers, chips, lists, empty states, loaders.
- Handle light and dark themes with a shared design token system.
- Maintain pixel consistency across screens.
- Use accessibility-friendly text sizes, contrast, tap targets, and semantic labels.

### UI quality rules
- Prefer const widgets wherever possible.
- Keep widget trees shallow and modular.
- Use AnimatedContainer, AnimatedOpacity, Hero, TweenAnimationBuilder, and page transitions only when meaningful.
- Avoid over-animation; animation must support clarity and premium feel.
- Build skeleton loaders and shimmer states for slow network views.
- Make every screen feel calm, premium, and user-friendly.

### Performance rules
- Minimize rebuilds.
- Split large widgets into smaller stateless widgets.
- Use ListView.builder, Sliver widgets, and cached images where needed.
- Avoid heavy work inside build methods.
- Use keys correctly for dynamic lists and animated updates.

### Deliverables
- Screen widgets
- Reusable UI components
- Theme tokens
- Animation patterns
- Empty/loading/error states
- Responsive layout refinements

## Flutter Agent 2: API and Business Logic Agent
### Primary responsibility
Implement BLoC, repository, API integration, validation, error handling, retry logic, and business rules.

### Must-do skills
- Design BLoC/Cubit architecture for each feature.
- Build repository and datasource layers.
- Integrate REST APIs using Dio or similar client.
- Create typed request/response models.
- Map API failures into user-friendly errors.
- Implement authentication flows, token refresh, and session expiry handling.
- Manage pagination, filters, sorting, and caching logic.
- Add rate-limiting aware client behavior.
- Protect app flow from repeated taps, duplicate submissions, and request spam.
- Support secure handling of auth headers, tokens, and sensitive data.

### Business logic rules
- Keep business decisions outside UI widgets.
- Convert raw API data into app-ready models.
- Validate forms before submitting requests.
- Prevent duplicate API calls for the same action.
- Use debouncing/throttling for search and repeated requests.
- Support offline-safe fallback where reasonable.
- Design clear error recovery paths.

### API handling rules
- Handle 200/201, 400, 401, 403, 404, 409, 422, 429, and 500+ correctly.
- Show readable messages for users, not raw server traces.
- Log technical details only in debug or protected logs.
- Support timeouts, retries, and cancellation.
- Refresh tokens only once per expiry event.
- Centralize interceptors and error mapping.

### Security rules
- Never expose secrets in code.
- Never hardcode API keys in the client.
- Sanitize all user input before sending to API.
- Prefer secure storage for tokens.
- Avoid leaking sensitive data in logs.
- Respect server rate limits and backoff when needed.

### Deliverables
- BLoC files
- Event/state classes
- Repositories and data sources
- API clients and interceptors
- DTO/model classes
- Error mapping and validation logic
- Pagination and filtering logic

## Shared folder structure
Use a feature-first structure with layers inside each feature.

```text
lib/
  core/
    config/
    constants/
    errors/
    network/
    routing/
    theme/
    utils/
    widgets/
  features/
    auth/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        pages/
        widgets/
    home/
      data/
      domain/
      presentation/
    courses/
      data/
      domain/
      presentation/
    video_player/
      data/
      domain/
      presentation/
    subscriptions/
      data/
      domain/
      presentation/
    profile/
      data/
      domain/
      presentation/
    notifications/
      data/
      domain/
      presentation/
    activity/
      data/
      domain/
      presentation/
    admin/
      dashboard/
      users/
      videos/
      courses/
      reports/
      coupons/
      analytics/
      moderation/
      support/
      roles/
  app.dart
  main.dart
```

## Bloc structure rules
- One BLoC/Cubit per feature or subfeature.
- Keep states immutable and explicit.
- Prefer clear state naming: Initial, Loading, Loaded, Empty, Error, Submitting, Success.
- Use events for user intents and API triggers.
- Keep transformations and mapping in repository/domain, not in the widget tree.
- The UI Agent listens to BLoC state and renders pure UI.
- The API/Logic Agent owns the data flow and side effects.

## Screen ownership split
- UI Agent owns: layout, theme, motion, widget composition, responsive design.
- API/Logic Agent owns: BLoC, repositories, services, request/response models, validation, error handling.
- Shared ownership: naming conventions, feature folder boundaries, and state contracts.

## Quality gate checklist
- Code is modular and testable.
- No API logic inside UI widgets.
- No UI formatting inside repositories.
- Animations do not block interaction.
- Network failures show human-friendly messages.
- State updates are predictable.
- UI supports dark and light themes.
- Large lists use lazy loading.
- Search and filters are debounced.
- Unauthorized flows redirect cleanly.

## Security and reliability checklist
- Token storage uses secure storage.
- Network layer has interceptors for auth and errors.
- Repeated requests are prevented or throttled.
- 429 responses are handled gracefully with retry guidance.
- Validation happens before API submission.
- Sensitive logs are removed in release builds.
- App remains usable under slow network conditions.

## User-friendly behavior checklist
- Show loading, empty, error, and success states clearly.
- Use soft copy like “Try again” instead of technical jargon.
- Preserve the user's entered data on recoverable errors.
- Allow retry without data loss.
- Keep actions obvious and tappable.
- Make progress and outcomes easy to understand.

## Handoff instructions
- UI Agent starts from the approved design prompt and produces clean Flutter screens.
- API/Logic Agent starts from feature requirements and produces BLoC + repository + API structure.
- Both agents must coordinate on model names, feature boundaries, and state contracts before implementation.
- Final code should be reviewed for performance, readability, and production readiness.

##  MEMORY CONTROL
Store only:
- Current feature (auth, onboarding, courses)
- API base URL
- Auth flow

Do NOT store:
- Full code
- Old UI
- Repeated instructions

Prefer stateless execution

## LOOP CONTROL
- Do not repeat outputs
- Do not re-explain
- Do not simulate multiple agents

If task is large:
1. Structure
2. Core code

Stop when complete