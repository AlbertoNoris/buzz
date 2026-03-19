# Model Specification and Formulation

## 1. Abstract and Architectural Overview
This document outlines the mathematical and physiological source of truth for the digital intoxication tracking engine. It explicitly abandons the rudimentary, single-compartment Widmark formulation ($C_t = W \times r_{A} - \beta t$), which assumes instantaneous absorption and relies on static population weight constants.

Instead, the model implements a Two-Compartment System with First-Order Absorption and Michaelis-Menten Elimination Kinetics, validated by recent pharmacometric population studies (Büsker et al., 2023). 

## 2. Anthropometric Foundations: Total Body Water (TBW)
Ethanol distributes exclusively into the aqueous compartments of the human body. Therefore, the foundational dilution parameter must be Total Body Water (TBW). The engine calculates TBW utilizing the Watson anthropometric equations:

**For Males:**
$$TBW_{male} = 2.447 - (0.09516 \times Age) + (0.1074 \times Height) + (0.3362 \times Weight)$$

**For Females:**
$$TBW_{female} = -2.097 + (0.1069 \times Height) + (0.2466 \times Weight)$$

*(Where Age is in years, Height is in cm, and Weight is in kg. TBW output is in Liters).*

This calculated TBW value serves as the absolute baseline for the Volume of Distribution ($V_d$).

## 3. The Two-Compartment Differential Equations
To accurately map the ascending limb of intoxication and the delayed equilibrium between blood and tissue, the system relies on a two-compartment structural model:

* **Central Compartment ($V_c$):** Bloodstream and highly perfused organs (57% of TBW).
* **Peripheral Compartment ($V_p$):** Resting tissue and skeletal muscle (43% of TBW).

$$V_c = 0.57 \times TBW$$
$$V_p = 0.43 \times TBW$$

The dynamic flow of ethanol is calculated via ordinary differential equations (ODEs), where $A$ represents the absolute mass of ethanol (in grams) in a specific compartment at time $t$. 

**1. Gastrointestinal Input and Absorption (First-Order):**
To account for first-pass metabolism, the initial dose of ethanol deposited into the gastrointestinal tract is scaled by the oral bioavailability constant ($F_{oral}$), where $F_{oral}$ represents the surviving fraction that reaches systemic circulation. 

$$A_{GI(initial)} = \text{Dose}_{grams} \times F_{oral}$$

The absorption from this bioavailable GI pool into the central compartment follows first-order kinetics:
$$\frac{dA_{GI}}{dt} = -k_a \times A_{GI}$$

**2. Central Compartment (Absorption + Intercompartmental Flux - Elimination):**
$$\frac{dA_c}{dt} = k_a \times A_{GI} - Q \left( \frac{A_c}{V_c} - \frac{A_p}{V_p} \right) - v_{elim}$$

**3. Peripheral Compartment (Intercompartmental Flux):**
$$\frac{dA_p}{dt} = Q \left( \frac{A_c}{V_c} - \frac{A_p}{V_p} \right)$$

*(Where $k_a$ is the absorption rate constant, and $Q$ is the capillary intercompartmental clearance rate in L/h).*

## 4. Non-Linear Elimination (Michaelis-Menten Kinetics)
Hepatic oxidation of ethanol shifts from first-order to zero-order at clinically relevant concentrations. The engine utilizes the Michaelis-Menten equation to calculate the elimination velocity ($v_{elim}$) within the central compartment:

$$v_{elim} = \frac{v_{max} \times C_c}{K_m + C_c}$$

*(Where $C_c$ is the current ethanol concentration in the central compartment in g/L, $v_{max}$ is the maximum hepatic elimination rate, and $K_m$ is the Michaelis-Menten constant).*

## 5. Environmental Modifiers: The "Food Effect"
Caloric bulk in the gastrointestinal tract alters pharmacokinetics. The engine modifies two state variables when transitioning from a fasted to a fed state:

1. **Gastric Retention:** Slower absorption requires a mathematical suppression of $k_a$.
2. **Splanchnic Blood Flow:** Digestion accelerates elimination capacity. The baseline $v_{max}$ is multiplied by a Food Effect ($FE$) constant:

$$v_{max(fed)} = v_{max(fasted)} \times FE$$

## 6. System Constants Matrix
The following constants (Büsker et al., 2023) reflect **capillary** parameter estimates to closely mirror arterial blood alcohol levels (breathalyzer equivalents) and must be initialized to solve the differential equations:

| Parameter | Symbol | Fasted Value | Fed Value | Unit |
| :--- | :--- | :--- | :--- | :--- |
| Oral Bioavailability | $F_{oral}$ | 0.944 | 0.944 | scalar |
| Absorption Rate Constant | $k_a$ | 3.64 | 1.45 | $h^{-1}$ |
| Max Elimination Rate | $v_{max}$ | 6.31 | 8.77 *(6.31 × 1.39)* | g/h |
| Food Effect Factor | $FE$ | 1.00 *(Baseline)* | 1.39 | scalar |
| Capillary Michaelis-Menten | $K_m$ | 0.0121 | 0.0121 | g/L |
| Capillary Intercomp. Clearance | $Q$ | 47.7 | 47.7 | L/h |

## 7. Final Output Generation
To display the user's BAC as a standard percentage (g/dL), the engine extracts the current concentration of the central compartment ($C_c$ in g/L) and divides by 10:

$$BAC_{display} = \frac{A_c / V_c}{10}$$

---
