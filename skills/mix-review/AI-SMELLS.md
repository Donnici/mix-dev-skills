# AI Smells

The baseline the Standards axis applies even when the repo documents nothing. Each entry:
**what it looks like** → **fix**. All are judgement calls; a documented repo rule overrides them.

## Noise

- **Narrating comment**: a comment that restates the next line (`// fetch the user`,
  `// loop over items`, `// return result`). → delete.
- **Essay comment**: a multi-line comment or docblock explaining what the code already says, or
  restating the type signature. → delete, or cut to the one-line *why*.
- **Change-log comment**: `// updated to use X`, `// new implementation`, `// fixed bug`,
  `// as requested`. History belongs in git. → delete.
- **Commented-out code** or `TODO` with no owner or ticket. → delete or link a ticket.
- **Debug leftovers**: `console.log`, `print`, `debugger`, temporary flags. → delete.

## Reinvention

- **Reimplemented helper**: a function that does what an existing util, hook, or service already
  does. → call the existing one (name it in the finding).
- **Shadow library**: a hand-written version of what an installed dependency does (date math with
  `Date` when `dayjs` is installed; manual fetch when the repo wraps axios). → use the library
  through the repo's wrapper.
- **Duplicate dependency**: a new package for a job an installed one already covers. → remove it.
- **Copied block**: the same logic shape in several places in the diff. → extract once, call twice.

## Pattern drift

- **Off-pattern file**: structure, naming, error handling, or placement differs from the golden
  file of its kind. → mirror the exemplar.
- **Inconsistent errors**: errors raised, logged, or surfaced differently from the rest of the
  layer. → follow the layer's convention.
- **Vocabulary drift**: names that use synonyms instead of the project glossary's terms. → rename.
- **Magic values** where the repo has constants, enums, or config for them. → use them.

## Over-engineering

- **Speculative generality**: options, parameters, hooks, generics, or interfaces for needs the
  spec doesn't have. → inline until a real second use appears.
- **Single-implementation abstraction**: an interface, factory, or strategy with one concrete
  class. → use the concrete thing.
- **Middle man / pass-through**: a function or class that only forwards to another. → call the
  target directly.
- **Defensive noise**: null checks on values the types guarantee, `try/catch` that only rethrows
  or logs and swallows, re-validating data already validated upstream. → delete; handle errors
  where they can be acted on.
- **Type escape hatches**: `any`, `as unknown as`, non-null `!`, `@ts-ignore` added to make code
  compile. → fix the types.

## Structure

- **Mysterious name**: a name that doesn't reveal what it holds or does. → rename.
- **Long function** doing several things at different levels of abstraction. → split by step.
- **Feature envy**: a function reaching into another module's data more than its own. → move it.
- **Data clump / primitive obsession**: the same few params travelling together, or a raw string
  standing in for a domain concept. → give it a type.
- **Repeated switch** on the same discriminator in several places. → one map or polymorphism.
- **Shotgun surgery**: one logical change scattered across many files. → gather what changes
  together.

## Scope

- **Drive-by change**: refactors, renames, reformatting, or fixes unrelated to the task. → revert
  and propose as a separate task.
- **Dead code**: unused exports, imports, files, branches, or parameters introduced by the diff. →
  delete.
