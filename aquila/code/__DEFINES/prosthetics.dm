// AQUILA - any item as a prosthetic arm (tgstation#91573) and organs spilling from open surgery (tgstation#98023)

/// From the top of /obj/item/bodypart/drop_limb(), before the held item is dropped: (mob/living/carbon/old_owner, special)
#define COMSIG_BODYPART_DROPPED "bodypart_dropped"

/// Before an item has been equipped as a prosthetic limb: (obj/item/bodypart/limb)
#define COMSIG_ITEM_PRE_USED_AS_PROSTHETIC "item_used_as_prosthetic"
/// After an item has been equipped as a prosthetic limb: (obj/item/bodypart/limb)
#define COMSIG_ITEM_POST_USED_AS_PROSTHETIC "item_post_used_as_prosthetic"
/// Item has been unequipped from a mob as a prosthetic limb: (obj/item/bodypart/limb)
#define COMSIG_ITEM_DROPPED_FROM_PROSTHETIC "item_dropped_from_prosthetic"

/// Trait source of the prosthetic item that can't be dropped
#define PROSTHETIC_ITEM_TRAIT "prosthetic_item"

/// Chance that a freshly attached, not yet secured item falls off on every attack
#define PROSTHETIC_LOOSE_DROP_PROB 80

/// Screen alert of a patient with an opened chest or head
#define ALERT_EXPOSED_ORGANS "exposed_organs"
