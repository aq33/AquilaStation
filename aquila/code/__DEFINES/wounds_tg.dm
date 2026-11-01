// AQUILA - pierce wounds, cranial fissure, scars and wound bonuses from tgstation (aquila/code/modules/wounds/)

#define WOUND_PIERCE "pierce"
#define WOUND_CRANIAL "cranial"

/// Damage past this is ignored when rolling for a wound (tg), stronger weapons wound more through wound_bonus
#define WOUND_MAX_CONSIDERED_DAMAGE 25
/// The wound roll is rand(1, damage ** this)
#define WOUND_DAMAGE_EXPONENT 1.4
/// Roll needed for a cranial fissure, only on a head of someone in hard crit (tg)
#define WOUND_CRANIAL_THRESHOLD 110

/// Trait source for the near sight of a scarred eye
#define EYE_SCAR_TRAIT "eye_scar"
