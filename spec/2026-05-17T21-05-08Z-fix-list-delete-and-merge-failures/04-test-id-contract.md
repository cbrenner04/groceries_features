# 04 - Document test-id contract between specs and client

This regression happened because the client redesign altered behavior around test ids that `groceries_features` depends on, and there is no contract or audit surface between the two repos. Add a documented contract list so future client redesigns flag spec-touching changes.

This subspec is **optional polish**, scoped to keep the plan PR small. It is independently shippable once subspecs 01–03 land but does not block them.

## Scope

- Add a short reference document to this repo (e.g. `spec/support/SELECTOR_CONTRACT.md` or similar) enumerating every `data-test-id` and `data-test-class` value that `spec/support/pages/home.rb` and `spec/support/pages/list.rb` rely on, with a one-line description of where each is produced in `groceries-client`.
- The list is informational — no programmatic enforcement is required as part of this subspec.
- Optionally, note this file from `groceries-client`'s contributing/redesign docs so future client work is reminded to update specs in lockstep.

## Decisions

- Do not introduce a build-time consistency check now; the maintenance cost outweighs the value at the current rate of redesigns. The doc alone is enough to surface drift during code review.
- Source-of-truth for naming stays in `groceries-client`. The doc records the contract from the consumer's (`groceries_features`) perspective.

## Tasks

- [ ] Grep `spec/support/pages/home.rb` and `spec/support/pages/list.rb` for `find_by_test_id`, `find_by_test_class`, `data-test-id`, `data-test-class`, and similar selectors.
- [ ] For each unique id/class, locate the producing component in `groceries-client` and record a one-line mapping.
- [ ] Save the result under `spec/support/` as a markdown file. Reference it from this repo's top-level README or contributing notes if any exists.

## Acceptance criteria

- [ ] A markdown document exists in this repo under `spec/support/` listing every `data-test-id` and `data-test-class` consumed by the page objects.
- [ ] Each entry names the `groceries-client` file (and ideally the component) that produces the attribute.
- [ ] The document is referenced from at least one discoverable location (top-level README, `spec/README.md` if present, or a comment at the top of `spec/support/pages/home.rb`).
- [ ] No production code in `groceries-client` or `groceries-service` was changed by this subspec.
