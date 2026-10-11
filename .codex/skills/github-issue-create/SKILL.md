---
name: github-issue-create
description: Draft and create a GitHub task or bug issue in the current repository after the user confirms its content. Use for requests to register a GitHub Issue; not for merely discussing or summarizing work.
---

# GitHub Issue Creation

Use `gh` for the current repository. Always obtain explicit confirmation of the final title and description before creating the issue.

## Draft and confirm

Create a title and description draft from the conversation. Use [the bug template](templates/bug-template.md) for bugs and [the task template](templates/task-template.md) for tasks. Ask about uncertain or empty fields, show the completed draft, and wait for confirmation or requested revisions before continuing.

Choose the default GitHub Project from the work context:

- GMS or WMS work: `wms-plan` — Project `33` in the `ktown4u` organization.
- FOMS or OMS work: `oms-plan` — Project `37` in the `ktown4u` organization.
- If neither applies or the context is ambiguous, ask the user which project to use before creating the issue.

## Schedule dates

When the user or conversation explicitly provides a start date or target date, write it to the selected Project item. Normalize dates to `YYYY-MM-DD`; never invent a date. If the work is described as scheduled but a required date is unclear, ask before confirmation. If only one date is known, set only that field.

| Project | Project ID | Start date field | Target date field |
| --- | --- | --- | --- |
| `wms-plan` (33) | `PVT_kwDOBI7MHM4Bl54F` | `PVTF_lADOBI7MHM4Bl54FzhkmVok` | `PVTF_lADOBI7MHM4Bl54FzhkmVoo` |
| `oms-plan` (37) | `PVT_kwDOBI7MHM4Bl54_` | `PVTF_lADOBI7MHM4Bl54_zhklCMY` | `PVTF_lADOBI7MHM4Bl54_zhklCOM` |

## Create

Write the confirmed body to a temporary file, create the issue, then add its URL to the selected project:

```bash
issue_url="$(gh issue create --title "<title>" --body-file <body-file> --assignee "@me")"
project_item_id="$(gh project item-add <33-or-37> --owner ktown4u --url "$issue_url" --format json --jq '.id')"
gh project item-edit --id "$project_item_id" --project-id <project-id> --field-id <start-date-field-id> --date <start-date>
gh project item-edit --id "$project_item_id" --project-id <project-id> --field-id <target-date-field-id> --date <target-date>
```

Run each `item-edit` command only when its date is known, substituting the IDs from the selected Project's row. Do not set labels, milestones, issue types, parent issues, or blocking relationships unless the user separately requests them. This requires an authenticated `gh` session, permission to create and self-assign issues in the current repository, and the `project` scope. If Project addition or date update fails after issue creation, do not create another issue; report the created issue URL and any partial Project updates or errors.

Report the created issue number and URL.
