---
type: llm
weight: 2
---
PASS if all of these hold:
- It says what is and is not possible: sync can only happen when the two devices can reach each other directly (same Wi-Fi/LAN, Bluetooth, cable or file transfer), not at any time from anywhere.
- It addresses conflicting edits made while the devices were apart (e.g. merge rules, last-write-wins, CRDTs).
- It recommends one specific approach and names at least one trade-off or platform limit (e.g. phone background restrictions, pairing, battery).
FAIL if it implies seamless always-on sync with no connection, ignores conflicting edits, or lists options without recommending one.
