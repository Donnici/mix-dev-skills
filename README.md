# mix-dev-skills

Skills de desenvolvimento guiado por specs para Claude Code (e outros agentes compatíveis com
`SKILL.md`). A base é o fluxo do [Spec Kit](https://github.com/github/spec-kit), refinado com as
[skills do Matt Pocock](https://github.com/mattpocock/skills) e com regras para atacar os
problemas mais comuns em PRs escritos por IA: comentários demais, testes redundantes, código que
ignora os padrões e as bibliotecas que o repositório já usa.

## O fluxo

```text
/mix-scope <projeto>   escolhe o projeto ativo (cada um com regras, docs, specs e repos próprios)
/mix-setup             uma vez por projeto: repos e papéis, convenções, arquitetura, constituição
    ▼
/mix-specify → /mix-clarify → /mix-plan → /mix-tasks → /mix-analyze → /mix-implement
   spec.md        perguntas      plan.md     tasks.md      checagem      código + commit local
                                 contratos   por repo                    (nunca push/PR)
    ▼
/mix-pr push | pr   (só quando você pede)  →  /mix-review  →  /mix-retro (comentários viram regras)
```

| Skill | O que faz | Tipo |
|-------|-----------|------|
| `/mix-scope` | Mostra, troca (`/mix-scope lumen`), lista ou cria projetos no hub. Todas as outras skills resolvem o contexto por ela. | comando + automática |
| `/mix-setup` | Pergunta hub ou in-repo, a pasta root e o papel de cada repo (web, bff, api...), padrão de branch/PR/tickets, e gera o mapa de cada repo (`package.json`, libs por finalidade, padrões, golden files) e, se houver vários, o mapa de integração (contratos, golden path ponta a ponta). Cria a constituição. | comando |
| `/mix-constitution` | Cria/altera as regras (MUST/SHOULD), versionadas. | comando + automática |
| `/mix-specify` | Explora o código, define entrega (branch, tickets, estratégia), faz o grill das decisões, escreve `spec.md`, mantém glossário e ADRs. | comando |
| `/mix-clarify` | Varredura de ambiguidades da spec (taxonomia do Spec Kit) + perguntas + atualização da spec. | comando |
| `/mix-plan` | Quais repos mudam e por quê, inventário de reuso, gate da constituição, **contratos entre repos primeiro** (rota, campos, tipos, erros, auth), design por repo, seams de teste. | comando |
| `/mix-tasks` | Fatias verticais por história; dentro da história: contrato → provider → consumer → integração; cada task com repo, arquivo, exemplar e bloqueios; cria/coleta tickets. | comando |
| `/mix-analyze` | Consistência spec ↔ plan ↔ tasks, somente leitura. | comando |
| `/mix-implement` | Implementa task a task em cada repo, lendo o exemplar antes e respeitando os contratos; ao fim de cada entrega: poda de testes, limpeza de comentários, self-review e **commit local só com sua aprovação**. Nunca faz push nem abre PR. | comando |
| `/mix-review` | Revisão em 3 eixos (Padrões, Spec, Testes) em subagentes paralelos, com verificação de cada achado; corrige, gera tasks de convergência ou comenta no PR. | comando + automática |
| `/mix-pr` | Dono das convenções de branch, commit e PR (single, por história, ou empilhado; um PR por repo). Push e PR só quando você pede explicitamente. | comando + automática |
| `/mix-retro` | Transforma comentários recorrentes de PR em lint/CI, regras ou contexto. | comando |
| `/mix-triage` | Triagem de issues (e PRs externos): categoria e estado, duplicidade e rejeições anteriores, reprodução, grill e brief pronto para agente. Nada é escrito no tracker sem confirmação; tracker só-leitura gera rascunhos locais. | comando |
| `mix-diagnose` | Bugs difíceis e regressões de performance: primeiro um loop de feedback que fica vermelho no bug, depois hipóteses, instrumentação, fix com teste de regressão e limpeza. Funciona entre repos. | comando + automática |
| `/mix-wait-what` | "Não entendi": reexplica a última mensagem com contexto, em linguagem simples e com os termos do glossário. | comando |
| `/mix-migrate` | Move a estrutura do Spec Kit e das skills do Matt para o layout do mix (`mix-dev-skills/` + `specs/`), convertendo constituição e configuração e corrigindo links. | comando |
| `mix-grill` | Primitiva de entrevista: rodadas, resposta recomendada, fatos são do agente e decisões são suas. | automática |
| `mix-testing` | Referência de testes: seams, mocks, anti-padrões e o passe de poda. | automática |
| `/mix-flow` | Roteador: qual skill usar em cada situação. | comando |

"Comando" = só roda quando você digita (não ocupa contexto). "Automática" = o agente ou outra
skill pode chamar sozinho.

## Instalação

**Pedindo ao Claude Code** (de qualquer pasta):

> Instale as skills de https://github.com/Donnici/mix-dev-skills seguindo o INSTALL.md.

**Plugin do Claude Code** (atualiza sozinho):

```bash
claude plugin marketplace add Donnici/mix-dev-skills
claude plugin install mix-dev-skills@mix-dev-skills
```

**Script** (copia para `~/.claude/skills`; `--project` para só o repo atual; `--target DIR` para
outros agentes):

```bash
git clone --depth 1 https://github.com/Donnici/mix-dev-skills /tmp/mix-dev-skills
/tmp/mix-dev-skills/install.sh
```

**skills.sh** (Cursor, Codex, OpenCode, etc.): `npx skills@latest add Donnici/mix-dev-skills`

Depois, em cada repositório: `/mix-setup`.

## Regras padrão (constituição)

O `/mix-setup` cria `constitution.md` já com estes princípios, e acrescenta as regras específicas
que encontrar no repo. Edite com `/mix-constitution "<regra>"`.

1. **Prior art first**: antes de criar qualquer arquivo, achar e ler o equivalente mais próximo
   no repo e imitar estrutura, nomes, tratamento de erro e local.
2. **Dependências instaladas primeiro**: olhar o `package.json` (ou manifesto equivalente) e usar
   a lib já instalada para cada finalidade; dependência nova só com justificativa e aprovação.
3. **Simplicidade**: o código mais simples que atende a spec; sem abstração com uma única
   implementação; sem validação defensiva do que os tipos já garantem.
4. **Comentários só quando relevantes**: só o *porquê* não óbvio, em uma linha; nada de
   comentário narrando o código, código comentado ou histórico de mudança.
5. **Testes que se pagam**: comportamento via interface pública nos seams acordados; um
   comportamento testado uma vez; **passe de poda obrigatório** após a implementação removendo
   testes redundantes, tautológicos, triviais ou acoplados à implementação.
6. **Disciplina de escopo**: o diff contém só o que a spec e as tasks pedem.
7. **Consistência com a arquitetura**: camadas, nomes e padrões do `architecture.md` e dos ADRs.
8. **Contratos entre repos** (multi-repo): definidos no plano antes de qualquer lado; provider e
   consumer batem exatamente.

## Branches, PRs e tickets

Configurado no `/mix-setup`, ajustável por feature no `/mix-specify`:

- **Padrão de branch**: texto fixo + `[variáveis]`. Padrão default `spec/[NNN]-[slug]`
  (ex.: `spec/001-alpha-login`). Presets: `[type]/[slug]` (feat, fix, chore...),
  `[type]/[ticket]-[slug]`, ou personalizado, ex.: `jane/[ticket]`.
  `[NNN]`, `[slug]` e `[story]` são preenchidas sozinhas; `[type]` é inferida e confirmada;
  `[ticket]` e qualquer variável personalizada são **sempre perguntadas** quando necessárias.
- **Estratégia de entrega**:
  - `single`: uma branch e um PR para a feature toda ("implemente com este código de branch").
  - `per-story`: uma branch e um PR por história, direto na base, em entregas pequenas e contínuas.
  - `per-story-stacked`: branch da feature com PR macro; os PRs das histórias apontam para ela.
- **Tickets** (Jira, Linear, GitHub, GitLab, outro): você informa os códigos que já tem, ou o
  `/mix-tasks` cria os tickets das histórias (via MCP/CLI disponível, sempre com confirmação).

## Hub de projetos (várias empresas, vários repos)

As skills não precisam morar dentro do repositório de código. Um **hub** é uma pasta fora do
código, que pode ser um repo que você já tem (um vault de notas, um repo centralizador) ou uma
pasta nova (`~/mix-dev-skills-hub/`). Cada **projeto** (escopo) é uma pasta em **qualquer
caminho** dentro do hub, com a sua pasta `mix-dev-skills/` e as suas `specs/`; os **repos de
código** ficam onde estiverem no disco:

```yaml
# ~/workspace/knowledge-hub/mix-dev-skills/hub.yml
active: nimbus
projects:
  nimbus: { path: work/clients/nimbus }
  orbit:  { path: work/clients/orbit }
  lumen:  { path: work/clients/lumen }
```

```yaml
# ~/workspace/knowledge-hub/work/clients/nimbus/mix-dev-skills/mix.yml (trecho)
knowledge: [index.md, files]          # notas da empresa, lidas como referência e nunca movidas
root: ~/code/nimbus                   # código em outro lugar
repos:
  - { name: storefront, path: storefront, role: Loja online, owns: [páginas, hooks, chamadas à catalog-api] }
  - { name: catalog-api, path: catalog-api, role: Web service, owns: [regras de negócio, serviços, banco, auth] }
integrations:
  - { from: storefront, to: catalog-api, via: REST/JSON }
```

- **Escopo**: `/mix-scope orbit` troca o projeto ativo. Abrir uma sessão dentro de
  `~/code/partner-x/orbit` seleciona o projeto Orbit sozinho (o hub fica registrado em
  `~/.mix-dev-skills/registry.yml`).
- **Pasta existente**: `/mix-scope add work/clients/nimbus` registra uma pasta que já existe; as
  notas dela entram em `knowledge:` e o local do código vira o `root`. As convenções do
  `CLAUDE.md` do hub (nomes, `index.md`, frontmatter) valem para tudo que as skills escrevem nele.
- **Feature ponta a ponta**: `/mix-specify autenticação` gera uma spec única; o `/mix-plan` decide
  que a página e os hooks de login vão no frontend, e as regras, o serviço e o banco na API (e a
  rota intermediária no BFF, se existir). Ele também define o **contrato** entre eles (rota,
  método, campos, tipos, erros, auth). O `/mix-implement` implementa os dois lados contra o mesmo
  contrato e verifica a integração. Branches e PRs são por repo, com o mesmo nome de branch e
  links entre os PRs irmãos.

## Migrando do Spec Kit ou das skills do Matt

As skills do mix não leem nem escrevem nas estruturas do Spec Kit (`.specify/`) ou do Matt
(`GLOSSARY.md`, `docs/adr/`, `.out-of-scope/`, `docs/agents/`, `.scratch/`). Quando encontram
uma delas, recomendam o **`/mix-migrate`**, que:

- inventaria tudo o que existe e mostra o plano (origem → destino → ação) antes de mexer em algo
  (`--dry-run` para parar aí);
- converte a constituição do Spec Kit para o formato do mix sem perder nenhuma regra, move
  glossário, ADRs (renumerando se houver várias pastas) e `out-of-scope`, e leva as configurações
  de tracker e labels para o `mix.yml`;
- mantém as specs em `specs/`, só acrescentando a linha de Delivery;
- remove scripts, hooks e comandos `speckit-*` só com sua confirmação, usa `git mv` para manter o
  histórico, corrige links para os caminhos antigos e nunca faz push.

## Sem git?

Git é opcional. Sem repositório git, nenhum passo trava: branch/commit/PR são pulados, os nomes
planejados vão para `delivery.md` e o review usa a lista de arquivos tocados.

## Nada sobe sem você

`/mix-implement` nunca faz push nem abre PR, e só faz commit local depois que você aprova cada um.
Push e PR acontecem apenas quando você pede (`/mix-pr push`, `/mix-pr pr`), depois de ver o plano
exato (repo, branch, base, título e corpo).

## Arquivos gerados

Tudo o que não é spec fica numa pasta `mix-dev-skills/`; as specs ficam em `specs/` ao lado dela.
As duas ficam na raiz do repo (in-repo) ou na pasta do projeto dentro do hub:

```text
<base>/
├── mix-dev-skills/
│   ├── mix.yml                  root do código, repos, papéis, notas, convenções
│   ├── constitution.md          regras (MUST / SHOULD), versionadas
│   ├── architecture.md          mapa do repo, ou do sistema quando há vários repos
│   ├── architecture/<repo>.md   mapa de cada repo (multi-repo)
│   ├── glossary.md              termos de domínio
│   ├── adr/                     decisões difíceis de reverter
│   ├── out-of-scope/            pedidos rejeitados (triagem)
│   ├── triage/                  rascunhos de triagem (tracker só-leitura)
│   └── templates/               templates próprios do projeto (sobrepõem os padrão)
└── specs/NNN-slug/              spec.md, plan.md, tasks.md, checklists/, delivery.md

<hub>/mix-dev-skills/hub.yml     projetos (nome → pasta) + ativo
~/.mix-dev-skills/registry.yml   hubs conhecidos (para achar o projeto a partir do repo de código)
```

## De onde veio cada parte

| mix-dev-skills | Spec Kit | Matt Pocock | Novo |
|----------------|----------|-------------|------|
| `mix-scope` | — | — | hub de projetos, escopo ativo, resolução de contexto |
| `mix-setup` | — | `setup-matt-pocock-skills` (explorar → confirmar → escrever) | mapa por repo, mapa de integração, libs por finalidade, golden files, convenções de branch/PR/tickets |
| `mix-constitution` | `constitution` (versionamento, placeholders) | `retro` (check automatizado > regra escrita), `writing-for-agents` (regras positivas e checáveis) | princípios padrão com suas regras |
| `mix-specify` | `specify` (template, numeração, checklist de qualidade) | `grill-with-docs`, `domain-modeling`, `to-spec` (problem/solution, out of scope) | Current Behaviour, entrega/tickets |
| `mix-clarify` | `clarify` (taxonomia de cobertura, integração incremental) | `grilling` (rodadas por fronteira) | — |
| `mix-grill` | `clarify` (formato das perguntas, "why it matters") | `grilling` (design tree, fatos vs decisões) | perguntas materiais vs defaults |
| `mix-plan` | `plan` (technical context, constitution check, complexity tracking) | `codebase-design` (módulos profundos, seams), `to-spec` (testing decisions) | inventário de reuso obrigatório |
| `mix-tasks` | `tasks` (formato, fases por história, [P]) | `to-tickets` (fatias verticais, bloqueios, prefactor, expand–contract) | exemplar por task, fase de hardening, tickets por história |
| `mix-analyze` | `analyze` | — | checagens de reuso, exemplar e testes redundantes |
| `mix-implement` | `implement` (gate de checklists, fases, marcar [X]) | `implement`, `tdd` | leitura de exemplar por task, poda de testes, passe de comentários, ship por história |
| `mix-review` | `converge` (missing/partial/contradicts/unrequested, append-only) | `code-review` (eixos em paralelo, smells do Fowler) | eixo de Testes, AI-smells, verificação de achados, `--fix/--tasks/--comment` |
| `mix-testing` | — | `tdd`, `tests.md`, `mocking.md` | passe de poda, redundância entre níveis |
| `mix-pr` | — | — | nomes por padrão com variáveis, estratégias single/per-story/stacked |
| `mix-retro` | — | `retro` | comentários de PR como entrada |
| `mix-triage` | — | `triage` (+ `AGENT-BRIEF.md`, `OUT-OF-SCOPE.md`) | labels e acesso do tracker via `mix.yml`, modo só-leitura, verificação em worktree, multi-repo |
| `mix-diagnose` | — | `diagnosing-bugs` (+ script HITL) | contexto do projeto e notas de incidentes, bugs entre repos/contratos, sem commit/push sem aprovação |
| `mix-wait-what` | — | `wait-what` | — |
| `mix-migrate` | — | — | migração das estruturas do Spec Kit e do Matt para o layout do mix |
| `mix-flow` | — | `ask-matt` | — |

Ficaram de fora (use os originais se precisar): `checklist`, `taskstoissues` (coberto pelo
`/mix-tasks`) do Spec Kit; `prototype`, `wayfinder`, `research` e afins do Matt Pocock. As
extensões/hooks e os scripts bash/PowerShell do Spec Kit também foram removidos: as skills são autocontidas e não dependem do CLI `specify` nem de git.

## Licença

MIT. Derivado de Spec Kit (© GitHub, Inc.) e mattpocock/skills (© Matt Pocock), ambos MIT; veja
[CREDITS.md](CREDITS.md).
