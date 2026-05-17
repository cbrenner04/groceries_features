# Fix list delete and merge failures

repo: cbrenner04/groceries_features

The `groceries_features` Capybara suite has 9 failing examples that all terminate in `Helpers::WaitHelper#wait_for` throwing `"full wait time lapsed"`. The failures cluster into two functional regressions in the sibling `groceries-client` repo:

- **Cluster A (7 failures):** clicking the trash/reject icon on a list row no longer causes the `ConfirmDialog` (`data-test-id="confirm-delete"` / `confirm-reject`) to mount. Suspected regression in `ListsContainer.tsx` / `ListCard.tsx` after the lists-page redesign (client commits `e05ac67`, `0a519c0`, `e881657`, `7b32a26`).
- **Cluster B (2 failures):** after a successful list merge, `Pages::List#find_list_item` cannot locate items on the merged list page. Either the merged list lacks the expected items, or items render under a different test-class container.

Plan PR for this repo contains spec/plan files only. Client (and possibly service) fixes are tracked here but live in separate PRs against `groceries-client` / `groceries-service`.

## Ordering

- **00** is a diagnostic prerequisite, but it should not assume the agent can successfully run the feature suite. Start from the failures already captured in `intent.md`; if another run is needed, the agent prepares targeted diagnostics and a `## Blocker`, the user runs the requested tests, and the evidence is recorded in `evidence.md`.
- **01** and **02** are independent of each other and can proceed in parallel once 00 is complete. Each lands as its own PR in `groceries-client` (and possibly `groceries-service` for 02).
- **03** is the only subspec that touches this (`groceries_features`) repo's code beyond plan files. Do not start until 01 and 02 are merged — running it earlier would either weaken specs against a real regression or mask it with longer waits.
- **04** is optional polish, independent of the others. It can ship before or after 01–03 and does not block the 9 failing examples.

## Subspecs

- [x] [00 - Prepare evidence capture and wait for user-run test results](./00-reproduce-and-capture-dom.md)
- [x] [Evidence log](./evidence.md)
- [ ] [01 - Fix Cluster A: restore single-row delete/reject confirm dialog (groceries-client)](./01-fix-cluster-a-confirm-dialog.md)
- [ ] [02 - Fix Cluster B: merged list items render/return correctly (groceries-client / groceries-service)](./02-fix-cluster-b-merge-result.md)
- [ ] [03 - Harden feature specs after client fixes land (this repo)](./03-harden-feature-specs.md)
- [ ] [04 - Document test-id contract between specs and client (optional)](./04-test-id-contract.md)
