---
name: fix-list-delete-and-merge-failures
---
Our groceries_features are failing with the following failures. As part of this work, a review of the groceries-client code should be done as it is unlikely to be just test issues at this point.

```text
Failures:

   1) A list behaves like a list that is incomplete is deleted
      Failure/Error: throw "full wait time lapsed" if counter  original_wait_time

      UncaughtThrowError:
        uncaught throw "full wait time lapsed"
      Shared Example Group: "a list" called from ./spec/features/lists/lists_spec.rb:6
      # ./spec/support/helpers/wait_helper.rb:31:in 'Kernel#throw'
      # ./spec/support/helpers/wait_helper.rb:31:in 'Helpers::WaitHelper#wait_time_lapsed?'
      # ./spec/support/helpers/wait_helper.rb:10:in 'Helpers::WaitHelper#wait_for'
      # ./spec/support/pages/home.rb:331:in 'Pages::Home#wait_until_confirm_delete_button_visible'
      # ./spec/support/shared_examples/lists.rb:143:in 'block (3 levels) in <top (required)>'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:124:in 'block in RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:110:in 'RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec_ext/rspec_ext.rb:12:in 'RSpec::Core::Example::Procsy#run_with_retry'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:37:in 'block (2 levels) in RSpec::Retry.setup'

   2) A list behaves like a list that is incomplete that is shared that is pending rejects
      Failure/Error: throw "full wait time lapsed" if counter  original_wait_time

      UncaughtThrowError:
        uncaught throw "full wait time lapsed"
      Shared Example Group: "a list" called from ./spec/features/lists/lists_spec.rb:6
      # ./spec/support/helpers/wait_helper.rb:31:in 'Kernel#throw'
      # ./spec/support/helpers/wait_helper.rb:31:in 'Helpers::WaitHelper#wait_time_lapsed?'
      # ./spec/support/helpers/wait_helper.rb:10:in 'Helpers::WaitHelper#wait_for'
      # ./spec/support/pages/home.rb:335:in 'Pages::Home#wait_until_confirm_reject_button_visible'
      # ./spec/support/shared_examples/lists.rb:192:in 'block (5 levels) in <top (required)>'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:124:in 'block in RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:110:in 'RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec_ext/rspec_ext.rb:12:in 'RSpec::Core::Example::Procsy#run_with_retry'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:37:in 'block (2 levels) in RSpec::Retry.setup'

   3) A list behaves like a list that is incomplete that is shared that is accepted with write access is deleted
      Failure/Error: throw "full wait time lapsed" if counter  original_wait_time

      UncaughtThrowError:
        uncaught throw "full wait time lapsed"
      Shared Example Group: "a list" called from ./spec/features/lists/lists_spec.rb:6
      # ./spec/support/helpers/wait_helper.rb:31:in 'Kernel#throw'
      # ./spec/support/helpers/wait_helper.rb:31:in 'Helpers::WaitHelper#wait_time_lapsed?'
      # ./spec/support/helpers/wait_helper.rb:10:in 'Helpers::WaitHelper#wait_for'
      # ./spec/support/pages/home.rb:331:in 'Pages::Home#wait_until_confirm_delete_button_visible'
      # ./spec/support/shared_examples/lists.rb:232:in 'block (6 levels) in <top (required)>'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:124:in 'block in RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:110:in 'RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec_ext/rspec_ext.rb:12:in 'RSpec::Core::Example::Procsy#run_with_retry'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:37:in 'block (2 levels) in RSpec::Retry.setup'

   4) A list behaves like a list that is incomplete that is shared that is accepted with read access is deleted
      Failure/Error: throw "full wait time lapsed" if counter  original_wait_time

      UncaughtThrowError:
        uncaught throw "full wait time lapsed"
      Shared Example Group: "a list" called from ./spec/features/lists/lists_spec.rb:6
      # ./spec/support/helpers/wait_helper.rb:31:in 'Kernel#throw'
      # ./spec/support/helpers/wait_helper.rb:31:in 'Helpers::WaitHelper#wait_time_lapsed?'
      # ./spec/support/helpers/wait_helper.rb:10:in 'Helpers::WaitHelper#wait_for'
      # ./spec/support/pages/home.rb:331:in 'Pages::Home#wait_until_confirm_delete_button_visible'
      # ./spec/support/shared_examples/lists.rb:287:in 'block (6 levels) in <top (required)>'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:124:in 'block in RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:110:in 'RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec_ext/rspec_ext.rb:12:in 'RSpec::Core::Example::Procsy#run_with_retry'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:37:in 'block (2 levels) in RSpec::Retry.setup'

   5) A list behaves like a list that is complete is deleted
      Failure/Error: throw "full wait time lapsed" if counter  original_wait_time

      UncaughtThrowError:
        uncaught throw "full wait time lapsed"
      Shared Example Group: "a list" called from ./spec/features/lists/lists_spec.rb:6
      # ./spec/support/helpers/wait_helper.rb:31:in 'Kernel#throw'
      # ./spec/support/helpers/wait_helper.rb:31:in 'Helpers::WaitHelper#wait_time_lapsed?'
      # ./spec/support/helpers/wait_helper.rb:10:in 'Helpers::WaitHelper#wait_for'
      # ./spec/support/pages/home.rb:331:in 'Pages::Home#wait_until_confirm_delete_button_visible'
      # ./spec/support/shared_examples/lists.rb:364:in 'block (3 levels) in <top (required)>'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:124:in 'block in RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:110:in 'RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec_ext/rspec_ext.rb:12:in 'RSpec::Core::Example::Procsy#run_with_retry'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:37:in 'block (2 levels) in RSpec::Retry.setup'

   6) A list behaves like a list that is complete that is shared with write access is deleted
      Failure/Error: throw "full wait time lapsed" if counter  original_wait_time

      UncaughtThrowError:
        uncaught throw "full wait time lapsed"
      Shared Example Group: "a list" called from ./spec/features/lists/lists_spec.rb:6
      # ./spec/support/helpers/wait_helper.rb:31:in 'Kernel#throw'
      # ./spec/support/helpers/wait_helper.rb:31:in 'Helpers::WaitHelper#wait_time_lapsed?'
      # ./spec/support/helpers/wait_helper.rb:10:in 'Helpers::WaitHelper#wait_for'
      # ./spec/support/pages/home.rb:331:in 'Pages::Home#wait_until_confirm_delete_button_visible'
      # ./spec/support/shared_examples/lists.rb:397:in 'block (5 levels) in <top (required)>'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:124:in 'block in RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:110:in 'RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec_ext/rspec_ext.rb:12:in 'RSpec::Core::Example::Procsy#run_with_retry'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:37:in 'block (2 levels) in RSpec::Retry.setup'

   7) A list behaves like a list that is complete that is shared with read access is deleted
      Failure/Error: throw "full wait time lapsed" if counter  original_wait_time

      UncaughtThrowError:
        uncaught throw "full wait time lapsed"
      Shared Example Group: "a list" called from ./spec/features/lists/lists_spec.rb:6
      # ./spec/support/helpers/wait_helper.rb:31:in 'Kernel#throw'
      # ./spec/support/helpers/wait_helper.rb:31:in 'Helpers::WaitHelper#wait_time_lapsed?'
      # ./spec/support/helpers/wait_helper.rb:10:in 'Helpers::WaitHelper#wait_for'
      # ./spec/support/pages/home.rb:331:in 'Pages::Home#wait_until_confirm_delete_button_visible'
      # ./spec/support/shared_examples/lists.rb:442:in 'block (5 levels) in <top (required)>'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:124:in 'block in RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:110:in 'RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec_ext/rspec_ext.rb:12:in 'RSpec::Core::Example::Procsy#run_with_retry'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:37:in 'block (2 levels) in RSpec::Retry.setup'

   8) A list behaves like a list multiSelect merge merges all selected lists regardless of ownership or permissions but only those of the same type
      Failure/Error: throw "full wait time lapsed" if counter  original_wait_time

      UncaughtThrowError:
        uncaught throw "full wait time lapsed"
      Shared Example Group: "a list" called from ./spec/features/lists/lists_spec.rb:6
      # ./spec/support/helpers/wait_helper.rb:31:in 'Kernel#throw'
      # ./spec/support/helpers/wait_helper.rb:31:in 'Helpers::WaitHelper#wait_time_lapsed?'
      # ./spec/support/helpers/wait_helper.rb:10:in 'Helpers::WaitHelper#wait_for'
      # ./spec/support/pages/list.rb:158:in 'Pages::List#find_list_item'
      # ./spec/support/shared_examples/lists.rb:516:in 'block (5 levels) in <top (required)>'
      # ./spec/support/shared_examples/lists.rb:515:in 'Array#each'
      # ./spec/support/shared_examples/lists.rb:515:in 'block (4 levels) in <top (required)>'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:124:in 'block in RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:110:in 'RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec_ext/rspec_ext.rb:12:in 'RSpec::Core::Example::Procsy#run_with_retry'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:37:in 'block (2 levels) in RSpec::Retry.setup'

   9) A list behaves like a list multiSelect merge successfully merges lists of same type with proper name
      Failure/Error: throw "full wait time lapsed" if counter  original_wait_time

      UncaughtThrowError:
        uncaught throw "full wait time lapsed"
      Shared Example Group: "a list" called from ./spec/features/lists/lists_spec.rb:6
      # ./spec/support/helpers/wait_helper.rb:31:in 'Kernel#throw'
      # ./spec/support/helpers/wait_helper.rb:31:in 'Helpers::WaitHelper#wait_time_lapsed?'
      # ./spec/support/helpers/wait_helper.rb:10:in 'Helpers::WaitHelper#wait_for'
      # ./spec/support/pages/list.rb:158:in 'Pages::List#find_list_item'
      # ./spec/support/shared_examples/lists.rb:646:in 'block (5 levels) in <top (required)>'
      # ./spec/support/shared_examples/lists.rb:645:in 'Array#each'
      # ./spec/support/shared_examples/lists.rb:645:in 'block (4 levels) in <top (required)>'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:124:in 'block in RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:110:in 'RSpec::Retry#run'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec_ext/rspec_ext.rb:12:in 'RSpec::Core::Example::Procsy#run_with_retry'
      # /Users/christopherbrenner/.rvm/gems/ruby-3.4.8/gems/rspec-retry-0.6.2/lib/rspec/retry.rb:37:in 'block (2 levels) in RSpec::Retry.setup'

 Top 9 slowest examples (71.31 seconds, 99.6% of total time):
   A list behaves like a list that is incomplete is deleted
     10.61 seconds ./spec/support/shared_examples/lists.rb:141
   A list behaves like a list multiSelect merge merges all selected lists regardless of ownership or permissions but only those of the same type
     9.43 seconds ./spec/support/shared_examples/lists.rb:499
   A list behaves like a list multiSelect merge successfully merges lists of same type with proper name
     9.19 seconds ./spec/support/shared_examples/lists.rb:629
   A list behaves like a list that is complete that is shared with write access is deleted
     7.05 seconds ./spec/support/shared_examples/lists.rb:395
   A list behaves like a list that is incomplete that is shared that is pending rejects
     7.04 seconds ./spec/support/shared_examples/lists.rb:190
   A list behaves like a list that is complete that is shared with read access is deleted
     7.03 seconds ./spec/support/shared_examples/lists.rb:440
   A list behaves like a list that is incomplete that is shared that is accepted with write access is deleted
     7.02 seconds ./spec/support/shared_examples/lists.rb:230
   A list behaves like a list that is incomplete that is shared that is accepted with read access is deleted
     7.01 seconds ./spec/support/shared_examples/lists.rb:285
   A list behaves like a list that is complete is deleted
     6.92 seconds ./spec/support/shared_examples/lists.rb:362

 Finished in 1 minute 11.61 seconds (files took 0.39472 seconds to load)
 9 examples, 9 failures

 Failed examples:

 rspec ./spec/features/lists/lists_spec.rb[1:1:2:6] # A list behaves like a list that is incomplete is deleted
 rspec ./spec/features/lists/lists_spec.rb[1:1:2:7:1:3] # A list behaves like a list that is incomplete that is shared that is pending rejects
 rspec ./spec/features/lists/lists_spec.rb[1:1:2:7:2:1:2] # A list behaves like a list that is incomplete that is shared that is accepted with write access is deleted
 rspec ./spec/features/lists/lists_spec.rb[1:1:2:7:2:2:2] # A list behaves like a list that is incomplete that is shared that is accepted with read access is deleted
 rspec ./spec/features/lists/lists_spec.rb[1:1:3:3] # A list behaves like a list that is complete is deleted
 rspec ./spec/features/lists/lists_spec.rb[1:1:3:4:1:2] # A list behaves like a list that is complete that is shared with write access is deleted
 rspec ./spec/features/lists/lists_spec.rb[1:1:3:4:2:2] # A list behaves like a list that is complete that is shared with read access is deleted
 rspec ./spec/features/lists/lists_spec.rb[1:1:4:2:1] # A list behaves like a list multiSelect merge merges all selected lists regardless of ownership or permissions but only those of the same type
 rspec ./spec/features/lists/lists_spec.rb[1:1:4:2:7] # A list behaves like a list multiSelect merge successfully merges lists of same type with proper name
```

## Interview turn 1

Scope and context discovered from this worktree (read-only):

- This repo is `groceries_features` — black-box Capybara feature specs that drive the running app. The client UI code lives in a **sibling repo** at `/Users/christopherbrenner/Work/groceries/groceries-client` (and the API/server at `/Users/christopherbrenner/Work/groceries/groceries-service`). Any client-side fix must be made in `groceries-client`, not here. This spec repo can only adjust selectors/waits and add test coverage.
- All 9 failures terminate the same way: `Helpers::WaitHelper#wait_for` throws `"full wait time lapsed"`. That helper polls a block until truthy, so every failure is a UI state that never arrives within the wait budget — not an assertion mismatch. Treat these as functional regressions until proven otherwise.
- The failures cluster into two distinct symptoms, which probably correspond to two distinct client bugs:
  - **Cluster A — inline list-row confirm never appears (7 failures: #1, #3, #4, #5, #6, #7 hit `wait_until_confirm_delete_button_visible`; #2 hits `wait_until_confirm_reject_button_visible`).** The spec calls `home_page.delete(name)` or `home_page.reject(name)`, which clicks the trash/reject icon on a list row, then waits for a `data-test-id="confirm-delete"` or `confirm-reject` element to render. The client appears to no longer render that inline confirm element after the trigger click. Suspect a regression in the home-page list-row component's "confirm-before-action" state (a missing `data-test-id`, a renamed/relocated confirmation control, or a render-only-on-hover behavior). Covers both incomplete and completed lists and both owned and shared-write/read variants, so it is unlikely to be permission-gated — most plausibly a single shared row component.
  - **Cluster B — merge result list is empty / unreadable (2 failures: #8, #9 in `multiSelect merge`).** Both fail at `Pages::List#find_list_item` while iterating expected item names on the post-merge list. The merge action either (a) did not produce the merged list with items, (b) produced it but it failed to load/route correctly, or (c) renders items under different test classes/ids than before. The fact that the merge-eligibility/warning tests in the same describe block presumably still pass narrows this to the *result* of a successful merge.
- Recent suspect commits on `master` (in this repo's git log):
  - `ccbeda8 Full send on new data model (#247)` — large data-model migration; if a parallel commit landed in `groceries-client` it is the most likely source of both clusters.
  - `e9c4c06 Add templates management UI (#252)` and `fe6150f Updating tests based on updates to UX and performance (#239)` — UX/perf updates may have moved or renamed the confirm controls.
  Whoever drafts the plan should `git log` the **`groceries-client` repo** around those dates for matching changes to the list-row component and the merge result/list-show page.
- The user explicitly said "it is unlikely to be just test issues at this point." Plan should therefore default to:
  1. Reproduce locally against current `groceries-client` + `groceries-service` HEAD.
  2. Inspect the rendered DOM at the failure point (e.g., `save_screenshot` / Capybara HTML snapshot) for each cluster to see what the page actually contains where the test-id is expected.
  3. Fix the client (in `groceries-client`) — most likely restore/rename the `confirm-delete` / `confirm-reject` test ids and fix merge result rendering — rather than weakening the specs.
  4. Only after the client fix, consider widening the wait budget or simplifying the brittle `sleep 1` interludes already present in `shared_examples/lists.rb` (lines 149, 197) which suggest pre-existing flakiness around the confirm step.
- Out-of-scope guardrails to encode in the plan: do not "fix" by deleting failing specs, do not bump `wait_for` timeouts as a workaround, do not change spec selectors without confirming the client really renamed them (and update the client back if the rename was accidental).
- Plan-mode constraint per spec-guidance: the resulting spec PR must contain only spec/plan files in this repo. Any client patches need a separate PR against `groceries-client`. The plan should list both deliverables.

Open questions the plan should surface (not blocking — drafter can infer reasonable defaults):

- Is there a known intended rename of `confirm-delete` / `confirm-reject` test ids in `groceries-client`? If so the spec changes are mechanical; if not it is a client bug.
- For the merge cluster, is the assertion against the *source* list pages or the *merged* list page (read `shared_examples/lists.rb:499`–`670` to disambiguate before drafting subspecs).

## Interview turn 2

Additional findings from cross-repo inspection of the sibling `groceries-client` checkout. These narrow the hypothesis significantly and should shape the plan.

### Test ids are NOT renamed — the dialog just isn't opening

- The spec helpers wait for `data-test-id="confirm-delete"` / `confirm-reject` (`spec/support/pages/home.rb:264-268`).
- In `groceries-client` these ids are still generated by `src/components/domain/ConfirmDialog.tsx` (line 40: `data-test-id={\`confirm-${title}\`}`), and `src/routes/lists/containers/ListsContainer.tsx:564,583` instantiates two dialogs with `title="delete"` and `title="reject"`.
- A grep for `confirm-delete` / `confirm-reject` across non-spec client source yields *zero* hits — i.e. the only path that creates the element is the `ConfirmDialog` mounted under `showDeleteConfirm` / `showRejectConfirm` state. The element is therefore conditionally rendered, not statically present.
- Conclusion: the feature spec is waiting on an element that only appears when the container's `showDeleteConfirm`/`showRejectConfirm` flips true. The selector contract is intact; what is broken is the path that flips that state when the trash/reject icon is clicked. Plan should NOT advise renaming spec selectors.

### The trash/reject click path likely regressed in the lists-page redesign

The list rows are now rendered by `src/components/domain/ListCard.tsx` (a card replacing the old react-bootstrap row), which:
- Sets the row's `data-test-class={testClass}` (`incomplete-list` / `complete-list` / `pending-list`) on the outer `Card` (line 246) — so `home_page.find_incomplete_list(name)` should still match.
- Renders the trash as an `IconButton` (line 224 for the incomplete variant) with `onClick={(e) => { e.stopPropagation(); onDelete(listId); }}`.
- ALSO wraps the whole card in `onClick={handleClick}` / `role="button"` / `tabIndex=0`. `handleClick` does a `closest('button')` lookup and dispatches by `dataset.testId` (lines 96–119) — there is duplicate dispatch logic on top of the per-button handler.

This duplication, combined with the `stopPropagation()` on the inner button, is a likely culprit. On Capybara click the inner handler runs `onDelete(listId)` but the outer `handleClick` may also fire (or not, depending on event ordering) and route to a different branch, or `onDelete` may now be a no-op shim because the container handed the deletion off to a `BottomSheet`/`MergeModal` flow.

Highly suspect recent client commits to inspect first (in `/Users/christopherbrenner/Work/groceries/groceries-client`, master):
- `e05ac67` UI Redesign Phase 4 (#702) — most recent, broadest blast radius.
- `0a519c0` Phase 3B carryover: remove react-bootstrap from list routes (#687).
- `e881657` Phase 3A: Redesign lists page with unified view, filter chips, and BottomInputBar (#674) — the unified view + filter chips fundamentally change which lists are mounted at a given time.
- `7b32a26` Fix pending and merge workflows — explicitly touches both clusters; check whether this introduced the merge regression.

### Most likely root cause per cluster

- **Cluster A (delete/reject confirm):** the lists-page redesign moved single-row deletion behind the same multi-select `ConfirmDialog` flow that previously was only exercised by bulk delete. The dialog opens only when state flips, and either (a) `onDelete(listId)` in `ListsContainer` no longer calls `setShowDeleteConfirm(true)` for the single-row path, or (b) the trash button's `stopPropagation` plus the Card's `handleClick` dispatcher cause the click to be swallowed/routed to a navigation. Either way, the fix is in `groceries-client`, not the spec. Reproduce by setting `showDeleteConfirm` true via devtools and verifying the dialog appears — if it does, the selector is fine and the bug is purely in the open-trigger.

- **Cluster B (merge result list):** all five non-failing merge tests in the same describe block stop *before* navigating to the merged list page (they only verify modal behavior). Both failing tests are the only ones that actually traverse into the merged list and iterate items. The earliest assertion (`home_page.incomplete_list_names.include?("new merged list")`) presumably passes — so the merge endpoint creates the list. The failure is at `Pages::List#find_list_item` (i.e. `find_by_test_class("non-completed-item", text: <item_name>)`). Two leading hypotheses:
  1. The merge endpoint no longer copies items into the new list under the same `pretty_title` — possibly affected by the "Full send on new data model" change in this repo's history (#247) if a matching change landed on the client/service. `pretty_title` (from the test models) joins quantity + name; if categories or quantity formatting changed, the rendered text will not match.
  2. The merged list page now renders items inside a different test-class container (e.g. unified view groups them by category and the items live under `category-header` siblings rather than directly addressable). Run one merge manually in a browser and inspect the DOM at the failure point.

### Recommended plan shape

Encode these subspecs (each independently testable):

1. **Reproduce + DOM snapshot.** Add a one-shot debug spec or use `save_page` inside the existing failing examples to capture HTML at the wait-for failure. This must run against current `groceries-client` HEAD. Output goes in the plan PR as evidence only; not committed long-term.
2. **Cluster A client fix (separate PR in `groceries-client`).** Restore the single-row delete/reject flow so it opens the `ConfirmDialog`. Likely change is in `ListsContainer.tsx` `onDelete`/`onReject` callbacks and/or `ListCard.tsx` `handleClick` dispatcher. Add a `groceries-client` unit test that asserts clicking `incomplete-list-trash` results in `data-test-id="confirm-delete"` being in the DOM.
3. **Cluster B client/service investigation (separate PR in `groceries-client` or `groceries-service`).** Verify merged list contains the expected items at the API layer, then verify rendering. Fix at the layer that diverged.
4. **Feature-spec hardening (this repo).** Once the client fix lands, replace the two `sleep 1` workarounds at `spec/support/shared_examples/lists.rb:149,197` with a `wait_for` that observes the dialog has finished mounting (e.g. `wait_for { home_page.confirm_delete_button.click rescue false }` is a smell — prefer waiting on a stable post-mount property). Do not extend `wait_for` timeouts.
5. **Selector audit.** After the fix, grep the client for every `data-test-id` / `data-test-class` referenced by `spec/support/pages/home.rb` and `pages/list.rb` and add a CI-time consistency check or at least a documented contract list under `spec/support/README.md`-style note so future redesigns flag spec-touching renames. (Optional; include only if scope allows.)

### Guardrails reaffirmed for the drafter

- Do not delete or skip any of the 9 failing examples.
- Do not extend `Helpers::WaitHelper` timeouts to mask the bug.
- Do not change spec test-id selectors unless a client-side rename has actually merged and you have updated the client tests in lockstep.
- The plan PR for this repo (`groceries_features`) must contain spec/plan files only. Client fixes live in `groceries-client`; service fixes (if Cluster B requires one) live in `groceries-service`. Enumerate all three deliverables in the plan even if only one repo's PR is opened from the plan branch.

## Interview skip

Turns 1 and 2 already document both failure clusters, the most-likely root causes in `groceries-client`, the recommended subspec shape, and the guardrails. No further refinement is warranted before drafting.
