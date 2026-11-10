// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj signals
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"				//! from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"				//! called in /obj/structure/setAnchored(): (value)

/// Called on a mob attempting to use a ladder to go in either direction.  (entrance_ladder, exit_ladder, going_up)
#define COMSIG_LADDER_TRAVEL "ladder-travel"
	#define LADDER_TRAVEL_BLOCK (1<<0)

// AQ EDIT START - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864)
//called in /obj/item/tank/jetpack/proc/turn_on() : (mob/user)
#define COMSIG_JETPACK_ACTIVATED "jetpack_activated"
	#define JETPACK_ACTIVATION_FAILED (1<<0)
//called in /obj/item/tank/jetpack/proc/turn_off() : (mob/user)
#define COMSIG_JETPACK_DEACTIVATED "jetpack_deactivated"

//called in /obj/item/organ/cyberimp/chest/thrusters/proc/activate() : (mob/user)
#define COMSIG_THRUSTER_ACTIVATED "jetmodule_activated"
	#define THRUSTER_ACTIVATION_FAILED (1<<0)
//called in /obj/item/organ/cyberimp/chest/thrusters/proc/deactivate() : (mob/user)
#define COMSIG_THRUSTER_DEACTIVATED "jetmodule_deactivated"
// AQ EDIT END
