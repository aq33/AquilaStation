// Broń microfusion (MCR-01), port z Monkestation/Monkestation2.0

/// The amount of cell charge drained during a drain failure.
#define MICROFUSION_CELL_DRAIN_FAILURE 500
/// The heavy EMP range for when a cell suffers an EMP failure.
#define MICROFUSION_CELL_EMP_HEAVY_FAILURE 2
/// The light EMP range for when a cell suffers an EMP failure.
#define MICROFUSION_CELL_EMP_LIGHT_FAILURE 4
/// Radiation intensity for when a cell suffers a radiation failure.
#define MICROFUSION_CELL_RADIATION_FAILURE 300

/// The lower most time for a microfusion cell meltdown.
#define MICROFUSION_CELL_FAILURE_LOWER (10 SECONDS)
/// The upper most time for a microfusion cell meltdown.
#define MICROFUSION_CELL_FAILURE_UPPER (15 SECONDS)

/// A charge drain failure.
#define MICROFUSION_CELL_FAILURE_TYPE_CHARGE_DRAIN 1
/// A small explosion failure.
#define MICROFUSION_CELL_FAILURE_TYPE_EXPLOSION 2
/// EMP failure.
#define MICROFUSION_CELL_FAILURE_TYPE_EMP 3
/// Radiation failure.
#define MICROFUSION_CELL_FAILURE_TYPE_RADIATION 4

/// Returned when the phase emtiter process is successful.
#define SHOT_SUCCESS "success"
/// Returned when a gun is fired but there is no phase emitter.
#define SHOT_FAILURE_NO_EMITTER "brak emitera fazowego!"

/// The error message returned when the phase emitter is processed but damaged.
#define PHASE_FAILURE_DAMAGED "EMITER FAZOWY: uszkodzony!"
/// The error message returned when the phase emitter has reached it's thermal throttle.
#define PHASE_FAILURE_THROTTLE "EMITER FAZOWY: dławienie termiczne!"

/// The heat dissipation bonus of an emitter being in space!
#define PHASE_HEAT_DISSIPATION_BONUS_SPACE 30
/// The heat dissipation bonus of an emitter being in air!
#define PHASE_HEAT_DISSIPATION_BONUS_AIR 10

// Slot defines for the gun.
/// The gun barrel slot.
#define GUN_SLOT_BARREL "lufa"
/// The gun underbarrel slot.
#define GUN_SLOT_UNDERBARREL "pod lufą"
/// The gun rail slot.
#define GUN_SLOT_RAIL "szyna"
/// Unique slots, can hold as many as you want.
#define GUN_SLOT_UNIQUE "dodatkowy"
/// Camo slot. Because why would you put four overlapping camos on your gun?
#define GUN_SLOT_CAMO "malowanie"
