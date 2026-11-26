# Security axis

The brief for the Security axis, and the rules for `security` and each finding's `security`
object in [RESULT.md](RESULT.md). Think like an attacker holding only what the outside world can
send: every claim is a path from a **source** (untrusted input) to a **sink** (the sensitive
operation), backed by lines you opened.

## Depth by profile

- **Full** (`deep`, and `pr.json` `sensitive` is non-empty; in the terminal, the diff touches an
  entry point, auth, permissions, crypto, SQL or queries, shell or `eval`, file paths, HTML
  rendering, IPC, infra or dependency manifests): every step below, tracing each source to its sink.
- **Reduced** (`quick`, or `deep` with nothing sensitive): steps 1 and 5 only, the surface and the
  risk. Report a security finding only when the flaw is plain in the diff itself; when its path is
  not traced, set `reachability` to `unknown`.

## 1. Map entry points and the attack surface

List what the diff adds, removes or changes where outside input enters or privilege is decided:

- **Entry points** (`entry_point`): HTTP routes and handlers, GraphQL resolvers, RPC and IPC
  handlers (Electron `ipcMain`, preload bridges), CLI commands and flags, queue and job consumers,
  webhooks, cron triggers, file and upload parsers, deep links.
- **`permission`**: role checks, policies, ACLs, scopes, feature gates on access.
- **`auth`**: login, sessions, tokens, cookies, CSRF, CORS, password and key handling.
- **`dependency`**: packages added, removed or bumped in a manifest.
- **`secret`**: keys, tokens, credentials, `.env` files.
- **`infra`**: Dockerfiles, CI workflows, IaC (`*.tf`, k8s, helm), network and runtime config.
- **`data_access`**: new queries, raw SQL, ORM calls over new tables or columns, storage buckets.

Each item is one `surface` entry with `change`, `kind`, `path`, `line` when there is one, and a
`note` naming the route, check or package. **Done when** every entry point and permission in the
diff is listed or deliberately judged not to be surface.

## 2. Mark trust boundaries

For each entry point, name who can reach it (anyone on the internet, any logged-in user, an
admin, another process on the machine, only the app itself) and where the input is validated,
authenticated and authorized. A boundary the input crosses unchecked is where findings live.

## 3. Trace source to sink

Follow each untrusted value through the changed code to every sink it reaches: a query, a shell
or `exec`, `eval`, a file path, an HTML or template render, a redirect, a deserializer, an outbound
request (SSRF), a permission decision, a log line holding personal data. Open the callers and the
callees; read the middleware and router setup that wraps the route. Name the weakness class by its
CWE and OWASP Top 10 names (`CWE-89 SQL Injection (OWASP A03 Injection)`, `CWE-862 Missing
Authorization (OWASP A01 Broken Access Control)`, `CWE-798 Hard-coded Credentials`).

The finding's `attackPath` is that trace, one hop per arrow, each hop with `path:line`.

## 4. Rate each finding

**Exploitability**, with `exploitabilityReason`:

- `high`: one request or input, no special access, no prior state; public exploit technique.
- `medium`: needs an account, a specific state, a second step, or a timing window.
- `low`: needs privileged access, an unlikely configuration, or a chain of other flaws.

**Reachability**, with `reachabilityEvidence` naming the lines read:

- `possible`: a path from a public or less-trusted entry point to the sink exists in the code.
- `internal`: only trusted callers reach it (the app itself, an admin-only route behind a check
  you opened, a local process with the same rights).
- `unknown`: the path could not be traced: a dynamic dispatch, a caller outside the repo, a
  config you cannot see. Say what is missing. Missing evidence is a coverage gap, not proof of
  safety: never lower `reachability` or severity because you found no path.

**Severity** follows [RESULT.md](RESULT.md): `critical` needs `possible` reachability and `high`
or `medium` exploitability, or an exposed secret; `high` for a real flaw with `internal` or
`unknown` reach, or `low` exploitability; `medium` for a missing defence that a second layer
still covers.

## 5. Rate the PR risk

| `risk` | When |
|---|---|
| `minimal` | No surface change and no security finding. |
| `low` | Surface changed with the expected checks in place; at most `low`/`info` security findings. |
| `medium` | A `medium` security finding, or a surface change whose checks you could not confirm (including every Reduced run that touched sensitive surface). |
| `high` | A `high` security finding, or an auth or permission change with an open concern. |
| `critical` | A `critical` security finding, or a secret in the diff. |

`rationale` names the finding or surface item that sets the level.

## Secrets

Shark masks secrets in `pr.diff` before the review sees them (the first 4 characters stay) and
raises its own `critical` finding for each. Still report each one you see: a `critical` `security`
finding with the kind (`AWS access key`, `GitHub token`, `private key`), the `path` and `line`,
`weakness` `CWE-798 Hard-coded Credentials`, and a fix that moves it to the secret store and
rotates it. Quote only the masked value. In the terminal, mask any secret you quote the same way.

## Keep out of findings

- Hardening wishes with no path to a sink (headers, rate limits, stricter types): `low` or
  `info`, or nothing.
- Issues in code the diff does not touch or reach: name them in `rationale` only when the change
  makes them worse.
- Generic advice ("validate all input") with no `path:line`.
- Anything a dependency scanner reports alone; name a bumped package with a known advisory only
  when you can cite the advisory.
