# The `mix-review-result` block

The structured result `--report` ends with, read by Shark. Version `1`. Shark validates the last
` ```mix-review-result ` block in the answer against its own schema; a block that fails validation,
or an unknown `version`, makes Shark show the whole answer as a single report. The older
`mix-review-findings` block is no longer emitted.

Shark computes the PR score (0–100 and a letter) itself, from `findings`, `adherence`, `checks` and
`security.risk`. The block has no score field: rate each field honestly and the score follows.

**Version rule**: any change to the shape (a field added, removed, renamed or made optional, a type
or an enum value changed) is a new `version`, released together with Shark's schema. Never emit a
field or an enum value this file does not list.

## Example

````text
```mix-review-result
{
  "version": 1,
  "summary": {
    "overview": "Adds a report export endpoint that filters orders by customer name, and a CSV writer for the result.",
    "groups": [
      { "title": "Export endpoint", "summary": "New GET /reports/export route and its handler.", "files": ["src/routes/reports.ts", "src/reports/export.ts"] },
      { "title": "CSV writer", "summary": "Streams rows to CSV with a header line.", "files": ["src/reports/csv.ts", "tests/csv.test.ts"] }
    ],
    "effort": { "level": 3, "minutes": 40 }
  },
  "security": {
    "risk": "high",
    "rationale": "A new public route builds SQL from a query-string value; the injection is reachable without authentication.",
    "surface": [
      { "change": "added", "kind": "entry_point", "path": "src/routes/reports.ts", "line": 14, "note": "GET /reports/export, no auth middleware." },
      { "change": "added", "kind": "data_access", "path": "src/reports/export.ts", "line": 22, "note": "Raw query over orders and customers." }
    ]
  },
  "adherence": {
    "requirements": [
      { "source": "SHOP-112", "text": "Export orders of one customer as CSV.", "status": "met", "reason": "Handler filters by customer and streams CSV.", "files": ["src/reports/export.ts", "src/reports/csv.ts"] },
      { "source": "SHOP-112", "text": "Only admins can export.", "status": "not_met", "reason": "The route has no permission check.", "files": ["src/routes/reports.ts"] }
    ],
    "outOfScope": [
      { "path": "src/db/pool.ts", "note": "Pool size raised from 10 to 50; no source asks for it." }
    ]
  },
  "checks": [
    { "name": "title", "status": "pass", "explanation": "Says what the PR adds." },
    { "name": "description", "status": "warn", "explanation": "Explains what, not why the pool size changed." },
    { "name": "adherence", "status": "warn", "explanation": "1 of 2 requirements not met." },
    { "name": "out_of_scope", "status": "warn", "explanation": "Pool size change is unrequested." }
  ],
  "findings": [
    {
      "path": "src/reports/export.ts", "startLine": 20, "line": 24, "side": "RIGHT",
      "severity": "critical", "category": "security",
      "title": "SQL built from the `name` query parameter",
      "explanation": "The customer name is concatenated into the WHERE clause, so any caller can run arbitrary SQL.",
      "evidence": "const sql = `SELECT * FROM orders WHERE customer = '${req.query.name}'`",
      "effort": "quick_win",
      "fix": "Use the repo's query builder with a bound parameter: db.query('... WHERE customer = $1', [name]).",
      "agentPrompt": "Verify each finding against current code. Fix only still-valid issues, skip the rest with a brief reason, keep changes minimal, and validate.\n\nIn `@src/reports/export.ts` around lines 20–24, replace the string-built SQL with a parameterized query through `db.query` and bind `name` as `$1`.",
      "security": {
        "attackPath": "GET /reports/export?name=… (src/routes/reports.ts:14) → exportOrders(name) → db.raw(sql) (src/reports/export.ts:24).",
        "exploitability": "high",
        "exploitabilityReason": "One crafted query-string value, no authentication, no prior state.",
        "reachability": "possible",
        "reachabilityEvidence": "The route is mounted on the public router in src/app.ts:31 with no auth middleware.",
        "weakness": "CWE-89 SQL Injection (OWASP A03 Injection)"
      }
    },
    {
      "path": "src/routes/reports.ts", "line": 14, "side": "RIGHT",
      "severity": "high", "category": "bug",
      "title": "Export route has no admin check",
      "explanation": "SHOP-112 requires admin-only export; the route is open to every caller.",
      "evidence": "router.get('/reports/export', exportHandler)",
      "effort": "quick_win",
      "fix": "Add the existing requireRole('admin') middleware, as src/routes/users.ts:9 does.",
      "agentPrompt": "Verify each finding against current code. Fix only still-valid issues, skip the rest with a brief reason, keep changes minimal, and validate.\n\nIn `@src/routes/reports.ts` around line 14, add `requireRole('admin')` before `exportHandler`, mirroring `src/routes/users.ts`.",
      "requirement": 1
    }
  ],
  "carried": []
}
```
````

## Fields

Every field is required unless marked optional. Text fields are in `pr.json` `language`, except
`agentPrompt`, which is always English. Text never reconstructs a masked secret.

### `summary`

- `overview`: one paragraph on what the PR does and why, for the whole PR.
- `groups`: the changes by area, each with a `title`, a one- or two-sentence `summary`, and the
  `files` it covers. Every reviewed file is in exactly one group; files in `pr.json` `skipped` are
  in none.
- `effort`: how hard the PR is to review. `level` and `minutes` are whole numbers; a fraction makes the whole block invalid.

  | `level` | Meaning | `minutes` (typical) |
  |---|---|---|
  | 1 | trivial: config, copy, one obvious change | ≤ 10 |
  | 2 | small and local, one concern | 10–20 |
  | 3 | several files or one non-trivial logic change | 20–45 |
  | 4 | cross-module, new flows, or security-relevant | 45–90 |
  | 5 | large or risky: auth, data migration, concurrency, many modules | 90+ |

### `security`

Rules and rubric in [SECURITY.md](SECURITY.md).

- `risk`: `minimal` | `low` | `medium` | `high` | `critical`, for the whole PR.
- `rationale`: one or two sentences naming what drives the level.
- `surface`: each attack-surface change, `[]` when none. `change`: `added` | `removed` | `changed`.
  `kind`: `entry_point` | `permission` | `auth` | `dependency` | `secret` | `infra` |
  `data_access`. `path`, optional `line`, and a one-line `note`.

### `adherence`

Both lists are `[]` when there is no source (no hub spec and no `read: true` item in
`sources.json`).

- `requirements`: one item per requirement of each source: an FR or acceptance scenario of the hub
  spec, or an acceptance criterion or explicit ask of a ticket or document.
  - `source`: where it comes from: the ticket key or URL from `sources.json` `source`, or the spec
    reference (`spec.md FR-003`, `spec.md US2/AC3`).
  - `text`: the requirement, quoted or tightly paraphrased.
  - `status`: `met` (the code does it; name where) · `partial` (some of it, or only some cases) ·
    `not_met` (absent, or the code contradicts it) · `manual` (cannot be judged from code: visual,
    copy, production config, an external system).
  - `reason`: why that status, one sentence. `files`: the files that implement it, `[]` when none.
- `outOfScope`: changes no source asks for that a reviewer should notice (behaviour, config,
  dependencies, refactors). Each has `path` and a one-line `note`. Skip formatting and imports.

### `checks`

Exactly four items, one per `name`, in this order:

| `name` | `pass` | `warn` | `n_a` |
|---|---|---|---|
| `title` | says what changes, specifically | vague, misleading, or names one part of a mixed PR | never |
| `description` | explains what and why, and its claims match the code | empty, only what, or claims behaviour the code lacks | never |
| `adherence` | every requirement `met` or `manual` | any `partial` or `not_met` | no source |
| `out_of_scope` | `outOfScope` is empty | `outOfScope` has an item | no source |

`explanation`: one sentence, naming the gap on `warn`.

### `findings`

One object per finding that survived verification, ordered by severity, then by path. `[]` when
none.

- `path`: the file, relative to the repo root; it exists at the head sha. Prefer the changed files;
  a finding on unchanged code is allowed when the change makes it wrong.
- Location, optional: `line` is the last line of the range, `startLine` its first (only with
  `line`, and smaller), `side` is `RIGHT` for the new version and `LEFT` for a deleted line. Omit
  all three for a finding on the whole file or on no single line.
- `severity`: see [Severity](#severity). `category`: see [Category](#category).
- `title`: one line, under 80 characters, stating the problem.
- `explanation`: what is wrong and what it causes, two to four sentences.
- `evidence`: the code or trace that proves it: a short quote of the cited lines, or the
  call path. Masked secrets stay masked.
- `effort`: `quick_win` when the finding is worth fixing in this PR, its value high for the cost
  of the fix; `low_value` when the fix is optional, its gain small for the cost. Every `critical`
  and `high` finding is `quick_win`.
- `fix` (optional): what to change, specific enough to apply; omit when the right fix needs a
  decision.
- `agentPrompt`: a self-contained instruction for a coding agent, exactly:

  ```text
  Verify each finding against current code. Fix only still-valid issues, skip the rest with a brief reason, keep changes minimal, and validate.

  In `@<path>` around lines <startLine>–<line>, <instruction>.
  ```

  With `line` and no `startLine`, write `around line <line>`; with no `line`,
  ``In `@<path>`, <instruction>.``. The instruction names the change and the
  existing helper or exemplar to follow, never the finding's explanation again.
- `requirement` (optional): the 0-based index in `adherence.requirements` of the requirement this
  finding comes from. Every `not_met` requirement has one `bug` finding pointing at it.
- `security`: required when `category` is `security`, absent otherwise. `attackPath`,
  `exploitability` (`high` | `medium` | `low`), `exploitabilityReason`, `reachability`
  (`possible` | `internal` | `unknown`), `reachabilityEvidence`, `weakness`. Rules in
  [SECURITY.md](SECURITY.md).

### `carried`

`[]` unless `pr.json` has `incremental`. Then one item per entry of `open-findings.json`, none
missing and none added: `key` copied from the entry, `status` `resolved` (the delta removed or
fixed the problem) or `open` (still there), and a one-sentence `reason` naming the change or the
line that keeps it open. An open carried finding is never repeated in `findings`.

## Severity

| Level | Use for |
|---|---|
| `critical` | Must not merge: exploitable security flaw reachable from untrusted input, exposed secret, data loss or corruption, crash or outage of a main path. |
| `high` | Should block merge: a bug that breaks a requirement or a main flow, a constitution MUST violated, a `not_met` requirement, a description that claims behaviour the code lacks, a security flaw with limited reach. |
| `medium` | Fix before merge unless there is a reason: an edge-case bug, a pattern deviation, a reinvented helper, an architecture rule bent, a missing test for an acceptance scenario, a redundant or coupled test, a performance cost on a warm path. |
| `low` | Worth a look: naming, minor clarity, small cleanups no linter enforces. |
| `info` | No action needed: context or an observation a reviewer benefits from. |

When torn between two levels, pick the lower one and say why in `explanation`. Old
`blocking` / `should_fix` / `nit` read as `high` / `medium` / `low`.

## Category

| `category` | Axis | Covers |
|---|---|---|
| `security` | Security | vulnerabilities, secrets, privacy, unsafe dependencies |
| `bug` | Bugs, Spec | wrong behaviour, a `not_met` requirement, a broken contract |
| `stability` | Bugs | crashes, unhandled errors, races, leaks, missing timeouts or retries |
| `data` | Bugs | integrity: migrations, transactions, partial writes, lost validation |
| `performance` | Bugs | needless work on a hot path: N+1, unbounded loads, sync I/O |
| `architecture` | Architecture | module boundaries, dependency direction, layering, coupling |
| `standards` | Standards | a documented repo rule broken; cite the rule |
| `maintainability` | Standards | AI smells, duplication, dead code, unclear structure, with no rule |
| `tests` | Tests | redundant, tautological, coupled or missing tests |

One category per finding: the one whose fix closes it.
