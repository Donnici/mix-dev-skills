# Clear Technical Portuguese

The writing rules `mix-explain` applies to every explanation. Adapted from the Simplified
Technical Portuguese skill by NOS Comunicações
(`nosportugal/portugues-tecnico-simplificado-skill`, MIT), itself built on ASD-STE100 (Simplified
Technical English) and ISO 24495-1 (plain language). The source targets European Portuguese for
machine readers; here the reader is a person who asked for an explanation, so the default variant
is Brazilian Portuguese and the reader is addressed directly.

## Variant

- Write in the language of the user's request. Default: Brazilian Portuguese (pt-BR).
- pt-BR: address the reader as "você"; use Brazilian vocabulary ("arquivo", "tela", "usuário",
  "baixar", "salvar"); gerund for an action in progress is fine ("está rodando").
- pt-PT, only when the user writes in it: "ficheiro", "ecrã", "utilizador", "está a executar",
  enclisis ("envia-o").
- English: the same structural rules, as ASD-STE100 (20 words per instruction, 25 per
  description).
- Keep code identifiers, file names, commands, and established loan words (commit, deploy, branch,
  merge, PR) as they are. Define each one the reader may not know on first use.

## Structural rules (always apply)

| Rule | Do | Avoid |
|------|----|-------|
| Main message first | Open with the result, the decision, or the conclusion. | Opening with background, history, or apologies. |
| Active voice | "O `mix-plan` cria o `plan.md`." | "O `plan.md` é criado." / "Cria-se o `plan.md`." |
| Full verb, no support verb | "Analise", "remova", "use", "inicie". | "Efetuar a análise", "proceder à remoção", "fazer uso de", "dar início a". |
| No idioms or tech slang | "Inicie o servidor." / "Envie a branch para o remoto." | "Suba o servidor." / "Dê um push." ("subir" has four meanings) |
| No wordy phrases | "para", "porque", "sobre", "está". | "de forma a", "tendo em conta que", "no que diz respeito a", "a nível de", "sendo que". |
| One idea per sentence | "Abra o arquivo. Leia a linha 3." | Chains joined by "e", "depois", "sendo que", or a gerund after a comma. |
| Condition before action | "Se o teste falhar, corrija o contrato." | "Corrija o contrato se o teste falhar." |
| Sentence length | Up to 22 words in instructions, 27 in descriptions. | Long chains of coordinate and subordinate clauses. |
| No semicolon | Split into separate sentences. | Any `;`, including legal-style list endings. |
| Direct order | "Se o token expirou, o servidor rejeita o pedido." | A clause wedged between subject and verb. |
| Short "de" chains | At most two "de" in a noun group. | "o módulo de controle de prioridade da fila de tarefas do agente". |
| Explicit subject when it changes | "O cliente envia o pedido. O servidor valida o pedido." | "O cliente envia o pedido. Valida o pedido." |
| No telegraphic ellipsis | "Os pedidos sem fatura foram cancelados." | "Pedidos sem fatura cancelados." |
| Unambiguous reference | Repeat the noun. | "o mesmo" as a pronoun; "seu" with two possible owners. |
| Keep the modality | "O pedido **pode ter** falhado." stays a possibility. | Promoting a hedge to a fact, or adding a hedge to a measured fact. |
| Ambiguous "deve" | Write "precisa" (order) or "provavelmente" (estimate). If the source does not say which, quote it and flag it. | Picking one meaning in silence. |
| Numbers and dates | "1000", "10 000", "1,5 s", "2026-10-07" or "7 de outubro". | "1.000", "07/10/2026", "07/10". |
| Acronyms | Spell out on first use: "tempo de vida (TTL)". | An acronym the text never defines. |
| Paragraphs | One topic per paragraph, stated early, at most 6 sentences. | Several topics in one paragraph. |
| Lists for sequences | A numbered or bulleted list for 3 or more steps or conditions. | A sequence hidden inside one sentence. |
| Known to new | Start the sentence with what the reader already saw, end with what is new. | A new term at the start of a sentence with no anchor. |
| Common case first | The normal flow, then the exceptions. | Rare exceptions mixed into the normal flow. |
| Descriptive headings | One short heading per topic. | "Notas", "Outros", or a heading the section does not deliver. |
| Neutral tone | Say what failed and what to do. | Blaming the reader, or dramatizing. |

## Lexical rules (direction, not a gate)

- **One word, one meaning**: pick one name per thing and one verb per action, and keep them for
  the whole explanation. Prefer the project's glossary term.
- **Two-meaning words**: avoid "excluir" (delete or leave out), "carregar" (upload, load, or
  press), "correr" (run or flow). Choose the form with one reading.
- **False friends**: "eventualmente" means "às vezes", not "por fim". Use "supor" for "assumir
  que", "tratar" for "endereçar", "aceitar" for "suportar JSON".
- **No deformed loans**: "deletar", "setar", "performar", "commitar" become "apagar", "definir",
  "ter desempenho", "fazer commit".
- **Marketing adjectives**: cut "robusto", "poderoso", "intuitivo", "de ponta", or replace them
  with the measure that supports the claim.

## Checklist before sending

1. Synonym rotation: the same thing has one name throughout.
2. Hedge stacking: no "pode potencialmente ajudar a melhorar". State the fact or cut it.
3. Support verbs replaced by the verb.
4. Marketing adjectives cut.
5. Chained sentences split.
6. Gerundism removed ("vou estar enviando" → "vou enviar").
7. Slang and idiomatic verbs replaced.
8. Numbers and dates unambiguous.
9. English calques replaced by the Portuguese construction.
10. Loose references resolved by repeating the noun.
11. Negative contrasts ("não é um bug, é uma decisão") turned affirmative, unless the negation
    removes a likely misreading.

## Limits

- Every fact, condition, number, and scope limit of the source survives. When a shorter form
  loses a needed precision, keep the long form and flag it.
- Add no fact, cause, example, or frequency the source does not state.
- Weak content stays weak: say the source is vague instead of polishing it.
- Stop shortening once each sentence has one reading.
