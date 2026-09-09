---
name: jira-create
description: Draft and create a Jira task or bug after the user confirms its content. Use for requests to register a Jira ticket; do not use merely to discuss or summarize work.
---

# Jira Ticket Creation

Use the available Jira or Atlassian connector tools only. Do not use separate scripts. Always obtain explicit confirmation of the final title and description before creating the issue.

## Project and issue type

Ask for the project key or name and issue type every time. If the project is unclear, use the Jira connector to list visible projects and let the user select one. Verify the requested issue type is valid for that project; if it is not, show the available types and ask again.

## Draft and confirm

Create a title and description draft from the conversation. Use [the bug template](templates/bug-template.md) for bugs and [the task template](templates/task-template.md) for tasks. Ask about uncertain or empty fields, show the completed draft, and wait for confirmation or requested revisions before continuing.

## Assign and create

Look up the current reporter's Jira account and set that account as assignee. If lookup fails, ask for an email address or name and retry. Create the issue with the confirmed project, issue type, title, description, and assignee only. Do not set labels, priority, due date, components, subtasks, or epic links unless the user separately requests them.

Report the created issue key and its browse URL.
