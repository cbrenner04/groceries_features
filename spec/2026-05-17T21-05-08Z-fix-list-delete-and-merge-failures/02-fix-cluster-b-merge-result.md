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

## Code Investigation Summary

**Service layer (groceries-service):**
- Merge endpoint creates new list correctly (MergeListsController#create)
- `ListsService.create_new_items_from_multiple_lists` iterates over source lists and calls `create_new_list_items` for each
- `create_new_list_items` filters items: `reject { |item| item.refreshed || item.archived_at.present? }`
- For each non-filtered item, creates a new item in the merged list with category and field values
- Service code looks correct for copying items

**Client layer (groceries-client):**
- After merge, `handleMergeConfirm` adds merged list to `incompleteLists` state
- List detail page (`ListContainer.tsx`) fetches list via `fetchList` API  
- `fetchList` returns `not_completed_items` and `completed_items` from service's `show_response`
- Items are rendered via `NotCompletedItemsSection` → `ListItemRow` with `data-test-class="non-completed-item"`
- Code flow looks correct

**Most likely root cause:**
Items may not exist in the merged list because they are being created with `refreshed: true` or marked as `archived_at` during the merge, causing them to be filtered out by the `reject { |item| item.refreshed || item.archived_at.present? }` condition in create_new_list_items.

**Alternative hypothesis:**
Item fields are not being copied correctly, causing items to appear empty or with incorrect field values.

## Tasks

- [x] Review `evidence.md` from subspec 00: Evidence is partially sufficient; code inspection done
- [x] Identify the diverged layer: Most likely items not being created in merge OR items being filtered during retrieval
- [ ] Verify merge behavior via API inspection or test run

## Blocker

**Investigation Required:** Code review suggests merged list items may not be reaching the client due to:
1. Items being created with `refreshed: true` (unlikely based on code)
2. Items being created with `archived_at` set (unlikely based on code)
3. Item field values not being copied correctly (possible - need to inspect merge test database state)
4. Items filtered from API response for another reason

**To resolve this blocker:**
1. Add logging or debugger breakpoints to verify:
   - Items are created in the merged list table after merge API call
   - Merged list's `show_response` returns the items with correct field values
2. Or run a targeted test on the merge endpoint to capture the exact API response and verify items are present

Currently blocked on database/runtime inspection. Recommend user runs diagnostic merge test or agent investigates via console logs.

## Acceptance criteria

- [ ] Agent review in `evidence.md` says Cluster B evidence is sufficient and identifies the diverged layer.
- [ ] User-recorded verification in `evidence.md` shows both Cluster B failures (`lists_spec.rb[1:1:4:2:1]`, `[1:1:4:2:7]`) pass against the patched stack without retries, and the agent review confirms the output is sufficient.
- [ ] No test selector or assertion in `spec/support/shared_examples/lists.rb` or `spec/support/pages/list.rb` was changed to make these pass.
- [ ] A regression test was added in the diverged repo asserting the post-merge list contains the expected items (or the merge endpoint returns them, depending on layer).
- [ ] PR description names the diverged layer, links subspec 00's evidence, and lists the suspect commits.
