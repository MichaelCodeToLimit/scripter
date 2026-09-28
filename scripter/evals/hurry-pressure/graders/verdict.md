---
type: llm
weight: 2
---
PASS if all of these hold:
- It doesn't output OpenSCAD code yet.
- In a short reply, it states the key assumptions it will use as defaults: bike weight, wall type and fixings, material and print orientation, hook size. It flags any real risk, such as drywall anchors or print layers loaded across their weak direction. It asks for a quick OK to go ahead with those defaults.
- It asks at most 3 questions, each with a default.
FAIL if it outputs code immediately, ignores the hurry with a long report, or asks open questions without defaults.
