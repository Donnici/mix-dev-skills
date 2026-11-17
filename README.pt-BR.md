# mix-dev-skills

[English](README.md) · **Português**

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
/mix-pr   (branch, commit, push e PR de uma vez)  →  /mix-review  →  /mix-retro (comentários viram regras)
```

Mudança pequena (um comportamento, poucos arquivos, sem contrato nem dependência nova)? Use
`/mix-quick-implement "<issue>"`: um comando, uma rodada de perguntas, spec curta em `specs/` e
implementação com teste até o fim.

Quer o fluxo inteiro de uma vez? `/mix-ticket COR-123` roda do spec ao PR na mesma sessão: você
aprova a spec uma vez e ele segue com plan, tasks, analyze, implementação (fatias em paralelo
quando independentes), review final e PR, se você pediu.

| Skill | O que faz | Tipo |
|-------|-----------|------|
| `/mix-scope` | Mostra, troca (`/mix-scope lumen`), lista ou cria projetos no hub. Todas as outras skills resolvem o contexto por ela. | comando + automática |
| `/mix-setup` | Pergunta hub ou in-repo, a pasta root e o papel de cada repo (web, bff, api...), padrão de branch/PR/tickets, e gera o mapa de cada repo (`package.json`, libs por finalidade, padrões, golden files) e, se houver vários, o mapa de integração (contratos, golden path ponta a ponta). Cria a constituição. | comando |
| `/mix-constitution` | Cria/altera as regras (MUST/SHOULD), versionadas. | comando + automática |
| `/mix-specify` | Explora o código, define entrega (branch, tickets, estratégia), faz o grill das decisões, escreve `spec.md`, mantém glossário e ADRs. | comando |
| `/mix-clarify` | Varredura de ambiguidades da spec (taxonomia do Spec Kit) + perguntas + atualização da spec. | comando |
| `/mix-plan` | Quais repos mudam e por quê, inventário de reuso, gate da constituição, **contratos entre repos primeiro** (rota, campos, tipos, erros, auth), design por repo, seams de teste. | comando |
| `/mix-tasks` | Fatias verticais por história; dentro da história: contrato → provider → consumer → integração; cada task com repo, arquivo, exemplar e bloqueios; cria/coleta tickets. | comando |
| `/mix-analyze` | Consistência spec ↔ plan ↔ tasks; só grava o `state.yml`. | comando |
| `/mix-implement` | Implementa task a task em cada repo, lendo o exemplar antes e respeitando os contratos; ao fim de cada entrega: poda de testes, limpeza de comentários, self-review e **commit local só com sua aprovação**. Nunca faz push nem abre PR. | comando |
| `/mix-quick-implement` | Atalho para mudanças pequenas: localiza o código, confirma o comportamento atual, faz **um único check-in** (mudança, teste, decisões com resposta recomendada, branch e commit), escreve uma spec curta, implementa test-first, faz a poda e registra o resultado na spec. Mudança que cresce é encaminhada ao `/mix-specify --quick` sem perder o que foi levantado. | comando |
| `/mix-review` | Revisão em 3 eixos (Padrões, Spec, Testes) em subagentes paralelos, com verificação de cada achado; corrige, gera tasks de convergência ou comenta no PR; com `--report`, só lê e devolve as sugestões num bloco JSON, sem perguntar, alterar ou publicar nada. | comando + automática |
| `/mix-pr` | Um comando, sem aprovação: cria a branch, faz commit, push e abre o PR (um por repo; single, por história ou empilhado) e mostra link, título e descrição. Quer mudar? Peça no chat que ele edita o PR. Também é dono das convenções de nomes. | comando + automática |
| `/mix-ticket` | Do ticket (ou ideia) ao PR numa sessão: lê o ticket no tracker, roda specify, clarify quando precisa, plan, tasks e analyze, para **uma vez** para você aprovar a spec, implementa (fatias independentes em paralelo, em worktrees), faz o review final e abre o PR quando você pediu. Nunca faz merge. | comando |
| `mix-land` | Deixa os PRs abertos prontos para merge: lista CI, conflitos e comentários; classifica cada falha de CI (deste PR, herdada da base, flaky, infra); reproduz antes de corrigir; rascunha respostas aos revisores no seu tom (`pr_reply_tone`); dá a ordem de merge entre repos. Push só via `/mix-pr` e com pedido seu. | comando + automática |
| `mix-housekeep` | Limpa worktrees e branches de PRs mergeados (nunca algo com trabalho dentro), lista o que falta subir e alinha o `state.yml` das specs e o `index.md` com o status real dos PRs. `--dry-run` só mostra o plano. | comando + automática |
| `/mix-retro` | Transforma comentários recorrentes de PR em lint/CI, regras ou contexto. | comando |
| `/mix-triage` | Triagem de issues (e PRs externos): categoria e estado, duplicidade e rejeições anteriores, reprodução, grill e brief pronto para agente. Nada é escrito no tracker sem confirmação; tracker só-leitura gera rascunhos locais. | comando |
| `mix-diagnose` | Bugs difíceis e regressões de performance: primeiro um loop de feedback que fica vermelho no bug, depois hipóteses, instrumentação, fix com teste de regressão e limpeza. Funciona entre repos. | comando + automática |
| `mix-spike` | Investigação técnica antes da spec: mapeia como os repos tratam o assunto hoje, roda uma prova de conceito descartável, compara opções e grava `spike.md` com recomendação em fases. Continua no `/mix-specify --quick` quando vira feature. | comando + automática |
| `/mix-untangle` | Dívida estrutural de um codebase ou de uma área, entre repos: mapeia hotspots, imports e o que muda junto no git; lista ligações ocultas, ligações desnecessárias, código sobrando e casos especiais; redesenha a partir dos requisitos de hoje e grava `untangle.md` com cada correção acima dos problemas que resolve, em fatias sem mudança de comportamento. Não altera código; segue pelo `/mix-specify --quick` (uma história por fatia) ou `/mix-quick-implement`. | comando |
| `/mix-explain` | Explica algo em português técnico claro: uma spec com plano, tasks e evidências (`/mix-explain spec 0014`), um ADR, um arquivo, uma doc, uma URL ou um tema. Sem argumento, explica a última resposta do agente. Não grava nada. | comando |
| `/mix-self-improve` | Lê o relatório do `/insights`, o histórico de sessões e o seu setup (CLAUDE.md, skills, hooks, MCP, settings); explica como você usa o Claude, pontos positivos e negativos, novos jeitos de usar, e propõe melhorias com evidência (regras, skills, hooks, rotinas), aplicadas uma a uma com sua aprovação. `routine` roda sem perguntas. | comando |
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
  `[NNN]`, `[slug]` e `[story]` são preenchidas sozinhas; `[type]` é inferida;
  `[ticket]` e variáveis personalizadas vêm da branch, spec ou commits; só são perguntadas quando nada as traz.
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
Push e PR acontecem apenas quando você roda `/mix-pr` (ou pede no chat): ele faz branch, commit,
push e PR de uma vez, sem pedir confirmação, e mostra o link, o título e a descrição de cada PR.
Para ajustar título ou descrição, peça no chat.

## Estado da spec

Cada skill do fluxo grava onde a spec parou em `specs/NNN-slug/state.yml`, ao lado da spec, com ou
sem git, e o relatório dela informa o mesmo próximo passo:

```yaml
status: Planned          # Specified | Clarified | Planned | Tasked | Analyzed | Implementing | Implemented
next_step: /mix-tasks    # /mix-clarify | /mix-plan | /mix-tasks | /mix-analyze | /mix-implement | /mix-quick-implement | none
prs:                     # opcional; gravado pelo /mix-pr
  - https://github.com/acme/web/pull/5
```

Cada skill altera só os próprios campos e mantém o resto do arquivo. O `/mix-pr` acrescenta o
link de cada PR que abre, e `/mix-quick-implement <pasta da spec>` retoma uma spec curta. O campo
Status saiu dos modelos de spec: o estado fica só neste arquivo.

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
└── specs/NNN-slug/              spec.md, plan.md, tasks.md, state.yml, checklists/, delivery.md
                                 (no /mix-quick-implement, só um spec.md curto com o Outcome e o state.yml;
                                 num spike, só o spike.md; num untangle, só o untangle.md)

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
| `mix-review` | `converge` (missing/partial/contradicts/unrequested, append-only) | `code-review` (eixos em paralelo, smells do Fowler) | eixo de Testes, AI-smells, verificação de achados, `--fix/--tasks/--comment/--report` |
| `mix-testing` | — | `tdd`, `tests.md`, `mocking.md` | passe de poda, redundância entre níveis |
| `mix-pr` | — | — | nomes por padrão com variáveis, estratégias single/per-story/stacked |
| `mix-retro` | — | `retro` | comentários de PR como entrada |
| `mix-triage` | — | `triage` (+ `AGENT-BRIEF.md`, `OUT-OF-SCOPE.md`) | labels e acesso do tracker via `mix.yml`, modo só-leitura, verificação em worktree, multi-repo |
| `mix-quick-implement` | `specify`, `implement` (compactados) | `diagnosing-bugs` (sinal antes do fix), `tdd` | gate de tamanho, check-in único, spec curta com Outcome |
| `mix-diagnose` | — | `diagnosing-bugs` (+ script HITL) | contexto do projeto e notas de incidentes, bugs entre repos/contratos, sem commit/push sem aprovação |
| `mix-explain` | — | `wait-what` (reexplicar a última mensagem) | alvos (spec, ADR, arquivo, URL, tema), evidências com fonte; regras de escrita adaptadas do [Português Técnico Simplificado](https://github.com/nosportugal/portugues-tecnico-simplificado-skill) (NOS, MIT) para pt-BR |
| `mix-self-improve` | — | — | relatório do `/insights` como entrada; ideia de modos, limites de evidência e estado inspirada na skill `improve-system` do [buildpartner-plugin](https://github.com/austinmarchese/buildpartner-plugin) (texto próprio, sem cópia) |
| `mix-ticket` | — | — | orquestra o fluxo principal numa sessão, com um único checkpoint na spec |
| `mix-land` | — | — | classificação de falhas de CI, reprodução antes do fix, respostas no tom configurado, ordem de merge |
| `mix-housekeep` | — | — | limpeza segura de worktrees e branches, sincronia de specs com o status dos PRs |
| `mix-spike` | — | — | investigação com prova de conceito e recomendação em fases (`spike.md`) |
| `mix-untangle` | — | `codebase-design` (módulos profundos) | adaptada da skill `untangle-codebase` do [caldoai/skills](https://github.com/caldoai/skills) (Maze, MIT): pergunta "muda junto?", casos especiais como sinal de design, log de decisões; aqui só diagnóstico e redesenho, multi-repo, em fatias que seguem pelo fluxo |
| `mix-migrate` | — | — | migração das estruturas do Spec Kit e do Matt para o layout do mix |
| `mix-flow` | — | `ask-matt` | — |

Ficaram de fora (use os originais se precisar): `checklist`, `taskstoissues` (coberto pelo
`/mix-tasks`) do Spec Kit; `prototype`, `wayfinder`, `research` e afins do Matt Pocock. As
extensões/hooks e os scripts bash/PowerShell do Spec Kit também foram removidos: as skills são autocontidas e não dependem do CLI `specify` nem de git.

## Contribuindo

Issues e PRs são bem-vindos. Leia o [CONTRIBUTING.md](CONTRIBUTING.md) e o
[Código de Conduta](CODE_OF_CONDUCT.md). Para relatar uma falha de segurança (por exemplo, uma
skill que pode ser usada para injeção de prompt ou para vazar dados), siga o
[SECURITY.md](SECURITY.md) em vez de abrir uma issue pública.

## Licença

MIT. Derivado de Spec Kit (© GitHub, Inc.), mattpocock/skills (© Matt Pocock) e
portugues-tecnico-simplificado-skill (© Dustin Yuchen Teng, Thiago Machado, NOS Comunicações)
e caldoai/skills (© Maze), todos MIT; veja
[CREDITS.md](CREDITS.md).
