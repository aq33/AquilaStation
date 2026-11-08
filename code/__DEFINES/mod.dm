/// Default value for the max_complexity var on MODsuits
#define DEFAULT_MAX_COMPLEXITY 15

/// Default cell drain per process on MODsuits
#define DEFAULT_CHARGE_DRAIN 5

/// Passive module, just acts when put in naturally.
#define MODULE_PASSIVE 0
/// Usable module, does something when you press a button.
#define MODULE_USABLE 1
/// Toggle module, you turn it on/off and it does stuff.
#define MODULE_TOGGLE 2
/// Actively usable module, you may only have one selected at a time.
#define MODULE_ACTIVE 3

/// This module can be used during phaseout
#define MODULE_ALLOW_PHASEOUT (1<<0)
/// This module can be used while incapacitated
#define MODULE_ALLOW_INCAPACITATED (1<<1)
/// This module can be used while the suit is off
#define MODULE_ALLOW_INACTIVE (1<<2)

/// Global cache of mod skins to deployed parts to module icon states
GLOBAL_LIST_EMPTY(mod_module_overlays)
