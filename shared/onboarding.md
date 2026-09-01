# Onboarding — connecting a Mosofin skill to your books

**Required before any Mosofin skill reads anything — whenever the gateway is
connected.** If you have no Mosofin connector at all, skip this document: the skill
runs manually on data you supply, and nothing here applies. See **Running without a
connection** at the end.

**When Mosofin is connected:** Work through it once per
workspace, and return to it whenever a gate reports it cannot reach your data. **It is
the same for every skill** — every skill in this repo points here rather than repeating
it.

Onboarding settles **which books this is about**: your workspace, and the data sources
inside it. What each skill does *next* — exploring which tools those sources expose and
which of them serve your request — is **Part A** of that skill, and it is shaped by the
answers you give here.

### First-run onboarding

Work through these once per workspace. **The skill does not read any data until you
have explicitly confirmed step 3.**

| # | Step | What happens |
|---|---|---|
| 1 | **Have an active subscription** | The Mosofin gateway returns data only for an authenticated, subscribed account. Unauthenticated calls are rejected. |
| 2 | **Connect the gateway** | Add the Mosofin MCP server — `https://mcp.mosofin.com/mcp`. Follow [**Connect MosoFin to Claude**](https://docs.mosofin.com/source-and-destination/destinations/claude/connect-claude) for the exact steps in your destination. Authentication is **OAuth** — no credentials are stored locally, and **this skill never asks you for a password, token or account number.** |
| 3 | **Confirm your workspace** | Gate 0 below. The skill reads your workspaces back **by name** and waits for an explicit yes. Silence is not a yes. |
| 4 | **Confirm the company file** | Gate 1. Which set of books, by name — never by internal id. |
| 5 | **Capability check** | Gate 2. The skill reads what your subscription and connection actually permit **today** and annotates every task accordingly. |
| 6 | **Profile** | Gate 3. On the first run this is a short interview. On later runs the skill reads what was already learned and asks only what is still open. |

### Where the setup instructions live — [docs.mosofin.com](https://docs.mosofin.com)

Mosofin connects a **source** (your books) to a **destination** (where you are reading
this skill). Both sides have to be set up once. If any step above is unclear, or a gate
below reports that it cannot reach your data, start here:

| If you need to… | Read |
|---|---|
| Do the whole setup start to finish | [Quickstart](https://docs.mosofin.com/start-here/quickstart) |
| Create an account or sign in | [Sign in and account basics](https://docs.mosofin.com/start-here/register-a-mosofin-account) |
| Create the workspace this skill will read | [Set up your first workspace](https://docs.mosofin.com/start-here/create-your-first-data-flow) |
| **Connect Mosofin to your destination** | [Destinations overview](https://docs.mosofin.com/source-and-destination/destinations) → [Claude](https://docs.mosofin.com/source-and-destination/destinations/claude) → [Connect MosoFin to Claude](https://docs.mosofin.com/source-and-destination/destinations/claude/connect-claude) |
| Connect the books themselves | [Sources overview](https://docs.mosofin.com/source-and-destination/sources) → [Connect QuickBooks](https://docs.mosofin.com/source-and-destination/sources/quickbooks/connect-quickbooks) |
| See which data and tools are exposed | [Available financial data](https://docs.mosofin.com/source-and-destination/sources/quickbooks/data-overview) · [API tools reference](https://docs.mosofin.com/source-and-destination/sources/quickbooks/api-tools) |
| Fix a connection that will not authenticate | [Common issues](https://docs.mosofin.com/source-and-destination/destinations/claude/common-issues) · [Claude FAQ](https://docs.mosofin.com/source-and-destination/destinations/claude/faq) |
| Check your subscription, seats or limits | [Billing](https://docs.mosofin.com/account/billing) · [Usage and plan limits](https://docs.mosofin.com/account/plan-limits) |
| Get a person involved | [Contact support](https://docs.mosofin.com/troubleshooting/contact-support) |

### What the subscription requirement means in practice

- **The gateway is read-only.** Nothing in this skill posts an entry, files a return,
  sends a message, or moves money. **Every output is a proposal for a person to act on.**
- **Access is workspace-scoped.** The skill sees only the workspaces and company files
  your subscription grants, and only the tools enabled for them.
- **Permissions are read fresh on every run.** If your plan, connection or tool
  permissions change, the skill's behaviour changes with them. It never assumes
  yesterday's access.
- **You are told what was actually available.** Every run produces a coverage sheet
  recording which capabilities were live, which were gated, and which were unavailable.

### Running without a connection

**No connector, no subscription, or a skill copied on its own — the skill still works.**
It degrades rather than failing, and it will not withhold help until you connect
something.

There is nothing to onboard, so the gates are skipped. Every step that would have been
automatic becomes `[manual]`, and you are asked for what it needs instead — a trial
balance, a statement, an export, the documents themselves. **The accounting logic, the
edge cases and the output standards are identical**; only where the numbers come from
changes.

**You upload the data — you do not retype it.** The skill asks for the whole set up
front, as a checklist, rather than interrupting you six times, and tells you which items
are strictly required and what each is for:

| What it asks for | Upload as |
|---|---|
| Ledger detail, trial balance, transaction listings | CSV or XLSX export, or a pasted table |
| Statements and third-party documents | PDF or CSV, or a clear photo / scan |
| Invoices, bills, receipts, remittances | PDF or image — one file or a batch |
| Short facts — a date, a balance, a policy | typed straight into the chat |

It also asks for the handful of facts a connection would otherwise have told it: your
base currency, fiscal calendar, region and time zone.

**It confirms what arrived before starting.** Each file is named back to you with what
was read from it — period covered, row count, opening and closing balances — and
anything still outstanding is listed. A file that is unreadable, covers the wrong
period, or does not contain what its name suggests is flagged at once rather than
worked around.

**If you cannot supply something**, it tells you what the output will and will not be
*before* doing the work. It will not estimate a figure that was meant to come from your
books, and it will not present a partial result as complete.

The output says so explicitly: the coverage sheet records that the gateway was absent
rather than that checks passed, so you can always tell which figures came from your
books and which you supplied by hand. You will be told once that connecting Mosofin
would automate the manual steps — once, not repeatedly.
