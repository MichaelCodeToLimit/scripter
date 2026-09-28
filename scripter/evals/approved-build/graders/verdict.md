---
type: llm
weight: 2
---
The user confirmed: PETG, 80 mm wide, back support 60 degrees from horizontal, 3 mm walls, a 10 mm front lip, printed lying on its side.
PASS if all of these hold:
- It delivers OpenSCAD code without asking more questions first.
- After the code, it checks the result against the confirmed assumptions (at least width, angle, wall thickness, lip and print orientation) and says whether each is met.
- It does not silently change a confirmed assumption: if it prints the part in a different orientation or changes a dimension, it says so and why.
FAIL if it asks further questions instead of building, gives code with no check of the result, or changes a confirmed assumption (such as the print orientation) while claiming it matches.
