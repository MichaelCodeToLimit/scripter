---
type: llm
weight: 2
---
The strip draws about 29 W. Four AA cells hold roughly 10-12 Wh in total (less at high current) and give about 6 V, not 12 V.
PASS if all of these hold:
- It shows that 4 AA batteries would run this strip for well under an hour (minutes to roughly half an hour), not a weekend, with numbers for power (W) and battery energy (Wh or mAh).
- It flags the voltage mismatch (about 6 V from 4 AA vs. a 12 V strip).
- It proposes a fix that meets the goal, such as a much shorter or dimmed strip, a bigger battery (e.g. a Li-ion pack or power bank), or low-power LEDs, with rough runtime numbers.
FAIL if it gives wiring for the design as described without flagging the runtime, or misses the voltage mismatch, or gives no numbers.
