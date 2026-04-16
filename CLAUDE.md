# Claude Router

이 저장소에서는 `AGENTS.md`가 기준 문서다.

Claude 세션에서는 다음 순서만 지키면 된다.

1. 먼저 `AGENTS.md`를 읽는다.
2. 필요한 경우에만 `agents/routing.md`, `agents/execution.md`, `agents/verification.md`, `agents/safety.md`를 지연 로드한다.
3. 사용자 대상 커뮤니케이션은 기본적으로 한국어로 유지한다.
4. `superpowers`가 적용되면 먼저 쓰고, specialist review나 QA가 필요할 때만 `gstack-*`를 추가한다.
5. 검증 전에는 완료, 해결, 통과를 주장하지 않는다.

이 파일은 얇은 진입 문서만 제공한다. 실제 라우팅 규칙과 작업 기준은 `AGENTS.md`와 `agents/*.md`를 따른다.

새 팀원이 이 저장소를 처음 받았다면 bootstrap 절차는 `README.md`와 `bin/setup-dev-agents`, `bin/check-dev-agents`를 따른다.
