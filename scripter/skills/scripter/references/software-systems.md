# Apps, websites and software systems

Checklists for the working model (step 2) and the feasibility check (step 4) when the "thing" is software, or a device that talks to other devices.

## The working model

- **Users and their jobs:** who uses it, for what, how often, and on which devices.
- **Data:** what it is, where it lives, who owns it, how big it gets and how fast it grows. Which copy counts as the true one?
- **Flows and state:** what happens from the user's action to the stored result. What states can each item be in?
- **Sync and offline:** can two copies change at the same time? How do they merge (last-write-wins, merge rules, CRDTs)? What happens while a device is offline, and when it comes back?
- **Connectivity:** how the devices actually reach each other (internet, local Wi-Fi, Bluetooth, cable, a file). Is that path available when it's needed?
- **Integrations:** other services and APIs, with their limits, costs and rules.
- **Accounts and security:** login, permissions, what an attacker would target, and where secrets are kept.
- **Privacy:** personal data, where it's stored, and the laws that apply (GDPR and others).
- **Failure cases:** network loss, partial failure, retries and duplicates, a crash mid-write, a full disk.
- **Scale and cost:** users, requests per second, storage, with rough numbers. Hosting cost per month.
- **Platform limits:**
  - iOS and Android restrict background work, Bluetooth and local-network access, and require permissions.
  - Browsers sandbox files, storage and devices.
  - App stores have review rules.

## Feasibility

- **Possible:** does the physics or logic allow it? For example, two devices can't sync without some path between them, and "real time" across the world has latency.
- **Buildable:** by whom, with which skills, in what time?
- **Operable:** who keeps it running, updates it and fixes it at 3 a.m.?
- **Legal:** privacy, licences, store rules.

## Best way

- **Build vs. buy vs. use an existing service or open-source tool.** Name one existing option if it exists.
- The simplest architecture that meets the need. Every server, queue and sync layer is something to run and debug.
- Recommend one approach, and say what would make you pick a different one.

## UX sanity check

- Walk the main tasks and count the steps.
- Error states: what the user sees when something fails, and how they recover.
- Empty states and first run.
- Accessibility: contrast, text size, keyboard and screen reader use.
