# Frontend / Backend Alignment Report

## 이번에 맞춘 부분

- API 기본 주소는 `https://ssuway.lapis0875.com` 기준으로 사용한다.
- 새 API 계층에서는 `ApiClient`를 통해 JSON 요청, Bearer token, 에러 응답을 공통 처리한다.
- 과목은 백엔드의 `GET/POST /api/v1/courses`, `PATCH/DELETE /api/v1/courses/{courseId}` 계약과 프론트 `Course` 모델을 맞췄다.
- 시간표는 과목과 별도 리소스인 `GET/POST /api/v1/timetable/slots`, `PATCH/DELETE /api/v1/timetable/slots/{slotId}` 계약을 따른다.
- 시험 일정은 `courseName`이 아니라 `courseId`를 기준으로 연결하는 것이 맞다.
- 시험 생성은 `/api/v1/courses/{courseId}/exams`에 `title`, `examAt`, `sessionIds`를 보내는 방식으로 맞췄다.
- 시험 날짜는 프론트 날짜 선택 UI에 맞춰 `Asia/Seoul` 기준 자정을 서버 `Instant`로 보낸다.
- 아직 화면 코드는 대부분 `MockData`를 사용한다. 이번 단계는 실제 화면 연결 전 API 계약 계층을 추가한 상태다.

## 프론트에는 있지만 백엔드 계약이 아직 부족한 부분

- 시험 일정 수정/삭제 UI가 있지만, 현재 백엔드에는 시험 수정/삭제 API가 없다.
  - 현재 프론트는 해당 기능을 서버 미지원으로 안내해야 한다.
- 알림 톤 선택(조용함/동기부여 톤)은 유저 플로우에는 있지만 현재 백엔드 preference API가 없다.
  - 실제 연결 시 빈 상태로 남기거나 미지원 표시가 필요하다.
- 주간 리포트/학습 통계 화면은 프론트에 있지만 현재 직접 대응되는 조회 API가 없다.
  - mock 제거 시 빈 상태 또는 “아직 데이터 없음” 상태가 필요하다.
- 프로필 상세 정보(학교, 학과, 학년)는 프론트 mock에는 있지만 현재 auth 응답/프로필 API와 직접 매핑되지 않는다.

## 백엔드에는 있지만 프론트 구현이 부족한 부분

- PDF 자료 업로드는 백엔드에 signed upload URL 흐름이 있지만, 프론트에는 실제 파일 선택/PUT 업로드/checksum 완료 처리가 없다.
- 녹음 업로드는 백엔드에 upload URL, 완료, 차시 후보, 차시 확정 API가 있지만, 프론트에는 mock 후보 표시만 있다.
- FCM 기기 토큰 등록/삭제 API가 있지만, 프론트에는 실제 push token 등록 흐름이 없다.
- 노트/필기 API는 백엔드에 조회/생성/수정/leave가 있지만, 프론트는 `NotesStore` 기반 로컬 상태를 사용한다.
- PDF annotation API는 백엔드에 있지만, 프론트 필기 저장은 아직 서버와 연결되지 않았다.
- job polling API는 백엔드에 있지만, 프론트의 AI 생성/업로드 진행 상태는 대부분 mock delay로 처리된다.

## 연결할 때 주의할 부분

- 인증이 먼저 연결되지 않으면 과목/시간표/시험 API는 401이 날 수 있다.
- 현재 로그인은 mock이므로, 실제 API 화면 전환 전에 access token 저장과 Google Sign-In 연결이 필요하다.
- 현재 프론트 시험 목록 화면은 전체 시험 목록처럼 동작하지만, 백엔드는 과목별 시험 목록만 제공한다.
  - 해결 방향: 과목 목록 조회 후 각 과목의 시험 목록을 병합해서 보여준다.
- 차시가 없는 과목은 시험을 생성할 수 없다. 백엔드 `ExamCreateRequest`는 `sessionIds`를 필수로 요구한다.
- 시험 목록을 보여줄 때는 `sessionIds`만으로 화면 문구를 만들 수 없다.
  - 해결 방향: 과목별 차시 목록을 함께 조회한 뒤 `sessionIds`를 차시 제목/주차로 매핑한다.
- 과목 삭제는 soft delete라 백엔드에서 목록/시간표에서 숨겨지고 연관 데이터는 보존된다.
