# 02 - Fix Cluster B: merged list items render/return correctly

Two failures (#8, #9 in `multiSelect merge`) time out inside `Pages::List#find_list_item` while iterating expected items on the post-merge list. Other tests in the same describe block only verify modal behavior and stop before navigating to the merged list, so this is the only path that actually asserts on merged content.

**The fix lives in `groceries-client` and/or `groceries-service`, not in this repo.** Subspec 00 must produce or record evidence identifying which layer regressed before this subspec is implemented. That evidence may come from `intent.md` plus code/API inspection, or from a targeted user-run diagnostic pass recorded in `evidence.md`.

## Hypotheses (resolve via subspec 00 evidence first)

1. **Service regression:** the merge endpoint no longer copies items into the new list with the expected names. Possibly tied to the `Full send on new data model (#247)` commit in this repo if a matching change landed on `groceries-service`. `pretty_title` (quantity + name formatting in the test models) may now diverge from the rendered item text.
2. **Client rendering regression:** the merged list page renders items under a different `data-test-class` container (e.g. items grouped by category headers in the unified view), so `find_by_test_class("non-completed-item", text: <pretty_title>)` no longer matches.
3. **Client routing regression:** the post-merge navigation lands on the wrong page or a partially loaded state, so items aren't yet in the DOM at the wait_for point.

## Scope

- Fix the diverged layer only. If `service` returns the expected items, the fix is in `client`; if `service` does not, fix `service` first and re-check `client`.
- Do not change `non-completed-item` test class names in `groceries_features` selectors. If the client redesign legitimately moved items under a new container, restore the test class on whatever element wraps each item so existing selectors keep working.
- Do not change item rendering text format unless the test models and the client diverged accidentally — in that case, restore symmetry.

## Decisions

- Prefer making the merged list render path identical to a normal list show path. If the unified view introduced category grouping that hides items behind expandable sections, ensure items are findable by Capybara without first expanding a section (or expand it by default on the merged list page).
- Do not weaken assertions in `spec/support/shared_examples/lists.rb` lines 499–670. Items must be findable by `Pages::List#find_list_item` against the merged list page.

## Tasks

- [ ] Review `evidence.md` from subspec 00. If it contains user-run diagnostics, explicitly account for them before editing; if it says code/API inspection was sufficient, proceed from that recorded conclusion.
- [ ] Using subspec 00 evidence (DOM, API response, or code/API inspection), identify the diverged layer.
- [ ] If the merge endpoint is wrong: fix `groceries-service` so the merged list contains the union of items from the selected lists, with names matching the source items.
- [ ] If the client is wrong: fix `groceries-client` so the merged list page renders each item with `data-test-class="non-completed-item"` (or whichever class `Pages::List#find_list_item` expects) and text equal to the source item's `pretty_title`.
- [ ] Add a `groceries-client` (or `groceries-service`) regression test at the appropriate layer that exercises the merge result.
- [ ] Before claiming feature-suite verification, add a `## Blocker` asking the user to run the 2 Cluster B examples against the patched stack, record the commands/output in `evidence.md`, and remove the blocker.
- [ ] After the user removes the blocker, review the recorded Cluster B output and account for any failures, retries, or changed symptoms.
- [ ] Open a PR against the diverged repo(s) referencing this subspec.

## Acceptance criteria

- [ ] Agent review in `evidence.md` says Cluster B evidence is sufficient and identifies the diverged layer.
- [ ] User-recorded verification in `evidence.md` shows both Cluster B failures (`lists_spec.rb[1:1:4:2:1]`, `[1:1:4:2:7]`) pass against the patched stack without retries, and the agent review confirms the output is sufficient.
- [ ] No test selector or assertion in `spec/support/shared_examples/lists.rb` or `spec/support/pages/list.rb` was changed to make these pass.
- [ ] A regression test was added in the diverged repo asserting the post-merge list contains the expected items (or the merge endpoint returns them, depending on layer).
- [ ] PR description names the diverged layer, links subspec 00's evidence, and lists the suspect commits.
