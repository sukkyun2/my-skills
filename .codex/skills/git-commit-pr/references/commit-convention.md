# Commit Convention

## Header

```
<type>(<scope>): <subject>
```

- `type`: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`
- `scope`: optional lowercase kebab-case module or directory
- `subject`: imperative, no trailing period, and at most 72 characters for the full header
- Breaking changes append `!` after type or scope.

Keep the `type` and `scope` in English; write the subject and body in Korean. When needed, put a blank line after the header and explain what changed and why, with lines wrapped at about 72 columns. Optional footers include `BREAKING CHANGE: ...`, `Closes #123`, and `Refs #123`.
