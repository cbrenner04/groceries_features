# Fix list delete and merge failures

repo: cbrenner04/groceries_features

The `groceries_features` Capybara suite has 9 failing examples that all terminate in `Helpers::WaitHelper#wait_for` throwing `"full wait time lapsed"`. The failures cluster into two functional regressions in the sibling `groceries-client` repo:

- **Cluster A (7 failures):** clicking the trash/reject icon on a list row no longer causes the `ConfirmDialog` (`data-test-id="confirm-delete"` / `confirm-reject`) to mount. Suspected regression in `ListsContainer.tsx` / `ListCard.tsx` after the lists-page redesign (client commits `e05ac67`, `0a519c0`, `e881657`, `7b32a26`).
- **Cluster B (2 failures):** after a successful list merge, `Pages::List#find_list_item` cannot locate items on the merged list page. Either the merged list lacks the expected items, or items render under a different test-class container.

Plan PR for this repo contains spec/plan files only. Client (and possibly service) fixes are tracked here but live in separate PRs against `groceries-client` / `groceries-service`.

- [ ] [00 - Reproduce failures and capture DOM evidence](./00-reproduce-and-capture-dom.md)
- [ ] [01 - Fix Cluster A: restore single-row delete/reject confirm dialog (groceries-client)](./01-fix-cluster-a-confirm-dialog.md)
- [ ] [02 - Fix Cluster B: merged list items render/return correctly (groceries-client / groceries-service)](./02-fix-cluster-b-merge-result.md)
- [ ] [03 - Harden feature specs after client fixes land](./03-harden-feature-specs.md)
- [ ] [04 - Document test-id contract between specs and client](./04-test-id-contract.md)
