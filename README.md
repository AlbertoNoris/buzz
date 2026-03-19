# Advanced Pharmacokinetic Intoxication Model (APIM)

## About This Repository
This repository contains the core mathematical engine and differential equations for real-time, anthropometry-based intoxication tracking. 

Most commercial Blood Alcohol Concentration (BAC) calculators rely on the outdated Widmark formula. This project provides a highly accurate, open-source alternative by utilizing a **Two-Compartment System with First-Order Absorption and Michaelis-Menten Elimination Kinetics**. 

By anchoring the volume of distribution to individualized Total Body Water (TBW), this engine ensures high-fidelity BAC tracking across varied anatomical profiles and environmental states (e.g., fed vs. fasted).

## Repository Structure
* **`README.md`**: You are here. High-level overview and contribution guidelines.
* **`FORMULATION.md`**: The definitive source of truth for the mathematics. This contains all the ordinary differential equations (ODEs), pharmacometric constants, and physiological logic that drive the engine.

## Contributing and Scientific Governance
We welcome peer review, optimization, and improvements to the core math from the scientific and developer communities. 

Because this repository governs the physiological truth of the application, we enforce strict rules for making changes to `FORMULATION.md`:
1. **No direct commits:** All changes must be submitted via a Pull Request (PR) from a forked repository.
2. **Scientific Backing:** Any proposed modifications to the ODE structure, the anthropometric equations, or the Constants Matrix **must** be accompanied by a citation to a peer-reviewed pharmacometric or medical study. Arbitrary tweaking of constants to "feel more accurate" will be rejected.
3. **Discussion First:** To propose a structural change, please open an Issue first to discuss the physiological rationale before submitting the code.
