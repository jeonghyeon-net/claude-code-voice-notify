# claude-code-voice-notify

Claude Code hook events에 맞춰 Warcraft III Peasant 음성을 재생하는 플러그인.

## Install

```bash
/plugin marketplace add jeonghyeon-net/claude-code-voice-notify
/plugin install peon-notifications@claude-code-voice-notify
```

## Events

| Event | Category | Description |
|---|---|---|
| `SessionStart` | `session_start/` | 세션 시작 시 재생 |
| `Stop` | `stop/` | Claude 응답 완료 시 재생 |
| `UserPromptSubmit` | `user_prompt/` | 사용자 입력 시 재생 |
| `PreToolUse` | `work/` | 도구 호출 시 재생 (30초 쿨다운) |
| `Notification` | `notification/` | 알림 도착 시 재생 |

## Sounds

`sounds/{category}/` 디렉토리에 MP3/WAV/AIFF 파일을 넣으면 자동 인식.
카테고리 내 파일이 여러 개면 랜덤으로 하나를 선택해서 재생한다.

### 기본 포함 사운드

```
sounds/
├── session_start/
│   └── ready_to_work.mp3
├── stop/
│   └── jobs_done.mp3
├── user_prompt/
│   ├── yes_me_lord.mp3
│   ├── what_is_it.mp3
│   └── more_work.mp3
├── work/
│   ├── right_o.mp3
│   ├── all_right.mp3
│   └── thats_it.mp3
└── notification/
    └── (empty)
```

### 사운드 추가/교체

카테고리 디렉토리에 MP3/WAV/AIFF 파일을 추가하면 된다.
파일명은 자유. 기존 파일을 삭제하거나 교체해도 된다.

## Notes

- `work` 카테고리는 30초 쿨다운 (도구 호출이 빈번하므로)
- `stop` 이벤트는 무한루프 방지 로직 내장
- 사운드 파일이 없는 카테고리는 조용히 무시됨
- macOS (`afplay`) / Linux (`paplay`, `mpv`, `aplay`) 지원
