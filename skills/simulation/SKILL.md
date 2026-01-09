---
name: Data Generation & Simulation
description: Ptychographic data simulation with grid vs nongrid pipelines
---

# Data Generation & Simulation

When working on synthetic data generation, simulation, dose studies, or data pipeline questions:

## Key Decision: Grid vs Nongrid

| Use Grid (`mk_simdata`) | Use Nongrid (`generate_simulated_data`) |
|-------------------------|----------------------------------------|
| Notebook reproduction | Production scripts |
| Regular scan patterns | Random/experimental coordinates |
| Pre-grouped output | Flexible grouping via KDTree |

## Quick Reference

**Grid mode:**
```python
from ptycho.diffsim import mk_simdata
X, Y_I, Y_phi, coords = mk_simdata(nimgs=2, size=392, probe=probe, outer_offset=8)
# Output is already grouped — can construct PtychoDataContainer directly
```

**Nongrid mode:**
```python
from ptycho.nongrid_simulation import generate_simulated_data
raw_data = generate_simulated_data(config, objectGuess, probeGuess, buffer=15.0)
# Output is ungrouped — needs raw_data.generate_grouped_data() before training
```

## Critical Requirements

1. **Grid mode:** Set `params.cfg` BEFORE calling `mk_simdata()` — it reads global state
2. **Nongrid mode:** Call `update_legacy_dict(params.cfg, config)` before legacy modules (CONFIG-001)
3. **Both:** Probe size must match N; gridsize must be consistent

## Full Documentation

Read `docs/DATA_GENERATION_GUIDE.md` for:
- Complete parameter mappings
- Container construction examples
- Common pitfalls
- Notebook-compatible examples
