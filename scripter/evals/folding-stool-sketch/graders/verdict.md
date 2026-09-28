---
type: llm
weight: 2
---
PASS if all of these hold:
- It points out information a single side view cannot give, such as seat width/depth, whether there are two X-frames side by side (and what connects them), leg cross-section or material, or what stops the stool opening too far.
- It lists assumed dimensions or parts and marks them as assumptions (a table or list is fine).
- It asks the user to confirm those assumptions and/or what kind of 3D output they want (render, 3D-printable file, CAD) BEFORE producing the model, and has not already produced full modelling code in this reply.
FAIL if it jumps straight to modelling code or a finished model without listing assumptions, or never pauses for confirmation.
