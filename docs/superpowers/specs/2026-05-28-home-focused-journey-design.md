# Home com foco em uma única jornada

## Contexto

A home atual tenta ser dashboard e todo-list ao mesmo tempo: 6 blocos
(stats, progresso do dia, hoje, jornadas, desafios soltos, recompensas)
disputam atenção. Resultado: usuário abre e não sabe pra onde olhar.

A filosofia escrita no `como_funciona` diz "consistência > perfeição",
"sem culpa", "uma coisa de cada vez". A home contradiz isso ao
amontoar tudo na mesma tela e empurrar streak (métrica de pressão
herdada de apps tipo Streaks/Duolingo).

Jornadas são o diferencial conceitual do Evolva — não é só habit
tracker, é sequência intencional rumo a uma recompensa. A home deve
refletir isso.

## Decisão

A home passa a mostrar **uma única coisa**: a jornada que o usuário
colocou em foco. Streak some. Outras jornadas e desafios soltos saem
da home e ficam nas abas que já existem (`/quests`, `/challenges`).

A jornada em foco é escolhida **manualmente** pelo usuário, como um
ato deliberado de "agora minha prioridade é essa".

## Layout

```
┌──────────────────────────────────┐
│ Oi, <nome>                       │
│                                  │
│  <ícone> <título da jornada>     │
│                                  │
│  <título do desafio atual>       │
│  Dia X de N                      │
│                                  │
│  ●●●●●●●●●●●○○○○○○○○○○○○○○○○○○ │
│                                  │
│  🎁 <recompensa>                 │
│  daqui Y dias                    │
│                                  │
│  [    Check-in de hoje    ]     │
│                                  │
└──────────────────────────────────┘
       Bottom nav existente
```

Mobile-first, single-column. Sem hero stats, sem tabela do dia, sem
listas paralelas. Tudo o que existir além disso é ruído.

## Estados

**Com jornada em foco e desafio ativo dentro dela:**
Layout acima, CTA = "Check-in de hoje".

**Check-in já feito hoje:**
CTA vira "✓ Feito hoje" (desabilitado), com micro-copy embaixo tipo
"volte amanhã" ou similar.

**Jornada em foco sem desafio ativo (ex: todos completos ou todos planned):**
Card mostra a jornada e o estado real ("Você terminou todos os
desafios desta jornada" ou "Você tem N desafios planejados nesta
jornada, faça check-in pra começar"). CTA contextual.

**Jornada em foco completada:**
Card de celebração com a recompensa desbloqueada e link pra resgatar.
Abaixo, sugestão "Colocar outra jornada em foco" listando as ativas.

**Nenhuma jornada em foco (mas tem jornadas ativas):**
Card "Escolha uma jornada pra colocar em foco" com lista clicável das
jornadas ativas. Clicar coloca em foco e recarrega.

**Nenhuma jornada criada:**
Card "Comece sua primeira jornada" com CTA pra `new_quest_path`. Link
secundário discreto "ou crie um desafio sem jornada" pra
`new_challenge_path`.

## Modelo de dados

A jornada em foco é uma propriedade do **usuário**, não da jornada.
Cada usuário tem 0 ou 1 jornada em foco em qualquer momento.

Adicionar `focused_quest_id` em `users`:

```
add_reference :users, :focused_quest, foreign_key: { to_table: :quests },
              null: true
```

`User` ganha `belongs_to :focused_quest, class_name: "Quest", optional: true`.

Validação `validate :focused_quest_owned_by_user` garantindo que se
`focused_quest_id` está presente, a jornada pertence ao próprio
usuário e está ativa (não completada). Tentar focar uma jornada
completada deve falhar — o estado "completada" tem outro fluxo.

## Ação de colocar em foco

Endpoint dedicado: `POST /quests/:id/focus`.

Controller (`QuestsController#focus`):
- Pega `@quest = Current.user.quests.find(params[:id])`
- Atualiza `Current.user.update!(focused_quest: @quest)`
- Redirect pra `root_path` com notice "Jornada em foco."

UI: botão "Colocar em foco" no show de cada jornada. Quando a jornada
já é a em foco, mostra badge "Em foco" no lugar do botão.

Limpar o foco: implícito ao escolher outra jornada. Não precisa de
"remover foco" explícito agora — se virar pedido, adiciona depois.

## O que sai do código

**`HomeController#index`** vira algo curto: pega
`Current.user.focused_quest` e o desafio "atual" dentro dela. Não
precisa mais de `@streak`, `@active_count`, `@solo_count`,
`@shared_count`, `@today_challenges`, `@today_checkins`,
`@day_progress`, `@active_quests`, `@active_challenges`,
`@rewards`, etc.

**`User#current_streak`** pode ser removido — não é usado em mais
lugar nenhum.

**Partials da home atual** (`_hero`, `_day_progress`, `_today`,
`_today_card`, `_quest_card`, `_quest_challenge`, `_challenge_card`,
`_reward_card`) deixam de ser usados pela home. Implementação verifica
via `grep` se cada um tem outro caller; sem caller, deleta o arquivo.

**CSS** `home.css` e parte de `cards.css` são reescritos. Estilos
específicos de hero/day-progress/today vão fora.

## Conceito de "desafio atual da jornada"

Já existe `Quest#focused_challenge` (challenge com check-in mais
recente). Mantém o nome — a home usa ele pra escolher qual desafio
mostrar dentro do card da jornada em foco. Não renomeia porque o
método já é usado em outros lugares (`Challenge#focused?`, view de
quest show).

Regra: se a jornada tem 1+ challenge ativo, o mais recentemente ativo
é o atual. Se tem só planejados, mostra o primeiro planejado e o CTA
vira "Fazer primeiro check-in" (que já promove pra active via
`Challenge#start!`).

## O que está fora desse spec

- Tone of voice e personalidade (saudações dinâmicas, copy emocional
  nos estados de transição) — fica pra iteração futura.
- Notificações push / lembretes — fora.
- Stats agregadas ("total de desafios completos", etc) — se quiser
  algo cumulativo no futuro, vai em outro lugar, não na home.
- Animações / micro-interactions no check-in — fora.
- Migrar usuários existentes pra escolher foco — não precisa, o
  estado "sem foco" já está coberto.

## Por que essa escolha

Três decisões deliberadas:

1. **Streak fora.** Métrica de app que pressiona consistência diária.
   O Evolva já assume que dias serão pulados ("um dia sem não apaga
   tudo"). Manter streak era contradição.

2. **Home = uma coisa só.** "Fazer várias coisas ao mesmo tempo acaba
   não fazendo nada" — quote do dono do app. A home reforça isso
   visualmente.

3. **Foco manual.** Escolher a jornada em foco vira um ritual. A app
   não decide por você; você assume.
