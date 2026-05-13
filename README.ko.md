# /munger — 찰리 멍거 의사결정 컨설팅 스킬 (Claude Code)

> 비가역적 결정을 내리기 전, 99세 Nebraska 노인에게 먼저 물어봐.

[Claude Code](https://docs.anthropic.com/claude-code) 스킬. 13개 검증된 공개 출처에서
추출한 **184개 verbatim Munger 인용**을 기반으로 "Brain of Munger"를 합성하고, Opus
sub-agent로 사용자의 결정을 Munger의 사고 도구 — inversion, latticework of mental
models, 25 standard causes of misjudgment, margin of safety, circle of competence —
에 통과시킨다.

출력은 **영어 + 한국어 이중 언어** 기본.

English README: [README.md](./README.md)

---

## 왜 이 스킬인가

대부분의 "AI 투자 조언"이 밋밋한 이유는 모델이 모든 voice를 평균내기 때문이다. 이
스킬은 정반대 — 모델을 *하나의 worldview에 핀으로 고정*하고, 184개 출처-검증 verbatim
인용으로 grounding하고, **terse, sardonic, unhedged, Munger-shaped**한 답을 강제하는
voice contract를 건다.

얻는 것:

- **Hybrid 출력 포맷**: 3-5 문단 Munger monologue (consulting-deck 헤더 없음) + 그
  뒤에 `Structured breakdown` (적용 모델, 트리거된 휴리스틱, 7일 내 구체적 다음
  행동).
- **이중 언어 기본**: 영어 원본 + 자연스러운 한국어 번역 (별도 번역 sub-agent 사용 —
  직역 금지).
- **8개 모드**: full / quick / buffett / debate / pushback / retro / eval / context.
- **검증 가능**: 모든 load-bearing 주장에 `_evals/extracted-quotes.md`로 역추적되는
  inline citation 부착. 1차 출처 URL까지 연결됨.
- **회귀 테스트**: 8개 canonical 질문 × vocab + anti-phrase + judge check. 마지막
  실행: **8/8 PASS, drift score 0**.

---

## 빠른 설치

### 한 줄 설치 (권장)

```bash
curl -fsSL https://raw.githubusercontent.com/jeongkpa/munger-skill/main/install.sh | bash
```

curl로 파이프하면 onboarding이 자동 실행되지 않습니다 (stdin이 TTY가 아니므로).
대화형 onboarding (3개 질문: 저장 경로, author wikilink, shell profile)을 실행하려면
clone 후 install.sh를 터미널에서 실행하세요:

```bash
git clone https://github.com/jeongkpa/munger-skill ~/.claude/skills/munger
bash ~/.claude/skills/munger/install.sh
```

설치 스크립트는 TTY를 감지하면 onboarding을 자동으로 띄웁니다. 언제든 다시 실행 가능:

```bash
bash ~/.claude/skills/munger/onboard.sh
```

### 수동 설치 (installer 스킵)

```bash
git clone https://github.com/jeongkpa/munger-skill ~/.claude/skills/munger
```

기본값으로 onboarding 없이도 작동합니다. Claude Code 세션 열고:

```
/munger 회사 그만두고 창업해야 할까요?
```

### Onboarding에서 묻는 것

1. **Consultation 저장 위치?** 기존 Obsidian vault (Google Drive sync, iCloud Drive,
   `~/Obsidian` 등) 자동 감지. 기본값 `~/.munger/consultations` 제공. 커스텀 절대 경로 가능.
2. **Author wikilink** — Obsidian frontmatter용 (예: `[[Fran]]`, `[[정기]]`,
   `[[홍길동]]`). 대괄호 없이 이름만 입력해도 자동으로 추가.
3. **Shell profile** — env var 추가할 파일 자동 감지 (zsh / bash / fish).

---

## 파일 구조

```
~/.claude/skills/munger/
├── SKILL.md                                # 오케스트레이션: 모드 라우팅, 프롬프트, 저장 포맷
└── brain/
    ├── 00-brain-of-munger.md               # 마스터 페르소나: 10 axioms, 프레임워크, voice, NO list
    ├── 01-investing.md                     # 도메인: 평가, margin of safety, Mr. Market
    ├── 02-business.md                      # Moats, capital allocation, See's Candies 교훈
    ├── 03-mental-models.md                 # 25 Standard Causes of Misjudgment, latticework
    ├── 04-decision-making.md               # Inversion, 20-punch-card, opportunity cost
    ├── 05-character-life.md                # 결혼, 학습, kindness, eulogy method
    ├── 06-money-ethics.md                  # 절약, envy, 세대 간 부의 이전
    └── _evals/
        ├── canonical.md                    # 8개 회귀 테스트 질문
        ├── extracted-quotes.md             # ★ 184개 verbatim Munger 인용 + 출처 URL
        ├── enrichment-report.md            # 출처 추적 리포트
        └── reports/                        # eval 실행 이력 (8/8 PASS)
```

---

## 모드

| 호출 | 모드 |
|---|---|
| `/munger <질문>` | **A — 풀 컨설팅** (기본). Clarity gate → Opus monologue + breakdown → 한국어 번역 → 저장. |
| `/munger --quick <질문>` | **B — 빠른 평결**. Clarity gate 스킵, 저장 안 함. 빠른 sanity check. |
| `/munger --buffett <질문>` | **C — Warren Buffett 페르소나**. 더 folksy한 톤, Mr. Market 시각, 소유주의 관점. |
| `/munger --debate <질문>` | **D — Munger + Buffett 병렬 + 합성**. |
| `/munger --pushback <slug>` | **E — 이전 평결에 반박**. Munger는 새 사실 없으면 안 굽힘. |
| `/munger --retro` | **F — 회고**. 과거 consultation의 follow-up 채우기, Munger 적중률 측정. |
| `/munger --eval` | **G — Voice 회귀 테스트**. `_evals/canonical.md`의 8개 질문 실행. |
| `/munger --context <path>` | **H — 파일 첨부** (.md/.txt/.pdf/.json/.yaml/.csv). 다른 모드와 결합 가능. |

### 한국어 트리거

메시지에 「버핏한테 물어봐」 또는 「워런 버핏」 + 질문이 포함되면 모드 C가 자동 선택됨.

---

## 환경변수 커스터마이징

| 변수 | 기본값 | 용도 |
|---|---|---|
| `MUNGER_BRAIN_PATH` | `~/.claude/skills/munger/brain` | brain 디렉토리 위치 |
| `MUNGER_CONSULTATIONS` | `~/.munger/consultations` | consultation 파일 저장 위치 |
| `MUNGER_USER_LINK` | `[[Author]]` | Obsidian frontmatter `author:` 필드 wikilink |

**Obsidian 사용자**: brain 디렉토리 옆에 sibling `_consultations` 폴더가 있는
vault라면 자동 감지되어 그 위치에 저장됨.

---

## 출처 (검증 가능)

13개 source class에서 184개 verbatim Munger 인용 추출. 전체 코퍼스 + URL은
[`brain/_evals/extracted-quotes.md`](./brain/_evals/extracted-quotes.md)에 있음.
주요 출처:

- **USC Gould Law Commencement (2007)** — "10 prescriptions for a happy life" 강연.
- **Psychology of Human Misjudgment (1995, 2005 revised)** — 25 standard causes.
- **USC Business 1994 — "A Lesson on Elementary Worldly Wisdom"** — latticework, scale.
- **Harvard School 1986** — "How to Be Miserable" inversion speech.
- **Caltech DuBridge Lecture (March 11, 2008)**.
- **UCSB 2003 — "How Academic Economics Is Doing More Harm Than Good"**.
- **Daily Journal Annual Meetings 2017–2023** — Latticework Investing, Steady
  Compounding 전체 transcript.
- **Wesco Financial Annual Meetings (특히 2003)** — Whitney Tilson 노트.
- **Acquired Podcast (October 2023)** — Munger의 마지막 long-form 인터뷰. 사망 1개월 전.
- **CNBC Becky Quick** — 2019 + 2023 "A Life of Wit and Wisdom".
- **25iq.com (Tren Griffin)** — 60+ 포스트 Munger compendium. 교차 검증용.

각 도메인 파일 (`brain/01-*.md` ~ `brain/06-*.md`) 하단의 `## Verified Sources` 섹션에
해당 도메인의 inline citation에 사용된 구체적 출처가 나열되어 있음.

---

## 빌드 과정

2단계 파이프라인:

1. **v1 LLM 합성** — 병렬 인물 스킬 (Naval Ravikant)의 구조 패턴을 미러링하고 Munger
   콘텐츠를 LLM 일반 지식으로 채움.
2. **v2 출처 보강** — 오케스트레이터 에이전트가 13개 source class를 병렬 크롤링.
   verbatim Munger 인용 184개 추출 + URL 부착. 6개 도메인 파일에 inline citation
   141개 병합. 8개 canonical 질문으로 회귀 테스트 (8/8 PASS, drift 0).

상세 내역: [`brain/_evals/enrichment-report.md`](./brain/_evals/enrichment-report.md).

---

## 라이선스

- **스킬 구조·프롬프트·프레임워크** (SKILL.md, brain composition, eval harness):
  [MIT License](./LICENSE).
- **Verbatim Munger 인용** (`brain/_evals/extracted-quotes.md` 및 도메인 파일의 inline
  citation): 미국 fair-use doctrine (criticism, commentary, research)에 따른 사용.
  각 인용은 짧고 (≤2 문장), 1차 출처에 귀속되며, 원본을 대체하지 않고 분석을 grounding
  하기 위해 사용됨. *Poor Charlie's Almanack* 등 저작권 보호 도서의 전문은 재현하지
  않음.

---

## 면책 조항

이 스킬은 **비공식 AI 합성 페르소나**다. 공개 Charlie Munger 강연, 주주 회의 transcript,
저술에서 도출됨. Charlie Munger 본인, 유족, Berkshire Hathaway, Daily Journal
Corporation, 어떤 Munger 관련 법인도 이 스킬을 **공식 승인·인증·지원하지 않음**. "Warren
Buffett" 보조 페르소나도 동일하게 비공식.

이 스킬은 **개인 참고 및 사고 훈련 용도 전용**. **투자, 법률, 세무, 의료, 심리 자문이
아님**. 이 스킬을 참고하여 내린 결정의 책임은 사용자에게 있음. Munger 본인도 같은 말을
할 것임.

---

## 기여

이슈와 PR 환영. 유용한 기여:

- **출처 검증** — 코퍼스의 verbatim 인용 중 실제 Munger 출처로 추적되지 않는 것 발견?
  이슈 열어주세요.
- **번역 개선** — 현재 한국어 번역 pass만 구현. 다른 언어 추가하려면 SKILL.md의
  A.2b translator 패턴 따라하세요.
- **새 도메인 파일** — 의미 있는 Munger 도메인이 빠졌다고 생각? (예: Berkshire 문화,
  philanthropy, 중국 관련 입장) PR 열어주세요.

brain 콘텐츠 변경 PR 제출 전에 `/munger --eval` 실행 필수. 8/8 PASS rate를 회귀시키는
PR은 거절됨.

---

## 감사

- Charlie Munger (1924–2023) — 60년간 부드러워지길 거부한 분.
- Peter Kaufman — *Poor Charlie's Almanack* 편집자.
- [Farnam Street (Shane Parrish)](https://fs.blog/) — 공개 웹에서 가장 포괄적인 Munger
  강연 아카이브.
- [Tren Griffin (25iq.com)](https://25iq.com/) — 60+ 포스트 compendium.
- [Whitney Tilson](https://worldlypartners.com/) — 수십 년치 Wesco/BRK 미팅 노트 아카이브.
- Acquired podcast — Munger의 마지막 long-form 인터뷰.
- Anthropic — [Claude Code](https://docs.anthropic.com/claude-code) 및 스킬 시스템.

> "Take a simple idea and take it seriously."
