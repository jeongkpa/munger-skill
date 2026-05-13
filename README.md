# /munger — Charlie Munger Consultation Skill for Claude Code

> Before you commit to anything irreversible, ask the 99-year-old Nebraska polymath.

A [Claude Code](https://docs.anthropic.com/claude-code) skill that loads a synthesized
"Brain of Charlie Munger" (built from 184 verbatim Munger quotes across 13 verified
public sources) and runs your decision through Munger's reasoning toolbox — inversion,
mental models, the 25 standard causes of misjudgment, margin of safety, circle of
competence — via an Opus sub-agent.

Output is **bilingual** by default: English Munger monologue + Korean translation.

한국어 README: [README.ko.md](./README.ko.md)

---

## Why this skill

Most "AI investing advice" is bland because the model averages over every voice it has
ever read. This skill does the opposite: it pins the model to one specific worldview,
grounds it in 184 source-attributed verbatim quotes, and enforces a voice contract
that keeps the answer **terse, sardonic, unhedged, and Munger-shaped**.

You get:

- **Hybrid output format**: 3-5 paragraph Munger monologue (no consulting-deck headers)
  followed by a `Structured breakdown` of models, heuristics, and a concrete next move.
- **Bilingual by default**: English original + natural Korean translation (separate
  translator sub-agent — no literal 직역).
- **8 modes** routed by CLI flags: full / quick / buffett / debate / pushback / retro
  / eval / context.
- **Verifiable**: every load-bearing claim in the brain is backed by an inline citation
  pointing to `_evals/extracted-quotes.md` and a primary public source URL.
- **Regression-tested**: 8 canonical questions × vocab + anti-phrase + judge check.
  Last run: **8/8 PASS, drift score 0**.

---

## Quick install

### One-line (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/jeongkpa/munger-skill/main/install.sh | bash
```

### Manual

```bash
git clone https://github.com/jeongkpa/munger-skill ~/.claude/skills/munger
```

Then in any Claude Code session:

```
/munger should I quit my job to start a company?
```

---

## What you get

```
~/.claude/skills/munger/
├── SKILL.md                                # Orchestration: mode routing, prompts, save format
└── brain/
    ├── 00-brain-of-munger.md               # Master persona: 10 axioms, frameworks, voice, NO list
    ├── 01-investing.md                     # Domain: valuation, margin of safety, Mr. Market
    ├── 02-business.md                      # Moats, capital allocation, See's Candies lesson
    ├── 03-mental-models.md                 # 25 Standard Causes of Misjudgment, latticework
    ├── 04-decision-making.md               # Inversion, 20-punch-card, opportunity cost
    ├── 05-character-life.md                # Marriage, learning, kindness, eulogy method
    ├── 06-money-ethics.md                  # Frugality, envy, generational wealth
    └── _evals/
        ├── canonical.md                    # 8 regression-test questions
        ├── extracted-quotes.md             # 184 verbatim Munger quotes with source URLs
        ├── enrichment-report.md            # Source provenance report
        └── reports/                        # Eval run history (8/8 PASS)
```

---

## Modes

| Invocation | Mode |
|---|---|
| `/munger <question>` | **A — Full consultation** (default). Clarity gate → Opus monologue + breakdown → Korean translator pass → save. |
| `/munger --quick <question>` | **B — Quick verdict**. No clarity gate, no save. Fast sanity check. |
| `/munger --buffett <question>` | **C — Warren Buffett persona**. Folksier register, Mr. Market lens, owner's view. |
| `/munger --debate <question>` | **D — Munger + Buffett parallel + synthesis**. |
| `/munger --pushback <slug>` | **E — Contest a prior verdict**. Munger defends unless you bring new verifiable facts. |
| `/munger --retro` | **F — Retrospective** on past consultations: fill in follow-up sections, score Munger's hit rate. |
| `/munger --eval` | **G — Voice regression test** against `_evals/canonical.md`. |
| `/munger --context <path>` | **H — Attach a file** (.md/.txt/.pdf/.json/.yaml/.csv). Stackable with any other mode. |

### Korean trigger

If your message contains 「버핏한테 물어봐」 or 「워런 버핏」 + a question, Mode C is
auto-selected.

---

## Customization (environment variables)

| Variable | Default | Purpose |
|---|---|---|
| `MUNGER_BRAIN_PATH` | `~/.claude/skills/munger/brain` | Brain directory location |
| `MUNGER_CONSULTATIONS` | `~/.munger/consultations` | Where consultation files are saved |
| `MUNGER_USER_LINK` | `[[Author]]` | Obsidian wikilink for the `author:` frontmatter field |

For Obsidian users: if you have a vault with a sibling `_consultations` folder next to
the brain directory, that location is auto-detected and used.

---

## Sources (verifiable)

184 verbatim Munger quotes were extracted across 13 source classes. The full corpus
with URLs is at [`brain/_evals/extracted-quotes.md`](./brain/_evals/extracted-quotes.md).
Primary sources include:

- **USC Gould Law Commencement (2007)** — "10 prescriptions for a happy life" speech.
  Mirrors at [Farnam Street](https://fs.blog/munger-operating-system/) and
  [James Clear](https://jamesclear.com/great-speeches/2007-usc-law-school-commencement-address-by-charlie-munger).
- **Psychology of Human Misjudgment (1995, revised 2005)** — 25 standard causes of
  misjudgment. Full text at
  [Farnam Street](https://fs.blog/great-talks/psychology-human-misjudgment/).
- **USC Business 1994 — "A Lesson on Elementary Worldly Wisdom"** — latticework, scale
  advantages. [Farnam Street](https://fs.blog/great-talks/a-lesson-on-worldly-wisdom/).
- **Harvard School 1986** — "How to Be Miserable" inversion speech. Mirror at
  [James Clear](https://jamesclear.com/great-speeches/how-to-guarantee-a-life-of-misery-by-charlie-munger).
- **Caltech DuBridge Lecture (March 11, 2008)** — full transcript via
  [educ8s.tv](https://educ8s.tv/charlie-munger-2008-dubridge-lecture-transcript-free/).
- **UCSB 2003 — "How Academic Economics Is Doing More Harm Than Good"** — via
  [Tilson PDF](https://tilsonfunds.com/MungerUCSBspeech.pdf).
- **Daily Journal Annual Meetings 2017–2023** — full transcripts via
  [Latticework Investing](https://latticeworkinvesting.com/) and
  [Steady Compounding](https://steadycompounding.com/).
- **Wesco Financial Annual Meetings (notably 2003)** — Whitney Tilson notes via
  [Worldly Partners](https://worldlypartners.com/).
- **Acquired Podcast (October 2023)** — Munger's final long-form interview, one month
  before his death.
- **CNBC Becky Quick interviews** — 2019 + 2023 "A Life of Wit and Wisdom" full
  transcripts.
- **25iq.com (Tren Griffin)** — 60+ post Munger compendium, used for
  cross-verification.

Each domain file (`brain/01-*.md` through `brain/06-*.md`) has a `## Verified Sources`
section at the bottom listing the specific primary sources used in that domain's
inline citations.

---

## How it was built

Two-stage pipeline:

1. **v1 LLM synthesis** — mirrored the structural pattern from a parallel "thinking
   persona" skill (Naval Ravikant), populated with Munger content from public knowledge.
2. **v2 source enrichment** — orchestrator agent crawled 13 source classes in
   parallel, extracted 184 verbatim Munger quotes with URLs, merged 141 inline
   citations across the 6 domain files, and ran an 8-question regression eval (8/8
   PASS, drift 0).

Both stages are documented in
[`brain/_evals/enrichment-report.md`](./brain/_evals/enrichment-report.md).

---

## License

- **Skill structure, prompts, framework** (SKILL.md, brain composition, eval harness):
  [MIT License](./LICENSE).
- **Verbatim Munger quotes** (`brain/_evals/extracted-quotes.md` and inline citations
  in domain files): used under U.S. fair-use doctrine (criticism, commentary, and
  research). Each quote is short (≤2 sentences), attributed to its primary source, and
  used to ground analysis — not to substitute for original works. *Poor Charlie's
  Almanack* and other copyrighted books are not reproduced.

---

## Disclaimer

This skill is an **unofficial, AI-synthesized persona** derived from public Charlie
Munger speeches, shareholder-meeting transcripts, and writings. It is **not affiliated
with, authorized by, or endorsed by** Charlie Munger, his estate, Berkshire Hathaway,
the Daily Journal Corporation, or any Munger entity. The "Warren Buffett" secondary
persona is similarly derived from public material and is unofficial.

This skill is for **personal reference and thinking practice only**. It is **not
investment, legal, tax, medical, or psychological advice**. Decisions you make after
consulting this skill are your own. Munger himself would tell you the same.

---

## Contributing

Issues and PRs welcome. Useful contributions:

- **Source verification** — find a verbatim quote in the corpus that you can verify
  doesn't trace to a real Munger source? Open an issue.
- **Translation improvements** — Korean is the only translation pass currently
  implemented. If you want to add another language, follow the A.2b translator pattern
  in SKILL.md.
- **New domain files** — if you think a meaningful Munger domain is missing (e.g.,
  Berkshire culture, philanthropy, China-specific positions), open a PR.

Run `/munger --eval` before submitting changes to brain content. PRs that regress the
8/8 PASS rate will be rejected.

---

## Acknowledgments

- Charlie Munger (1924–2023) for sixty years of refusing to soften.
- Peter Kaufman for editing *Poor Charlie's Almanack*.
- [Farnam Street (Shane Parrish)](https://fs.blog/) for the most comprehensive
  Munger-speech archive on the public web.
- [Tren Griffin (25iq.com)](https://25iq.com/) for the 60+ post compendium.
- [Whitney Tilson](https://worldlypartners.com/) for archiving decades of Wesco / BRK
  meeting notes.
- The Acquired podcast for Munger's final long-form interview.
- Anthropic for [Claude Code](https://docs.anthropic.com/claude-code) and the skill
  system this is built on.

> "Take a simple idea and take it seriously."
