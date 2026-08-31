# Mulgil

흐르듯 공부하다 — 필기·퀴즈·AI 요약을 한 앱에서.

## 스택

- **Flutter** (Dart) — iOS / Android / Web
- **google_fonts** — Noto Sans KR + Nunito
- **flutter_lints** — 정적 분석

## 실행

```bash
# 의존성 설치
flutter pub get

# iOS 시뮬레이터 (권장)
open -a Simulator
flutter run

# 웹
flutter run -d chrome
```

## 코드 품질

```bash
# 포맷 (prettier 역할)
dart format lib/

# lint 체크
flutter analyze

# 자동 수정
dart fix --apply
```

VS Code에서 저장 시 자동 포맷 적용됨 (`.vscode/settings.json` 포함).

## 프로젝트 구조

```
lib/
├── main.dart                  # 앱 진입점, 라우트
├── theme/
│   └── app_theme.dart         # 컬러 토큰, 텍스트 스타일, ThemeData
├── data/
│   └── mock_data.dart         # 백엔드 연동 전 목업 데이터 (Course/Exam/Quiz 등)
├── models/                    # Course, TimetableSlot, Exam, Lecture, QuizQuestion 등
├── widgets/
│   ├── common_widgets.dart    # MulgilButton, MulgilChip, CourseDropdown, BackIfPushed 등
│   ├── course_form_sheet.dart # 과목 추가 폼 (온보딩·설정 공용)
│   └── mulgil_logo.dart       # 로고 버블 + Wordmark
└── screens/
    ├── auth/                  # Google 로그인
    ├── onboarding/            # 온보딩 (스플래시 → 시간표 등록)
    ├── shell_screen.dart      # 네비게이션 셸 (모바일: 바텀탭 / iPad: 사이드바)
    ├── home/                  # 홈 대시보드
    ├── note/                  # 필기 목록 · 상세 · PDF 업로드 · AI 요약
    ├── quiz/                  # 퀴즈 (O/X · 4지선다)
    ├── review/                # 오답 노트
    ├── report/                # 주간 리포트
    ├── exam/                  # 시험 관리 (기출 첨부, 요약/예상문제 생성)
    ├── notification/          # 알림함
    ├── recording/             # 강의 녹음 업로드
    └── settings/              # 설정 (과목 관리, 법적 고지 등)
```

## 적응형 레이아웃

```dart
final isTablet = MediaQuery.of(context).size.width > 768;
```

- **모바일**: 바텀 네비게이션 바 (홈 / 필기 / 퀴즈 / 오답노트 / 마이)
- **iPad**: 다크 사이드바 (홈 / 과목 / 퀴즈 / 오답노트 / 리포트 / 설정) + 스플릿 뷰

홈 화면의 "필기"·"퀴즈"·"설정" 진입은 셸의 탭 전환으로 처리되어 사이드바/바텀바가 유지됩니다. 셸 탭과 겹치지 않는 화면(요약, 녹음, 시험 관리, 알림함, PDF 업로드 등)은 push되며, 이때만 뒤로가기 화살표가 나타납니다(`BackIfPushed` 위젯, `Navigator.canPop` 기반).

## 라우트

| 경로 | 화면 |
|---|---|
| `/login` | Google 로그인 (초기 진입) |
| `/onboarding` | 온보딩 |
| `/` | 셸 (홈) |
| `/note` | 필기 목록 |
| `/note/detail` | 필기 상세 (필기/타이핑 모드) |
| `/note/pdf-upload` | PDF 자료 업로드 |
| `/summary` | AI 요약 |
| `/quiz` | 퀴즈 |
| `/settings` | 설정 |
| `/notifications` | 알림함 |
| `/exams` | 시험 관리 |
| `/recording` | 강의 녹음 업로드 |

오답 노트·주간 리포트는 셸의 탭 콘텐츠로만 존재하며 별도 라우트가 없습니다(항상 `ShellScreen`을 통해서만 접근).
