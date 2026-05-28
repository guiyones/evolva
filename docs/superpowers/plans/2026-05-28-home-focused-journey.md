# Home com foco em uma única jornada — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reescrever a home pra mostrar apenas a jornada que o usuário colocou em foco. Streak some, outras jornadas/desafios saem da home, foco é escolhido manualmente.

**Architecture:** Adicionar `focused_quest_id` em `users` apontando pra `quests`. Action `POST /quests/:id/focus` seta esse FK no `Current.user`. `HomeController#index` carrega apenas `Current.user.focused_quest`. View renderiza um único card grande com 5 sub-estados. Partials antigos da home viram código morto e são removidos.

**Tech Stack:** Rails 8.1.3, Postgres, ActionView (Hotwire/Turbo Drive sem JS novo), Minitest, Tailwind + CSS por componente.

---

## Files

**Create:**
- `db/migrate/<timestamp>_add_focused_quest_to_users.rb`
- `app/views/home/_focus_card.html.erb`
- `app/views/home/_choose_focus.html.erb`
- `app/views/home/_no_quests.html.erb`

**Modify:**
- `app/models/user.rb` — associação `focused_quest` + validação
- `app/controllers/home_controller.rb` — simplifica index
- `app/controllers/quests_controller.rb` — action `focus`
- `config/routes.rb` — rota `POST /quests/:id/focus`
- `app/views/home/index.html.erb` — reescrita
- `app/views/quests/_header.html.erb` — botão/badge de foco
- `app/assets/stylesheets/home.css` — substitui estilos antigos pelos do novo card

**Test:**
- `test/models/user_test.rb`
- `test/controllers/quests_controller_test.rb`
- `test/controllers/home_controller_test.rb`
- `test/fixtures/users.yml` — adiciona referência opcional ao focused_quest se útil

**Delete (Task 7 — só depois que tudo verde):**
- `app/views/home/_hero.html.erb`
- `app/views/home/_day_progress.html.erb`
- `app/views/home/_today.html.erb`
- `app/views/home/_today_card.html.erb`
- `app/views/home/_quest_card.html.erb`
- `app/views/home/_quest_challenge.html.erb`
- `app/views/home/_challenge_card.html.erb`
- `app/views/home/_reward_card.html.erb`
- `User#current_streak` (e potencialmente `active_challenges_count`, `unlocked_rewards_count` se grep não achar uso fora da home)

---

## Task 1: Migration + associação `User#focused_quest`

**Files:**
- Create: `db/migrate/<timestamp>_add_focused_quest_to_users.rb`
- Modify: `app/models/user.rb`
- Test: `test/models/user_test.rb`

- [ ] **Step 1: Escreve teste falhando**

Em `test/models/user_test.rb`, adiciona:

```ruby
test "user can have a focused_quest" do
  user = users(:one)
  quest = quests(:leitura)
  user.update!(focused_quest: quest)
  assert_equal quest, user.reload.focused_quest
end
```

- [ ] **Step 2: Roda teste, vê falhar**

```
bin/rails test test/models/user_test.rb -n test_user_can_have_a_focused_quest
```

Esperado: erro tipo `NoMethodError: undefined method 'focused_quest='` ou similar.

- [ ] **Step 3: Cria a migration**

```
bin/rails generate migration AddFocusedQuestToUsers focused_quest:references
```

Edita o arquivo gerado pra garantir `null: true` e foreign key correta:

```ruby
class AddFocusedQuestToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :focused_quest,
                  foreign_key: { to_table: :quests },
                  null: true
  end
end
```

- [ ] **Step 4: Roda a migration**

```
bin/rails db:migrate
bin/rails db:test:prepare
```

- [ ] **Step 5: Adiciona associação no model**

Em `app/models/user.rb`, depois dos outros `has_many`:

```ruby
belongs_to :focused_quest, class_name: "Quest", optional: true
```

- [ ] **Step 6: Roda teste, vê passar**

```
bin/rails test test/models/user_test.rb
```

Esperado: todos verdes.

- [ ] **Step 7: Commit**

```
git add db/migrate db/schema.rb app/models/user.rb test/models/user_test.rb
git commit -m "feat(user): adiciona belongs_to :focused_quest"
```

---

## Task 2: Validação — focused_quest tem que pertencer ao usuário e estar ativa

**Files:**
- Modify: `app/models/user.rb`
- Test: `test/models/user_test.rb`

- [ ] **Step 1: Escreve dois testes falhando**

Em `test/models/user_test.rb`:

```ruby
test "rejects focused_quest belonging to another user" do
  user = users(:one)
  other_quest = users(:two).quests.create!(title: "Outra", status: :active)
  user.focused_quest = other_quest
  assert_not user.valid?
  assert_includes user.errors[:focused_quest], "deve pertencer a você"
end

test "rejects focused_quest that is completed" do
  user = users(:one)
  user.focused_quest = quests(:completada)
  assert_not user.valid?
  assert_includes user.errors[:focused_quest], "precisa estar ativa"
end
```

- [ ] **Step 2: Roda os 2 testes, vê falhar**

```
bin/rails test test/models/user_test.rb -n /focused_quest/
```

Esperado: ambos falham por "expected invalid? to be true".

- [ ] **Step 3: Adiciona validação no User**

Em `app/models/user.rb`, abaixo da associação:

```ruby
validate :focused_quest_owned_by_user_and_active

private

def focused_quest_owned_by_user_and_active
  return if focused_quest.blank?

  if focused_quest.user_id != id
    errors.add(:focused_quest, "deve pertencer a você")
  elsif !focused_quest.active?
    errors.add(:focused_quest, "precisa estar ativa")
  end
end
```

- [ ] **Step 4: Roda testes, vê passar**

```
bin/rails test test/models/user_test.rb
```

Esperado: todos verdes.

- [ ] **Step 5: Commit**

```
git add app/models/user.rb test/models/user_test.rb
git commit -m "feat(user): valida que focused_quest pertence ao user e esta ativa"
```

---

## Task 3: Action `QuestsController#focus` + rota

**Files:**
- Modify: `config/routes.rb`
- Modify: `app/controllers/quests_controller.rb`
- Test: `test/controllers/quests_controller_test.rb`

- [ ] **Step 1: Escreve 3 testes falhando**

Em `test/controllers/quests_controller_test.rb`, no bloco do `class`:

```ruby
test "focus sets focused_quest on current user" do
  quest = quests(:leitura)
  post focus_quest_path(quest)
  assert_redirected_to root_path
  assert_equal quest, users(:one).reload.focused_quest
end

test "focus forbids quest from another user" do
  other_quest = users(:two).quests.create!(title: "Outra", status: :active)
  assert_raises(ActiveRecord::RecordNotFound) do
    post focus_quest_path(other_quest)
  end
end

test "focus on completed quest is rejected" do
  post focus_quest_path(quests(:completada))
  assert_redirected_to quest_path(quests(:completada))
  assert_nil users(:one).reload.focused_quest
end
```

- [ ] **Step 2: Roda os 3, vê falhar**

```
bin/rails test test/controllers/quests_controller_test.rb -n /focus/
```

Esperado: todos falham por "undefined local variable or method `focus_quest_path`".

- [ ] **Step 3: Adiciona a rota**

Em `config/routes.rb`, dentro do bloco `resources :quests do member do ... end end`, acrescenta `post :focus`:

```ruby
resources :quests, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
  member do
    post :attach_challenge
    post :focus
  end
end
```

- [ ] **Step 4: Adiciona a action**

Em `app/controllers/quests_controller.rb`, depois de `attach_challenge`:

```ruby
def focus
  @quest = Current.user.quests.find(params[:id])

  if Current.user.update(focused_quest: @quest)
    redirect_to root_path, notice: "Jornada em foco."
  else
    redirect_to @quest, alert: "Não foi possível colocar essa jornada em foco."
  end
end
```

- [ ] **Step 5: Roda testes, vê passar**

```
bin/rails test test/controllers/quests_controller_test.rb
```

Esperado: todos verdes.

- [ ] **Step 6: Commit**

```
git add config/routes.rb app/controllers/quests_controller.rb test/controllers/quests_controller_test.rb
git commit -m "feat(quests): action POST /quests/:id/focus"
```

---

## Task 4: Botão "Colocar em foco" / badge "Em foco" no quest show

**Files:**
- Modify: `app/views/quests/_header.html.erb`
- Modify: `app/assets/stylesheets/quest_show.css` (estilos do badge)
- Test: smoke test no controller

- [ ] **Step 1: Smoke test no QuestsControllerTest**

Em `test/controllers/quests_controller_test.rb`, no bloco existente, adiciona:

```ruby
test "show has focus button when quest is not focused" do
  get quest_path(quests(:leitura))
  assert_response :success
  assert_select "form[action=?]", focus_quest_path(quests(:leitura))
end

test "show has 'Em foco' badge when quest is focused" do
  users(:one).update!(focused_quest: quests(:leitura))
  get quest_path(quests(:leitura))
  assert_response :success
  assert_select ".quest-focus-badge", text: "Em foco"
end
```

- [ ] **Step 2: Roda, vê falhar**

```
bin/rails test test/controllers/quests_controller_test.rb -n /show_has/
```

Esperado: falham por "Expected at least 1 element matching..."

- [ ] **Step 3: Atualiza `_header.html.erb`**

Substitui o conteúdo de `app/views/quests/_header.html.erb` por:

```erb
<div class="quest-header">
  <%= quest_status_badge(quest) %>
  <div class="challenge-header-actions">
    <% if Current.user.focused_quest_id == quest.id %>
      <span class="quest-focus-badge">Em foco</span>
    <% elsif quest.active? %>
      <%= button_to "Colocar em foco", focus_quest_path(quest),
          method: :post,
          class: "action-btn action-btn-focus" %>
    <% end %>
    <%= link_to "Editar", edit_quest_path(quest), class: "action-btn action-btn-edit" %>
    <%= link_to "Apagar", quest_path(quest),
        data: { turbo_method: :delete, turbo_confirm: "Tem certeza? Isso apaga a jornada e todos os desafios." },
        class: "action-btn action-btn-delete" %>
  </div>
</div>
```

- [ ] **Step 4: Adiciona estilos**

Em `app/assets/stylesheets/quest_show.css`, depois das `.quest-status` classes, acrescenta:

```css
.quest-focus-badge {
  height: 32px;
  padding: 0 14px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  font-size: 13px;
  background: rgba(108, 77, 255, 0.15);
  color: var(--evolva-purple);
}

.action-btn-focus {
  background: rgba(108, 77, 255, 0.15);
  color: var(--evolva-purple);
  border: none;
  cursor: pointer;
}
.action-btn-focus:hover { background: rgba(108, 77, 255, 0.3); }
```

- [ ] **Step 5: Roda os 2 testes, vê passar**

```
bin/rails test test/controllers/quests_controller_test.rb
```

Esperado: tudo verde.

- [ ] **Step 6: Commit**

```
git add app/views/quests/_header.html.erb app/assets/stylesheets/quest_show.css test/controllers/quests_controller_test.rb
git commit -m "feat(quests): botao 'Colocar em foco' e badge 'Em foco' no show"
```

---

## Task 5: HomeController simplificado + testes de estado

**Files:**
- Modify: `app/controllers/home_controller.rb`
- Test: `test/controllers/home_controller_test.rb`

- [ ] **Step 1: Atualiza os testes da HomeController**

Substitui o conteúdo de `test/controllers/home_controller_test.rb` por:

```ruby
require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when unauthenticated" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "renders 'no quests' state when user has no quests" do
    user = User.create!(email_address: "nq@example.com", password: "secret123")
    sign_in_as user
    get root_path
    assert_response :success
    assert_select "*", text: /sua primeira jornada/i
  end

  test "renders 'choose focus' state when user has active quests but none focused" do
    sign_in_as users(:one)
    get root_path
    assert_response :success
    assert_select "*", text: /Escolha uma jornada/i
  end

  test "renders focus card when user has a focused quest" do
    users(:one).update!(focused_quest: quests(:leitura))
    sign_in_as users(:one)
    get root_path
    assert_response :success
    assert_select "*", text: /Ler mais livros/
  end
end
```

- [ ] **Step 2: Roda testes, vê falhar**

```
bin/rails test test/controllers/home_controller_test.rb
```

Esperado: vários falham (vai depender do estado atual da view).

- [ ] **Step 3: Reescreve `HomeController#index`**

Substitui o conteúdo de `app/controllers/home_controller.rb` por:

```ruby
class HomeController < ApplicationController
  def index
    @focused_quest = Current.user.focused_quest
    @active_quests = Current.user.quests.active.recent if @focused_quest.nil?
  end
end
```

- [ ] **Step 4: Não roda os testes ainda** — a view ainda precisa ser reescrita (próxima task). Apenas confirma que o controller sintaxe OK:

```
bin/rails runner "puts HomeController.instance_method(:index).owner"
```

Esperado: `HomeController`.

- [ ] **Step 5: Commit (parcial — view vem na próxima)**

```
git add app/controllers/home_controller.rb test/controllers/home_controller_test.rb
git commit -m "refactor(home): simplifica controller para focused_quest"
```

---

## Task 6: Reescreve `home/index.html.erb` e cria os partials de estado

**Files:**
- Create: `app/views/home/_focus_card.html.erb`
- Create: `app/views/home/_choose_focus.html.erb`
- Create: `app/views/home/_no_quests.html.erb`
- Modify: `app/views/home/index.html.erb`

- [ ] **Step 1: Reescreve `home/index.html.erb`**

```erb
<div class="home">
  <p class="home-greeting">Oi, <%= Current.user.display_name %></p>

  <% if @focused_quest.present? %>
    <%= render "focus_card", quest: @focused_quest %>
  <% elsif @active_quests.any? %>
    <%= render "choose_focus", quests: @active_quests %>
  <% else %>
    <%= render "no_quests" %>
  <% end %>
</div>
```

- [ ] **Step 2: Cria `_focus_card.html.erb`**

Em `app/views/home/_focus_card.html.erb`:

```erb
<% current_challenge = quest.focused_challenge || quest.challenges.where(status: :planned).order(created_at: :asc).first %>
<% checked_today = current_challenge.present? && current_challenge.checkins.where(created_at: Date.current.all_day).exists? %>

<div class="focus-card">
  <p class="focus-card-quest">📖 <%= quest.title %></p>

  <% if quest.completed? %>
    <p class="focus-card-celebration">✓ Jornada concluída</p>
    <% if quest.reward.present? %>
      <%= link_to "Resgatar #{quest.reward.description}", reward_path(quest.reward),
          class: "focus-card-cta" %>
    <% end %>
    <p class="focus-card-hint">Coloque outra jornada em foco na aba Jornadas.</p>

  <% elsif current_challenge.present? %>
    <p class="focus-card-challenge"><%= current_challenge.title %></p>
    <% if current_challenge.active? && current_challenge.started_at.present? %>
      <p class="focus-card-day">Dia <%= current_challenge.current_day %> de <%= current_challenge.duration_days %></p>
    <% elsif current_challenge.planned? %>
      <p class="focus-card-day">Planejado · <%= current_challenge.duration_days %> dias</p>
    <% end %>

    <div class="focus-card-track">
      <div class="focus-card-fill" style="width: <%= current_challenge.progress_percentage %>%"></div>
    </div>

    <% if quest.reward.present? %>
      <p class="focus-card-reward">🎁 <%= quest.reward.description %></p>
    <% end %>

    <% if checked_today %>
      <div class="focus-card-cta is-done">✓ Feito hoje</div>
    <% elsif current_challenge.planned? %>
      <%= link_to "Fazer primeiro check-in", new_challenge_checkin_path(current_challenge),
          class: "focus-card-cta" %>
    <% else %>
      <%= link_to "Check-in de hoje", new_challenge_checkin_path(current_challenge),
          class: "focus-card-cta" %>
    <% end %>

  <% else %>
    <p class="focus-card-empty">Sem desafio ativo nesta jornada.</p>
    <%= link_to "Criar desafio", new_challenge_path(quest_id: quest.id),
        class: "focus-card-cta" %>
  <% end %>
</div>
```

- [ ] **Step 3: Cria `_choose_focus.html.erb`**

Em `app/views/home/_choose_focus.html.erb`:

```erb
<div class="choose-focus">
  <p class="choose-focus-title">Escolha uma jornada pra colocar em foco</p>
  <p class="choose-focus-hint">A home vai mostrar apenas essa jornada.</p>

  <div class="choose-focus-list">
    <% quests.each do |quest| %>
      <%= button_to focus_quest_path(quest),
          method: :post,
          class: "choose-focus-item" do %>
        📖 <%= quest.title %>
      <% end %>
    <% end %>
  </div>
</div>
```

- [ ] **Step 4: Cria `_no_quests.html.erb`**

Em `app/views/home/_no_quests.html.erb`:

```erb
<div class="no-quests">
  <p class="no-quests-title">Comece sua primeira jornada</p>
  <p class="no-quests-hint">Uma jornada é uma missão maior com vários desafios e uma recompensa no fim.</p>
  <%= link_to "Criar jornada", new_quest_path, class: "no-quests-cta" %>
  <%= link_to "ou crie um desafio sem jornada", new_challenge_path, class: "no-quests-alt" %>
</div>
```

- [ ] **Step 5: Roda testes do home, vê passar**

```
bin/rails test test/controllers/home_controller_test.rb
```

Esperado: 4 verdes.

- [ ] **Step 6: Commit**

```
git add app/views/home/
git commit -m "feat(home): reescreve home com card de jornada em foco e estados vazios"
```

---

## Task 7: Estilos do novo home

**Files:**
- Modify: `app/assets/stylesheets/home.css`

- [ ] **Step 1: Substitui o conteúdo de `home.css` por estilos novos**

Em `app/assets/stylesheets/home.css`:

```css
/* Home redesenhada: foco em uma jornada */

.home {
  max-width: 32rem;
  margin: 0 auto;
  padding: 2rem 1rem 5rem;
}

.home-greeting {
  font-size: 18px;
  color: var(--evolva-muted);
  margin-bottom: 2rem;
}

/* Focus card */
.focus-card {
  background: var(--evolva-card);
  border: 0.5px solid rgba(108, 77, 255, 0.2);
  border-radius: 16px;
  padding: 1.75rem 1.5rem;
  box-shadow: 0 4px 32px rgba(108, 77, 255, 0.08);
}

.focus-card-quest {
  font-size: 14px;
  color: var(--evolva-muted);
  margin-bottom: 0.75rem;
}

.focus-card-challenge {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--evolva-text);
  margin-bottom: 0.5rem;
}

.focus-card-day {
  font-size: 14px;
  color: #9ca3af;
  margin-bottom: 1.25rem;
}

.focus-card-track {
  width: 100%;
  height: 6px;
  background: var(--evolva-border);
  border-radius: 9999px;
  overflow: hidden;
  margin-bottom: 1.5rem;
}
.focus-card-fill {
  height: 100%;
  border-radius: 9999px;
  background: linear-gradient(90deg, var(--evolva-purple), var(--evolva-green));
}

.focus-card-reward {
  font-size: 14px;
  color: var(--evolva-text);
  margin-bottom: 1.5rem;
}

.focus-card-cta {
  display: block;
  width: 100%;
  text-align: center;
  color: white;
  background: var(--evolva-purple);
  font-weight: 600;
  padding: 1rem;
  border-radius: 0.75rem;
  text-decoration: none;
  border: none;
  cursor: pointer;
  transition: background 0.15s;
}
.focus-card-cta:hover { background: var(--evolva-purple-hover); }
.focus-card-cta.is-done {
  background: transparent;
  border: 0.5px solid var(--evolva-border);
  color: var(--evolva-muted);
  cursor: default;
}

.focus-card-celebration {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--evolva-green);
  margin-bottom: 1rem;
}

.focus-card-empty {
  color: var(--evolva-muted);
  margin-bottom: 1rem;
}

.focus-card-hint {
  font-size: 13px;
  color: var(--evolva-muted);
  margin-top: 1rem;
  text-align: center;
}

/* Choose focus */
.choose-focus {
  padding: 3rem 0;
  text-align: center;
}
.choose-focus-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--evolva-text);
  margin-bottom: 0.5rem;
}
.choose-focus-hint {
  font-size: 14px;
  color: var(--evolva-muted);
  margin-bottom: 2rem;
}
.choose-focus-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.choose-focus-item {
  background: var(--evolva-card);
  border: 0.5px solid var(--evolva-border);
  border-radius: 12px;
  padding: 1rem;
  color: var(--evolva-text);
  font-size: 14px;
  cursor: pointer;
  transition: border-color 0.2s;
  width: 100%;
}
.choose-focus-item:hover { border-color: var(--evolva-purple); }

/* No quests */
.no-quests {
  padding: 4rem 0;
  text-align: center;
}
.no-quests-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--evolva-text);
  margin-bottom: 0.75rem;
}
.no-quests-hint {
  color: var(--evolva-muted);
  margin-bottom: 2rem;
}
.no-quests-cta {
  display: inline-block;
  color: white;
  background: var(--evolva-purple);
  font-weight: 600;
  padding: 0.75rem 2rem;
  border-radius: 0.5rem;
  text-decoration: none;
  margin-bottom: 1rem;
}
.no-quests-cta:hover { background: var(--evolva-purple-hover); }
.no-quests-alt {
  display: block;
  color: var(--evolva-purple);
  font-size: 14px;
  text-decoration: none;
}
```

- [ ] **Step 2: Sobe servidor e confere visual rapidão**

```
bin/rails server -p 3050
```

Manualmente acessa `/` em cada estado (sem foco / com foco / sem jornada). Não precisa testar todos os caminhos — visual sanity check.

- [ ] **Step 3: Commit**

```
git add app/assets/stylesheets/home.css
git commit -m "feat(home): estilos do card de jornada em foco"
```

---

## Task 8: Limpa código morto

**Files:**
- Delete: 8 partials da home
- Modify: `app/models/user.rb` (remove métodos não usados)

- [ ] **Step 1: Verifica que cada partial antigo não tem mais caller**

```bash
for f in _hero _day_progress _today _today_card _quest_card _quest_challenge _challenge_card _reward_card; do
  echo "=== $f ==="
  grep -rn "render.*home/${f#_}\|render \"$f\|render '$f" app/ test/ | grep -v "home/_$f"
done
```

Esperado: nenhum resultado pra cada um. Se algum aparecer, **não delete esse partial** (e revisa o que ele tá fazendo lá).

- [ ] **Step 2: Deleta os partials sem caller**

```
rm app/views/home/_hero.html.erb \
   app/views/home/_day_progress.html.erb \
   app/views/home/_today.html.erb \
   app/views/home/_today_card.html.erb \
   app/views/home/_quest_card.html.erb \
   app/views/home/_quest_challenge.html.erb \
   app/views/home/_challenge_card.html.erb \
   app/views/home/_reward_card.html.erb
```

- [ ] **Step 3: Verifica que `User#current_streak` não é mais usado**

```
grep -rn "current_streak" app/ test/
```

Esperado: nenhum resultado (a home era o único caller). Se aparecer em outro lugar, **não remove o método**.

- [ ] **Step 4: Remove `current_streak` do User**

Em `app/models/user.rb`, deleta o método inteiro:

```ruby
def current_streak
  streak = 0
  date = Date.current
  loop do
    has_checkin = challenges.joins(:checkins)
      .where(checkins: { created_at: date.all_day })
      .exists?
    break unless has_checkin
    streak += 1
    date -= 1.day
  end
  streak
end
```

- [ ] **Step 5: Verifica `active_challenges_count` e `unlocked_rewards_count`**

```
grep -rn "active_challenges_count\|unlocked_rewards_count" app/ test/
```

Se só aparecer dentro de `app/models/user.rb`, remove ambos os métodos. Se aparecer em qualquer outro lugar, deixa.

- [ ] **Step 6: Roda a suite completa**

```
bin/rails test
bin/rubocop
```

Esperado: 0 falhas, 0 ofensas.

- [ ] **Step 7: Commit**

```
git add -A
git commit -m "chore(home): remove partials e metodos sem caller depois da reescrita"
```

---

## Self-Review

**Cobertura do spec:**
- Streak removido → Task 8 (remove `current_streak`)
- Home só mostra foco → Task 5 (controller), Task 6 (view)
- Foco manual → Task 1-3 (model + action), Task 4 (botão)
- Layout e 5 estados → Task 6 (partials cobrem todos os estados)
- Modelo `focused_quest_id` em users → Task 1
- Validação ownership + active → Task 2
- Action `POST /quests/:id/focus` → Task 3
- Botão e badge no quest show → Task 4
- Estilos novos → Task 7
- Limpeza de código morto → Task 8

Tudo coberto.

**Placeholder scan:** nenhuma instância de TBD, TODO, "implement later", "add appropriate error handling". Todos os steps têm código concreto.

**Consistência:** `focused_quest_id` usado consistentemente. `User#focused_quest` retorna `Quest`. `focus_quest_path` é a rota gerada pelo `member do post :focus end`. `Quest#focused_challenge` mantido (já existe). Sem renomeações inconsistentes.

**Ambiguidades resolvidas:** Task 4 deixa claro que o badge só aparece quando `Current.user.focused_quest_id == quest.id` e o botão só aparece quando a quest é active. Task 6 cobre todos os sub-estados do focus_card.
