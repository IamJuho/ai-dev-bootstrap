# Verification Rules

이 문서는 완료 주장 전 무엇을 검증해야 하는지 정한다.
이 문서가 결정하는 것은 `검증 게이트`, `변경 유형별 검증 강도`, `shipping 전 확인`이다.
이 문서는 테스트 프레임워크 자체를 설명하지 않는다.

## Verification Gate

- 코드, 설정, 문서처럼 repo 상태를 바꾸는 변경이 있었다면 `verification-before-completion` 기준을 적용한다.
- 검증 없이 `완료`, `해결`, `통과`, `잘 동작함` 같은 표현을 쓰지 않는다.
- 최종 응답에는 최소한 아래 세 가지를 남긴다.
- 실제 실행한 검증
- 확인된 결과
- 남아 있는 미검증 항목 또는 리스크

## Verification Matrix

- 작은 로컬 수정:
- 가장 작은 정직한 검증을 한다.
- 비사소한 구현:
- 관련 테스트, 정적 검사, 수동 확인 중 실제 변경을 증명하는 검증을 한다.
- 버그 수정:
- 원래 증상을 재현하는 검증과 수정 후 통과를 모두 확인한다.
- 문서 개편:
- 참조 경로, 문서 간 충돌, 누락된 링크나 파일명 불일치를 확인한다.

## UI / User-Facing Rules

- 사용자-facing 변경이면 `gstack-review`를 기본 검토 옵션으로 고려한다.
- 브라우저 기반 확인이나 사용자 흐름 검증이 필요하면 `gstack-qa`, `gstack-qa-only`, `gstack-browse` 중 하나를 쓴다.
- 시각적 polish나 디자인 일관성이 중요하면 `gstack-design-review`를 추가한다.

## Shipping Rules

- ship 또는 deploy 요청이면 먼저 `verification-before-completion`을 통과해야 한다.
- 사용자-facing ship이면 기본 순서는 다음과 같다.
- `verification-before-completion`
- `gstack-review`
- `gstack-qa`
- 이후 ship/deploy flow
- QA나 검증이 실패했으면 완료나 배포 준비 완료처럼 말하지 않는다.
