# Aquila legacy overrides: audit

This file tracks Aquila changes that still live outside `aquila/`: edits to core files and procs that `aquila/` overrides wholesale. Use it when merging upstream (Beestation/NSV13). Every entry here is a place where an upstream change can conflict, or worse, get silently shadowed.

Audited against the merge base with `upstream/master` (`69565b730f`, 2026-09-12). The modularization pass is on branch `modularize-legacy-aquila-overrides`.

Rule for this pass: **current gameplay behaviour is authoritative.** Anything that could not be shown to behave identically was left alone and is listed below with the reason.

## How to read the classes

| Class | Meaning |
|---|---|
| A | Safe to modularize: a self-contained addition or var value that can move to `aquila/` unchanged |
| B | Safe with a small core hook |
| C | Full-copy override: `aquila/` redefines a whole upstream proc |
| D | Localization only (Polish strings), left in place on purpose |
| E | Map-bound, not touched |
| F | Too risky or architectural; left unchanged |

## Full-copy overrides (class C)

These are same-type redefinitions in `aquila/` that do not call `..()`, so they silently replace the upstream proc. Find them with a scan for `aquila/` proc definitions that match a core `type/proc` and do not call `..()`.

| Proc | Status | Notes |
|---|---|---|
| `/obj/item/powersink/process()` | **Reduced** to the `on_drain()` hook | Core calls `on_drain(drained)` in place of its APC block (1 AQ EDIT line). APC draining and infiltrator tracking stay in `aquila/.../powersink.dm`. Includes the hardened `newavail()`/`add_delayedload()` drain. |
| `/datum/admins/one_click_antag()` | **Reduced** to the `aquila_one_click_antag_links()` hook | 1 AQ EDIT line appends the Aquila buttons; the HTML is byte-identical. |
| `/turf/open/openspace/airless/zAirIn()`, `zAirOut()` | Full override (one line each) | The parents `/turf/open/openspace/zAirIn()`/`zAirOut()` always return TRUE, so `..()` cannot be used. Outer vacuum exchanges air vertically like `/turf/open/space` (in only from above, out only upward). Both are needed: each turf of the pair computes adjacency on its own, so one open side reconnects them. Without it, tiles under deck-3 vacuum (the docked Atlas escape shuttle) vent upward. |
| `/datum/nanite_program/nanite_sting` (+ `spreading/active_effect`) | Left (C/F) | Core's copies are commented out (`/* AQUILA EDIT */`) and `aquila/` defines the whole type. The delta (`COMSIG_NANITE_SET_CLOUD` sent *between* `AddComponent` and `COMSIG_NANITE_SYNC`, cloud extra setting, trigger cost 50) is interleaved, so it can't be a post-hook. Part of the larger Aquila nanite rework. |
| `/obj/item/screwdriver/abductor/get_belt_overlay()` | Left (minimal) | A one-line resource swap; the override *is* the delta. |
| `/datum/radial_menu/SetElement()` | Full override in the SS14 style only (`aquila/code/_onclick/hud/radial_ss14.dm`) | Menus with a custom `radial_icon` (blood cult) still call `..()`. The SS14 style keeps the sector centred on the anchor and rotates it with `transform`, the choice icon goes to a separate mouse-transparent `icon_holder`, so the base positioning and overlays cannot be reused. The name logic is copied from core: change both when upstream changes how names are read. |
| `/obj/machinery/ship_weapon/gauss_gun/do_animation()` | Full override (`aquila/code/modules/munitions/gauss_firing_animation.dm`) | One barrel per shot, alternating `gauss_firing0`/`gauss_firing1`; the base animated both barrels per shot, so a two-shot burst overlapped and showed only one barrel. `chamber(rapidfire = TRUE)` is overridden for gauss guns too (no `_chambering` flick mid-burst); the non-rapid branch calls `..()`. |
| `/mob/living/simple_animal/pulse_demon/Process_Spacemove()`, `PushAM()` | Full override (Aquila mob) | Return TRUE without `..()`: the base pushes off the nearest unanchored dense object (canisters flew away in zero gravity) and pushes bumped movables. |
| `/obj/structure/falsewall/update_icon()` | Partial (C) | `aquila/code/modules/paradise_struktury/false_walls.dm`. For false walls with Paradise sprites (`bitmask_smooth`) the NSV13 version is skipped: it adds goon corner overlays that the Paradise icons don't have. Types without bitmask still call `..()`. |
| `/datum/species/ipc/post_death()` | Left (minimal) | A one-line no-op (keep the BSOD screen after death); the override *is* the delta. |
| `/obj/machinery/gravity_generator/part/get_status()` | Left (minimal) | A one-line null-safe `main_part?.get_status()`; the override *is* the delta. |
| `/turf/closed/wall/break_wall()`, `devastate_wall()`, `/turf/closed/wall/r_wall/devastate_wall()`, `/obj/structure/girder/deconstruct()`, `/obj/structure/girder/screwdriver_act()` | Partial (C) | Shipbreaking (`aquila/code/modules/shipbreaking/hooks.dm`). Only inside `/area/space/shipbreak` the drops are swapped for scrap and `..()` is skipped; everywhere else they call `..()`. The girder screwdriver branch copies the core `GIRDER_DISPLACED` disassembly, because core spawns the iron inline. |
| `/datum/hud/human/update_locked_slots()` | Left (C) | BeeStation#13707 port (`aquila/code/_onclick/hud/locked_slots.dm`): dims every slot `can_equip()` would refuse (no jumpsuit, no suit, missing limbs or head, `no_glasses`), not just the species `no_equip` list. Upstream only checked `no_equip`, so the override replaces the whole loop. |
| `/obj/machinery/computer/security/telescreen/entertainment/notify()` | Partial (C) | Spess.tv port (`aquila/code/modules/broadcast/telescreen.dm`): skips the upstream proc when the screen is already on or another broadcast is live, because upstream `notify()` blanks the screen in both cases. The broadcast procs (`start/stop/set_network_broadcast_status`) moved from `bitrunning/server/util.dm` to `aquila/code/modules/broadcast/broadcast.dm`. |
| `/mob/living/carbon/getStaminaLoss()`, `adjustStaminaLoss()`, `setStaminaLoss()`, `/mob/living/carbon/update_stamina()` (+ the same three on `/mob/living`) | Replaced (C) | BeeStation#14750 port (`aquila/code/modules/mob/living/stamina.dm`): stamina is one pool per mob (`mob.stamina`, `/datum/stamina_container`), so the old API is a compatibility layer on the pool instead of a sum over limbs; the old stamcrit in `update_stamina()` is replaced by `/datum/status_effect/incapacitating/stamcrit` (random stun below 20%). The heretic `COMSIG_LIVING_ADJUST_STAMINA_DAMAGE` override in `heretic/_compat/shared.dm` was removed, the pool sends the signal. |
| `/obj/structure/overmap/move_toward()` | Partial (C) | Overmap scale (`overmap_scale.dm`): a ship with a standoff range (carrier, torpedo ship, scared ship) backs off or orbits instead of closing in. Flanking (`ai_flanking.dm`): a flanker flies to its slot (`..(slot)`) and holds there facing the target. Both call `..()` otherwise. |
| `/datum/ai_goal/retreat/action()` | Partial (C) | Overmap scale (`aquila/code/modules/overmap/overmap_scale.dm`): an AI carrier holds at its standoff range (`move_toward()` override) instead of running away; every other supply ship calls `..()`. |
| `/obj/structure/overmap/ai_fire()`, `ai_elite_fire()` | Partial (C) | AI morale (`aquila/code/modules/overmap/ai_morale.dm`): a commander who just picked a new target holds fire for 1-4 slowprocess ticks (`ai_hold_fire_until`); otherwise both call `..()`. |
| `/datum/orbital_objective/complete_objective()`, `/datum/orbital_objective/nuclear_bomb/on_assign()`, `check_failed()` and `get_text()` of the five Bee exploration objectives | Partial (C) | Derelict mission (`aquila/code/modules/overmap/derelict_ruin.dm`): when the objective belongs to the overmap mission (`linked_mission`), the payout goes to department budgets and the mission completes, with no `SSorbits.current_objective` or exploration points; the decommission nuke spawns inside the ruin instead of on the bridge; the texts talk about the ship. Every supercruise objective (no `linked_mission`) calls `..()`. |
| `/turf/closed/indestructible/dropship/setDir()`, `/turf/open/indestructible/dropship/setDir()` | Replaced (C) | Sabre rotation (`aquila/code/modules/overmap/sabre_shuttle.dm`): sets `dir` and turns the whole tile picture with `transform`, without `/atom/setDir()`'s `COMSIG_ATOM_DIR_CHANGE`. The decal element turns decals on that signal, and the turf transform already turns its overlays, so the stripes on a rotated Sabre floor would turn twice. These turfs have no other dir listeners. Test: `sabre_shuttle_rotated` |
| `/obj/structure/overmap/small_craft/transport/docking_act()`, `can_move()`, `exit()` | Partial (C) | Shuttle-interior craft (`aquila/code/modules/overmap/shuttle_craft.dm`): with `shuttle_port` set (Sabre in a hangar, a shuttle built with the Rapid Shuttle Designator) docking lands the interior shuttle on a port or next to the target's hull, a docked craft can't move, and leaving goes out of the hatch or airlock; without `shuttle_port` all three call `..()`. |
| `/obj/machinery/computer/shuttle_flight/custom_shuttle/ui_interact()`, `ui_data()`, `ui_static_data()`, `ui_act()` | Partial (C) | Custom shuttles on the overmap (`aquila/code/modules/overmap/custom_shuttle_overmap.dm`): once the console has an overmap craft it opens the fighter controls for it (launch prompt while docked) instead of the old shuttle console; before that all four call `..()`. |
| `/atom/movable/do_item_attack_animation()` | Replaced (C) | Port tgstation/tgstation#88418 (`aquila/code/game/objects/items/attack_animations.dm`): the item icon slashes in an arc, thrusts or hits depending on `get_attack_animation()` (pierce wounds = thrust, sharp = slash), turned by `icon_angle`. The old version only flew the icon towards the target, so nothing of it can be reused. Effect icons (`visual_effect_icon`) grow from 0.4 to 0.75 like in tg. |
| `/obj/item/clothing/suit/space/hardsuit/ui_action_click()` | Replaced (C) | Hardsuity z modułami (`aquila/code/modules/clothing/spacesuits/hardsuit_modules.dm`): bazowe woła `attack_self()`, a to otwierało panel modułów przy każdej akcji; obsługuje tylko hełm i wbudowaną butlę. |
| `/obj/structure/vampire/vassalrack/mouse_buckle_handling()` | Full override (returns FALSE) | The generic drag buckle (`/atom/movable/MouseDrop_T()`, carried victims in `attackby()`) skipped the bolting check and reset of the torture progress, so the rack buckles only through its own `MouseDrop_T()` and the `riding_offhand` branch of its `attackby()`. `aquila/code/modules/antagonists/vampire/objects_vampire.dm` |

The other ~60 same-type redefinitions in `aquila/` call `..()`, so they are already pre/post hooks.

## Core hooks added by the modularization pass

| Hook | Location | Feature |
|---|---|---|
| `initialized_changed` is a counter in `/datum/controller/subsystem/atoms/proc/set_tracked_initalized()` / `clear_tracked_initalize()` (was a flag with a stack trace on the second begin) | `code/controllers/subsystem/atoms.dm` | Two map loads overlapping in time (ruin generator parts of the Derelict station mission sleep inside `CreateAtoms()`, a room spawner loads its room meanwhile) no longer log "We started maploading while we were already maploading", and the first load to finish no longer restores `initialized` while the other is still loading. Tests: `derelict_ruin_mission`, `atoms_init_state` |
| `fix_template_node_links(atmos_machines)` between the `atmos_init()` loop and the pipeline build in `/datum/controller/subsystem/air/proc/setup_template_machinery()` | `code/controllers/subsystem/air.dm` | A template loaded next to another one (ruin generator parts of the Derelict station mission) can leave one-way pipe links: a new pipe takes as its node a device whose own node in that direction is already taken, and building the pipeline then runtimes in `set_pipenet()`. The proc gives a plain pipe with a free connection the link back, otherwise drops the one-way link. Entry: `aquila/code/modules/atmospherics/machinery/template_node_links.dm` |
| `bypass_cooldown` argument of `/datum/proc/update_static_data()` passed to `send_full_update()` (Bee upstream, default FALSE here), `bypass_cooldown = TRUE` in `/obj/item/modular_computer/ui_interact()` | `code/modules/tgui/external.dm`, `code/modules/modular_computers/computers/item/computer_ui.dm` | Switching a PDA program skips the 5 s full update limit, so it no longer shows the spinning toolbox for up to 5 s. Other static updates keep the limit (players can trigger them from UI actions). A bypassed update does not restart the limit (`if(!bypass_cooldown)` around `COOLDOWN_START` in `/datum/tgui/proc/send_full_update()`, `code/modules/tgui/tgui.dm`). |
| `if(thing.loc != src && oldT.density) continue` at the top of the contents loop in `/turf/proc/toShuttleMove()` | `code/modules/shuttle/on_move.dm` | A landing shuttle no longer crushes a multi-tile object standing next to the dock whose bounds only overlap a solid hull tile of the shuttle (Snake gauss turret by the mining Sabre pad). Objects overlapping an open floor of the shuttle are still crushed as upstream, so nothing dense ends up inside the shuttle. Test: `sabre_shuttle_wide_neighbour` |
| `SEND_SIGNAL(src, COMSIG_LIVING_AQ_PRE_SAY, ...)` after `can_speak_vocal()` in `/mob/living/say()` (flags `COMPONENT_AQ_SAY_INTERCEPTED` / `COMPONENT_AQ_SAY_AS_COMMON`, defines in `code/__DEFINES/dcs/signals/signals_mob/signals_living.dm`) | `code/modules/mob/living/say.dm`, `code/__DEFINES/dcs/signals/signals_mob/signals_living.dm` | Foreigner translator: English speech goes to DeepL and comes back through `say()` in Common with the same prefixes. Only mobs with a translator listen to the signal, so the hook does nothing without the EN module. Entry: `aquila/code/modules/i18n/foreigner.dm` |
| `!aq_translated` (trait `TRAIT_AQ_TRANSLATED_SPEECH`, defined in `code/__DEFINES/traits.dm`) in the `CHAT_FILTER_CHECK` and `RP_FILTER_CHECK` conditions of `/mob/living/say()` | `code/modules/mob/living/say.dm` | The foreigner's translated re-say skips the IC/RP chat filters, which already checked the original (no double brain damage). Entry: `aquila/code/modules/i18n/foreigner.dm` |
| `aq_ooc_prepare(raw_msg)` before the recipient loop in `/client/verb/ooc()` and picking `aq_ooc_texts[C]` at the top of the loop (plus saving/restoring `msg`) | `code/modules/client/verbs/ooc.dm` | OOC in the recipient's language: one DeepL translation per message, only for recipients who see it and use the other language. Base proc does nothing (`aquila/code/__HELPERS/chat_translation.dm`), the EN module overrides it (`aquila/code/modules/i18n/chat_translation.dm`) |
| `Z_LEVEL_UP`/`Z_LEVEL_DOWN` and the `GET_TURF_ABOVE`/`GET_TURF_BELOW` macros (`AQ EDIT` block); `SSmapping.get_turf_above/below()`, `get_step_multiz()`, `turf.above()/below()` and the multi-z lookups in `turf/Initialize()`/`Destroy()` use the macros instead of `level_trait()`; `get_zs_in_range()` reads `SSmapping.get_multiz_stack()` instead of walking turfs | `code/__DEFINES/multi_z.dm`, `code/modules/mapping/space_management/traits.dm`, `code/modules/mapping/space_management/multiz_helpers.dm`, `code/game/turfs/turf.dm` | Multi-z links computed once per z-level (tgstation/tgstation#76248, list from tgstation/tgstation#66657). `SSmapping.multiz_levels` is filled by overrides of `InitializeDefaultZLevels()`/`add_new_zlevel()`/`Recover()` in `aquila/code/modules/mapping/multiz_levels.dm`; the per-z floor stack cache is cleared on every new z-level. Up is always z+1, down z-1 (our maps use `"Up": 1` / `"Down": -1`) |
| `msg = aq_admin_msg_for(recipient, msg, !aq_html, aq_html)` (with `aq_html = check_rights(R_SERVER|R_DEBUG, 0)`) before `rawmsg` in `/client/proc/cmd_admin_pm()` | `code/modules/admin/verbs/adminpm.dm` | Admin PMs between players and admins with different languages get the translation appended. Same base/override pair |
| `msg = aq_admin_msg_for(null, msg, FALSE)` after `trim()` in `/client/verb/adminhelp()` | `code/modules/admin/verbs/adminhelp.dm` | A foreigner's adminhelp reaches the (Polish) admins with a Polish translation appended. Same base/override pair |
| `start_alarm_sound()` zamiast `playsound` | `code/game/machinery/firealarm.dm` (`alarm()`) | Alarm pożarowy gra pętlę dźwięków z tg, dopóki obszar jest w alarmie (`aquila/code/game/machinery/firealarm_sound.dm`). |
| `"Guru Granth Sahib", "Kojiki"` na końcu `biblenames`, `biblestates` (`gurugranthsahib`, `kojiki`) i `bibleitemstates` (`bible`, `kojiki`) | `code/game/objects/items/storage/book.dm` | Dwa wyglądy księgi kapelana ze sprite'ami z tg. Nadpisanie `InitGlobal*` w `aquila/` nie działało w teście (`/datum/controller/global_vars/Initialize()` woła procki przez `call(src, ścieżka)()`). Test: `aquila_service_tg_sprites` |
| `"Claude"` na liście `ai_core_display_screens` (obok `"PapAI"`) | `code/_globalvars/lists/flavor_misc.dm` | Wygląd rdzenia SI „Claude” (stany `ai-claude` i `ai-claude_dead` w `icons/mob/ai.dmi`). Lista jest `GLOBAL_LIST_INIT`, nadpisanie z `aquila/` nie działa (jak przy księgach). Test: `aquila_ai_core_displays` |
| `/obj/item/food/kabanosy = 6` w `products` automatu z przekąskami | `code/modules/vending/snack.dm` | Kabanosy z Polonium Station w automacie (typ w `aquila/code/game/objects/items/food/polskie.dm`). Test: `aquila_polonium_polskie` |
| `get_eyelid_overlays()` po nakładce oczu | `code/modules/mob/living/carbon/human/species.dm` (`handle_body()`) | Mruganie z tg: powieka w kolorze skóry, zamknięte oczy u nieprzytomnych (`aquila/code/modules/mob/living/carbon/human/eyelids.dm`). |
| `map_size` w JSON mapy | `code/datums/map_config.dm` (zmienna + `LoadConfig()`) | Rozmiar mapy w nawiasie w oknie głosowania i w preferencji mapy (`get_vote_label()` w `aquila/code/controllers/subsystem/vote.dm`). |
| `READPREF_INT`/`PREP_WRITEPREF_RAW`/`sanitize_integer` for `soft_lighting`, `glow_level`, `light_glare` + tags `PREFERENCE_TAG_SOFT_LIGHTING` (34), `PREFERENCE_TAG_GLOW_LEVEL` (35), `PREFERENCE_TAG_LIGHT_GLARE` (36) | `code/modules/client/preferences2/preferences2.dm`, `code/__DEFINES/preferences.dm` | Preferencje „Miękkie światło”, „Poświata” i „Promienie świateł” w bazie (`toggles2` jest pełne). Efekty w `aquila/code/modules/lighting/soft_lighting.dm`. |
| `if(!QDELETED(L))` | `code/controllers/subsystem/mobs.dm` (`fire()`) | `currentrun` survives between ticks, so a mob deleted meanwhile still got `Life()` (e.g. an unpowered AI calling `addtimer` on itself). Test: `aquila_logi_rund_26_10` |
| `image(icon, "teg-op[L]")` zamiast stałego `'icons/obj/power.dmi'` | `code/modules/power/generator.dm` (`update_icon()`) | Sprite TEG Quartofela w `aquila/icons/obj/power/teg.dmi`, nakładki mocy idą z ikony maszyny (`aquila/code/modules/power/generator.dm`). |
| `'aquila/icons/mob/clothing/id.dmi'` zamiast `'icons/mob/mob.dmi'` jako domyślny plik slotu ID | `code/modules/mob/living/carbon/human/update_icons.dm` (`update_inv_wear_id()`) | Karta na smyczy w kolorach karty, PDA i portfel widoczne na postaci (`aquila/code/modules/clothing/id_worn.dm`). |
| Ramki ogłoszeń jak w tg (`MAJOR_ANNOUNCEMENT_*`, `MINOR_ANNOUNCEMENT_*`, `CHAT_ALERT_SPAN`) i argument `color_override` w `priority_announce()`/`minor_announce()`; defines `boxed_message`, `fieldset_block`, `separator_hr`, znaczniki `AQ_EXAMINE_*` | `code/__HELPERS/priority_announce.dm`, `code/__DEFINES/chat.dm`, `nsv13/code/__HELPERS/priority_announce.dm` (`gq_announce()`), `code/modules/security_levels/security_levels.dm` (kolory ramek alarmów) | Czat w układzie tg: pasiaste ramki ogłoszeń w kolorze poziomu alarmu, ramki `boxed_message` (style w `tgui-panel/styles/tgchat/`). |
| `aq_examine_html(A, result)` zamiast `EXAMINE_BLOCK(...)` | `code/modules/mob/mob.dm` (`run_examinate()`) | Examine w układzie tg: tytuł w zakładce ramki, portret postaci (`aquila/code/modules/mob/examine_layout.dm`). |
| Tytuł bez `<span class='info'>`, znaczniki `AQ_EXAMINE_STATUS_MARK`/`AQ_EXAMINE_HUD_MARK`/`AQ_EXAMINE_HUD_END`, pusta lista `msg` nie dodaje linii | `code/modules/mob/living/carbon/human/examine.dm` | Sekcje examine (ubranie, stan, HUD-y, link) układa `aq_order_examine_sections()`, także z liniami dopisanymi przez nadpisania po `..()`. |
| Zawsze dwa gangi, start dopiero przy dwóch szefach | `code/game/gamemodes/gangs/gangs.dm` (`pre_setup()`) | Wojna gangów Aquili: limit członków, dominator, panel i okno (`aquila/code/modules/antagonists/gang/`). Dominator przeniesiony z core do `aquila/code/game/gamemodes/gangs/dominator.dm`. |
| Bez `return` w pętli i `gangster?.gang` | `code/modules/antagonists/gang/gang.dm` (`message_gangtools()`) | Wiadomości gangtoola dostawał tylko pierwszy przytomny posiadacz; teraz wszyscy w gangu. |
| `greet_and_capture()` | `code/modules/antagonists/_common/antag_datum.dm` (`on_gain()`) | The role greeting from `greet()` is also stored and shown in the role window (`AntagInfoGeneric` intro) for roles without a `playstyle_string`. Before, many roles (pulse demon, dragon, revenant...) had only the name and objectives there. `aquila/code/modules/antagonists/_common/antag_info.dm`, test `aquila_antag_info_greeting` |
| `GLOB.antag_greeting_capture.capture_greeting()` | `code/modules/tgchat/to_chat.dm` (`to_chat()`) | Collects the greeting lines sent to the role owner while `greet()` runs (one global null check otherwise). |
| `gib_keeps_brain` | `code/game/objects/items/implants/implant_explosive.dm` (var, `activate()`, `timed_explosion()`) | The CE punishment implant gibs without destroying the brain, so the engineer can be revived or put into an MMI. Test `aquila_engineering_implant_keeps_brain` |
| `disposal_tag = rand(1, length(GLOB.TAGGERLOCATIONS))` | `code/modules/mod/modules/modules_supply.dm` (`/obj/item/mod/module/disposal_connector/Initialize()`) | The MOD disposal connector picked a destination name with `pick()`, but disposal holders compare numeric tags and the config reads `TAGGERLOCATIONS[disposal_tag]`, so nothing reached its destination. Test `aquila_mod_disposal_tag_is_number` |
| `tips = "boarder"`, `tips = "bloodling_thrall"` | `nsv13/code/modules/antagonists/boarders/boarders.dm`, `nsv13/code/modules/antagonists/bloodling.dm` | `show_tips()` builds `html/antagtips/[tips].html` itself; the file paths there opened empty tip windows. |
| `if(type == "display/refresh_rate")` | `code/modules/tgui_panel/tgui_panel.dm` (`on_message()`) | Panel czatu wysyła zmierzone odświeżanie monitora; przy FPS „Zalecane” klient dostaje FPS równe odświeżaniu (`aquila/code/modules/client/monitor_refresh.dm`). |
| `translateUiText(title)` przed `toTitleCase` | `tgui/packages/tgui/layouts/TitleBar.tsx` (`TitleBar`) | Angielska wersja językowa: tytuł okna (nazwa obiektu, np. „automat składu”, „konsola działu (Nauka)”) jest tłumaczony, zanim dostanie Wielkie Litery, bo słownik ma klucze małymi literami (`tgui/packages/tgui/i18n.ts`). Test: `i18nCase.test.ts` |
| `get_path_to(...) || list()` | `code/modules/mob/living/simple_animal/bot/medbot.dm` (`handle_automated_action()`) | A medibot without a turf (world shutdown after tests) got a null path and runtimed on `path.len`. |
| `if(kb)` / `kb?.any_modifier` | `code/modules/keybindings/bindings_client.dm` (`keyDown()`, `keyUp()`) | Saved prefs can name a keybinding that no longer exists; the null went into the list and `cmp_keybinding_dsc` or `kb.any_modifier` runtimed. Load-time cleanup in `aquila/code/datums/keybinding/unknown_keybinds.dm`. |
| `M_turf ? multi_z_dist(...) : INFINITY` | `code/controllers/subsystem/explosion.dm` (`explode()`, sound/shake loop) | A player in the lobby has no turf; `multi_z_dist()` runtimed and broke the loop, so later players never heard the explosion or got the camera shake. Test: `aquila_logi_rund_6552` |
| `isclothing(wear_mask)` | `code/modules/mob/living/carbon/human/life.dm` (`has_smoke_protection()`), `code/modules/mob/living/carbon/human/species.dm` (`handle_hair()`, `dynamic_fhair_suffix` and `dynamic_hair_suffix`), `code/modules/mob/living/carbon/life.dm` (`can_breathe_internals()`), `code/modules/mob/living/carbon/monkey/life.dm` (`has_smoke_protection()`), `code/game/objects/items/tanks/tanks.dm` (`toggle_internals()`), `code/game/objects/structures/shower.dm` (clothing check) | The mask slot can hold a non-clothing item (harmonica); reading `clothing_flags`/`dynamic_fhair_suffix` on it runtimed. Test: `aquila_logi_rund_6552` |
| `strip_auto_articles()` on `html` and `text` | `code/modules/tgchat/to_chat.dm` (`to_chat()`, `to_chat_immediate()`) | BYOND inserts an English "the"/"The" before every embedded object with a lowercase name, which broke every Polish message ("To the teczka"). Test: `aquila_auto_articles` |
| `INVOKE_ASYNC(...)` without `return` in the `COMSIG_PARENT_ATTACKBY` handler | `code/datums/components/construction.dm` (`action()`), `code/game/mecha/mecha_construction_paths.dm` (gygax `action()`) | `INVOKE_ASYNC` returns a `/datum/task` since the 515 compatibility change; `_SendSignal` ORed it into the flags and runtimed on every mech construction click. Test: `aquila_logi_rund_26_10` |
| `if(parent)` before `SEND_SIGNAL` | `code/datums/components/material_container.dm` (`use_amount_mat()`) | A fabricator with local materials (not linked to the silo) drops them as sheets in `remote_materials/Destroy()` after the material container is already detached, so `parent` is null and every deletion runtimed. Test: `test_chamber` (MOD kit fabricator) |
| `cycle_sleep(delay, stage)` instead of `sleep(delay)` | `nsv13/code/modules/munitions/ship_weapons/_ship_weapon.dm` (`unload()`, `feed()`, `chamber()`, `unchamber()`), `nsv13/code/modules/munitions/ship_weapons/ballistic_weapons/gauss_gun.dm` (`raise_rack()`) | Przyciski etapów w oknie broni (I1, I2, I4) nabijają się paskiem, dopóki etap trwa (`aquila/code/modules/munitions/weapon_cycle_stage.dm`, `tgui/.../interfaces/common/WeaponStageButton.tsx`). |
| `user.mind?.` / `user.client?.` null guards | `code/game/objects/items/melee/misc.dm` (contractor baton `pickup()`), `code/game/objects/items/granters.dm` (martial `already_known()`), `code/game/machinery/computer/camera_advanced.dm` (`give_eye_control()`) | A mob without a mind (monkey AI picks up items) or without a client runtimed on these. Found by `test_chamber_smoke` |
| `if(controller.pawn)` before `stop_looping()` | `code/datums/ai/movement/_ai_movement.dm` (`stop_moving_towards()`) | A behaviour finishing after the pawn was deleted passed null to the move manager. Found by `test_chamber_smoke` |
| `return ..()` at the end of `/obj/machinery/deepfryer/deconstruct()` | `code/modules/food_and_drinks/kitchen_machinery/deep_fryer.dm` | Without the parent call a destroyed fryer stayed on the map at 0 integrity and every hit logged a stack trace. Test: `aquila_logi_rund_26_10` |
| `"fryer_open"` as the open panel state in `default_deconstruction_screwdriver()` of `/obj/machinery/deepfryer/attackby()` | `code/modules/food_and_drinks/kitchen_machinery/deep_fryer.dm` | The fryer shows an open maintenance panel (tgstation sprite `fryer_open` in `icons/obj/machines/kitchen.dmi`); before it kept `fryer_off` |
| `if(!magazine?.max_ammo) return ..()` | `code/modules/projectiles/guns/ballistic.dm` (`fire_sounds()`) | A shot without a magazine divided by null and played no sound. Test: `aquila_logi_rund_26_10` |
| `streak_diseases = list()` before `COMSIG_GIBS_STREAK` | `code/game/objects/effects/decals/cleanable/humans.dm` (`gibs/streak()`) | The list was null on the first streak (runtime in `try_infect_streak()`) and was emptied right after the signal filled it, so splatters never carried the diseases. Test: `aquila_logi_rund_26_10` |
| `if(!current_area) continue` | `code/controllers/subsystem/ambience.dm` (`fire()`) | A client whose mob is in nullspace has no area, `play_buzz()` read `null.ambient_buzz` every tick |
| `log_ahelp_pm(recipient, rawmsg)` | `code/modules/admin/verbs/adminpm.dm` (`cmd_admin_pm()`) | Ticket replies go to the `ticket` table for the player ticket history; the commented-out `LogAhelp()` in `blackbox.dm` is replaced by `aquila/code/modules/admin/ticket_db_log.dm` |
| `SSlag_switch.measures[DISABLE_DEAD_KEYLOOP]` skip in the keyLoop | `code/controllers/subsystem/input.dm` (`fire()`) | Lag switches (tgstation#59717, #95976): dead non-admin mobs stop flying around. tg keeps a separate `keyloop_list`; our mob lists differ, so one check in the loop does the same. Test: `aquila_lag_switch` |
| `DISABLE_RUNECHAT` early return / speech bubble | `code/datums/chatmessage.dm` (`create_chat_message()`), `code/modules/mob/living/say.dm` (`send_speech()`) | Lag switches: no runechat, listeners get the speech bubble instead |
| `DISABLE_USR_ICON2HTML` early return | `code/__HELPERS/icons.dm` (`icon2html()`, `costly_icon2html()`) | Lag switches: no icons in verb output such as examine |
| `SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CLIENT_CONNECT, src)` | `code/modules/client/client_procs.dm` (`/client/New()`) | Lag switches auto trigger; the wiremod global signal list used this name without a definition, so circuits never got it |
| `aquila\code\__DEFINES\lag_switch.dm` included early | `nsv13.dme` | Lag switch indexes and `TRAIT_BYPASS_MEASURES` are used by the core hooks above |
| `HIST` button (`tickethistory` action) | `tgui/packages/tgui/interfaces/TicketMessenger.tsx` | Player ticket history (tgstation#75830); the action is handled by a `/datum/admin_help/ui_act()` override in `aquila/code/modules/admin/player_ticket_history.dm` |
| `json_decode(response.body)` instead of `response["body"]` | `code/modules/admin/topic.dm` (`centcomlookup`), `code/modules/client/client_procs.dm` (`check_upstream_bans()`) | Indexing the `/datum/http_response` like a list runtimed for every player with a CentCom ban, so the lookup window never opened |
| `LAZYACCESS(ban_attributes, "BeeStationGlobal")` | `code/modules/client/client_procs.dm` (`check_upstream_bans()`) | Bans from other servers have no `banAttributes` |
| `/obj/item/melee/sickly_blade/lock` in `can_hold` | `code/game/objects/items/storage/belt.dm` (`/obj/item/storage/belt/utility/ComponentInitialize()`) | Heretic key blades fit in the toolbelt as in tg (wiki audit) |
| Delimber zone defines and `continue` | `code/game/objects/effects/anomalies.dm` (`ANOMALY_DELIMBER_ZONE_*`, `delimber_pulse()`) | Arms and legs were swapped; one target without the rolled limb ended the whole pulse |
| `clamp(round(threat_level/10), 1, length(required_enemies))` | `code/game/gamemodes/dynamic/dynamic_rulesets_midround.dm`, `dynamic_rulesets_latejoin.dm` (`ready()`) | Index 0 runtime below threat 10 (Sleeper Agent, latejoin Infiltrator) aborted midround rolling |
| `WIRE_SHOCK`, `aidisabled = !mend` | `code/datums/wires/autolathe.dm`, `airalarm.dm`, `airlock_cycle.dm` (`on_cut()`) | Duplicate `WIRE_HACK` made the shock wire dead; AI wire logic was inverted |
| `prb && !prob(prb)` | `code/game/machinery/suit_storage_unit.dm` (`shock()`) | Inverted chance check |
| `ice_chili`, `ghost_chili` types | `code/modules/cargo/bounties/botany.dm` | Three bounties shared one type path, so only the ghost chili bounty existed |
| `/datum/material/iron` | `code/modules/research/designs/mecha_designs.dm` (`mech_taser`) | `MAT_METAL` cost; design added to `mech_disabler` in `aquila/code/modules/research/techweb/all_nodes.dm` |
| Foam dart damage after unscrewing | `code/modules/projectiles/ammunition/caseless/foam.dm` | Modified dart did no damage until dropped |
| `A.stage_rate`, `mutability -= 2`, `A.mutability = mutability` | `code/datums/diseases/advance/symptoms/viral.dm`, `code/datums/diseases/advance/advance.dm` (`Copy()`) | Unset `A.speed`, asymmetric Viral Evolution, copies lost mutability |
| Description/comment only | `other_tools.dm` (repair droid), `layermanifold.dm` (dead `volume`), `implant_chem.dm` (`get_data()`), `heart.dm`, `brain_item.dm`, `buffs.dm` (`exercised`) | Texts matched to actual behaviour after the wiki audit |
| `M.ckey` instead of `C.ckey` for `centcomlookup` | `code/modules/admin/admin.dm` (`/datum/admin_player_panel/ui_act()`) | The CentCom button did nothing for disconnected players |
| `data["centcom_db"]` set before the no-client return | `code/modules/admin/admin.dm` (`/datum/admin_player_panel/ui_data()`) | The CentCom button in the option row of `AdminPlayerPanel.tsx` also shows for disconnected players |
| `\|\| !thing.managed_vis_overlays` early return | `code/controllers/subsystem/vis_overlays.dm` (`remove_vis_overlay()`) | The do_after cogbar removed its cog after the managed list was already gone (`null -= list`). Test: `aquila_logi_rund_26_10` |
| `categories = {}` default, `Object.entries(categories)` | `tgui/packages/tgui/interfaces/Vending.tsx` | A pooled window got data without `categories` and `Object.keys(null)` crashed it |
| `if(!throttled_exposure(location)) return TRUE` before the contents loop | `code/modules/atmospherics/environmental/LINDA_fire.dm` (`/obj/effect/hotspot/perform_exposure()`) | Hotspots burn their tile every `HOTSPOT_CONTENTS_INTERVAL` ticks and smoke every `HOTSPOT_SMOKE_INTERVAL` ticks (`aquila/code/modules/atmospherics/environmental/hotspot_throttle.dm`); a big fire cost several seconds per SSair run. Test: `hotspot_throttle` |
| `if(cached_my_atom && !fire_mutes_reaction(cached_my_atom))` before the reaction sound and message | `code/modules/reagents/chemistry/holder.dm` (`/datum/reagents/proc/instant_react()`) | Puddles and ash on a burning tile react without a sound or a message (`aquila/code/modules/atmospherics/environmental/hotspot_throttle.dm`); ash baking into ash rims looked up viewers on every reaction and cost most of a fire. Test: `fire_mutes_reaction` |
| `if(GLOB.temperature_expose_typecache[item.type])` in the `temperature_expose()` loop | `code/modules/atmospherics/gasmixtures/reactions.dm` (`/proc/fire_expose()`) | Burning gas calls `temperature_expose()` only on movables that override it (`aquila/code/modules/atmospherics/environmental/hotspot_throttle.dm`); the loop called the empty base proc for every item on every burning tile each tick. New movable overrides go in the cache. Test: `temperature_expose_typecache` |
| Header without `air_turf_count`, `air_eg_count`, `air_superconductive_count`; SendMaps values in header order | `code/controllers/subsystem/time_track.dm` (`Initialize()`, `fire()`) | Perf CSV rows had fewer fields than the header and SendMaps columns changed between rows. Test: `perf_log_columns` |
| `METACOIN_CO_REWARD` 1000, `METACOIN_ESCAPE_REWARD` 2000, new `METACOIN_PATROL_REWARD` 3000 | `code/__DEFINES/metacoin.dm`, `code/modules/metacoin/metacoin.dm` (`process_endround_metacoin()`) | Aquila aquilos rewards: crew objective, surviving and escaping, won patrol. The per-objective antag reward (500 each) is in `aquila/code/modules/metacoin/metacoin.dm` |
| `icon = 'icons/obj/tools.dmi'`, `item_state`/`belt_icon_state` per colour | `code/game/objects/items/tools/wirecutters.dm` (`Initialize()`) | The Paradise `pcutters_*` states exist only in core `tools.dmi`, while `aquila/` points wirecutters at `aquila/icons/obj/tools.dmi`; inhand/belt states exist only for `cutters_red`/`cutters_yellow` (same pattern as the screwdriver) |
| `icon_exists()` check before the shield overlay | `code/datums/components/shielded.dm` (`on_update_overlays()`) | `icons/effects/effects.dmi` has no `broken` state; a depleted shield drew a missing state, which showed a random sprite with the walk animation on 516 |
| `initialized = INITIALIZATION_INNEW_REGULAR` before the round start `InitializeAtoms()` instead of `INITIALIZATION_INNEW_MAPLOAD` | `code/controllers/subsystem/atoms.dm` (`Initialize()`) | `InitializeAtoms()` switches to MAPLOAD itself and restores the previous state; starting from MAPLOAD made that the restored state, map loads during the late loaders (ship interiors) copied it and it stuck for the round, so `LateInitialize()` of runtime atoms (cables laid by players) never ran. Test: `atoms_init_state` |
| `get_overmap()?.beacons_in_ship` in the patrol beacon loops | `code/modules/mob/living/simple_animal/bot/bot.dm` (`get_next_patrol_target()`, `find_nearest_beacon()`) | A bot outside the ship (a reservation, e.g. the bingle pit dimension) has no overmap, the loops runtimed on every patrol step |
| Lower `LATTICE_LAYER` … `CATWALK_LAYER`, new `GRILLE_LAYER` | `code/__DEFINES/layers.dm` | Floor-level objects (lattices, disposals, hidden pipes, cables, catwalks, grilles) go below `CLOSED_TURF_LAYER` like in Paradise, so the 8 px overhang of 3/4 walls covers them. `LATTICE_LAYER` 1.6 sits below every hidden pipe (piping layer 1 = 1.62) and `UNDER_CATWALK`/`CATWALK_LAYER` 1.834/1.835 above every one (piping layer 5 = 1.82), as before the change; lattices and hull plates moved from `FLOOR_PLANE` to `GAME_PLANE` in `aquila/code/modules/paradise_struktury/warstwy.dm`, otherwise the floor turf covered them. Test: `aquila_audyt_warstwy_*` |
| `A.bitmask_smooth_icon()` branch in `smooth_icon()` | `code/__HELPERS/icon_smoothing.dm` | Paradise walls, windows and doors (32x40, 47-state bitmask) skip corner and legacy smoothing; logic in `aquila/code/modules/paradise_struktury/smoothing.dm` |
| `QDEL_IN(src, 20)` in `/obj/effect/particle_effect/sparks/Initialize()` | `code/game/objects/effects/effect_system/effects_sparks.dm` | Sparks are cleaned up even if their `LateInitialize()` never runs |
| `isaicore()` / `isvalidAIloc()` macros | `code/__DEFINES/is_helpers.dm` | Decentralized AI (Monkestation/Monkestation2.0#11862): the AI lives inside a data core, so "AI is in its core" means a turf or a data core. Logic in `aquila/code/modules/mob/living/silicon/ai/decentralized/` |
| `TECHWEB_POINT_TYPE_AI` in the point type list | `code/__DEFINES/research.dm` | Separate AI research points generated by spare AI CPU, spent on AI hardware nodes (`aquila/code/modules/research/ai_hardware.dm`) |
| `try_tg_surgery()` at the start of `melee_attack_chain()` | `code/_onclick/item_attack.dm` | New surgery skeleton from tgstation#93697 (`aquila/code/modules/surgery_tg/`): on a mob prepared for surgery (`TRAIT_READY_TO_OPERATE`) a tool first offers the new operations, before `tool_act` like tg `item_interaction`. Empty hand goes through the `/mob/living/carbon/attack_hand` override; both in `_operation.dm`. Surgical aids (drapes, bedsheet, `TRAIT_SURGERY_AID`) are skipped, they prep the zone |
| `is_chest_open_for_surgery()` check before `AttemptGrow()` | `code/modules/mob/living/carbon/alien/special/alien_embryo.dm` (`on_life()`, stage 5) | New surgery skeleton: a chest opened with the new operations (skin open + bone sawed, like tg) counts as surgery in progress, so the larva bursts out without killing the host. Replaces the old `manipulate_organs` loop. Helper in `aquila/code/modules/surgery_tg/bodypart_surgery_state.dm` |
| `can_receive_shot_organ()` instead of the old surgery loop | `code/modules/mod/modules/modules_medical.dm` (`/obj/item/projectile/organ/on_hit()`) | New surgery skeleton: the MOD organ thrower inserts into a limb opened with the new operations (skin open, organs cut, bone sawed, like tg). Helper in `aquila/code/modules/surgery_tg/bodypart_surgery_state.dm` |
| Old surgery skeleton removed (`/datum/surgery`, `/datum/surgery_step`, `surgery_initiator`, `GLOB.surgeries_list`, `COMSIG_MOB_SURGERY_STARTED`, `mob/living.surgeries`); the files `code/modules/surgery/*` with old operations and steps, `advanced/**`, `abduction_surgery.dm`, `nsv13/.../surgery_initiator.dm` and `SurgeryInitiator.tsx` are deleted. Comment markers (`AQ EDIT`) where loops over `surgeries` were | `carbon.dm` (`attackby()` removed), `carbon_defense.dm` (`attack_hand()`), `slime.dm` (`attack_hand()`, `attackby()`), `pill.dm` (`attack()`), `organ_internal.dm` (unused `check_for_surgery()` removed), `dismemberment.dm` (`drop_limb()`, `attach_limb()`), `global_lists.dm`, `_globalvars/lists/objects.dm`, `signals_mob.dm`, `living_defines.dm` | New surgery skeleton (`aquila/code/modules/surgery_tg/`, tgstation#93697) replaces every old operation. The base surgery disk, the debug disk (`surgery_unlocks.dm`), `/datum/bioware` with its subtypes (`bioware.dm`, including the old `Destroy()` fix) and `activate_pill` (`operation_dental.dm`) moved to `aquila/` |
| `AddElement(/datum/element/surgery_aid, ...)` instead of `AddComponent(/datum/component/surgery_initiator)` | `code/modules/surgery/tools.dm` (`/obj/item/surgical_drapes/Initialize()`), `code/game/objects/items/bedsheets.dm` (`/obj/item/bedsheet/Initialize()`) | tg surgery aid: drapes and bedsheets toggle the surgery prep of the selected zone (`aquila/code/modules/surgery_tg/surgery_prepped.dm`) |
| Old surgery speed modifiers in `reaction_mob()` replaced by a comment (`AQ EDIT`) | `medicine_reagents.dm` (mine salve), `alcohol_reagents.dm` (ethanol), `food_reagents.dm` (honey), `other_reagents.dm` (sterilizine) | New modifiers (`add_surgery_speed_mod()`) in `aquila/code/modules/surgery_tg/surgery_reagents.dm` |
| `surgery = /datum/surgery/...` values removed from `/datum/design/surgery/*`, `AQ EDIT` on `var/surgery` | `code/modules/research/designs/medical_designs.dm` | The designs hold operation types (`/datum/surgery_operation/...`), set in `aquila/code/modules/research/designs/medical_designs.dm` |
| `get_loaded_operation_ids()` and `add_patient_surgery_data()` in `ui_data()` instead of the old advanced surgery list and the "next step" of `/datum/surgery` | `code/game/machinery/computer/Operating.dm` | New surgery skeleton: the operating computer lists operation types loaded from disks and research, the surgical state of the selected body zone and the operations possible next (tg `operating_computer.dm`). Helpers, zone selection (`change_zone`) and the body zone asset in `aquila/code/game/machinery/computer/operating_computer.dm` |
| `COMP_STATE_*` / `COMP_SECURITY_ARREST_AMOUNT_TO_FLAG` | `code/__DEFINES/wiremod.dm` (end of file) | Wiremod from tg (whole module in `aquila/code/modules/wiremod/`): the security records USB components in `code/game/machinery/computer/security.dm` still use these, tg dropped them with its old records console. The values are the record strings used everywhere else (`"Arrest"`, not the old `"*Arrest*"`), with `Search`/`Monitor` like the console |
| Security records USB components on the tg circuit API (`desc`, `populate_ports()`, option port) | `code/game/machinery/computer/security.dm` | Wiremod from tg: the old `display_desc`/`options`/`input_value` API is gone |
| `COMSIG_CABLE_ADDED_TO_POWERNET`, `COMSIG_CABLE_REMOVED_FROM_POWERNET`, `COMSIG_TURF_CABLE_ADDED_TO_POWERNET` | `code/__DEFINES/dcs/signals/signals_datum/signals_circuit.dm`, sent from `add_cable()`/`remove_cable()` in `code/modules/power/powernet.dm` | Wirenet circuit components (`aquila/code/modules/wiremod/dcs_components/component_wirenet_connection.dm`) follow the cable under the shell; we have one cable layer, so the tg layer buttons are gone |
| Circuit digital valve component on the tg circuit API | `code/modules/atmospherics/machinery/components/binary_devices/valve.dm` | Wiremod from tg |
| `SScircuit_component` replaced by the tg version (instant execution queue) | `code/controllers/subsystem/delay_component.dm` | Wiremod from tg |
| `circuit_click_intercept()` / `circuit_attack_ai()` | `code/_onclick/ai.dm` (`ClickOn()`) | Wiremod from tg: an AI connected to a B.O.R.I.S. MMI component clicks through the circuit (`aquila/code/modules/wiremod/components/action/mmi.dm`) |
| `electronics.apply_circuit_shell(door)` | `code/game/objects/structures/door_assembly.dm` | Wiremod from tg: airlock electronics with the circuit shell option build an airlock shell (`aquila/code/modules/wiremod/usb/misc_objects.dm`) |
| `user?.client` in `captureimage()` | `code/modules/photography/camera/camera.dm` | Wiremod from tg: the polaroid camera as a circuit shell takes pictures without a user |
| "Obudowa układu" checkbox | `tgui/packages/tgui/interfaces/AirlockElectronics.tsx` | Wiremod from tg: airlock electronics circuit shell option |
| `SEND_SIGNAL(fired_from, COMSIG_PROJECTILE_ON_HIT, firer, target, Angle)` in `/obj/item/projectile/proc/on_hit()` (was a misplaced `COMSIG_PROJECTILE_BEFORE_FIRE`) | `code/modules/projectiles/projectile.dm` | Wiremod from tg: the circuit gun outputs (Shooter, Shot Entity, Shot) and `/datum/component/mirv` listen to it on the gun, like in tg |
| `"Arrest"` instead of `"*Arrest*"` in the wanted check of the scanner gate and in the ninja records hack | `code/game/machinery/scan_gate.dm`, `code/modules/antagonists/ninja/ninjaDrainAct.dm` | The records console, sec HUD and secbots use `"Arrest"`; the old value only matched the gate, so the circuit arrest component (now `"Arrest"`) and the gate agree |
| `isturf(loc)` -> `isvalidAIloc(loc)` | `code/modules/mob/living/silicon/ai/ai.dm` (stat panel, mech domination, `can_see()`, `reset_perspective()`), `freelook/eye.dm` (`setLoc()`, `view_core()`), `life.dm`, `multicam.dm`, `Malf_Modules.dm` (`can_place_transformer()`) | Decentralized AI: an AI inside a data core behaves like one standing in its core |
| `AI_MECH_HACK` stores `last_used_data_core` instead of an empty core; `go_out()` calls `ai_return_to_data_core()` | `code/game/mecha/mecha.dm` | Decentralized AI: an AI leaving a mech goes back to a data core through `relocate()` |
| `/client/proc/adventure_manager` in `GLOB.admin_verbs_debug` | `code/modules/admin/admin_verbs.dm` | Admin "Adventure Manager" (Debug) for exploration drone adventures; the verb lives in `aquila/code/modules/explorer_drone/manager.dm` |
| `/datum/admins/proc/ship_structure_admin` in `GLOB.admin_verbs_server` (AQ EDIT line) | `code/modules/admin/admin_verbs.dm` | Admin "Ship Structure" (Server) for the persistent ship structure; the verb and the system live in `aquila/code/modules/persistence/ship_structure.dm` |
| `late_loaders` swapped for a fresh list before the late init loop | `code/controllers/subsystem/atoms.dm`, `InitializeAtoms()` | Overlapping map loads no longer wipe each other's late loaders (stuck sparks and other lateload atoms) |
| `exit_push()` pushes along `pushed.dir` | `code/modules/security/genpop.dm` | Turnstiles on our maps have the free direction pointing out of the brig |
| Opt-in role preferences (`role_preference_enabled()`, the old prefs toggle, no drafting in `get_players_for_role()`) | `code/__DEFINES/role_preferences.dm`, `code/modules/client/preferences.dm`, `code/game/gamemodes/game_mode.dm` | Antagonist roles are off unless the player enables them (`aquila/.../preferences_menu/middleware.dm` matches) |
| `on_drain(drained)` call | `code/game/objects/items/devices/powersink.dm`, `process()` | Aquila power sink APC draining and infiltrator objective |
| `dat += aquila_one_click_antag_links()` | `code/modules/admin/verbs/one_click_antag.dm` | Aquila "Create Antagonist" buttons |
| `ROLE_PARADOX_CLONE` + `antagonist_bannable_roles` entry | `code/__DEFINES/role_preferences.dm` | Paradox Clone (tgstation#71141 port); the define has to be in core because `aquila.dm` is included after the list |
| `ROLE_CHRONO_LEGIONNAIRE` + `antagonist_bannable_roles` entry | `code/__DEFINES/role_preferences.dm` | Chrono Legionnaire midround antagonist; same reason as `ROLE_PARADOX_CLONE` |
| `Destroy()` of `chrono_eraser`, chronosuit helmet and suit | `code/game/objects/items/chrono_eraser.dm`, `code/modules/clothing/spacesuits/chronosuit.dm` | Bugfix for the Chrono Legionnaire gear: they called `dropped()` without a user and runtimed on every delete |
| `ANTAG_HUD_PARADOX_CLONE` (33) + `GLOB.huds` entry | `code/__DEFINES/atom_hud.dm`, `code/datums/hud.dm` | Paradox Clone HUD; must stay the next index after `ANTAG_HUD_VAMPIRE` |
| `paradox_clone` icon state | `icons/mob/hud.dmi` | Paradox Clone HUD icon, copied from tgstation's `antag_hud.dmi` |
| `GAS_MIASMA` define | `code/__DEFINES/atmospherics.dm` | Miasma (restores what BeeStation-Hornet#6445 removed, reworked around `SSmiasma`); in core because the core gas lists below use it |
| `GAS_MIASMA` list entries | `code/modules/atmospherics/machinery/airalarm.dm` (3 TLV lists, scrubbing/contaminated/refill filters), `components/unary_devices/vent_scrubber.dm` (default `filter_types`), `portable/canister.dm` (label list), `mob/living/simple_animal/bot/atmosbot.dm` (gases to scrub) | Miasma alarms, scrubbing and canister relabelling. Scrubbers filter it by default so it doesn't build up |
| `handle_miasma_breath()` call | `code/modules/surgery/organs/lungs.dm`, `check_breath()` | Miasma breath effects (`aquila/code/modules/miasma/miasma_breath.dm`); the only breath path that handles miasma |
| `handle_pollution_breath()` call | `code/modules/surgery/organs/lungs.dm`, `check_breath()` | Smoke and smells (Monke pollution, `aquila/code/modules/pollution/pollution_mob.dm`): breathe_act and passive smelling once a minute |
| `update_adjacent_pollutants()` call | `code/modules/atmospherics/environmental/LINDA_system.dm`, `ImmediateCalculateAdjacentTurfs()` | Pollution next to a tile whose atmos adjacency changed (opened door, broken wall) starts spreading again |
| Perfume box, scented candle pack, air refresher in vendor lists | `code/modules/vending/clothesmate.dm`, `wardrobes.dm` (JaniDrobe, ChapDrobe) | Sources of perfumes and scented candles, air refresher for janitors (`aquila/code/modules/pollution/smells/`) |
| Orlen caps in EngiDrobe and AtmosDrobe | `code/modules/vending/wardrobes.dm` | Engineering in Orlen colours (`aquila/code/modules/orlen/orlen.dm`) |
| Security and engineering sprites replaced in place | `icons/obj/clothing/*.dmi`, `icons/mob/clothing/*.dmi`, `icons/mob/{eyes,mask,neck,hud}.dmi`, `icons/obj/{closet,vending,storage,radio,device}.dmi`, `nsv13/icons/obj/{card,pda}.dmi`, `nsv13/icons/{obj,mob}/clothing` uniforms and hats | Żandarmeria (green), Orlen (red) and InPost (yellow) sheets; same state names, so every type using them changes. Security was already Police navy in place before. |
| `ROLE_THIEF` + `antagonist_bannable_roles` entry | `code/__DEFINES/role_preferences.dm` | Thief (tgstation#64144 port); same reason as `ROLE_PARADOX_CLONE` |
| `ANTAG_HUD_THIEF` (34) + `GLOB.huds` entry | `code/__DEFINES/atom_hud.dm`, `code/datums/hud.dm` | Thief HUD; must stay the next index after `ANTAG_HUD_PARADOX_CLONE` |
| `ROLE_HORROR` + `antagonist_bannable_roles` entry, `ishorror()` | `code/__DEFINES/role_preferences.dm`, `code/__DEFINES/is_helpers.dm` | Eldritch Horror (Yogstation#13033 port); in core for the same reason as `ROLE_PARADOX_CLONE`, and `ishorror()` is used by `death.dm` |
| Horror hooks (`has_horror_inside()` checks) | `scanners.dm` (`healthscan()`, advanced), `suicide.dm` (`canSuicide()`), `death.dm` (`gib()`), `brain_item.dm` (`Remove()`), `human.dm` (`get_stat_tab_status()`), `transform_procs.dm` (`monkeyize()`), `gun.dm` (`handle_suicide()`), `organ_manipulation.dm` (`preop()`/`success()` extract), `changeling/powers/headcrab.dm`, `changeling/powers/panacea.dm` | Eldritch Horror: detection, surgical removal, no suicide/self-shot/monkeyize while infested, eject on brain removal, headslug and panacea |
| `/mob/living/simple_animal/horror`, `/obj/item/horrortentacle` in phobia typecaches | `code/controllers/subsystem/traumas.dm` | Eldritch Horror ("the supernatural" mobs and objects, "anime" objects) |
| `horror.txt` | `strings/names/` | Eldritch Horror names (`GLOB.horror_names`); in core `strings/` for the same reason as `thief_flavor.json` |
| `amount` var on `/datum/objective/steal_five_of_type` | `code/game/gamemodes/objective.dm` | Replaces the hardcoded 5 in both `check_completion()`s (default stays 5), so the thief guns/organs objectives can ask for a different count |
| `thief`, `hoard`, `hoarder_circle` icon states | `icons/mob/hud.dmi`, `icons/mob/actions/actions_minor_antag.dmi`, `icons/mob/telegraphing/telegraph.dmi` | Thief HUD icon, "declare hoard" action and hoard marker, copied from tgstation |
| `thief_flavor.json` | `strings/` | Thief flavor texts; lives in core `strings/` because `tools/deploy.sh` only ships that folder and `strings()` strips `/` from file names |
| `spy_objective.json` | `strings/` | Spy objective flavor texts (port of tgstation `strings/antagonist_flavor/spy_objective.json`); core `strings/` for the same reason as `thief_flavor.json` |
| `squid_male.txt`, `squid_female.txt` | `strings/names/` | Squidperson first names (`GLOB.squid_names_*`); core `strings/` for the same reason as `thief_flavor.json` |
| `standing += H.get_tears_overlays()` / `add_overlay(get_tears_overlays())` | `code/modules/mob/living/carbon/human/species.dm` (`handle_body()`), `code/modules/mob/living/carbon/human/update_icons.dm` (`update_body_parts_head_only()`) | Łzy po `*cry` (Yogstation#15690 port), drawn right after the eyes overlay |
| Custom landing link in `ui_interact()` + `designate` branch in `Topic()` | `nsv13/code/modules/shuttle/computer.dm` | Custom shuttle / bluespace pod landing spot; the var and procs are in `aquila/code/modules/shuttle/computer.dm` |
| `TRAIT_EAT_MORE`, `TRAIT_GENELESS` defines; `TRAIT_GENELESS` check in `add_mutation()`; `TRAIT_EAT_MORE` hunger multiplier | `code/__DEFINES/traits.dm`, `code/datums/dna.dm`, `code/modules/mob/living/carbon/human/species.dm` | Sinful demons (Yogstation sync); the defines are in core because core procs use them |
| `aquila_monkey_spat()`, `aquila_monkey_sucked()`, `aquila_potion_spat()` calls, `balloon_alert()`s | `code/modules/research/xenobiology/xenobio_camera.dm` (actions and click handlers, each path twice) | Xenobio tubes and HUD (tgstation#90775 port). The "now has N monkeys" chat lines were replaced by the HUD. Slime pickup/place needs no hook: `aquila/.../xenobio_tubes.dm` reacts in `Entered()`/`Exited()` |
| `aquila_shell_hidden()` call in the Windows branch of `world.shelleo()` | `code/__HELPERS/shell.dm` | Runs shell commands through a hidden `wscript` launcher so the host doesn't get a cmd window (e.g. jukebox yt-dlp calls); falls back to plain `shell()`. The proc is in `aquila/code/__HELPERS/shell.dm` |
| `audio/setMusicGain` message + `gain` multiplier (`volume` option of `audio/playMusic`) | `tgui/packages/tgui-panel/audio/{player,middleware}.js` | Jukebox YouTube music gets quieter with distance; DM side is `/datum/tgui_panel/proc/set_music_gain()` in `aquila/code/modules/tgui_panel/audio.dm` |
| Health HUD without stamina (`if(..())` instead of `min(health, maxHealth - getStaminaLoss())`) | `code/modules/mob/living/carbon/human/human.dm`, `update_health_hud()` | Stamina HUD (BeeStation#11521 port, `aquila/code/_onclick/hud/stamina.dm`); stamina has its own indicator now |
| Chat message cleanup in `/atom/Destroy()` (AQ EDIT block) + `code/datums/chatmessage.dm` brought to BeeStation#12193 (grouped, non-sleeping runechat) | `code/game/atoms.dm`, `code/datums/chatmessage.dm` | Runechat grouping port. `chatmessage.dm` is patched as a whole, without markers; when syncing with upstream, diff it against BeeStation's version of that PR instead of the NSV13 one |
| `CHAT_DISABLE_LOOC_RUNECHAT` (chat_toggles bit 13), LOOC runechat block in `/client/verb/looc()`, `looc` prefix in `/datum/chatmessage/proc/generate_image()` | `code/__DEFINES/preferences.dm`, `code/modules/client/verbs/looc.dm`, `code/datums/chatmessage.dm` | LOOC above heads (BeeStation#12918 port); the toggle verb is `toggle_looc_runechat()` in `aquila/code/modules/client/preferences_toggles.dm` |
| Screentips (BeeStation#11938 port, `aquila/code/modules/screentips/`): `..()` in `MouseEntered()` overrides that skipped it; `PREFTOGGLE_2_DISABLE_SCREENTIPS` (last free toggles2 bit); `COMSIG_ATOM_ADD_CONTEXT`; `screentip_verb` on `/datum/element/processable`; `.small-icon` and bigger `.reallybig`/`.extremelybig` in the map style | `code/game/objects/items.dm`, `code/_onclick/hud/{action_button,alert,blob_overmind,ghost,screen_objects}.dm`, `code/__DEFINES/preferences.dm`, `code/__DEFINES/dcs/signals/signals_atom.dm`, `code/datums/elements/food/processable.dm` (+ uncommented `screentip_verb` in `items/food/*.dm`), `interface/skin.dmf` | `/atom/MouseEntered()` itself lives in `aquila/code/modules/screentips/atom_extensions.dm` |
| Ghost role polls through `SSpolling` (BeeStation#12738/#13722 port): `pollGhostCandidates()`/`pollCandidates()`/`pollCandidatesForMob(s)()` rewritten as wrappers and `showCandidatePollWindow()` removed (AQ EDIT block); `timeout_override`/`no_anim` on `throw_alert()`; `POLL_AUTO_ADD_*` defines | `code/__HELPERS/game.dm`, `code/_onclick/hud/alert.dm`, `code/__DEFINES/role_preferences.dm` | Subsystem, poll datums and the alert live in `aquila/code/controllers/subsystem/polling.dm`, `aquila/code/datums/polls/`, `aquila/code/_onclick/hud/poll_alert.dm`. Old call signatures are kept, so the 67 existing callers did not change |
| TGUI on React (BeeStation#12204 and the TGUI updates around it): `tgui/` is BeeStation's tree with our interfaces converted from Inferno, `code/modules/tgui/tgui.dm` and `tgui_window.dm` taken from BeeStation (layout prefs, `tgui_lock` pref, `icon_ref_map` and batched spritesheets left out), `SStgui` injects `tgui-setup` helpers instead of polyfills, `tgui_max_chunk_count` config entry, flat `large_buttons`/`swapped_buttons` in the input modals | `code/modules/tgui/`, `code/controllers/subsystem/tgui.dm`, `code/__DEFINES/tgui.dm`, `code/controllers/configuration/entries/general.dm`, `code/modules/tgui_input/{alert,list,number,text}.dm`, `tgui/`, `tools/bootstrap/node*`, `dependencies.sh` (Node 22) | Our tgui changes kept on top of BeeStation's: jukebox player (`tgui-panel/audio/player.js`, `audio/setMusicGain`), chat storage throttling on 516, auto-reconnect after a round restart or a lost connection (`tgui-panel/game/{middleware.js,constants.ts}`), longer asset retries in `tgui-setup/helpers.js`, themes `dominion`/`hackeros`, NSV components `Map`/`StarButton` and the deprecated `Grid`, curried `common/collections` helpers. When syncing tgui with BeeStation, re-apply these |
| Chat reliability from BeeStation: every chat message is a `/datum/chat_payload` with a sequence number (the React chat panel drops anything else) and the panel asks for missing ones with `chat/resend`; the first sequence starts at 0 instead of Bee's null | `code/controllers/subsystem/chat.dm`, `code/modules/tgchat/to_chat.dm`, `code/__DEFINES/chat.dm`, `code/modules/tgui_panel/tgui_panel.dm`, `aquila/code/datums/chat_payload.dm` | Chat panel message types also keep our old radio/admin log classes, since our server does not add Bee's `srt_*` classes (`tgui-panel/chat/constants.ts`) |
| Chat panel DM side from BeeStation: admin music sends duration/artist/album/upload date for the Now Playing widget and hides them on "No" (#9249); stat panel groups the same items on a tile with tags for sorting, admin buttons check rights, tickets get a Claim button (#9655); time to reboot in the Status tab (#13727, Reboot() still sleeps, it only records `reboot_at`); blood brother and carp wavespeak chat use theme classes instead of hex colors (#9908); cult colors in the old stylesheet (#12325) | `code/modules/admin/verbs/playsound.dm`, `code/modules/mob/mob_stat.dm`, `code/modules/admin/verbs/adminhelp.dm`, `code/controllers/subsystem/ticker.dm`, `code/__DEFINES/colors.dm`, `code/game/objects/items/implants/implant_bb.dm`, `code/modules/antagonists/brother/brother.dm`, `code/modules/mob/living/simple_animal/hostile/space_dragon.dm`, `interface/stylesheet.dm` | New procs in `aquila/code/modules/mob/mob_stat.dm`; the panel frontend for these came with the BeeStation `tgui/` tree |
| Orbit panel from BeeStation #9034: collapsible sections, antag HUD icons, team names, generic theme; refreshes when the target is gone | `code/modules/mob/dead/observer/orbit.dm`, `tgui/packages/tgui/interfaces/Orbit.jsx` | `antag-hud` spritesheet in `aquila/code/modules/mob/dead/observer/orbit.dm` (cropped from our `icons/mob/hud.dmi`) |
| `onChangeAmount={(value) => …}` instead of `(e, value)` | `tgui/packages/tgui/interfaces/ChemMaster.tsx`, `AutoInjectorPrinter.tsx` | tgui-core `NumberInput` calls `onChange(value)`; the old two-argument handlers stored `undefined` in the machine's shared state and every later open crashed on `value.toString()` |
| Crew manifest in TGUI from BeeStation #9836: lobby, ghost and silicon manifest open the `CrewManifest` window instead of an HTML table; `get_manifest()` entries carry the job HUD icon | `code/datums/datacore.dm`, `code/modules/mob/dead/new_player/new_player.dm`, `code/modules/mob/dead/observer/observer.dm`, `code/modules/mob/living/silicon/silicon.dm`, `tgui/packages/tgui/interfaces/CrewManifest.tsx`, `tgui/packages/tgui/styles/colors.scss` (Munitions color) | `/datum/crew_manifest` in `aquila/code/modules/mob/dead/crew_manifest.dm` builds Bee's data from our department HUD lists; `get_manifest_html()` stays for NtOS printing |
| Latejoin job selection in TGUI: `LateChoices()` opens the `JobSelection` window (departments, slots, job HUD icons, greyed-out roles with the reason) instead of the yogs HTML table; `close_spawn_windows()` closes it | `code/modules/mob/dead/new_player/new_player.dm` | `/datum/latejoin_menu` in `aquila/code/modules/mob/dead/new_player/latejoin_menu.dm`; picking a job goes through the old `SelectedJob` Topic branch, so queue and popcap checks are unchanged |
| Station goals without the intercept report: one combined announcement and one printed report instead of a separate announcement per goal | `code/game/gamemodes/game_mode.dm` (`post_setup()`) | `send_station_goals_report()` in `aquila/code/game/gamemodes/station_goals.dm` |
| Language menu window from BeeStation #13895 (only the UI, not the random names or station trait): one list of all languages with `can_speak`/`could_speak`/`can_understand`, the window hides unknown ones outside admin mode | `code/modules/language/language_menu.dm` (`ui_data`), `tgui/packages/tgui/interfaces/LanguageMenu.tsx` | Language icons come through `icon_ref_map` |
| Antag info windows from BeeStation #9205: every antag gets an "Informacje o roli" action that opens its window, opened on gain (not when silent); default `ui_name` is `AntagInfoGeneric`; traitor's HTML tips replaced by the window, codewords stay in chat and notes | `code/modules/antagonists/_common/antag_datum.dm` (`ui_name`, `info_button_ref`, `on_gain`, `on_body_transfer`, `on_removal`, `optional` in objectives), `code/modules/antagonists/traitor/datum_traitor.dm` (`show_tips`), `tgui/packages/tgui/interfaces/AntagInfo*.tsx` | Action and per-antag data in `aquila/code/modules/antagonists/_common/antag_info.dm` and `antag_info_windows.dm` (sets `tips = null` for antags with their own window); extra pictures in `aquila/html/img` |
| TGUI changelog from BeeStation #12236: the Changelog verb opens the `Changelog` window, which loads `html/changelogs/archive/YYYY-MM.yml`; `ss13_genchangelog.py` now also writes those monthly files from `.all_changelog.yml` (CI already commits `html/changelogs`); `tools/deploy.sh` ships the monthly files; header shows our project instead of BeeStation | `interface/interface.dm`, `tools/changelog/ss13_genchangelog.py`, `tools/deploy.sh`, `html/changelogs/archive/`, `tgui/packages/tgui/interfaces/Changelog.tsx` | `/datum/changelog` and `/datum/asset/changelog_item` in `aquila/code/datums/changelog/changelog.dm`; `changelog.html` stays for `GLOB.changelog_hash` |
| `icon_ref_map` from BeeStation: every TGUI window gets a JSON map of .dmi paths to resource refs, used by the `DmIcon` component | `code/modules/tgui/tgui.dm` (`send_assets`) | `/datum/asset/json` and `/datum/asset/json/icon_ref_map` in `aquila/code/modules/asset_cache/json.dm`; stage 4 test in `aquila/code/modules/unit_tests/aquila_bee_windows.dm` |
| Vending window from BeeStation #13072: grid/list layout, categories (Produkty, Premium, Contraband), item icons through DmIcon, stock as objects; our same-department discount added to the Bee window; grid/list choice remembered per session until Preferences Redux | `code/modules/vending/_vending.dm` (`ui_static_data`, `ui_data`, custom vendor `image`), `code/modules/tgui/tgui.dm` (`layout`), `code/modules/tgui/external.dm` (`change_ui_state`), `tgui/packages/tgui/interfaces/Vending.tsx`, `tgui/packages/tgui/interfaces/common/LayoutToggle.tsx` | `layout_prefs_used` and the session store in `aquila/code/modules/tgui/layout.dm` |
| Smartfridge sprites and window from BeeStation #13072 (no weld-down/frame mechanics, our type paths kept): new `smartfridge.dmi` with contents levels per fridge type, glass, light and broken states, new drying rack sprite; `SmartVend` window with grid/list and item icons, items released by a type-name key | `code/modules/food_and_drinks/kitchen_machinery/smartfridge.dm` (icons, `update_icon_state`/`update_overlays`, `ui_data`, `ui_act`), `tgui/packages/tgui/interfaces/SmartVend.tsx` | Sprite file in `aquila/icons/obj/smartfridge.dmi`; the stormdrive prop and survival pod storage keep their own icons |
| Holopad from BeeStation #14515, built on our older holopad code: TGUI `Holopad` window replaces the HTML menu and `Topic()`; heads of staff (keycard auth access) connect to other pads without them answering; `/obj/machinery/holopad/secure` refuses that, its board toggles with a multitool; head of staff offices, MAA office and AI areas on our maps got secure pads | `code/game/machinery/hologram.dm`, `code/datums/holocall.dm` (`head_call`), `code/game/objects/items/circuitboards/machine_circuitboards.dm`, `_maps/` (95 pads), `tgui/packages/tgui/interfaces/Holopad.tsx` | Bee's full rewrite was not taken, it needs newer APIs (combat mode, `span_*`, `set_anchored`, prefs) |
| Votes from BeeStation #13247: `SSvote` rewritten around `/datum/vote` singletons and the `VotePanel` window (admins can end votes early, reset the cooldown, toggle dead votes, call custom single/multi choice votes); our restart, transfer, gamemode, map, round extension and hardmode votes keep their non-voter rules; the map vote keeps the NSV13 `MapVote` window, preferred maps and map vote bans (no persistent tallies from Bee) | `code/controllers/subsystem/vote.dm`, `code/__DEFINES/subsystems.dm`, `code/controllers/subsystem/autotransfer.dm`, `code/controllers/subsystem/shuttle.dm`, `code/__HELPERS/roundend.dm`, `nsv13/code/controllers/subsystem/overmap_mode.dm`, `nsv13/code/controllers/subsystem/map_vote.dm`, `tgui/packages/tgui/interfaces/VotePanel.tsx`, `MapVote.tsx` | Vote datums in `aquila/code/datums/votes/`, sounds in `aquila/code/controllers/subsystem/vote.dm`, test `aquila_votes` |
| Techfab/protolathe/circuit imprinter window from BeeStation #14723: the `Fabricator` window with Bee's design browser (category tree, search, material bar, reagent bar), orders up to x50; our design categories are kept as they are (Bee also re-categorized every design) | `code/modules/research/machinery/_production.dm`, `tgui/packages/tgui/interfaces/Fabricator.tsx`, `tgui/packages/tgui/interfaces/Fabrication/`, removed `TechFab` window | Design and material data in `aquila/code/modules/research/fabricator_ui.dm` |
| Autolathe and exosuit fabricator windows from BeeStation #14723: `ModularFabricator` (design browser + queue, security panel, data disk) and `ExosuitFabricator` (one row per queued item, Queue All per category) on our modular fabricator; new queue actions (`build`, `build_queue`, `stop_queue`, `del_queue_part`, `remove_mat`); our exosuit fabricator keeps its R&D sync, as a button added to the Bee window | `code/game/machinery/fabricators/modular_fabricator.dm`, `code/game/machinery/fabricators/exosuit_fab.dm`, `tgui/packages/tgui/interfaces/ModularFabricator.tsx`, `ExosuitFabricator.tsx` | Shared helpers in `aquila/code/modules/research/fabricator_ui.dm` |
| Newscaster from BeeStation #7779 (current BeeStation version): TGUI `PhysicalNewscaster`/`NtosNewscaster` windows with the bounty board, TGUI admin newscaster, newscaster NtOS program on the job disk; the old `code/game/machinery/newscaster.dm` and the HTML admin newscaster (`access_news_network` in admin.dm, `ac_*` hrefs in topic.dm, `admincaster_*` vars in holder2.dm) are gone; `news_network` procs renamed (`submit_article`, `create_feed_channel`, `/datum/feed_*`); map paths `directional/*` and `security_unit/*` kept | `code/modules/admin/admin.dm`, `code/modules/admin/topic.dm`, `code/modules/admin/holder2.dm`, `code/__HELPERS/roundend.dm`, `code/__HELPERS/priority_announce.dm`, `code/game/machinery/requests_console.dm`, `code/modules/crew_objectives/civilian_objectives.dm`, `code/modules/library/lib_machines.dm`, `code/modules/modular_computers/hardware/job_disk.dm`, `code/__DEFINES/devices.dm` (`DISK_NEWSCASTER`), `nsv13.dme`, `tgui/packages/tgui/interfaces/{Newscaster,PhysicalNewscaster,NtosNewscaster,BountyBoard}.jsx` | The newscaster code itself lives in `aquila/code/game/machinery/newscaster/`, `aquila/code/modules/admin/verbs/admin_newscaster.dm` and `aquila/code/modules/modular_computers/file_system/programs/newscaster.dm`, translated to our API |
| Crafting menu from BeeStation #12485: the personal crafting component moved to aquila/ (BeeStation version: crafting and cooking modes, "Can Make", mass crafting, required tools/machines/structures, guide recipes and food from chemical reactions); our recipe files are unchanged, `aquila_setup()` maps old two-level categories, `tools` and `always_available` to the new fields; stack recipes (sheets, rods, wood...) are listed in the menu too; `CAT_ROBOT` is "Robotics" | removed `code/datums/components/crafting/crafting.dm` from `nsv13.dme`, `code/__HELPERS/global_lists.dm` (`aquila_init_crafting_recipes()`), `code/__DEFINES/construction.dm`, `code/__DEFINES/misc.dm` (`STACK_CHECK_*` as bitflags), `tgui/packages/tgui/interfaces/PersonalCrafting.tsx` | `aquila/code/datums/components/crafting/` (component, recipes_bee.dm, recipes_guide.dm), `aquila/code/__DEFINES/crafting.dm`; the drinking glass appearance part of the PR (takes_reagent_appearance) was not taken |
| Preferences window from BeeStation #8776 (Preferences Redux): the TGUI `PreferencesMenu` (character page with preview and icon buttons, occupations with a Munitions department, loadout shop, antagonists, quirks, game settings, keybindings) replaces the HTML `ShowChoices` menu. Storage is unchanged: every `/datum/preference` reads and writes our existing vars (`active_character`, `features`, `toggles`/`toggles2`/`chat_toggles` bits, `/datum/preferences` vars), saving is still `active_character.save()` and `save_preferences()`; no new database tables or migration | `code/modules/mob/dead/new_player/new_player.dm` (lobby "Setup Character" opens `open_character_menu()`), `code/modules/client/preferences_toggles.dm` (`setup_character` verb opens `open_game_menu()`), `tgui/packages/tgui/interfaces/PreferencesMenu/` | `aquila/code/modules/client/preferences_menu/`, `aquila/code/__DEFINES/preferences_menu.dm`; the old `ShowChoices`/`process_link` code in `code/modules/client/preferences.dm` is left in place but no longer opened |
| `/obj/machinery/jukebox/nukie` placed in the ready room, tile (9,18) | `_maps/shuttles/infiltrator/infiltrator_basic.dmm` | Syndicate speaker for nuke ops (`aquila/code/game/machinery/jukebox_nukie.dm`) |
| Samouczek (rdzeń z cmss13-devs/cmss13#5030, `aquila/code/modules/tutorial/`): `aquila_tutorial_first_connection()` przy pierwszym połączeniu w `client/New()`; `PREFERENCE_TAG_COMPLETED_TUTORIALS` ("30") z odczytem i zapisem JSON w `preferences2.dm` | `code/modules/client/client_procs.dm`, `code/__DEFINES/preferences.dm`, `code/modules/client/preferences2/preferences2.dm` | Tag 30 jest nasz (29 zajął wybór modsuitu); przy merge'u z upstreamem sprawdzić, czy Bee nie zajął tego numeru. Przycisk „Samouczek” jest w oknie `LobbyMenu.tsx` (akcja `tutorial` obsłużona w `aquila/code/modules/tutorial/lobby.dm`), menu, propozycja i zmienna `completed_tutorials` są w `aquila/` |
| Koło emotek (`aquila/code/modules/emote_panel/emote_wheel.dm`): `PREFERENCE_TAG_QUICK_EMOTES` ("32") z odczytem i zapisem JSON w `preferences2.dm` | `code/__DEFINES/preferences.dm`, `code/modules/client/preferences2/preferences2.dm` | Tag 32 jest nasz; przy merge'u z upstreamem sprawdzić, czy Bee nie zajął tego numeru |
| Siatka ekwipunku (`aquila/code/datums/keybinding/storage_grid.dm`): `PREFERENCE_TAG_KEYBIND_MIGRATIONS` ("33") z odczytem i zapisem JSON w `preferences2.dm`, lista jednorazowych migracji keybindów | `code/__DEFINES/preferences.dm`, `code/modules/client/preferences2/preferences2.dm` | Obrót E/Q dopisuje się do zapisanych keybindów raz; bez zapisanej migracji skrót odpięty przez gracza wracał przy każdym logowaniu. Tag 33 jest nasz, przy merge'u z upstreamem sprawdzić numer |
| Zlecenia amunicji w konsoli zleceń cargo (`aquila/code/modules/cargo/civilian_bounty/nsv_bounties.dm`): przypadek 14 w `random_bounty()` i `/datum/bounty/item/munitions = 2` w `setup_bounties()` | `code/modules/cargo/bounty.dm` | Tam też siedzi przypadek 13 bitrunningu |
| Działo Gaussa: werb „Access gun camera” zamieniony na proc `show_view(user)`, a kamera i wyjście z działa to przyciski akcji strzelca „Kamera działa” i „Wyjdź z działa” (`aquila/code/modules/munitions/gauss_gunner_actions.dm`, nadpisania `set_gunner()`/`remove_gunner()` z `..()`); werb „Access internal computer” przetłumaczony na „Panel działa”. Okno konsoli działa (`MunitionsComputer`) i automatu składu (`SquadVendor`) oraz nazwy i opisy zestawów składu przetłumaczone | `nsv13/code/modules/munitions/ship_weapons/ballistic_weapons/gauss_gun.dm`, `nsv13/code/modules/squads/squad_vendor.dm`, `tgui/packages/tgui/interfaces/MunitionsComputer.tsx`, `tgui/packages/tgui/interfaces/SquadVendor.tsx` | Prośba przy samouczku (lekcja Alarm bojowy używa przycisków akcji); tłumaczenie to klasa D |
| `auxmos_cleanup()` calls in `/world/Reboot()` and `/world/Del()`; `/proc/__auxmos_reset()` binding | `code/game/world.dm`, `code/__DEFINES/bindings.dm` | Patched `auxmos.dll` that survives soft reboots; the proc is in `aquila/code/game/world.dm`, the DLL patch in `tools/auxmos/` |
| `request_watchdog_restart()` call in `/world/Reboot()` | `code/game/world.dm` | BYOND 516 soft reboot hangs for minutes; under `server_watchdog.bat` / `server_watchdog.sh` the world leaves a marker and the watchdog restarts DreamDaemon. The proc is in `aquila/code/game/world.dm` |
| `return aquila_random_unique_name()`, old body commented out (AQ EDIT block) | `code/__HELPERS/mobs.dm`, `random_unique_name()` | Random names with a surname matching the gender (global procs can't be overridden in DM); proc in `aquila/code/__HELPERS/names.dm` |
| `laser_eyes/on_ranged_attack()` signature + eye damage (AQ EDIT block) | `code/datums/mutations/sight.dm` | Laser Eyes received the click params instead of the target and runtimed (aq33/AquilaStation#461) |
| Hydration check lets `TRAIT_NOTHIRST` mobs regenerate blood | `code/modules/mob/living/blood.dm`, inside the existing AQ EDIT block | Thirst (aq33/AquilaStation#461) |
| Hitsplatter `GoTo()` through `INVOKE_ASYNC`, no debug `message_admins` | `code/modules/mob/living/carbon/human/species.dm` (existing AQ EDIT block), `code/modules/projectiles/projectile/bullets.dm` | Blood splatter doesn't sleep in the attack chain (aq33/AquilaStation#461) |
| `QDELETED(target)` guard in `shock_drop()` | `code/modules/flufftext/Hallucination.dm` | The shock hallucination timer fired on a deleted mob in unit tests (`null.species` in `Paralyze()`) |
| Bullet blood splatter range `rand(1, clamp(round(damage / 15), 1, 3))` instead of `rand(1,7)` | `code/modules/projectiles/projectile/bullets.dm`, `process_hit()` | Splatter strength follows the damage (shiptest-ss13/Shiptest#3239); window and wall stains in `aquila/code/modules/mob/living/blood_effects.dm` |
| `aq_try_blood_trail(T, old_direction)` instead of the lying-only `makeTrail()` call in `/mob/living/Move()` (AQ EDIT block) | `code/modules/mob/living/living.dm` | tg blood trails (`make_blood_trail()`, joined half/straight/corner pieces in a `trail_holder`), also left by walking while bleeding over `BLEED_CUT`; non-blood mobs (xenos) keep `makeTrail()`. Code in `aquila/code/modules/mob/living/blood_trails.dm`; sprites in `aquila/icons/effects/blood_trails.dmi` are our trails from `icons/effects/blood.dmi` with the half pieces (`*_start`, 8 dirs) cut out of them, straight diagonal pieces are stretched by sqrt(2) to join |
| `drop.add_drip(src)` instead of `drips++` + `add_overlay()` in `add_splatter_floor()` | `code/modules/mob/living/blood.dm` | Each further drop is its own decal in the first drop's `vis_contents` (tg), so it keeps its own colour and drying |
| `AQ_DAMAGE_OVERLAY_ICON` define; brute/burn overlays use it and add the untinted `*_overlay` bruise state over the blood-tinted brute state (AQ EDIT lines/block) | `code/__DEFINES/mobs.dm`, `code/modules/mob/living/carbon/update_icons.dm` (`update_damage_overlays()`), `code/modules/surgery/bodyparts/bodyparts.dm` (`get_limb_icon()`, dropped limbs) | tg damage overlays: `aquila/icons/mob/effects/dam_mob.dmi` is our `icons/mob/dam_mob.dmi` with the human brute states (greyscale, still tinted with the blood colour) and their `_overlay` bruise states from tgstation `icons/mob/effects/dam_mob.dmi` (CC-BY-SA 3.0); burn, monkey and robotic states stay ours. `icons/mob/dam_mob.dmi` is no longer used |
| `WOUND_LAYER` 31, `TOTAL_LAYERS` 30 -> 31 | `code/__DEFINES/misc.dm` | tg bleeding overlays on the body (`aquila/code/modules/mob/living/carbon/bleed_overlays.dm`, `aquila/icons/mob/effects/bleed_overlays.dmi` from tgstation, CC-BY-SA 3.0). The index is new, the overlay is drawn at `BODY_FRONT_LAYER - 0.5` (above hands, like tg); zones come from `aq_limb_bleed` (tourniquet.dm), the rest on the chest |
| Exploding implants don't merge a non-engineering implant into `/obj/item/implant/explosive/engineering` | `code/game/objects/items/implants/implant_explosive.dm`, `implant()` | CE punishment implant keeps a traitor's microbomb separate (aq33/AquilaStation#461) |
| `COMSIG_GLOB_STROMDRIVE_EXPLOSION` sends the reactor | `nsv13/code/modules/power/stormdrive.dm`, `code/__DEFINES/dcs/signals/signals_global.dm` | CE implant only reacts to its own ship's stormdrive (aq33/AquilaStation#461) |
| `return` after handing out a non-nullrod holy weapon | `code/game/objects/items/holy_weapons.dm` | Exorcist shotgun has no `reskinned` var (aq33/AquilaStation#461) |
| RD suit storage unit holds the HEV suit instead of the research MODsuit | `code/game/machinery/suit_storage_unit.dm` | HEV from the 2024 changelog (aq33/AquilaStation#461) |
| Szafy na skafandry kapitana, CentComu, inżynierii, CE, HoS-a, medyczna, CMO, Syndykatu i ładowacza trzymają hardsuity z modułami (`suit_type = ...` z `// AQ EDIT`), obsługa MOD-ów (`mod`, `mod_type`, slot w radialu) usunięta; ładowanie ogniwa i uzupełnianie butli hardsuitu w `aquila/code/game/machinery/suit_storage_unit.dm` | `code/game/machinery/suit_storage_unit.dm` | MODsuity usunięte, moduły przeniesione na hardsuity (`aquila/code/modules/clothing/spacesuits/hardsuit_modules.dm`, warianty w `hardsuit_variants.dm`) |
| Deck technician job card uses the `munitech` state | `code/game/objects/items/cards_ids.dm` | `decktechnician` state doesn't exist in `nsv13/icons/obj/card.dmi` |
| Mouse modifiers passed to `preparePixelProjectile()` only when not empty | `code/modules/projectiles/ammunition/_firing.dm`, `throw_proj()` | `params2list(null)` is an empty list, which is true, so a living shooter without mouse data (NPCs without a client, the pulse demon firing a hijacked gun) aimed at angle 0 and shot north. Test: `aquila_gun_fire_without_params` |
| `[ssd_examine_text()]` in the blank stare line | `code/modules/mob/living/carbon/human/examine.dm` | SSD indicator (Monkestation2.0 port): how many minutes the player has been gone; logic in `aquila/code/modules/mob/living/ssd_indicator.dm` |
| `explode_on_destruction` var, checked in `Destroy()` | `code/modules/vehicles/sealed.dm` | VIM (tg + Monkestation2.0) does not explode when destroyed; `aquila/code/modules/vehicles/cars/vim.dm` |
| `!dest || !get_turf(H)` guard before `get_path_to()` | `nsv13/code/modules/overmap/knpc.dm` (`pathfind_to()`) | Boarders whose target (or themselves) is in nullspace, e.g. during a test chamber reset, no longer hit "Invalid A* start or destination" (flaky `test_chamber` unit test) |
| `QDELETED` guards after the shot and `call_backup()`, and per boarder inside `call_backup()` | `nsv13/code/modules/overmap/knpc.dm` (`engage_targets/action()`, `call_backup()`) | Shooting, `say()` and `pathfind_to()` can sleep; when the test chamber reset deletes boarders meanwhile, the AI no longer reads `dna`/`ears` of a deleted mob (flaky `test_chamber` unit test on slow CI) |
| `QDELETED(src)` guard at the start of `ai_lose_power()` | `code/modules/mob/living/silicon/ai/life.dm` | An AI deleted mid-tick (test chamber reset) no longer queues `start_RestorePowerRoutine` on itself ("addtimer called with a callback assigned to a qdeleted object") |
| `lampButton?.update_icon()` in `toggle_headlamp()` | `code/modules/mob/living/silicon/robot/robot.dm` | A cyborg being deleted has no lamp button left ("Cannot execute null.update icon()" in the `test_chamber` unit test) |
| `/obj/item/citationinator` in Deputy, Security Officer and NSV13 security (`/datum/outfit/job/security`, the outfit the job actually uses) `backpack_contents` | `code/modules/jobs/job_types/deputy.dm`, `code/modules/jobs/job_types/security_officer.dm`, `nsv13/code/modules/jobs/job_types/marine/military_police.dm` | Citationinator (Monkestation2.0 port), `aquila/code/modules/security/citationinator.dm` |
| `if(explode_z) explosion_particles_visual(...)` after the explosion effect system | `code/controllers/subsystem/explosion.dm` (`explode()`) | Monkestation explosion particles (`aquila/code/modules/visual_changes/explosions.dm`): origin only, off with `GLOB.explosion_particles_enabled`, capped by `GLOB.explosion_particles_max`. Gun smoke and impact debris need no core hook (`shoot_live_shot()`/`bullet_act()` overrides with `..()`) |
| `Loafer` entry in `GLOB.disposal_pipe_recipes` | `code/game/objects/items/RPD.dm` | Monkestation loafer (`aquila/code/modules/monke/loafer.dm`) is built with the RPD like other disposal pipes |
| `TRAIT_FAST_CLIMBER`, `TRAIT_SHOVE_RESIST` defines; `TRAIT_FAST_CLIMBER` check in `climb_structure()`; `resist_shove()` call in `/datum/species/proc/disarm()` | `code/__DEFINES/traits.dm`, `code/game/objects/structures.dm`, `code/modules/mob/living/carbon/human/species.dm` | Monkestation leg implants (`aquila/code/modules/cybernetics/leg_augments.dm`): table-glider climbs 3x faster, BU-TAM turns a shove into a little stamina damage. Leg slots are in `aquila/`; the new organ manipulation (`aquila/code/modules/surgery_tg/operation_organ_manip.dm`) reaches organs by zone, so legs need nothing extra |
| NTSL: `signal.data["server"]` and `Compiler.Run(signal)` before relaying | `code/game/machinery/telecomms/machines/server.dm` (`receive_information()`) | Traffic control scripts edit or block radio messages; logic in `aquila/code/modules/ntsl/` |
| NTSL: `lvls` argument of `/datum/signal/subspace/vocal/New()` | `code/game/machinery/telecomms/broadcasting.dm` | `broadcast()` from a script sends on the server's z-level, its radio has no turf |
| NTSL: return when a virtual speaker has no source | `code/datums/chatmessage.dm` (`create_chat_message()`) | `broadcast()` from a script has no real speaker |
| `ACCESS_TCOMMS_ADMIN` (36) in the access lists, the Inżynieria group (`/datum/department_group/engineering`), description and the CE job | `code/__DEFINES/access.dm`, `code/modules/jobs/access.dm`, `code/modules/jobs/job_types/chief_engineer.dm` | NTSL traffic control console |
| `vended_item.mark_contraband()` for hidden (contraband) records | `code/modules/vending/_vending.dm` (`vend()`) | N-spect scanner (tgstation `inspector.dm`): items bought from the hacked contraband list are contraband; `aquila/code/datums/contraband.dm` |
| `I.mark_contraband(TRUE)` after `ILLEGAL` | `code/modules/uplink/uplink_items.dm` (`spawn_item()`) | N-spect: the contents of uplink kits are contraband too (the item itself already has `ILLEGAL`, which `is_contraband()` reads) |
| `SCANGATE_CONTRABAND` mode | `code/game/machinery/scan_gate.dm`, `tgui/.../ScannerGate.tsx` | Scanner gate alarms on contraband (`contains_contraband()`), smuggler's satchel and storage implant hide it |
| `/obj/item/card/id/syndicate/undercover` in `chameleon_blacklist` | `code/game/objects/items/cards_ids.dm` | Agent cards cannot disguise as the detective's Undercover I.D. (Monkestation port) |
| `img.icon { width: auto; height: auto }` in the `map` style (no marker, DMF has no comments) | `interface/skin.dmf` | Runechat radio/emote icons (`\icon[image]`) were drawn at 32x32 instead of 9x9; same rule as tgstation's skin |
| `shower` directions swapped (S<->N, E<->W) | `icons/obj/watercloset.dmi` | The Paradise sprite from #469 uses dir = wall side; ours (and the `water` overlay and maps) use dir = facing |
| Skip mobs without a turf in `check_for_empty_levels()` | `code/controllers/subsystem/zclear.dm` | A mob with a mind in nullspace (e.g. during unit tests) caused a `null.z` runtime that failed random tests |
| `doorctrl1` replaced with the Paradise state | `icons/obj/stationobjs.dmi` | #469 swapped every button state but the pressed one; from ParadiseSS13/Paradise `icons/obj/stationobjs.dmi`, CC BY-SA 3.0 |
| `on-size = ".auto_fit_viewport"` | `interface/skin.dmf` (`mainwindow`) | The map is refitted after every window resize instead of getting black bars; verb in `aquila/code/modules/ui_porzadki/viewport.dm` |
| `apply_fullscreen_pref()` | `code/modules/client/client_procs.dm` (`/client/New()`, after `initialize_escape_menu()`) | The fullscreen preference is applied on login, not only after F11 |
| `PREFTOGGLE_2_FULLSCREEN` in `TOGGLES_2_DEFAULT`, `tesla_volume = 50` | `code/__DEFINES/preferences.dm`, `code/modules/client/preferences.dm` | New players start in fullscreen with tesla sounds at 50% |
| `holomap.fit_to_view(user.client)` | `nsv13/code/modules/holomap/station_holomap.dm` (`open_map()`), `code/datums/components/holomap.dm` | Bigger HUD minimap scaled to the viewer's view; `aquila/code/modules/ui_porzadki/holomap_scale.dm` |
| Stamina forwarded to the owner's pool, not stored on the limb (`receive_damage()`, `heal_damage()`) | `code/modules/surgery/bodyparts/bodyparts.dm` | BeeStation#14750 stamina pool (`aquila/code/modules/mob/living/stamina.dm`). Limbs no longer get disabled by stamina |
| `stamina` stripped to the pool before the limb loops | `code/modules/mob/living/carbon/damage_procs.dm` (`heal_bodypart_damage()`, `heal_overall_damage()`, `take_overall_damage()`) | Same; without it a heal would apply once per limb |
| `stamina_swing(stamina_cost)` | `code/_onclick/item_attack.dm` (`/obj/item/proc/attack()`) | Swing cost (`aquila/code/game/objects/items_stamina.dm`) |
| `apply_item_stamina_damage(I)` | `code/modules/mob/living/carbon/carbon_defense.dm` (`attacked_by()`), `code/modules/mob/living/carbon/human/species.dm` (`spec_attacked_by()`) | Item hits take `stamina_damage` (+ crit) from the pool |
| Unarmed: `stamina_swing(STAMINA_SWING_COST_UNARMED)`, fixed `STAMINA_DAMAGE_UNARMED` (x1.5 kick); disarm `stamina_swing(STAMINA_DISARM_COST)`; `animate_interact()` | `code/modules/mob/living/carbon/human/species.dm` (`harm()`, `disarm()`, `spec_attack_hand()`) | Bee#14750 unarmed costs and the hand particle (`aquila/code/datums/interaction_particle.dm`) |
| Block threshold `stamina.loss_as_percent >= 45` | `code/game/objects/items.dm` (`hit_reaction()`, `on_block()`) | Blocking without a limb-stamina model |
| `Disorient()` from `disorient_*` projectile vars | `code/modules/mob/living/living_defense.dm` (`bullet_act()`) | Disablers/electrodes disorient (`aquila/code/modules/projectiles/disorient.dm`); their `damage`/`knockdown` zeroed in `beams.dm`, `energy/stun.dm`, `nsv13/.../security/weapons.dm` |
| `Disorient()` instead of `Paralyze()` | `code/game/objects/items/stunbaton.dm`, `code/game/objects/items/melee/misc.dm` (police/deputy/telescopic/contractor), `code/modules/assembly/flash.dm`, `code/game/objects/items/robot/robot_items.dm` (borg stun arm, + 2.5 s cooldown) | Stun weapons drain stamina and only floor the exhausted (`aquila/code/datums/status_effects/disorient.dm`) |
| Thresholds moved to the 250 pool (`TRAIT_EXHAUSTED`, `loss_as_percent`, x1.5) | `spooky.dm`, `boxing.dm`, `krav_maga.dm`, `sleeping_carp.dm`, `strained_muscles.dm`, `scanners.dm`, `human_defense.dm` (self-check), `other_reagents.dm` (tire), `toxin_reagents.dm` (zombie powder), `glass.dm` (chugging), `scooter.dm`, `vehicle_actions.dm`, `living.dm` (grab resist), `Hallucination.dm`, `nsv13/.../overmap.dm` (G-force) | Old thresholds assumed stamcrit at 100 |
| Arm lock disables the arm with `disable_limb_temporarily()` | `nsv13/code/modules/jobs/security/martial_art.dm` | MAA used 100 stamina on an arm to disable it, which a pool can't do |
| `code/__DEFINES/stamina.dm` (new) | `nsv13.dme` | Stamina defines used by the core hooks above |
| `languages_possible_base.Copy()` instead of `languages_possible_base +=`; `/datum/language/vampiric` and `/datum/language/darkspawn` in `languages_possible_base` | `code/modules/surgery/organs/tongue.dm` | `+=` in the robot/ethereal/golem/slime tongue `Initialize()` added their language to the shared static list, so every tongue could speak it. Aquila antag languages need to be speakable like narsie/ratvar. Egg and squid tongues add their own language in `aquila/` (`eggpeople.dm`, `squidpeople.dm`). Test: `aquila_jezyki_ras` |
| `\|=` instead of `+=` in the old keybinding loop | `code/__HELPERS/global_lists.dm` (`make_datum_references_lists()`) | `init_keybindings()` (aquila) already registers every keybinding, so the leftover core loop put each default key in `keybinding_list_by_key` twice and the Esc help page listed it twice |
| `if(!LAZYFIND(gauss_gunners, user))` before granting `off_action` | `nsv13/code/modules/overmap/camera.dm` (`CreateEye()`) | A Gauss gunner got "Stop observing" next to our "Wyjdź z działa" (`aquila/code/modules/munitions/gauss_gunner_actions.dm`); both just left the gun |
| `if("purify")` calling `purify_buffer_reagent()`, `pureVolume` in the buffer list | `code/modules/reagents/chemistry/machinery/chem_master.dm` (`ui_act()`, `ui_data()`) | ChemMaster "Oczyść" button: an impure reagent in the buffer is reduced to its pure part at 100% purity (`aquila/code/modules/reagents/chemistry/machinery/chem_master.dm`). Test: `aquila_chemia_ulepszenia` |
| `attached_accessory.detached_pockets?.parent != src` | `code/modules/clothing/clothing.dm` (`/obj/item/clothing/under/attack_hand()`) | A holster or webbing attached to a uniform hands its storage to the uniform, so forwarding the click to the accessory opened nothing and the detective could not reach their revolver. The uniform's own storage now handles the click. |
| Admin ghost login (`IsAdminGhost(usr)`) | `code/game/machinery/computer/communications.dm` (`toggleAuthentication` in `ui_act()`) | An admin ghost has no ID card, so it could not log in to the communications console to test the response team and crew wake requests. Closing the console logs the admin ghost out again (`ui_close()` in `aquila/code/game/machinery/computer/communications.dm`), so the crew never finds it logged in with every access. |
| `wake` and `ert` actions | `code/modules/requests/request_manager.dm` (`ui_act()`) | Admins answer crew wake and response team requests from the request manager (buttons in `RequestManager.tsx`). Both go through `/datum/request/proc/admin_take_over()` in `aquila/code/modules/requests/request.dm`: a fulfilled request never starts again, and a request someone is already handling (the automatic poll or another admin) is taken over only after the admin confirms it, because two ERT makers could each send a team. |
| `close(can_be_suspended = FALSE)` before `return FALSE`, `user?.client` before `browse_queue_flush()` | `code/modules/tgui/tgui.dm` (`open()`, `send_assets()`) | A window opened for a mob that lost its client while the window initialised (death info of a swarmer deleted on death) stayed blank and locked on the screen. |
| Skip mutant organs the mob already has when not replacing them (`replace_current = FALSE`, heals) | `code/modules/mob/living/carbon/human/species.dm` (`regenerate_organs()`) | Every heal or revive inserted a new copy and dropped the old one, so an IPC left power cord implants on the floor. |
| `DISEASE_CONTACT_FLUIDS_TRANSMISSION` / `DISEASE_CONTACT_SKIN_TRANSMISSION` (3 and 6, were 6 and 11) | `code/__DEFINES/diseases.dm`, `code/datums/diseases/advance/advance.dm` (`SetSpread()`) | The disease2 symptoms have almost no transmission, so viruses made of them never spread by touch. Test: `disease2_contact_spread` |
| `/datum/species/oozeling` in the green extract and unstable mutation toxins | `code/modules/reagents/chemistry/reagents/other_reagents.dm` (`mutationtoxin/jelly/on_mob_life()`, `mutationtoxin/unstable`) | The playable slime race could not come out of xenobiology toxins, only the jelly subtypes. Test: `aquila_oozeling_mutation_toxin` |
| `return teamSpawned > 0` instead of `return TRUE` | `code/modules/admin/verbs/one_click_antag.dm` (`makeEmergencyresponseteam()`) | Candidates who left before spawning made the maker report a team anyway: the crew wake/ERT request stayed locked and the crew heard the request was accepted. The "centcom" button in `topic.dm` now reports too few volunteers in that case. |
| Swarmer spawner text without `<b>`, goals in `important_info` | `code/modules/antagonists/swarmer/swarmer.dm` (`/obj/effect/mob_spawn/swarmer`) | The spawner menu showed raw HTML tags and one run-on paragraph. |
| `manual` argument and `ejecting.ogg` in `create_escape_pod()` | `nsv13/code/modules/overmap/fighters/_fighters.dm` | Manual eject from the console panel (`aquila/code/modules/overmap/fighter_manual_eject.dm`; Polish panel PNGs in `aquila/icons/overmap/gui/`) reuses the escape pod code and says "pilot pulls the handles" instead of "automatic ejection". Test: `aquila_manual_eject` |
| `powerswitch.ogg` and `return TRUE` on the battery switch (no generic `switch.ogg` on top), `apu_start.ogg` when the APU turns on | `nsv13/code/modules/overmap/fighters/_fighters.dm` (`ui_act()`, `"battery"`, `"apu"`) | Unused fighter sounds hooked up |
| `takeoff.ogg` relayed to the fighter | `nsv13/code/modules/overmap/fighters/fighters_launcher.dm` (`finish_launch()`) | Unused fighter sound hooked up |
| `locking.ogg` for the locker, `being_locked.ogg` for the target (no sound channel, so it does not cut the target's hull crit announcements) | `nsv13/code/modules/overmap/overmap.dm` (`start_lockon()`) | The locker used to hear the "you are being locked" warning and the target heard nothing |
| `if(!(amount >= 0)) return FALSE` | `code/modules/economy/account.dm` (`transfer_money()`) | Ujemna kwota odwracała przelew i tworzyła pieniądze (nagroda z newscastera). Zero przechodzi, żeby pensja 0 kr nie dawała błędu. Test: `aquila_negative_transfer` |
| blok `if(world.system_type == MS_WINDOWS)` | `code/__HELPERS/shell.dm` (`shell_url_scrub()`) | `cmd /c` rozwija `%ZMIENNA%`, a kodowanie `%XX` samo tworzy `%`; na Windowsie złe znaki są usuwane zamiast kodowane. Test: `aquila_jukebox_url_whitelist` |
| `own_multi_selection` | `code/controllers/subsystem/vote.dm` (`ui_data()`) | Do okna głosowania idą tylko własne głosy gracza, nie `choices_by_ckey` wszystkich. |
| limit `owed` + `chip.spend()` | `code/game/machinery/computer/warrant.dm` (`pay_fine_holochip()`) | Holożeton płacił spłacone grzywny i ponad dług; reszta zostaje na żetonie. Test: `aquila_warrant_holochip_change` |
| `"200 kosmicznych kredytów"` za 1200 pkt | `code/modules/mining/machine_vending.dm` (`prize_list`) | Kurs punktów górniczych na gotówkę w dół: 400 kr za 2400 pkt zamiast 1000 kr |
| `grilled_result.reagents?.clear_reagents()` | `code/datums/components/grillable.dm` (`FinishGrilling()`) | Zgrillowany wynik miał swoje `food_reagents` + reagenty surowca (płat 8u → stek 16u). Test: `aquila_food_cooking_reagents` |
| `baked_result.reagents?.clear_reagents()` | `code/datums/components/bakeable.dm` (`FinishBaking()`) | To samo podwajanie przy pieczeniu (tylko dobry wynik; przypalony zostaje jak był). |
| `this_food.reagents?.clear_reagents()` | `code/datums/components/food/edible.dm` (`on_microwave_cooked()`) | Podwajanie reagentów z mikrofalówki, jak w tg. Test: `aquila_food_cooking_reagents` |
| `tongue?.toxic_food` | `code/datums/components/food/edible.dm` (`check_liked()`) | Ageuzja bez języka dawała runtime przy jedzeniu. |
| usunięty `protected` | `code/datums/components/food/decomposition.dm` | Zmienna zapisywana, nigdy nieczytana. |
| usunięta druga `crowbar_act()` | `code/modules/food_and_drinks/kitchen_machinery/griddle.dm` | Druga definicja przez `..()` rozbierała płytę dwa razy. |
| `if(.) return` | `griddle.dm` / `oven.dm` (`attack_hand()`) | Przełączanie ignorowało przerwanie z rodzica (przewody, `COMSIG_TRY_USE_MACHINE`). |
| `crowbar_act()` wyważa najpierw odzysk wody | `nsv13/code/game/machinery/blast_shower.dm`, `code/game/objects/structures/shower.dm` | Późniejsza definicja z NSV13 (rozbiórka) wygrywała i odzysk ginął razem z prysznicem; teraz z odzyskiem woła `..()` (wersję z shower.dm), a wersja z shower.dm bez odzysku woła `..()` |
| `used_lum_power` symetrycznie, `update_used_lum_power()`, `LIGHT_NO_LUMCOUNT` | `code/datums/components/overlay_lighting.dm` | Ujemne światła (darkspawn, Anti-Glow) zostawiały -1 lumcountu na stałe; obsługa `LIGHT_NO_LUMCOUNT` zginęła w AQ#414. Test: `aquila_movable_light_lumcount` |
| `set_light_range_power_color()` zamiast `set_light()` | `code/modules/research/xenobiology/xenobiology.dm` (yellow extract) | `set_light()` → `update_light()` daje CRASH przy `MOVABLE_LIGHT` |
| `cable_color` przed testem nakładania; kolor zwoju przy dzieleniu/łączeniu; openspace `get_cable()` | `code/modules/power/cable.dm`, `code/modules/power/cable_coil.dm` | Smartwires. Test: `aquila_cable_coil_colour` |
| `AQ EDIT` zablokowany chwyt kończy kliknięcie | `code/_onclick/click.dm` (`/mob/living/carbon/CtrlClick`) | Chwyt zablokowany przez `check_block`/`TRAIT_ONEWAYROAD` spadał do `..()`: drugi `grab_act` i ciągnięcie celu bez cooldownu. Test: `aquila_review_blocked_grab` |
| `M.combat_mode \|\| RIGHT_CLICK` przy `check_shields` | `code/modules/mob/living/carbon/human/species.dm` (`spec_attack_hand()`) | Popchnięcie poza combat mode omijało tarcze. |
| `H.run_armor_check(..., BLEED, ...)` | `code/modules/mob/living/carbon/human/species.dm` (`spec_attacked_by()`) | Pancerz przeciw krwawieniu liczony od atakującego zamiast od ofiary. |
| prawy klik strzykawką → `afterattack_secondary` | `code/modules/reagents/chemistry/machinery/chem_heater.dm` (`attackby()`) | Strzykawką nie dało się pobrać z zlewki w podgrzewaczu. Test: `aquila_review_chem_heater_syringe` |
| `else return ..()` | `code/game/machinery/doors/airlock.dm` (`crowbar_act()`) | Łom przy otwartym panelu i warstwie, której nie zdejmuje, nic nie robił. |
| `. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN` | `code/game/machinery/_machinery.dm` (`attackby_secondary()`) | `if(.)` było zawsze prawdą, `update_last_used` nie działało. |
| `connect_loc` ENTERED/EXITED, `set_patient(null)` w `Destroy` | `code/game/objects/structures/tables_racks.dm` (`/obj/structure/table/optable`) | `table_entered` nie był podpięty, `TRAIT_NO_BLEEDING` zostawał przy każdym położeniu się. Test: `aquila_review_optable_patient` |
| `table_entered` zamiast własnego `connect_loc` | `code/modules/antagonists/abductor/equipment/abduction_gear.dm` | Drugi `connect_loc` nadpisałby handler ENTERED stołu operacyjnego. |
| `COMSIG_ATOM_ATTACK_HAND, user, modifiers` | `code/modules/mob/living/carbon/carbon_defense.dm` (`attack_hand()`) | Handlery nie widziały RIGHT_CLICK: podwójne zgłaszanie popchnięcia, AI małp. Test: `aquila_review_relay_shove` |
| `if(H.is_in_tutorial()) continue` | `code/modules/events/heart_attack.dm`, `brain_trauma.dm`, `spontaneous_appendicitis.dm` (`start()`) | Eventy losujące ofiarę pomijają postacie w samouczku (`is_in_tutorial()` w `aquila/code/modules/tutorial/tutorial_status.dm`) |
| zakomentowane `SSshuttle.registerHostileEnvironment(revolution)` | `code/game/gamemodes/dynamic/dynamic_rulesets_roundstart.dm`, `dynamic_rulesets_latejoin.dm` (`execute()`) | Rewolucja w dynamic nie blokuje promu, tak jak tryb revolution od aq33/AquilaStation#444 |
| `TGUI_BROWSER_OPTIONS` | `code/__DEFINES/tgui.dm`, `code/modules/client/client_procs.dm`, `code/modules/tgui_panel/external.dm` | Devtools nadpisywały find/refresh/byondstorage |
| walidacja `tab`/`selected` przed zabraniem papieru | `portrait_printer.dm`, `ai_portrait_picker.dm` (`ui_act()`) | Indeks od klienta bez sprawdzenia dawał runtime po zużyciu papieru |
| `REMOVE_KEEP_TOGETHER` | `code/datums/elements/decals/blood.dm` (`Detach()`) | Para do `ADD_KEEP_TOGETHER` |
| `unreachable_items_reset_at` | `nsv13/code/modules/overmap/knpc.dm` (`acquire_weapon/action()`) | Lista nieosiągalnych broni rosła przez całą rundę |
| `SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ATOM_SOLD, thing, sold, allowed_categories)` | `code/modules/cargo/exports.dm` (`export_item_and_contents()`, `export_contents()`) | Sygnał niesie kategorie eksportu, żeby sprzedaż padem piratów (`EXPORT_PIRATE`) nie dawała nauce nagród za artefakty xenoarch |
| `success_spawn = TRUE` | `code/modules/antagonists/ninja/ninja_event.dm`, `code/modules/events/devil.dm` (`spawn_role()`) | Bez tego `kill()` po udanym evencie zmniejszał `occurrences` i `max_occurrences` nie działało |
| `!istype(..., /obj/item/card/id/syndicate/undercover)` | `code/modules/mob/living/carbon/human/human.dm` (`assess_threat()`), `human_helpers.dm` (`can_track()`), `nsv13/code/modules/overmap/knpc.dm` | Undercover I.D. detektywa dziedziczyła po karcie agenta -5 zagrożenia, ukrycie przed kamerami SI i kopiowanie dostępów. Test: `aquila_review_undercover_threat` |
| `speed_mult = get_overmap_speed_mult()` on the speed cap and thrust | `nsv13/code/modules/overmap/physics.dm` (`/obj/structure/overmap/process()`) | Overmap scale: ships and fighters fly at half speed on overmap levels (`aquila/code/modules/overmap/overmap_scale.dm`). Test: `aquila_overmap_scale` |
| `LAZYREMOVE` of `ai_attackers` and the fleet's `ai_salvos` in the existing AQ EDIT loop, and `fleet.forget_ai_salvo_ship(src)` next to `stop_reporting_all()` (the ship leaves the cached ship lists of its fleet's salvos) | `nsv13/code/modules/overmap/overmap.dm` (`Destroy()`) | AI morale and torpedo salvos keep per-ship and per-fleet memory lists; ships parked in nullspace stop pruning them, so a deleted ship is removed from every list here (GC) |
| `\|\| QDELING(src)` early return | `code/modules/projectiles/projectile.dm` (`/obj/item/projectile/Moved()`) | A projectile whose range ran out on a ship's tile was moved to nullspace by its own `Destroy()`, scanned that tile, hit the ship and was qdel'd again ("destroy proc was called multiple times"). The halved gun range (overmap scale) made it common. Seen in the AI sandbox |
| `/ get_overmap_speed_mult()` on `total_force` | `nsv13/code/modules/overmap/physics.dm` (`collide()`) | Overmap scale: slower ships still deal the same ram damage |
| `if(DC)` / `DC?.` guards for the docking computer | `nsv13/code/modules/overmap/fighters/fighters_launcher.dm` (`check_overmap_elegibility()`, `transfer_from_overmap()`), `nsv13/code/modules/overmap/fighters/control_console.dm` (`ui_data()`, `ui_act()` "toggle_docking") | A destroyed fighter component now frees its hardpoint slot (`aquila/code/modules/overmap/fighter_component_cleanup.dm`); upstream wrote to the deleted docking computer instead of checking for one. Seen in `fighter_docking` after `test_chamber` blew up a sabre |
| `if(QDELETED(turret)) return` | `nsv13/code/modules/munitions/ship_weapons/ballistic_weapons/50Cal.dm` (`/obj/machinery/computer/anti_air/examine()`) | An anti-air console without a paired turret runtimed in `examine()`, so shift-click showed nothing. Test: `aquila_examine_no_runtime` |
| `try`/`catch` around `A.examine(src)` | `code/modules/mob/mob.dm` (`/mob/proc/run_examinate()`) | A runtime in any type's `examine()` left the player with an empty shift-click. Now the player sees the name and `desc`, and `stack_trace` still reports the runtime (unit tests fail on it) |
| `take_damage(..., get_dir(src, user), I.armour_penetration)` in `/obj/attacked_by()` | `code/_onclick/item_attack.dm` | Port tgstation/tgstation#88418: the attacking weapon's armour penetration now counts against structure and machine armour, like it does against mobs. |
| `return COMPONENT_INTERCEPT_ALT` in `/datum/component/gps/item/proc/on_AltClick()` and `. = COMPONENT_INTERCEPT_ALT` in `/datum/ai_controller/tamed/proc/check_altclicked()` | `code/datums/components/gps.dm`, `code/datums/ai/tamed/tamed_controller.dm` | RPG Loot (tgstation/tgstation#82533): Alt+click on a GPS lying on the floor or on a tamed animal does its own action and does not also open the tile window. `tools/ci/check_alt_click_loot.py` checks every COMSIG_CLICK_ALT handler. |
| `user.open_loot_panel(src, T)` in `/atom/AltClick()` and `user.open_loot_panel(A, T, TRUE)` in `/atom/AltClickNoInteract()`, in place of `listed_turf`/`set_stat_tab()` | `code/_onclick/click.dm` | Port tgstation/tgstation#82533 (RPG Loot): Alt+click opens the tile window (`aquila/code/modules/lootpanel/`) instead of the tile tab in the stat panel. Types with their own Alt+click action are listed in `alt_click_actions.dm` (`alt_click_loot = FALSE`); `tools/ci/check_alt_click_loot.py` fails CI when a new `AltClick()` override is missing there. The stat panel tile tab code (`listed_turf`, Bee #9655 `render_stat_information`) stays but is no longer reached. |
| Halucynacje jako efekt statusu: `var/hallucination` (living) i `next_hallucination` (carbon) usunięte, `code/modules/flufftext/Hallucination.dm` usunięty, w jego miejsce `aquila/code/modules/hallucination/`; `aquila/code/__DEFINES/hallucination.dm` dołączany wcześnie w `nsv13.dme` (makro `cause_hallucination`); ~60 linii `// AQ EDIT - halucynacje jako efekt statusu (Bee#13095)` zamienia `hallucination += N` na `adjust_hallucinations(N * 2 SECONDS)` i podobne; `hallucinating()` czyta efekt; `COMSIG_BODYPART_UPDATING_HEALTH_HUD` w `human.dm` i `COMSIG_BODYPART_CHECKED_FOR_INJURY` w `human_defense.dm`; `CHAT_RDS_UNLIMITED` w `preferences.dm` | reagenty, traumy, choroby, anomalie, nanity, wydarzenie masowych halucynacji, supermateria, zbroja reaktywna, `carbon.dm`, `human.dm`, `human_defense.dm`, `negative.dm`, `mild.dm` | Port BeeStation/BeeStation-Hornet#13095 + tgstation/tgstation#89865: halucynacje to `/datum/status_effect/hallucination` z poziomami i odstępem zależnym od nasilenia. 1 jednostka starej zmiennej = 2 s (tyknięcie Life). Cecha Zaburzenia Dysocjacyjne do 60 s (bez skrajnych poziomów), z preferencją do 240 s. |
| Zupy z garnka: z `code/game/objects/items/food/soup.dm` usunięte 22 zupy-przedmioty, które stały się odczynnikami (zostały: zupa życzeń, mämmi, spacy liberty duff, galaretka z muchomorów), z `recipes_soup.dm` i `recipes_salad.dm` ich receptury; odwołania w `lootdrop.dm`, `bluespace_tap.dm`, `nsv13/.../replicatorDS.dm`, `replicator_designs.dm`, `donation/food.dm` i `marine_frigate.dmm` wskazują gotowe miski `/obj/item/reagent_containers/glass/bowl/soup/*`; w `reagent_recipe_collisions.dm` zupy o różnych składnikach-przedmiotach nie kolidują | jw. | Port tgstation/tgstation#74205: zupa to odczynnik z garnka na kuchence (`aquila/code/modules/food_and_drinks/soup/`). Automat z zastawą dostaje garnki i chochle w `Initialize` modułu. |
| `if(!(source_mob.mobility_flags & MOBILITY_STAND))` in `/proc/is_source_facing_target()` (the check was inverted, every standing mob faced nothing) | `code/__HELPERS/atmos.dm` | Vampire mesmerize and lunge, disease spread and `check_target_facings()` see a standing mob face its target. Test: `aquila_zgloszenia_0711.dm` |
| At most one bonus pill in `/obj/item/storage/firstaid/radbgone/PopulateContents()` | `code/game/objects/items/storage/firstaid.dm` | The radiation kit spawned up to 8 items into 7 slots. Test: `aquila_zgloszenia_0711.dm` |
| `if(P.hitsound)` before `playsound()` in `/obj/bullet_act()` | `code/game/objects/obj_defense.dm` | Silent projectiles (accelerator particles piercing tesla coils) play nothing |
| `MA.layer += 1` for layers below `TURF_LAYER` in `/proc/t_ray_scan()` | `code/game/objects/items/devices/scanners.dm` | Cables and pipes sit below the floor layer since aq33/AquilaStation#460, so T-ray images were drawn under the tile (scanner, engineering goggles, MOD module). Checked in a client |
| Subsystem offset `rand(0, DS2TICKS(min(wait, 2 SECONDS)))` per subsystem, `rand(0, 1)` for tickers | `code/controllers/master.dm` (`Loop()`, `Initialize()` tickers) | tgstation/tgstation#71730: the old `stagger += rand(1, 5)` ticks grew with every subsystem, so the last ones started seconds after round start |
| `#if defined(TIMER_DEBUG)` around the full timer name, short name otherwise; `TIMER_DEBUG` defined under `UNIT_TESTS` | `code/controllers/subsystem/timer.dm` (`bucketJoin()`), `code/_compile_options.dm` | tgstation/tgstation#76214 (name part only, `QDEL_IN` stays stoppable): the full name joined flags and callback arguments on every `addtimer` |
| `flicker()` returns early for lights that are off or broken, `stoplag` instead of `sleep`, stops without power | `code/modules/power/lighting.dm` | tgstation/tgstation#92503 |
| `aq_flicker_ship_lights(src, chance)` instead of the `GLOB.machines` loop | `nsv13/code/modules/power/stormdrive.dm` (`handle_overload()`, 12 MW+), `nsv13/code/modules/power/reactor/rbmk.dm` (`process()`) | The whole-ship light flicker runs outside `process()` with `CHECK_TICK` (`aquila/code/modules/power/light_flicker_mass.dm`); a reactor outside any ship flickers nothing. Test: `aquila_ship_flicker_needs_overmap` |
| `get_cached_height()` instead of `icon(icon, icon_state, dir).Height()` (29 lines) | `code/game/data_huds.dm`, `code/datums/components/nanites.dm`, `code/modules/antagonists/abductor/equipment/gland.dm`, `code/modules/antagonists/swarmer/swarmer.dm`, `code/modules/guardian/guardian.dm`, `code/modules/mob/living/simple_animal/guardian/guardian.dm`, `code/modules/mob/living/simple_animal/friendly/drone/_drone.dm` | tgstation/tgstation#88266: HUDs created a new icon on every update. Helper in `aquila/code/__HELPERS/icon_dimensions.dm`. Test: `aquila_cached_icon_height` |
| `aq_cached_icon_states(icon_file)` instead of `icon_states(icon_file)` (3 calls) and `aq_icon_states_cache = null` at the end of `register()` | `code/modules/asset_cache/asset_list_items.dm` (`research_designs`) | Each icon file is read once instead of once per design; designs with a missing state are still skipped with a warning. Helper in `aquila/code/modules/asset_cache/asset_list_items.dm` |
| `#ifdef UNIT_TESTS` around the `icon_states()` check | `code/modules/asset_cache/asset_list_items.dm` (`vending`) | tgstation/tgstation#69635: the check cost about 1 s of asset init; a product with a missing state is skipped by `Insert()` or takes the file's blank state (no such product today, the unit test run reports them) |
| `#include` Atlantis.dmm i Atlantis2.dmm w bloku `ALL_MAPS` | `_maps/_basemap.dm` | CI kompiluje Atlantis, który jest w rotacji (wcześniej przeszły przez to błędne zmienne mapy). Test: `aquila_map_standard` sprawdza, że każda mapa z jego listy jest w tym bloku. |
| `#define JOB_MODIFICATION_MAP_NAME "NSV Atlantis"` + `#include` jego `job_changes.dm` | `code/modules/jobs/map_changes/map_changes.dm` | Zmiany profesji Atlantis (sloty pilotów, usunięty kurator, prawnik, zastępca) wcześniej w ogóle się nie kompilowały. Test: `aquila_map_standard` (`check_job_changes`). |
| Usunięte `MAP_REMOVE_JOB(virologist)` | `_maps/map_files/Atlantis/job_changes.dm` | Atlantis ma wirusologię jak Atlas i Trawnik, więc wirusolog zostaje. |
| `MAP_REMOVE_JOB(brig_physician)` zamiast `brig_phys` | `_maps/map_files/Atlas/job_changes.dm`, `Serendipity/job_changes.dm`, `vonneumann/job_changes.dm` | `brig_phys` nie jest profesją: makro po cichu tworzyło pusty typ. Lekarza więziennego i tak wyłącza `aquila/code/modules/jobs/job_slots.dm`; test `aquila_map_standard` odrzuca teraz takie literówki. |
| `&& !aquila_internal_in_worn_hardsuit()` przy sprawdzaniu `internal.loc` | `code/modules/mob/living/carbon/life.dm` (`get_breath_from_internal()`) | Wbudowana butla hardsuitu leży w kombinezonie, nie w mobie, więc bez tego oddychanie z niej od razu się wyłączało. Procka w `aquila/code/modules/clothing/spacesuits/hardsuit_modules.dm`, test `aquila_hardsuit_modules` |
| Gotowe hardsuity z modułami zamiast MODsuitów (`suit = ...` z `// AQ EDIT`) | `code/modules/clothing/outfits/ert.dm`, `code/modules/clothing/outfits/standard.dm`, `code/modules/antagonists/wizard/equipment/spellbook.dm`, `code/modules/uplink/uplink_items.dm` | MODsuity usunięte; stroje ZRK, szwadronu śmierci, admina, zbroja maga bitewnego i uplink dostają warianty z `aquila/code/modules/clothing/spacesuits/hardsuit_variants.dm` |
| Bez sygnału `COMSIG_ATOM_ATTACK_HAND` w standardowym rdzeniu, tekst examine o łomie | `code/modules/mod/mod_core.dm` (`/obj/item/mod/core/standard/install()`, `uninstall()`, `on_examine()`) | Pokrywa hardsuitu jest stale otwarta, więc klik pustą ręką w trzymany kombinezon zaczynał wyjmować ogniwo zamiast go podnieść. Ogniwo wyjmuje się łomem (`crowbar_act()` w `hardsuit_modules.dm`) |
| `try_activate()` przed akcją modułu i panelu | `code/modules/mod/mod_actions.dm` | Kombinezon założony komuś przez menu ściągania nie uruchamia się sam; blokada DNA sprawdza noszącego przy jego pierwszej akcji, jak dawniej przy aktywacji MOD. Test `aquila_hardsuit_review_fixes` |
| `allowed = allowed \| ...` i `allowed = allowed - ...` zamiast `\|=` / `-=` | `code/modules/mod/modules/modules_security.dm` (`/obj/item/mod/module/magnetic_harness/on_install()`, `on_uninstall()`) | `allowed` hardsuitów ochrony to wspólna `GLOB.security_hardsuit_allowed`; wyjęcie uprzęży z jednego kombinezonu zabierało broń z listy wszystkich. Test `aquila_hardsuit_review_fixes` |
| `type = MESSAGE_TYPE_INFO` w `to_chat()` | `code/modules/mob/mob.dm` (`/mob/proc/run_examinate()`) | Tytuł examine nie ma już `span info` (jest w zakładce ramki), więc czat nie wiedział, że to informacja |
| Mining asteroids and ruins, `_maps/virtual_domains` and `aquila/_maps` added to `DmMapsIncludeTarget` (Aquila maps via `../`) | `tools/build/build.js` | CI (`compile_all_maps`) compiles these templates too; errors in them used to pass |
| `MAPS=(_maps/**/*.dmm aquila/_maps/**/*.dmm)` instead of `_maps/**/*.dmm` in the map linters | `tools/ci/check_grep.sh` | The map linters cover Aquila maps |
| Fixed `mappath` of `sk_rdm139`, `sk_rdm165`, `sk_rdm169` (pointed at missing files) | `code/modules/mapping/random_rooms.dm` | These rooms never spawned. Test: `aquila_random_rooms` |
| `quality = min(quality, FOOD_QUALITY_TOP)` | `code/datums/components/food/edible.dm` (`examine()`) | Szkielet oglądający szalonego hamburgera kucharza miał jakość 8 przy liście 7 opisów: runtime i brak opisu. `check_liked()` przycinał już tak samo. Test: `aquila_audyt_food_quality_examine` |
| `icon = 'icons/obj/food/meat.dmi'` | `code/modules/guardian/guardianbuilder.dm` (`/obj/item/guardiancreator/carp`) | Port Newfood przeniósł stan `fishfingers` do `meat.dmi`, więc holokarpie paluszki z uplinka były niewidoczne. Test: `aquila_audyt_holocarp_icon` |
| `if(QDELETED(src)) return` po `..()` | `code/modules/reagents/reagent_containers/pill.dm` (`afterattack()`) | Taca hydroponiczna kompostuje pigułkę w sygnale `COMSIG_ATOM_AFTER_ATTACKEDBY`, a dalszy kod pigułki wołał `trans_to` na usuniętych reagentach. Test: `aquila_audyt_tray_compost` |
| `newstruct.report_construct_built(stoner)` na końcu bloku `AQ EDIT` | `code/modules/antagonists/wizard/equipment/soulstone.dm` (`makeNewConstruct()`) | Konstrukt kultu krwi zgłasza klucz `build_construct`, więc rytuał „Po jednym z każdego” da się ukończyć (jak `check_ritual("build_construct")` w vg). Procedura w `aquila/code/modules/antagonists/bloodcult/constructs/constructs/_construct.dm`, test `aquila_audyt_antagi_constructs` |
| `if(emote_type & EMOTE_AUDIBLE)` zamiast `& (EMOTE_AUDIBLE \| EMOTE_VISIBLE)` przy hologramie | `code/datums/emotes.dm` (`/datum/emote/run_emote()`) | Emotka SI tylko widoczna (np. *nod) przez hologram szła jako dźwięk do niewidomych; gałąź `visible_message` była martwa od przejścia na bitflagi |
| `ui.set_autoupdate(TRUE)` w `ui_interact()` | `code/game/mecha/mecha_topic.dm`, `code/modules/power/generator.dm`, `code/game/machinery/computer/pod.dm`, `code/game/machinery/computer/apc_control.dm` | Okna z tg (Mecha, ThermoElectricGenerator, MassDriverControl, ApcControl) pokazują dane zmieniające się same; u nas `autoupdate` jest domyślnie FALSE |
| `PROC_REF(try_handle_speech)` zamiast `PROC_REF(handle_speech)` przy rejestracji `COMSIG_MOB_SAY` | `code/modules/surgery/organs/tongue.dm` (`/obj/item/organ/tongue/Insert()`) | Moduł infiltracyjny hardsuitu blokuje zmianę mowy języka przez `COMSIG_TRY_MODIFY_SPEECH` (jak w tg). Procka w `aquila/code/modules/surgery/organs/tongue_speech.dm` |
| Sortowanie obrazów po `plane`, potem po `layer` (`FLOAT_PLANE` jak `GAME_PLANE`) | `code/modules/photography/camera/camera_image_capturing.dm` (`camera_get_icon()`) | Po obniżeniu warstw kable, rury i kratownice mają warstwę poniżej `TURF_LAYER` na `GAME_PLANE`; samo sortowanie po warstwie rysowało na nich turf i znikały ze zdjęć. Test: `aquila_audyt_warstwy_photo` |
| `return FALSE` po `place_on_turf()` przy prawym kliku | `code/modules/power/cable_coil.dm` (`/obj/item/stack/cable_coil/pre_attack()`) | Port Bee zwracał TRUE, które u nas znaczy „idź dalej”: cel dostawał jeszcze `attackby(zwój)` (maszyna zasilana kładła drugi kabel pod graczem). Test: `aquila_audyt_warstwy_cable_rmb` |
| `!usr.can_hold_items()` w `MouseDrop()` | `code/game/objects/structures/beds_chairs/chair.dm` | Port combat mode usunął warunek, a nasze `canUseTopic()` nie ma `need_hands` z Bee: zwierzęta i borgi zwijały krzesła. Test: `aquila_audyt_warstwy_chair_drag` |
| `var/assignment = H.get_assignment("No id", "No job")` and comparisons with it in `/datum/objective/crew/promotion/check_completion()` | `code/modules/crew_objectives/civilian_objectives.dm` | `get_assignment()` returns Polish defaults, so the English `"No id"`/`"No job"` comparisons never matched and an ID without a job counted as a promotion. Test: `aquila_promotion_objective_unknown` |
| `SO.pack.get_cost()` instead of `SO.pack.cost` in the cart and request lists | `code/modules/modular_computers/file_system/programs/budgetordering.dm` | Galactic material market packs price themselves in `get_cost()` at shuttle departure and keep `cost` at 0, so the PDA ordering program showed them for free |
| `get_all_accesses()` sums the station groups of SSdepartment (`DEPARTMENT_BITFLAG_STATIONS`) instead of a static list; `get_region_accesses()`/`get_region_accesses_name()` removed; descriptions of `ACCESS_MINING_ENGINEERING`/`ACCESS_MINING_BRIDGE` in `get_access_desc()` | `code/modules/jobs/access.dm` | Access groups port (BeeStation/BeeStation-Hornet#14139). Groups, jobs and helpers in `aquila/code/controllers/subsystem/department.dm`; the mining ship accesses were in no region and now sit in Zaopatrzenie |
| `DEPARTMENT_BITFLAG_CENTCOM`, `DEPARTMENT_BITFLAG_OTHER`, `DEPARTMENT_BITFLAG_STATIONS`; `INIT_ORDER_DEPARTMENT` (72, before SSjob) | `code/__DEFINES/jobs.dm`, `code/__DEFINES/subsystems.dm` | Same port: core files (consoles, remotes, electronics) need the bitflags before `aquila/` is included |
| ID console: `department_bitflag`/`accessible_region_bitflag`/`is_centcom` instead of `target_dept`/`region_access` and the `DEPT_*` numbers; login through `SSdepartment.get_managed_departments()`/`get_subordinate_jobs()` (old `get_subordinates()` removed); the `access` choice only toggles accesses from `SSdepartment.find_access_in_departments()` (whitelist of the managed groups); a job assignment strips station accesses only (CentCom jobs on the CentCom console strip CentCom accesses only); demote checks login and `JOB_NAME_ASSISTANT`; the minor console reads the bitflag from its board | `code/game/machinery/computer/card.dm` | Same port. The TGUI window (`aquila/code/game/machinery/computer/card_ui.dm`) reads the same groups and `get_manageable_department_bitflag()` |
| Department console board: `counting` index into `dept_list` (bitflags, „ogólny” = Służba and Zaopatrzenie) and `dept_list_name` | `code/game/objects/items/circuitboards/computer_circuitboards.dm` | Same port |
| NtOS ID program: `accessible_region_bitflag`/`department_bitflag` instead of `region_access`/`target_dept`/`sub_managers` and `CARDCON_DEPARTMENT_*`; `authenticate()` through SSdepartment; `PRG_access` and `PRG_grantregion`/`PRG_denyregion` use the whitelist and the clicked region (Bee took the first managed department); `PRG_denyall` removes only managed accesses; job tabs named after `dept_name` | `code/modules/modular_computers/file_system/programs/card.dm` | Same port |
| Door remotes: `department_bitflag` instead of `region_access`, `access_list` from `SSdepartment.get_accesses_by_bitflag()`; the command remote stays Command (Bee gives the whole station) | `code/game/objects/items/control_wand.dm`, `nsv13/code/game/objects/items/munitions_items.dm` | Same port |
| Airlock electronics: regions from `SSdepartment.sorted_department_for_access` (station groups only), `regid` is the department bitflag, a region outside the station bits does nothing | `code/game/machinery/doors/airlock_electronics.dm` | Same port; the Aquila name/cycle id blocks are untouched |
| `lazy_template_load_started()`/`lazy_template_load_finished()` instead of setting `SSair.can_fire` directly | `nsv13/code/modules/overmap/boarding/interiors.dm` (`load_interior()`, interior unload), `code/controllers/subsystem/air.dm` (`reset_all_air()`) | One shared pause counter with bitrunning domain loads (`aquila/code/modules/bitrunning/lazy_template.dm`): an interior or air reset finishing in the middle of another load no longer restarts atmos early, and none of them can leave it off for the round |
| `spill_turf.spill_reagents(reagents)` in the floor branch of `SplashReagents()`, `splash_turf.spill_reagents()` in the combat mode splash of `/obj/item/reagent_containers/glass/afterattack()`, `epicenter.pool_splash_remainder(splash_holder, threatscale)` at the end of `chem_splash()` | `code/modules/reagents/reagent_containers.dm`, `code/modules/reagents/reagent_containers/glass.dm`, `code/modules/reagents/chem_splash.dm` | Liquids (Monkestation 2.0 port): every spill reacts with the floor once as before; below 50 units it stays a splash and small spills on one tile add up, 50+ makes a puddle. Grenades and broken tanks leave at most 200 units (`LIQUID_SPLASH_PUDDLE_MAX`) without exposing mobs again. Entry: `aquila/code/modules/liquids/liquid_turf.dm`. Tests: `aquila_liquid_spill_reacts_once`, `aquila_liquid_chem_splash_cap` |
| `liquids_push_out_by_door()` when a door/airlock starts closing | `code/game/machinery/doors/door.dm` (`close()`, not border firelocks), `code/game/machinery/doors/airlock.dm` (`close()`) | A closing door pushes the liquid off its tile (Monke) |
| `liquids.liquid_group.ignite_turf(src)` after the oxygen check in `/turf/open/hotspot_expose()` | `code/modules/atmospherics/environmental/LINDA_fire.dm` | Burning liquids: fuel, alcohol and oil puddles catch fire from any hotspot (Monke) |
| `liquids_before_change(path)` / `W.liquids_after_change()` in `ChangeTurf()` | `code/game/turfs/change_turf.dm` | A puddle moves over to the new floor, and disappears when the turf becomes a wall or space (Monke) |
| `sprint_slide` in `/turf/open/handle_slip()`: a slip while sprinting calls `sprint_slip_slide()` | `code/game/turfs/open/_open.dm` | Walking never slips on a wet floor, running slips as before, and a slip right after a real sprint step also throws you one tile forward, never into a blocked tile (unless the slip already slides, like lube or ice). Entry: `aquila/code/modules/mob/living/carbon/sprint.dm`. Tests: `aquila_wet_floor_slip`, `aquila_sprint_slide_blocked` |
| `H.accidental_release()` instead of `actually_shit_myself()` + reset in the `DEFECATION_ACTUALLY_SHIT_YOURSELF` branch of the species digestion | `code/modules/mob/living/carbon/human/species.dm` | Urine is part of the defecation need; an accident releases only the bigger part (feces or urine). Entry: `aquila/code/modules/bladder/urination.dm`. Test: `aquila_urination` |
| `PREFERENCE_TAG_HIDE_BODILY_FUNCTIONS` ("37") and its read/sanitize/write lines | `code/__DEFINES/preferences.dm`, `code/modules/client/preferences2/preferences2.dm` | Saved censorship toggle for defecation and urine (`aquila/code/modules/bladder/censor.dm`) |
| `SEND_SIGNAL(src, COMSIG_ATOM_NO_LONGER_PULLING, ex_pulled)` na końcu `stop_pulling()` (define w `signals_atom.dm`) | `code/game/atoms_movable.dm` | Port BeeStation/BeeStation-Hornet#14864: puszczony w trakcie dryfu przedmiot leci dalej w tempie ciągnącego (`stopped_pulling()` w `drift.dm`). Test: `aquila_drift_released_pull` |
| `update_parallax_contents()` raz po obu krokach ruchu po skosie w `Move()` i `!moving_diagonally` przed nim w `Moved()` | `code/game/atoms_movable.dm` | Port BeeStation/BeeStation-Hornet#14864: skos przesuwał paralaksę dwa razy w jednym ticku, a druga animacja ucinała pierwszą |
| `C.do_parallax_animations` w `apply_parallax_pref()` i blok `glide_rate`/`run_parallax` w `update_parallax()` | `code/_onclick/hud/parallax.dm` | Port BeeStation/BeeStation-Hornet#14864: warstwy dociągają przesunięcie przez czas ślizgu obiektu niosącego oko (`get_parallax_glide_rate()` w `aquila/code/_onclick/hud/parallax.dm`), na niskich ustawieniach bez animacji. Oko bez ślizgu (kamera overmapy, `NO_STEPS`) zostaje przy starym czasie `last_delay`. FTL (`update_status()`, `check_ftl_state()`) i szczeliny kultu bez zmian |
| `mod.wearer` jako argument `COMSIG_MODULE_TRIGGERED` i `COMSIG_MODULE_DEACTIVATED` | `code/modules/mod/modules/_module.dm` | Moduł jetpacka w hardsuicie włącza `/datum/component/jetpack` na noszącym (jak w BeeStation/BeeStation-Hornet#14864). Test: `aquila_jetpack_module` |
| `get_ingest_holder()` dla `method == INGEST` po wyborze celu i nowy argument `ignore_stomach` w `trans_to()`; `skip_reagents` w `metabolize()`; gałąź organu w `del_reagent()` pomija żołądek | `code/modules/reagents/chemistry/holder.dm` | Port BeeStation/BeeStation-Hornet#14340: połknięte reagenty trafiają do żołądka (reakcja z mobem jak dawniej), mała dawka toksyny jest pomijana w metabolizmie, a reagent, który opuszcza żołądek, nie woła `on_mob_delete()` na właścicielu (nigdy na niego nie działał). Wejście: `aquila/code/modules/surgery/organs/stomach_contents.dm`, `liver_toxins.dm`. Test: `aquila_stomach_ingest`, `aquila_liver_toxins` |
| `trans_to_ingested()` zamiast `trans_to()` po `reaction(M, INGEST)` | `code/modules/food_and_drinks/drinks/drinks.dm`, `food/condiment.dm`, `code/modules/reagents/reagent_containers/glass.dm` (łyk przez `addtimer`), `pill.dm` (tylko `apply_type == INGEST`), `code/game/objects/items/crayons.dm` | Napój, przyprawa, łyk ze zlewki, pigułka i zjedzona kredka idą do żołądka. `reaction()` zostaje, bo wysyła `COMSIG_ATOM_EXPOSE_REAGENTS` (heretyckie organy) i daje smak |
| `handle_stomach_digestion()` przed pętlą `on_life()` organów | `code/modules/mob/living/carbon/life.dm` (`/mob/living/carbon/Life()`) | Żołądek oddaje część zawartości do krwi, zanim wątroba ją zmetabolizuje; z trawieniem w `on_life()` żołądka opóźnienie zależałoby od kolejności organów |
| `if(M.vomit_from_stomach(V)) return` na początku `clear_reagents_to_vomit_pool()` | `code/game/turfs/turf.dm` | Wymioty opróżniają żołądek, nie krew. Stara ścieżka (10% krwi) zostaje dla mobów bez żołądka z natury (ksenomorfy) |
| `process_reagents(C)` zamiast filtra toksyn, metabolizmu i niewydolności w `/obj/item/organ/liver/on_life()` (stary blok usunięty) | `code/modules/surgery/organs/liver.dm` | Wymiana `liver/on_life()`: nowa wątroba z Bee z obrażeniami skalibrowanymi do starych, etapy niewydolności, żółte oczy (`aquila/code/modules/surgery/organs/liver_toxins.dm`). Przy zmianie metabolizmu w upstreamie przenieś ją do `process_reagents()` |
| `message += M.stomach_scan_lines()` | `code/game/objects/items/devices/scanners.dm` (`chemscan()`) | Zawartość żołądka w trybie chemicznym analizatora i w monitorze funkcji życiowych |
| `#include "aquila\code\__DEFINES\radiation.dm"` w miejscu starego `code\__DEFINES\radiation.dm`; usunięte includy `__HELPERS/radiation.dm`, `subsystem/radiation.dm`, `radiation_wave.dm`, `components/rad_insulation.dm`, `components/radioactive.dm`, `devices/geiger_counter.dm` (pliki skasowane) | `nsv13.dme` | Promieniowanie z BeeStation/BeeStation-Hornet#13442: nowe makra (progi, izolacja, cechy, sygnały, `CAN_IRRADIATE`, `RAD_LEGACY_TO_INTENSITY`) są potrzebne w core. Reszta systemu w `aquila/` (zob. sekcja „Radiation port”) |
| `if(irradiate) SSradiation.irradiate(...)` zamiast `apply_effect(..., EFFECT_IRRADIATE)` w `apply_effects()`; `EFFECT_IRRADIATE` usunięty z `apply_effect()` i `__DEFINES/combat.dm` | `code/modules/mob/living/damage_procs.dm`, `code/__DEFINES/combat.dm` | Pociski zachowują `irradiate` w starej skali radów (NSV13 celowo wzmocnił cząstki akceleratora), przeliczane `RAD_LEGACY_TO_INTENSITY` (0,03) i osłabiane pancerzem jak dawniej. W Bee zmienna znikła |
| `/datum/species/proc/handle_radiation(H, intensity, delta_time)` zamiast `handle_mutations_and_radiation(H)` (blok `AQ EDIT`) | `code/modules/mob/living/carbon/human/species.dm` | Woła go `/datum/component/irradiated`. Zostają zmiany NSV13: syntetyki nie wymiotują, IPC (`TRAIT_IPCRADBRAINDAMAGE`) dostaje uraz mózgu od 75%. Mutacje przeniesione do komponentu (Bee#14011, #14339) |
| `handle_mutations()` zamiast `handle_mutations_and_radiation()`; bez `radiation` w `living_defines.dm`, bez `/mob/living/rad_act()`, bez oddychania trytem; `qdel` komponentu i `remove_status_effect(genetic_damage)` w `fully_heal()` | `code/modules/mob/living/life.dm`, `carbon/life.dm`, `human/life.dm`, `monkey/life.dm`, `monkey/monkey.dm`, `living.dm`, `living_defense.dm`, `living_defines.dm` | Natężenie trzyma komponent `irradiated`. Uwaga NSV13 z `carbon/life.dm` (odporni na toksyny bez obrażeń) przeszła do komponentu |
| `contamination_cleanse()` woła `irradiated_component.on_radiation_clean()` | `code/game/objects/structures/shower.dm` | W Bee prysznic czyści przez `CLEAN_TYPE_RADIATION`, którego u nas nie ma (siła czyszczenia). Blok plumbingu `AQ EDIT` w `wash_atom()` bez zmian |
| `receive_radiation_pulse()` zamiast `rad_act()` | `code/modules/power/singularity/collector.dm` | Kolektory zostają (decyzja 19); `SSradiation.feed_collectors()` liczy dawną siłę: `collector_power × izolacja / (odległość × spadek)²`. Rejestracja w `GLOB.rad_collectors` w `aquila/code/modules/power/singularity/collector.dm` |
| `emit_radiation_pulse(last_rads)` zamiast `radiation_pulse(src, last_rads)`; impulsy przy pochłanianiu z wartościami Bee i `collector_power` | `code/modules/power/supermatter/supermatter.dm`, `supermatter_delamination.dm` | Wzór Bee na próg i natężenie (`aquila/code/modules/power/supermatter/supermatter_radiation.dm`), kolektory dostają `last_rads` jak dawniej. Nasza SM (auxmos) bez zmian |
| `radiation_burn()` i spalanie trytu z zasięgiem od spalonego trytu (`TRITIUM_RADIATION_*`, `GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE` w `__DEFINES/reactions.dm`), fuzja z impulsem Bee | `code/modules/atmospherics/gasmixtures/reactions.dm`, `code/__DEFINES/reactions.dm` | `radiation_burn()` woła też auxmos przy natywnym spalaniu. Kolektory dostają `energia / TRITIUM_BURN_RADIOACTIVITY_FACTOR` jak dawniej. `/turf/open/rad_act()` (pluoxium) usunięty, zastępuje go reakcja `pluox_formation` w `aquila/code/modules/atmospherics/gasmixtures/pluoxium_formation.dm` |
| Od razu tworzy `area_sound_manager`, gdy cel już jest na pasującym poziomie | `code/datums/elements/weather_listener.dm` | Bee#13796: syrena burzy radiacyjnej słyszalna bez zmiany poziomu |
| Burza: `telegraph()` z pętlami syreny, `weather_act()` z napromieniowaniem 1–5% i urazem IPC, `end()` zdejmuje pętle; fałszywy alarm z syreną i wyświetlaczami | `code/datums/weather/weather_types/radiation_storm.dm`, `code/modules/events/radiation_storm.dm` | Bee#13796 i #14487 (kostnica osłania), uraz mózgu IPC z NSV13 zostaje, mieszanie DNA znika. Pętle i `GLOB.rad_storm_sounds` w `aquila/code/datums/weather/rad_storm_sounds.dm` |
| `subjectRads` liczy `/datum/status_effect/genetic_damage`; mieszanie DNA, pulsowanie i bufor dają uszkodzenia genetyczne | `code/game/machinery/computer/dna_console.dm`, `tgui/.../DnaConsole/DnaScanner.tsx` (etykieta) | Bee#13442. Klucz `subjectRads` zostaje, żeby nie ruszać okna |
| Dawka odżywki do wymiotów z `get_free_nutriment_volume()` żołądka, nie z krwi (blok `AQ EDIT`) | `code/modules/surgery/organs/stomach.dm` (`on_life()`) | Jedzenie czeka w żołądku (Bee#14340: `get_free_nutriment_volume()`); poprawka z przeglądu aq33/AquilaStation#600 |
| `ADD_TRAIT`/`REMOVE_TRAIT(TRAIT_RADIATION_PROTECTED_CLOTHING, MOD_TRAIT)` przy aktywacji, dezaktywacji i zdjęciu modułu ochrony | `code/modules/mod/modules/modules_engineering.dm` | Ochronę daje cecha, nie pancerz `rad` (jak w Bee); poprawka z przeglądu aq33/AquilaStation#600 |
| Przeniesienie napromieniowania przy przemianie tylko gdy `CAN_IRRADIATE(O)` | `code/modules/mob/transform_procs.dm` | Małpy u nas nie są ludźmi; komponent na małpie dawał COMPONENT_INCOMPATIBLE |
| `computer.update_static_data()` po zalogowaniu i wylogowaniu; `PRG_assign` zdejmuje tylko `get_all_accesses()`; nazwy w logu z `get_department_access_desc()` | `code/modules/modular_computers/file_system/programs/card.dm` | Okno należy do komputera, nie do programu; stanowisko zmienia tylko dostępy stacji jak w konsoli ID |
| Nazwy dostępów w logu z `get_department_access_desc()` | `code/game/machinery/computer/card.dm` (`Topic()`, `access`) | Konsola Centrali zmienia też dostępy Centrali i „Inne”, których `get_access_desc()` nie zna |
| `rad_insulation = RAD_MEDIUM_INSULATION` reaktora; natężenie prętów `clamp(siła / 300, 1, 10)`; stormdrive `/ 500` (impuls co 2 s) | `nsv13/code/modules/power/reactor/rbmk.dm`, `reactor/fuel_rods.dm`, `power/stormdrive.dm` | Obudowa osłania pręty w środku; pręty jak w Bee (5% dla plutonowego); poprawki z przeglądu aq33/AquilaStation#600 |

Pre-existing single-call hooks that stay in core: `parts += mouse_report()` (`roundend.dm`) and `/datum/admins/proc/reloadwhitelist` in the admin verb list (`admin_verbs.dm`).

## Moved out of core by the modularization pass (class A)

| From | To | What |
|---|---|---|
| `items/tanks/jetpack.dm`, `crates_lockers/closets.dm`, `closets/bodybag.dm`, `closets/cardboardbox.dm` | `aquila/code/game/objects/items/tanks/jetpack.dm`, `aquila/code/game/objects/structures/crate_lockers/closets.dm` | `Moved()` dragging sounds; the jetpack thruster sound is now the `thrust_sound` var, played by `/datum/component/jetpack` on each thrust (BeeStation/BeeStation-Hornet#14864) |
| `items/cards_ids.dm` | `aquila/code/game/objects/items/cards_ids.dm` | Budget card withdrawal config gate |
| `client/verbs/ooc.dm` | `aquila/code/modules/client/verbs/ooc.dm` | "Zabij TGUI" verb |
| `admin/admin.dm`, `admin/verbs/pray.dm` | `aquila/code/modules/admin/admin.dm`, `aquila/code/modules/admin/verbs/pray.dm` | Whitelist reload verb, `ert_request()` |
| `__HELPERS/roundend.dm` | `aquila/code/__HELPERS/roundend.dm` | `mouse_report()` |
| `reagents/.../alcohol_reagents.dm` | `aquila/.../alcohol_reagents.dm` | Ethanol `get_hydration_factor()` |
| `power/rtg.dm` | `aquila/code/modules/power/rtg.dm` | Movable RTG (var, `wrench_act()`, network step of `process()`). The `if(anchored)` in `Initialize()` stays as an AQ EDIT. |
| `projectiles/guns/energy/laser.dm`, `projectiles/projectile/beams.dm`, `projectiles/guns/ballistic/automatic.dm` | `aquila/code/modules/projectiles/...` | Hitscan laser balance var values |
| `subsystem/processing/turf_fire.dm`, `effects/turf_fire.dm`, `icons/effects/turf_fire.dmi`, `sound/weapons/flamethrower{1,2,3,_empty}.ogg` | same paths under `aquila/` | Turf fires (Yogstation #19738): the fire effect and its subsystem |
| `LINDA_fire.dm` (`IgniteTurf()`, ignition in `temperature_expose()`), `LINDA_turf_tile.dm` (`flammability`), `fancy_floor.dm`, `mineral_floor.dm`, `reinf_floor.dm`, `grille.dm`, `tank_types.dm`, `beams.dm` / `_incendiary.dm` (`on_hit()` ignition), `reagents.dm` / `holder.dm` and five reagent files (`accelerant_quality`) | `aquila/code/modules/atmospherics/environmental/LINDA_fire.dm`, `aquila/code/game/turfs/open/floor/turf_fire_flammability.dm`, `aquila/code/game/objects/structures/grille.dm`, `aquila/code/game/objects/items/tanks/tank_types.dm`, `aquila/code/modules/projectiles/projectile/{beams,bullets/_incendiary}.dm`, `aquila/code/modules/reagents/chemistry/accelerants.dm` | Turf fires: var values, new procs and post-`..()` additions |
| `antagonists/morph/morph.dm`, `morph_antag.dm` | `aquila/code/modules/antagonists/morph/morph_objectives.dm` | Morph objectives (Yogstation #13996); counting hooks in through an `eat()` override |
| `nsv13/.../clothing/masks/_masks.dm` | `aquila/code/modules/clothing/masks/gasmask.dm` | Gas mask breathing sound only on internals |

## Remaining core edits, by kind

### Left on purpose: interleaved logic (F unless noted)

These change lines *inside* upstream procs. Moving them would mean copying whole procs into `aquila/` (new full copies) or adding speculative hooks.

- **Thirst / defecation systems** (`species.dm`, `carbon.dm`, `blood.dm`, `food_reagents.dm`, `drink_reagents.dm`, `alcohol_reagents.dm` var, `watercloset.dm`, `cleanable.dm`, `cleanable/humans.dm`, `_shoes.dm`, `__DEFINES/misc.dm`, `__DEFINES/mobs.dm`, species `inherent_traits` lists). Spread across core metabolism procs; architectural.
- **RP filter** (`configuration.dm`, `mob/living/say.dm`, `__DEFINES/say.dm`). Interleaved in `say()`; would need a new say signal.
- **Radio say keybind (Y)** (`subsystem/input.dm`, `client/verbs/input_box.dm`). Data inside core lists.
- **Admin metacoins panel / topic** (`admin.dm`, `topic.dm`). The `modmetacoins` branch sits *after* core `Topic()`'s owner and `CheckAdminHref()` checks. The existing Aquila `Topic()` override runs *before* those checks, so moving the branch there would weaken security. Left in core.
- **Communications console ERT** (`communications.dm`, `requests/request.dm`). Inside `ui_data`/`ui_act`.
- **Holy weapons list** (`holy_weapons.dm`), **compile_monkey_icon multi-state** (`storage.dm`, `_head.dm`, `_masks.dm`, `_under.dm`), **monkey antag check** (`mob_helpers.dm`), **devil/sintouched lust** (`contracts.dm`, `devil/objectives.dm`, `sintouched.dm`, `spell_types/devil.dm`), **sentient disease channels** (`advance.dm`), **nuke challenge TC** (`nuclear_challenge.dm`, `shuttle/syndicate.dm`), **cargo battery export** (`exports.dm`), **looping machine sounds** (`_computer.dm`, `modular_fabricator.dm`, `_production.dm`, `generator.dm`, `lore_terminal.dm`, FTL `drive.dm`).
- **Recent fixes and ports kept inline** (do not move): `stasis.dm` null guard, `implant_storage.dm` deleted-implantee path, `roomspawner.dm` late-load fix, `heal.dm` teratoma loot chance, `macrophage.dm` skin init.
- **Monkey-like trait rename** (`TRAIT_MONKEYLIKE` → `TRAIT_DISCOORDINATED`: `traits.dm`, `_globalvars/traits.dm`, `severe.dm`, `human_helpers.dm`, `status_composers.dm`, `bloody_eye.dm`). A rename across core uses.
- **Nanites rework** (`components/nanites.dm`, `nanite_programs.dm`, `nanite_programs/utility.dm` incl. the Aquila-only `cloud_change` program, `__DEFINES/nanites.dm`, `all_nodes.dm` commented nodes).
- **Turf fires port, interleaved part** (Yogstation #19738): `flamethrower.dm` (fuel and ignition rewrite), `firealarm.dm` (`temperature_expose()` condition), `change_turf.dm` (fire carried over on `ChangeTurf()`), `anomalies.dm` (pyroclastic anomaly), `bottle.dm` (molotov). Everything else of the port is in `aquila/`.
- **Emote update port, interleaved part** (BeeStation #11617): `EMOTE_*` bitflags and `ALWAYS_SHOW_SELF_MESSAGE` (`__DEFINES/say.dm`; `EMOTE_VISIBLE` stays 1 so `emote("me", 1, ...)` callers keep meaning "visible"), `run_emote()` rewrite (`datums/emotes.dm`), self-message runechat and `show_message()` return value (`mob.dm`), custom say emote (`mob/say.dm`, `living/say.dm`), `emote_type` on every emote (core emote files, plus `EMOTE_VISIBLE` on the Aquila/NSV13 emotes that relied on the old default), deathgasp mask sound, moth flutter and whistle sound (`living/emote.dm`). New emotes, animations, the mask var and the emote panel are in `aquila/`.
- **Job datums** (`jobs/job_types/*.dm`, `military_police.dm`, `subsystem/job.dm`). Outfits, implants, slots and exp requirements are mixed with hardened job-title and radio-channel constants. Left alone to avoid touching the job/config parsing hardening.

### Access groups port (BeeStation/BeeStation-Hornet#14139 on the core of BeeStation/BeeStation-Hornet#11209, B/F)

Only the access part of SSdepartment is ported (`aquila/code/controllers/subsystem/department.dm`): department datums with `access_list`, `access_group_name`, `access_filter`, `jobs`, `leaders`, `manager_access`, plus `get_department_by_bitflag()`, `get_jobs_by_dept_id()`, `sorted_department_for_access`. `GLOB.*_positions`, the manifest, preferences and the bank (BeeStation/BeeStation-Hornet#7559) are untouched; BeeStation/BeeStation-Hornet#14395 is not needed. The datums are created lazily, because `get_all_accesses()` can run before `SSdepartment.Initialize()`.

- **Our split stays:** Służba/Ogólne, Ochrona, Medyczny/Ambulatorium, Nauka, Inżynieria, Zaopatrzenie, Dowództwo, Uzbrojenie (MAA, technicians, pilots, controller, Oficer Pokładowy), Centrala and Inne (Syndicate incl. the NSV13 wings, pirates, hunters, away missions, cults, `ACCESS_HERETIC`, `ACCESS_PRISONER`). Job lists match `get_all_jobs()` (unit test). No `ACCESS_SERVICE` (Bee 71 is our `ACCESS_MUNITIONS_STORAGE`).
- **Whitelist instead of Bee's blacklist:** consoles only toggle accesses of the groups the logged-in card manages (`find_access_in_departments()`, matched as text because `ACCESS_HERETIC` is a string). The CentCom console manages every group and logs in any card that passes its `req_access`.
- **Kept from us, not Bee:** demotion only of subordinates and Majtek (Bee: anyone), heads in NtOS assign their subordinates only, the command door remote is Command only, the general minor console is Służba + Zaopatrzenie (Bee: all departments).
- **Bee bugs fixed while porting:** `PRG_grantregion`/`PRG_denyregion` granted the first managed department instead of the clicked one; `get_department_by_bitflag(region)[1]` on a bad href was a runtime (electronics, NtOS); the minor board examine printed the bitflag.
- Pre-existing bugs fixed: `DEPT_MUN = 7` gave the MAA the Command region on the ID console; the „Assistant” demote condition was dead (wrong title and `in` precedence); NtOS heads could grant any region with a crafted `PRG_grantregion`.

### Voices and sounds (`dzwieki` branch)

One-line hooks; everything else is in `aquila/code/modules/mob/voice.dm`, the Aquila emote files and the mirrored machine files.

- `code/game/sound.dm`: `playsound()` accepts a prepared `/sound` (muffled voices) and rolls `vary` once for all listeners; `get_rand_frequency()` returns a playback multiplier instead of Hz (sample-rate independent); extra `get_sfx()` keys in the AQ EDIT block.
- `code/datums/emotes.dm`: `run_emote()` calls `play_emote_sound()` (voice pitch of vocal emotes).
- `code/datums/looping_sounds/_looping_sound.dm`: `play()` passed `extra_range` as `vary`; it also passes `vary`, falloff and `ignore_walls` (vars added in `aquila/code/datums/looping_sounds/machinery_sounds.dm`).
- `code/game/objects/items.dm`: `equip_sound` only when worn (`slot_flags & slot`), not when picked up.
- `code/game/turfs/turf.dm`: `handle_fall()` also thuds, more quietly, when lying down on purpose.
- `code/modules/client/preferences2/character_save.dm`: sanitizing and randomising `features["voice_pitch"]`. The setting itself is the `voice_pitch` entry of the preferences window (`aquila/code/modules/client/preferences_menu/entries_character.dm`, „Posłuchaj” = `voice_pitch_test` in `menu.dm`); the old HTML row in `code/modules/client/preferences.dm` went away with the HTML menu (aq33/AquilaStation#480).
- `code/game/machinery/telecomms/broadcasting.dm`: the receive beep goes to the listener only (`play_radio_receive_sound()`), it used to be a positional sound everyone around heard.
- `code/game/objects/items/devices/radio/radio.dm`: `talk_into_impl()` plays `play_radio_talk_sound()`, audible next to the speaker.

### Smartwires port (BeeStation/BeeStation-Hornet#14275, F)

The power cable system is replaced in core, at the same paths as in BeeStation, so a later upstream sync of smartwires lands on the same files. Merging upstream power code needs care here.

- **Rewritten:** `code/modules/power/cable.dm` (whole file), new `code/modules/power/cable_coil.dm`. NSV13 differences against Bee: cables still hide with `level`/`hide(intact)` (we have no `undertile` element), the `/obj/structure/cable/multiz` mapping subtype (our maps link decks on plain floor), a cable computes its own node on `reform_connections()` and counts linked directions with `!!` (Bee summed the bit values, so only north-ending cables got a node), `clear_connections()` also resets the cable's own links (shuttle moves), player-laid open space cables are multi-z, coil keeps the robotic limb repair, cyborg subtype and `novariants = TRUE`.
- **Changed procs:** `power.dm` (`WANTS_POWER_NODE`, `get_powernet()`, new `get_bridged_cables()`, `get_cable_node()` uses `has_power_node`, old propagation procs removed; `lateShuttleMove()` kept), `powernet.dm` (`dirty`, `mark_dirty()`, `repropogate_cables()` which also walks multi-z cables and `get_bridged_cables()`, and after a split keeps the old powernet on the piece with most of its machines, then most cables, instead of the piece holding `cables[1]`, without queueing it again), `subsystem/machines.dm` (dirty powernet queue in `process_dirty_powernets()`; upstream skipped the last queued net of a run; `dequeue_recalculation()` nulls the entry instead of `-=`, so a powernet deleted mid-run does not shift the queue), `merge_powernets()` carries `avail`/`newavail`/`load` of the absorbed net, `cable.dm` `deconstruct()` unlinks stacked multi-z cables with `unlink_multiz()` (shared with `clear_connections()`) before removing them (upstream recursed forever), `multiz.dm` (deck relays bridge through `get_bridged_cables()`, `break_connections()` marks the net dirty), `turf.dm` (`attackby` lays cable with `place_on_turf()`).
- **Removed:** RCL (`items/RCL.dm`, crafting recipe) and the mech cable layer (`work_tools.dm`); coloured coil subtypes (code and maps repathed); `GLOB.powernets`; cable procs in `on_move.dm` and `shuttle_rotate.dm`; noose stack recipe (now a crafting recipe in `recipes.dm`).
- **Hooks:** `WANTS_POWER_NODE` define in `__DEFINES/machines.dm`, cable colours in `__DEFINES/colors.dm`, `WANTS_POWER_NODE` lines in `grille.dm` and `shieldgen.dm`, two map lints in `tools/ci/check_grep.sh`. NSV13 machines that feed from the cable under them get their `WANTS_POWER_NODE` in `aquila/code/modules/power/smartwires.dm`.
- **Maps:** converted with `tools/smartwires/convert.py`, which keeps every old powernet as exactly one powernet. Run it on maps from older branches before merging them.

### Combat mode port (BeeStation/BeeStation-Hornet#11899, F)

Combat mode and right-click actions are ported in core, at the same paths as in BeeStation, so later Bee click/attack code lands on the same procs. Post-merge Bee fixes included: #12301 (F key), #12324 (a pull survives a misclick next to the grabbed mob), #13404, #13406 (combat mode always hits borgs), the adjacent-shot part of #13155, #14313 (`inverted_rotation`). Merging upstream click, attack, martial arts and HUD code needs care here.

- **Rewritten like Bee:** `_onclick/click.dm`, `_onclick/item_attack.dm`, `_onclick/other_mobs.dm` (secondary attack chain, `tool_act` with `is_right_clicking`), `datums/components/rotation.dm` (Bee API, Alt+LMB/RMB), martial arts (`cqc`, `karate`, `plasma_fist`, `psychotic_brawl`, `sleeping_carp`, `tribal_claw`, `boxing`, `_martial.dm` combos and info button), syringes (LMB injects, RMB draws), airlock/door tool acts, tables, windows, stacks, RCD, closets/chairs/filing cabinets (wrench on RMB).
- **Kept from NSV13 on purpose:** `a_intent`/`possible_a_intents` and the `INTENT_*` defines (the legacy mode needs them), our `can_inject()` signature (Bee's `try_inject`/`INJECT_*` refactor not ported), `RemoveComponent()` (not renamed), `spec_unarmedattacked()`, the devil soul counter, the recycler, sprays, teleprod, stun baton (NSV hard stun), krav maga/wrestling/mushpunch. `apply_martial_art()` only runs human vs human, because our martial arts expect `dna`/species on both sides.
- **Legacy mode:** everything lives in `aquila/code/_onclick/legacy_intents.dm`. Core hooks: `translate_legacy_intent_click()` in `ClickOn()`, `combat_mode_intent_change()`/`legacy_intent_changed()` in `a_intent_change()`, `sync_intent_with_combat_mode()` in `/mob/living/set_combat_mode()`, `update_shift_context_menu()` in `keyDown`/`keyUp`. The old selector types (`/atom/movable/screen/act_intent*`) moved to the same file.
- **Standardisation (both control schemes reach everything):** `check_click_intercept()` translates the disarm intent into a right click (not grab), so abilities that intercept clicks see it. `a_intent_change()` reads `legacy_intent_choices()`, which gives every living mob except silicons all four intents in the legacy mode. The help/disarm/grab/harm keybindings in `datums/keybinding/carbon.dm` work for any living mob. Clicks that skip `ClickOn()` use `is_secondary_click()` (`action_button.dm`, holomap, MOD kinesis). Silicons have no disarm intent, so they keep the right click in the legacy mode (`legacy_keeps_right_click()`). Screentips show `Rozbrój+LPM` instead of `PPM` for legacy players. The combat mode indicator is on by default for every living mob without its own selector.
- **Defines and prefs:** `CHAT_LEGACY_INTENTS`, `CHAT_DISABLE_COMBATMODE_SOUND`, `CHAT_INVERTED_ROTATION` (`chat_toggles`, because `toggles2` is full), `COMSIG_KB_LIVING_TOGGLE_COMBAT_DOWN`, `COMSIG_LIVING_UNARMED_ATTACK`, the secondary attack signals at the end of `signals_atom.dm` (`COMSIG_ITEM_ATTACK_SECONDARY` uses its own string, Bee reused the primary one), `ui_combat_toggle`/`ui_combo`, `NO_DEXTERITY` alias, `ISADVANCEDTOOLUSER()` wrapping our `IsAdvancedToolUser()`. `aquila/code/__DEFINES/span.dm` is included early in `nsv13.dme`, because Bee hunks in core use `span_*`.
- **NSV13 code converted by hand:** KNPC AI (combat mode, sometimes a right-click shove), jujitsu grab, hugbot tipping (RMB), mech clamp arm ripping (RMB), ethereal APC charging (RMB = give power), overmap F key (special weapon action wins over the combat toggle at the helm or guns).
- **Assets:** `combat`/`combat_off` states in every `icons/mob/screen_*.dmi` style plus alien and cyborg, `combo*` states in `screen_gen.dmi`, `icons/effects/mouse_pointers/examine_pointer.dmi`, `sound/misc/ui_togglecombat.ogg`, `ui_toggleoffcombat.ogg`, `sound/effects/glassbash.ogg`, all from Bee.

### Radiation port (BeeStation/BeeStation-Hornet#13442, F)

Promieniowanie tg w wersji Bee: impuls z natężeniem, izolacja mnożona po linii, komponent `irradiated` 0–100%. Z poprawkami Bee#14011 (mutacje od 75% z odstępem), #14339 (`can_mutate`), #14393 (radhealer bez obrażeń), #13796 (burza 1–5%, syrena), fragment #14487 (kostnica). Bez supermaterii, tesli i RBMK z Bee: nasza SM, tesla i reaktor NSV zostają, tylko ich impulsy przeszły na nowe API.

- **W `aquila/`:** makra `aquila/code/__DEFINES/radiation.dm` (dołączane wcześnie w `nsv13.dme`), `radiation_pulse()` i `get_perceived_radiation_danger()` (`__HELPERS/radiation.dm`), `SSradiation` (`controllers/subsystem/radiation.dm`, z `irradiate_internal()` dla leków i oddechu oraz `feed_collectors()`), komponenty `irradiated`, `radiation_countdown`, `geiger_sound`, elementy `radioactive` (plus `add_temporary_radioactivity()`), `radiation_protected_clothing` (nadawany też każdemu ubraniu z pancerzem `rad` >= 100 w `/obj/item/clothing/Initialize()`), efekt `genetic_damage`, licznik Geigera (`game/objects/items/devices/geiger_counter.dm`), `get_clothing_on_part()` (`human_defense.dm`), cechy na czas metabolizmu leków (`reagents/radiation_reagents.dm`), SM (`power/supermatter/supermatter_radiation.dm`), kolektory (`power/singularity/collector.dm`), basen (`modules/pool/pool_radiation.dm`), reakcja pluoxium (`atmospherics/gasmixtures/pluoxium_formation.dm`), syrena burzy (`datums/weather/rad_storm_sounds.dm`, dźwięki w `aquila/sound/weather/radstorm/`, CC-BY 4.0), ikona alertu `aquila/icons/hud/screen_alert_radiation.dmi` (z Bee).
- **Różnice względem Bee:** naturalny zanik 0,1%/s (`RADIATION_NATURAL_DECAY_PER_SECOND`); odporni na toksyny nie dostają obrażeń (Bee: oparzenia); kolektory zostają i dostają dawną siłę z `collector_power`; pociski, `dna_scanner` (przewód LIMIT), RTG z otwartym panelem i rozkład cząstek akceleratora nadal napromieniowują (przeliczone `RAD_LEGACY_TO_INTENSITY` / `RAD_LEGACY_PULSE_TO_INTENSITY`); hełmy hardsuitów mają licznik Geigera słyszalny tylko dla noszącego; mikrolaser zdrajcy napromieniowuje (1–20%), w Bee tylko usypia; prysznic woła komponent bezpośrednio; analizatory czytają komponent i efekt zamiast `COMSIG_LIVING_HEALTHSCAN`; `metabolized_traits` zastąpione `on_mob_metabolize()`; bez angielskich komunikatów głosowych burzy i bez nowego sprite'u burzy.
- **Usunięte z core:** `rad_flags` (zmienna, makra `RAD_PROTECT_CONTENTS`/`RAD_NO_CONTAMINATE`, wpis w `bitfields.dm`, przypisania w drzwiach, ścianach, kratach, oknach, tablicach, rurach zsypu, mechu Ripley, kombinezonach i silikonach), `/atom/proc/rad_act()` z wyjątkiem basenu, nadpisania `rad_act()` (revenant, eminence, hełm hardsuitu, kolektor), sygnały `COMSIG_ATOM_RAD_*`, stara pętla Geigera z `item_sounds.dm`, tryb radiacyjny gogli inżynieryjnych, `PROMIENIOWANIE` na metce pancerza, podtyp `geiger_counter/cyborg`, promieniowanie wstrzykiwaczy DNA, teleportera, zbroi reaktywnej i przyciągania osobliwości (jak w Bee).
- **Przepisane na nowe API (z `AQ EDIT`):** reagenty (`medicine`, `toxin`, `other`, `drink`, `alcohol`), objawy „Promieniujące komórki” i „Apoptotyczna selekcja”, uranowe ściany, podłogi, posągi, fałszywe ściany i śluzy, rdzeń bomby i odłamek SM (`theft_tools.dm`), meteor, granat mrożący, generator mechów, miotacz ognia, eksperymentator, generator grawitacji, RTG, golem uranowy, mutacja promieniotwórcza, podludzie (`TRAIT_RADHEALER`), płuca (nukleium), SSU, sztandar inżynierii, szczotka druciana, przemiany (`transform_procs.dm`), skanery, program `phys_scanner`, konsola DNA. NSV13: stormdrive (impuls co 1 s: zasięg 2, próg 0,7, natężenie `heat × radiation_modifier / 1000` do 2%), RBMK (zasięg 4, próg 0,5, `temperature × spice / 200` do 5%), pręty paliwowe i sterujące, szlam plutonowy, PDSR, generator grawitacji, tłumik bezwładności, trafienia ogólnokwaterowe, skrzynia z bombą (`mission_cargos.dm` nie jest w buildzie, zmiana tylko po to, żeby plik się kompilował), brudny pocisk (element na 5 minut), opad z napędu, prysznic odkażający, środek dla syntetyków. Aquila: inwazja kryształów, gizmo, ksenoarcheologia (wersja z Bee), kuźnia amunicji, analizator TGUI, fermi, horror, empatia (Paradise).

### Bleeding port (BeeStation/BeeStation-Hornet#10372, F)

Bleeding is a status effect (`/datum/status_effect/bleeding` in `mob/living/blood.dm`), ported in core at Bee paths. Post-merge Bee fixes included by hand: #13797 (no blood drop on `add_bleeding()`, dead bodies bleed slower), #13913/#14239 (no blood on groundless turfs or inside containers), #13827 (the cauterise message goes to the victim), #11057 (medbots bandage, rewritten for our tend-wounds medbot). Left out: the blood anomaly event and reactive bleed armour (not medical, needs Bee projectile paths), #11614 self-tend (needs Bee metabolites), #12130 (our operating table does not buckle).

- **`blood.dm` is the Bee file** with our edits on top: the hydration check in blood regeneration (`AQ EDIT`), `DISEASE_SPREAD_FALTERED`, quirks in blood data, `add_bloodiness()`, Polish texts.
- **Kept from NSV13:** the `armor` lists with string keys (`"bleed"` was added to `/datum/armor` next to our `overmap_*` fields), our medical stacks (only the bleeding check and the `stop_bleeding` values changed), our human `attack_animal()` (bleeding added there instead of Bee's carbon version), blood splatter on hits in `spec_attacked_by()` (Aquila hit splatter), the optable bleeding trait on resting.
- **Values:** `bleed_force` and the `"bleed"` armour were copied from Bee by type path (Bee paths mapped to ours, e.g. `/obj/projectile` to `/obj/item/projectile`). NSV13/Aquila clothing got the value of its nearest parent, or 50 for armoured clothes (melee or bullet 20+), same as `/obj/item/clothing/suit/armor`.
- **Assets:** `aquila/icons/hud/screen_alert_bleeding.dmi` (bleeding alerts), `aquila/icons/obj/bleeding.dmi` (pressure offhand), `aquila/sound/surgery/blood_wound.ogg`, all from Bee #10372 (CC-BY-SA 3.0).

### Blood types and species blood colours (BeeStation/BeeStation-Hornet#13410, F)

`code/datums/blood_type.dm` (Bee path) defines `/datum/blood_type` with colour, compatibility and glow. Unlike Bee, `dna.blood_type` and blood DNA lists still hold the type **name** (`"A+"`, `"L"`, `"X*"`), looked up with `get_blood_type()`, so records, cloning, the DNA console, injectors and NSV13 blood freight are untouched. `get_safe_blood()` now reads the datums.

- **Colour:** human blood sprites in `icons/effects/blood.dmi`, `footprints.dmi` and `icons/mob/dam_mob.dmi` were replaced with Bee's greyscale versions; our own states (`trails_*`, `ltrails_*`, Aquila `hitsplatter*`) were greyscaled the same way. Blood decals, drag trails, splatters, item stains, clothing overlays, bloody hands and brute overlays (now tg's greyscale ones in `aquila/icons/mob/effects/dam_mob.dmi`) are tinted with `get_blood_dna_color()`/`get_blood_color()`. Non-blood footprints (oil, xeno, feces) clear the colour. Drying (`make_old()` in `aquila/code/game/objects/effects/decals/cleanable/humans.dm`) darkens the current blood colour by 160/255 instead of setting the flat `BLOOD_DRY_COLOR` (which on the greyscale sprites made dried and mapped `/old` blood grey/black); `make_fresh()` restores the species colour from blood DNA.
- **Species:** IPCs bleed `Coolant` (light grey) instead of oil, ethereals bleed glowing `E` blood instead of liquid electricity, lizards stay `L` (teal). `species.blood_color` was removed. Blood packs: `E` and `Coolant` added, the old liquid electricity `LE` pack is now an `E` pack.
- **Left out from Bee:** datum values in DNA lists, `blush_color`, the inventory slot guards, the `trail_holder` rename (ours was already a child of blood).

### Vampire port (BeeStation vampires, BeeStation/BeeStation-Hornet#12092 and follow-ups, B/F)

The old Hippie/Yogs vampire (`aquila/code/game/gamemodes/vampire/*`, species `vampire`) is gone. The BeeStation antagonist lives in `aquila/code/modules/antagonists/vampire/` with its own compatibility layer (`_compat.dm`, `aquila/code/__HELPERS/tg_compat.dm` copied from the heretic port). Core edits:

- `code/__DEFINES/traits.dm`: `TRAIT_MASQUERADE`, `TRAIT_WHISPER_ONLY` (used by core files below).
- `code/__DEFINES/dcs/signals/signals_mob/signals_living.dm`: `COMSIG_LIVING_PET_ANIMAL`, `COMSIG_LIVING_HUG_CARBON`, `COMSIG_LIVING_APPRAISE_ART` (Humanity gain), sent from `animal_defense.dm`, `carbon_defense.dm` (also the Sol "overheating" hug message) and `artstuff.dm` (paintings; we have no art element).
- `code/datums/hud.dm`: `ANTAG_HUD_VAMPIRE` is a shared (not hidden) antag HUD, vampires and vassals see each other; icons come from `aquila/icons/vampires/vampire_hud.dmi`.
- `code/modules/mob/living/carbon/human/species.dm`: `+ user.unarmed_damage_bonus` in the punch (Bee keeps unarmed damage on arms).
- `code/modules/mob/living/carbon/human/examine.dm`: `status_effect_examines()` also prints `get_examine_text()`.
- `code/modules/mob/living/say.dm`: `TRAIT_WHISPER_ONLY` forces a whisper (Awe).
- `code/game/objects/items/devices/scanners.dm`: Masquerade shows 100% blood.
- `code/game/objects/items/implants/implant_mindshield.dm`: mindshield frees vassals.
- `code/modules/mob/living/blood.dm`: `handle_blood()` skips vampires (their blood is vitae).
- `code/modules/mining/lavaland/necropolis_chests.dm`: memento mori refuses vampires.
- `code/modules/reagents/chemistry/reagents/food_reagents.dm`: garlic checks the vampire antag datum; `other_reagents.dm`: the old holy water burn is removed (Bee has none).
- `code/datums/components/team_monitor.dm`: the monitor can sit on a mob (vassals track their master).
- `code/datums/elements/embed.dm`: `tryForceEmbed()` takes the hit zone from a bodypart target (BeeStation fix; stakes).
- Removed: species `vampire` (`species_types/vampire.dm`, `human.dm` subtype, `isvampire`), the vampire bite in `human_defense.dm`.

### Blood cult "Cult 4" port (Monkestation/Monkestation2.0#3867 draft + vgstation, B/F)

The BeeStation blood cult is replaced. The new cult (rune words, rune spells, rituals, devotion, tattoos, Eclipse, Tear Reality, Blood Stone, mind_ui cult panel, refusable conversion, constructs and shades) lives in `aquila/code/modules/antagonists/bloodcult/`, included from the generated `aquila/bloodcult.dm`. Compatibility helpers are in `bloodcult/_compat/` (`core.dm`: mind_ui on `/datum/mind` and `/mob`, Login/Logout, MouseDown/MouseUp, cult fullscreens; `integration.dm`: deconversion ritual, chaplain cross, Eclipse ghosts, parallax rifts, cult backpack; the rest per area). Removed: `code/modules/antagonists/cult/blood_magic.dm`, `cult.dm`, `cult_comms.dm`, `cult_structures.dm` (old `/obj/structure/destructible/cult` base now in `bloodcult/structures/destructable/`). `rune_spawn_action.dm` stays (constructs). Core edits:

- `code/modules/antagonists/cult/runes.dm`: removed convert/narsie/apocalypse runes, empower invoke, manifest ghost actions (as in the draft).
- `code/modules/antagonists/cult/cult_items.dm`: removed tome, cultblade (dagger, ghost), bastard sword, dash, bola, spear, robes/hardened (redefined in `bloodcult/items` and `bloodcult/clothing`); shield hood is `/obj/item/clothing/head/hooded/cult_hoodie/cult_shield`.
- `code/modules/antagonists/cult/narsie.dm`: `set_blood_target(src, duration = INFINITY)` instead of the eldergod objective.
- `code/datums/components/cult_ritual_item.dm`: rune scribing cut out (runes are written through the tome/rune words).
- `code/game/gamemodes/cult/cult.dm`: no `is_sacrifice_target`/`is_convertable_to_cult` (moved to `bloodcult/helpers`), credits read `narsie_summoned`.
- `code/game/objects/items/stacks/sheets/sheet_types.dm`: runed metal recipes without pylon/forge/altar (now rune spells), archives use the item dispenser, plus cult bindings.
- `code/_onclick/hud/alert.dm`: bloodsense alert without sacrifice/eldergod branches.
- `code/_onclick/hud/parallax.dm`: `create_parallax` calls `bloodcult_eclipse_parallax(C)` (Eclipse rifts and red sky).
- `code/_onclick/hud/radial.dm`: `radial_icon` on `/datum/radial_menu` and `show_radial_menu()`.
- `code/modules/tooltip/tooltip.html`: `.radial-cult` CSS theme for cult panel tooltips.
- `code/modules/mob/living/living_defense.dm`: `/mob/living/narsie_act` always makes a random hostile construct (proteon included).
- `code/modules/reagents/chemistry/reagents/other_reagents.dm`: holy water no longer purges blood magic nor deconverts after 30u (deconversion is the bible ritual).
- `code/modules/mob/living/simple_animal/constructs.dm`: rune actions and the eldergod objective cut from constructs; draft construct changes live in `bloodcult/constructs/`.
- `code/modules/antagonists/wizard/equipment/soulstone.dm`: no sacrifice-target lock, perfect gem constructs, cultists made through `add_antag_datum` and `CanConvert()`, `report_construct_built()` for the `build_construct` ritual key.
- `code/modules/unit_tests/create_and_destroy.dm`: `bloodcult_create_and_destroy_ignores()` (as the draft's unit_test.dm).
- `code/modules/shuttle/.../generator_netherworld.dm`: new pylon/forge types.
- `nsv13/code/modules/antagonists/bloodling.dm`: `SUMMON_POSSIBILITIES` define (was in the removed cult.dm).
- `aquila/code/modules/antagonists/heretic/items/heretic_armor.dm`: `hood_up` comes from the new cult robes.
- Overrides with `..()` in `bloodcult/_compat/`: `/client/Move_object` (soulblade control), `/mob/living/Login|Logout`, `/client/MouseDown|MouseUp`, `/datum/mind/Destroy`, observer `narsie_act`, `/mob/living/carbon/human/death` (cultist becomes a shade, `bloodcult/rune_spells/reincarnation.dm`).
- Maps: old talisman/forge/pylon/tome structures swapped for `/obj/structure/cult/*` and archives; convert/narsie runes removed.

### Munitions forge (ParadiseSS13 smithing, B)

The forge lives in `aquila/code/modules/munitions_forge/`. Forged ammunition carries `/datum/component/forged_munition`, which is copied onto every projectile through one-line hooks marked `AQUILA EDIT - kuźnia amunicji`:

- `code/modules/projectiles/ammunition/_firing.dm`: `ready_proj()` copies the component from the casing to `BB`.
- `nsv13/code/modules/overmap/weapons/damage.dm`: `forged_munition_overmap_hit()` before `spec_overmap_hit()`.
- `animate_projectile()` in `deck_guns.dm`, `broadsides.dm`, `gauss_gun.dm`, `torpedo_launcher.dm` and `revision2/vls.dm`: copy from `chambered` to the fired projectile (broadsides and gauss now keep the returned projectile in a var).
- Fighters: `primary/fire()` and `secondary/ordnance_launcher/fire()` in `_fighters.dm` return the ammo object instead of its `projectile_type`; `async_nonphysical_fire()` in `delta_overmap_ship_weapons/firing.dm` fires its `projectile_type`, copies the component and deletes it.
- `new_torpedo()` / `new_missile()` in `torpedo_construction.dm` / `missile_construction.dm`: copy from the warhead to the built munition.
- `railgun_forge.dm`: `getConductivity/getDensity/getHardness` read the shared `/datum/munition_material` table instead of three `switch` blocks (same values).
- `code/_onclick/adjacent.dm`: `/turf/Adjacent()` treats a multi-tile movable (`length(locs) > 1`) as adjacent through any turf it covers. Without it the 3x3 crucible and 2x2 hammer/furnace are reachable only from their bottom-left tile.

### Small tgstation medical ports

- **Hearts regenerate blood (tgstation#96129):** `aquila/code/modules/surgery/organs/heart_blood.dm`; core hook: the multiplier in the `AQ EDIT` block of `/mob/living/carbon/human/handle_blood()` (`mob/living/blood.dm`).
- **Cause of death (tgstation#95655):** `AQ EDIT` lines in `machinery/computer/medical.dm` (shown and editable only for `*Deceased*`, wiped on any other status, printed on the record). Stored in the general record as `fields["cause_of_death"]`.
- **IV drip tube (tgstation#88217):** `aquila/code/game/machinery/iv_drip_beam.dm` and `aquila/code/datums/components/tug_towards.dm`, synced from `update_icon()`, no core edit. Our old `/datum/beam` has no colour or origin offset, so the tube is a silver `/obj/effect/ebeam/iv_tube` drawn from the drip's centre.
- **Defibrillation without a time limit (tgstation style):** `aquila/code/game/objects/items/defib_reasons.dm` (`is_defib_possible()`, `has_dnr()`, med HUD refresh when a dead heart or brain decays). Core hooks marked `AQ EDIT`: `shockpaddles/can_defib()` and the DNR reason in `do_help()` (`items/defib.dm`), the defib-able HUD icon (`data_huds.dm`), the analyzer line (`scanners.dm`), the stethoscope (`clothing/neck/_neck.dm`). `DEFIB_TIME_LIMIT` is now only used by the old HUD refresh timer in `living/death.dm`.
- **BeeStation surgeries:** stomach pump (`aquila/code/modules/surgery_tg/operation_pump.dm`) and identity recalibration (`operation_identity_recalibration.dm`, robotic chests, BeeStation #12856), on the new surgery skeleton. Our `vomit()` has no `purge_ratio`, so the pump removes 67% of the stomach contents itself (since BeeStation/BeeStation-Hornet#14340 swallowed reagents wait in the stomach, the blood stays untouched); the rename uses `fully_replace_character_name()` instead of only `real_name`.
- **Vitals monitor (tgstation#94704):** `aquila/code/game/machinery/vitals_reader.dm`, icon `aquila/icons/obj/machines/vitals_monitor.dmi` (tgstation, MrMelbert, CC-BY-SA 3.0). Built from a protolathe frame (biotech / advanced biotech nodes), connects with a multitool to an operating table, stasis bed, sleeper, cryo cell, DNA scanner or autodoc within 3 tiles. Our machines have no occupant signal, so it polls the machine each process tick. Core hook: `tochat = FALSE` in `healthscan()`/`chemscan()` (`scanners.dm`, `AQ EDIT`) returns the text for examine. Not placed on maps.
- **Autopsy (tgstation coroner, #75065/#77386/#89094):** the operation in `aquila/code/modules/surgery_tg/operation_autopsy.dm`, the autopsy scanner in `aquila/code/modules/surgery/autopsy.dm` (2 in every NanoMed Plus, protolathe design in biotech). Uses its own `autopsied` trait (removed on revive) instead of `TRAIT_DISSECTED`, so experimental dissection still works; no "surgically analyzed" bonus, morbid mood or experiment. Icons from tgstation (CC-BY-SA 3.0): `aquila/icons/obj/autopsy_scanner.dmi`, `aquila/icons/mob/inhands/autopsy_scanner_*.dmi`, `aquila/icons/mob/autopsy_scanner_belt.dmi`.
- **Recovered Crew and Thanatorenasia (tgstation#87072, #87491, #95469):** `aquila/code/modules/lost_crew/`. Cargo crate "Odzyskana załoga" (medical, 2000 kr) with a body bag holding a dead crewmember (random look, job and cause of death, decayed organs, maybe a lost limb). Revived without a player, the body polls ghosts (`/datum/component/ghostrole_on_revive`, mob only, through SSpolling, takeover like `offer_control()`); the new player gets the job via `SSjob.EquipRank()` and the manifest, and medbay gets 3000 kr if they live 3 minutes. Simplified from tg: our own seven causes of death, no mind lockbox, no brain-removal bomb, no spawner menu entry or soul eyes. Thanatorenasia is a 0-point quirk: choosing DNR adds the component. Core hook: `on_dnr()` in the ghost DNR verb (`observer.dm`, `AQ EDIT`); `has_dnr()` ignores bodies with the component. Event "Recovered Crew Delivery" (`lost_crew_delivery.dm`, subtype of the stray cargo pod) drops a free body bag in the cargo bay up to twice a round; every bag holds a card with step-by-step revival instructions.
- **Medical records console in TGUI:** `aquila/code/game/machinery/computer/medical_records_ui.dm` + `MedicalRecordsConsole.tsx`, same approach as the security console: buttons send the old link parameters through `Topic()`, so logging, access checks and printing stay in `medical.dm`. Record statuses stay in English in the records (HUDs read them) and are translated in the window only.
- **tgstation sutures and regenerative mesh:** `aquila/code/game/objects/items/stacks/medical_tg.dm`, sprites in `aquila/icons/obj/medical/stack_medical.dmi`. They replace bruise packs and ointment (`AQ EDIT`) in `firstaid.dm`, `boxes.dm`, crafting `recipes.dm`, `ghost_role_spawners.dm`, `warping.dm`, the ruin generator `mapping.dm` and `maintenance_loot.dm`, and are sold by both NanoMeds (`vending/medical.dm`, `medical_wall.dm`). Bruise packs and ointment were removed as types in aq33/AquilaStation#530 (see the bandage entry below).
- **tgstation medkit sprites:** `aquila/icons/obj/medical/medkit.dmi` and `aquila/icons/mob/inhands/equipment/medkit_*hand.dmi`; `firstaid.dm` icon states (`AQ EDIT`, no random alternate sprites any more); radiation and mystery kits keep the old Aquila sprites, the gang medkit (`gang_items.dm`) uses `oldbezerk`.
- **Bandage replaces gauze (aq33/AquilaStation#530):** `aquila/code/modules/medical/bandage.dm`. The bandage is a 12-piece stack that stops bleeding (`stop_bleeding = BLEED_CRITICAL`), heals 5 brute, splints fractures and is cut into cloth, i.e. Bee gauze under a tg sprite; makeshift (from cloth, ex improvised gauze), sterile (ex `gauze/adv`, crafted with sterilizine) and cyborg subtypes. Gauze, bruise packs and ointment are deleted from `stacks/medical.dm` (`AQ EDIT`); paths swapped (`AQ EDIT - bandage replaces gauze`) in `firstaid.dm`, crafting `recipes.dm`, `sheet_types.dm` (cloth recipe, no marker inside the macro list), `watercloset.dm` (sink rag), `cargo/packs.dm`, `robot_modules.dm`, `warping.dm`, `lavaland_ruin_code.dm` (cloth golem), the ruin generator `mapping.dm` and both NanoMeds. Maps converted with `tools/UpdatePaths/Scripts/530_bandage_replaces_gauze.txt` (gauze to bandage, bruise pack to sutures, ointment to mesh).
- **Light wounds (tgstation wounds, simplified):** `aquila/code/modules/wounds/`, defines in `aquila/code/__DEFINES/wounds.dm`. Rolled in `human/attacked_by()` and `human/bullet_act()` overrides from the damage each limb really took (snapshot before and after `..()`), so no core hit code changes. Blunt (dislocation, fracture, compound fracture), slash on top of Bee bleeding (deep cut, torn artery), burn (second and third degree with infection). Treatment: help intent with an empty hand resets dislocations, a bandage splints fractures, sutures close cuts, mesh dresses burns; bone and debridement operations of the new surgery skeleton (`aquila/code/modules/surgery_tg/operation_bone_repair.dm`, `operation_debride.dm`). Core hook: wound lines in `healthscan()` (`scanners.dm`, `AQ EDIT`). No scars, wound armor or per-weapon wound bonus; `WOUND_THRESHOLD_MULTIPLIER` tunes how often they happen.
- **Health analyzer window (PowerfulBacon-2/AuriStation#15):** `aquila/code/game/objects/items/devices/health_analyzer_ui.dm`, `HealthAnalyzer.tsx`, `components/ScrollingChart.tsx` and two stylesheets. Health mode on carbons opens the window (body outline, injuries per limb, pulse/oxygen/blood/damage charts, reagents); chemical mode, simple mobs and clumsy users keep the chat scan, and the window has a button to print the old scan to chat. Auri's pain, consciousness and injury trees are not ported, the data comes from our damage, wounds, bleeding, organs, traumas and diseases.
- **Vitals monitors over stasis beds and next surgery step:** every stasis bed on Atlas, Snake and Serendipity has a wall vitals monitor paired by `id_tag` (`aq_vitals_<map>_<x>_<y>`), so it never links to a neighbouring operating table; wall items that sat in that spot were moved to a free wall spot in the same room (Atlas brig and medbay fire alarms, light switch and intercom; Snake defibrillator mount; Serendipity status display, camera and poster). The advanced health analyzer (window and chat) shows each operated zone's surgical state and the operations possible next (`aquila/code/modules/surgery/surgery_progress.dm`, chat line in `healthscan()`, `AQ EDIT`).

### Jetpack i dryf w kosmosie (BeeStation/BeeStation-Hornet#14864, B/F)

Port tg#54416, #65005, #65769, #66567, #66628, #76133 przez Bee. Komponent jetpacka jest w `aquila/code/datums/components/jetpack.dm`, reszta to edycje core z `AQ EDIT` (synchronizacji z upstreamem już nie robimy). Testy: `aquila/code/modules/unit_tests/aquila_jetpack_drift.dm`.

- **Pętla ruchu:** `status` (`MOVELOOP_STATUS_RUNNING`/`QUEUED`, defines w `__DEFINES/movement.dm`), `queued_time` i `pause_for()` z BeeStation/BeeStation-Hornet#14176 (`movement.dm`, `movement_types.dm`), bez reszty tamtego PR (orbita, `pause_loop()`, wyniki `MOVELOOP_SUCCESS`). Kubełek wyjmowany po `queued_time`, a pętla wstawiona już w `process()` (`pause_for()`) nie idzie drugi raz do kubełka. `// AQUILA` z `process()` zostaje.
- **Dryf:** `drift.dm` (opóźniony start `start_delay`, `apply_initial_visuals()` zamiast ślizgu w `newtonian_move()` i usuniętego `/mob/newtonian_move()`, pauza pętli przy własnym ruchu z `COMSIG_MOVABLE_UPDATE_GLIDE_SIZE`, puszczony przedmiot leci dalej, `COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT`/`DRIFT_BLOCK_INPUT` dla jetpacka). Inaczej niż w Bee `NEWTONIAN_MOVE` rejestrujemy w `Initialize()` i zdejmujemy przy zatrzymaniu pętli, a ślizg 0 nie wstrzymuje pętli.
- **`Process_Spacemove(movement_dir, continuous_move)`:** drift sprawdza oparcie z kierunkiem i `continuous_move = TRUE`; parametr dostały wszystkie nadpisania (core, `nsv13/` i `aquila/`), bo nazwany argument nieznany w nadpisaniu to runtime. `newtonian_move(direction, instant, start_delay)` tak samo. `/mob/Process_Spacemove()` w trakcie dryfu nie odpycha się od niczego, `last_pushoff` blokuje odepchnięcie od moba, który w tym ticku sam się odepchnął. `get_spacemove_backup()` (movable i mob) jak w Bee. Mech (`/obj/mecha`, nasz stary) przepisany ręcznie: przy ścianie staje też bez kierunku; inaczej niż w Bee dysze mecha działają tylko przy własnym ruchu (w Bee zatrzymywały dryf i zużywały gaz drugi raz na krok).
- **Jetpacki:** `items/tanks/jetpack.dm` (plecaki, improwizowany, `jetpack/suit` w hardsuitach zostaje i ciągnie z butli w schowku przez `get_thrust_user()`), implant dysz (`augments_chest.dm`, `activate()`/`deactivate()`), moduł jetpacka (`modules_general.dm`). `/mob/living/carbon/Process_Spacemove()` z plecakiem i implantem usunięte (`carbon_movement.dm`), tak samo `AQUILA EDIT` w `carbon/Move()`, który drugi raz wołał `allow_thrust()` (podwójne zużycie paliwa, też w grawitacji). Paliwo schodzi przez `remove_air()`: stare `assume_air_moles(air_contents, num)` przelewało gaz z butli do niej samej. Prędkości zostają nasze (`MOVESPEED_ID_JETPACK`, `MOVESPEED_ID_CYBER_THRUSTER`, −2), nie datumy z BeeStation/BeeStation-Hornet#9992.
- **Pominięte z Bee:** refaktor paralaksy (BeeStation/BeeStation-Hornet#7041/#10202/#13660, `connect_mob_behalf`, warstwa planety, `COMSIG_VIEW_SET`), `canon_client`/`become_uncliented()`, settery VV i `admin_teleport()`, `map_view`, listy żywych/martwych mobów, jetpack w pionie (BeeStation/BeeStation-Hornet#8044), usunięcie hardsuitów, `SLIDE_STEPS` MULEbota.

### Data tweaks left in core lists (D-like)

Vending product lists (`wardrobes.dm`, `clothesmate.dm`, `autodrobe.dm`, `plasmaresearch.dm`, `munitions_machinery.dm`), loot lists (`lootdrop.dm`, `mailspawner.dm`, `uplink_kits.dm`, `boxes.dm`, `cargo/packs.dm`, `security.dm` closet), techweb `design_ids` (`all_nodes.dm`), `poll_ignore.dm`, ambience lists. Overriding a whole list in `aquila/` would silently hide upstream additions, which is worse than a visible merge conflict.

### Sound and resource swaps (D-like)

About 40 single-line `playsound`/`sound =`/`icon =` swaps to `aquila/sound` or `aquila/icons` inside upstream procs (mecha, robots, bots, medbot voice lines, cat/dog, hydroponics, chem dispenser, pour sounds, megaphone, lightswitch, newscaster, particle accelerator, ORM, title music volume, ...). Each is a one-line change in the middle of an upstream proc.

### Map-bound (E)

`mapping/random_rooms.dm` (Aquila room templates), `effects/spawners/roomspawner.dm` (gulag/atlas spawners), `nsv13/.../munitions_trolley.dm` dummy, `datums/map_config.dm` (`has_gulag`), area definitions in `game/area/*` and `nsv13/code/game/area/*` (Polish names; maps reference these types), `controllers/subsystem/mapping.dm`. Not touched.

Known pre-existing issue: the gulag random room `sk_rdm_glg_06` (Syndicate Listening Post) has stacked pipes. When the spawner rolls it, two runtimes fire during `SSair` template setup (`set_pipenet` index out of bounds). This makes CI runs randomly unclean, on master as well.

### Aquila feature ports living at upstream paths (F)

The heretic rework (`antagonists/heretic/**`, replacing `eldritch_cult/**`), space dragon rework (`space_dragon/**`, `gravity_aura`), `snacks_cheese.dm`, `void_storm.dm` and their unit tests. These are BeeStation ports kept at BeeStation paths so later BeeStation cherry-picks apply cleanly. Moving them into `aquila/` would also change `typesof()`/`subtypesof()` order (surgery menu order, knowledge lists), so it is not behaviour-neutral.

### Localization only (D)

String-only changes (Polish translations) in core: see the generated list below. Kept in place; moving thousands of strings would only make merges worse. `__DEFINES/radio.dm` (Polish radio channel names) and `__DEFINES/jobs.dm` (Polish job titles) are string-only but are load-bearing for the hardening fixes (channel constants, job title lookups). Never move or retranslate them independently.

### Other notes

- `aquila/code/modules/food_and_drinks/recipes/tablecraft/recipes_pie.dm` exists but is not included in `aquila.dm`. It is dead on master; including it would change crafting, so it was left alone.
- The Aquila `/datum/admins/Topic()` override (`aquila/code/modules/admin/topic.dm`) handles `makeAntag` before core's `CheckAdminHref()` validation. It does call `check_rights(R_ADMIN)`. Worth hardening separately.

## Generated inventory (core files differing from the upstream merge base)

Produced by comparing every changed line with string literals, `'resource'` literals and comments masked out.

| Kind | Files |
|---|---|
| Logic changes (incl. string changes) | 420 |
| Localization only | 111 |
| Localization and resource swaps only | 9 |
| Comment/whitespace only (or binary) | 30 |
| Added by Aquila | 60 |
| Deleted by Aquila | 13 |

Of the logic files, 182 contain an AQ/AQUILA marker or an `aquila/` resource; the other 238 are unmarked (mostly older Aquila ports and translations mixed with code).

<details><summary>Localization only (111)</summary>

- `code/__DEFINES/jobs.dm`
- `code/__DEFINES/radio.dm`
- `code/__HELPERS/priority_announce.dm`
- `code/controllers/subsystem/nightshift.dm`
- `code/datums/ai/dog/dog_controller.dm`
- `code/datums/ai_laws.dm`
- `code/datums/components/aiming.dm`
- `code/datums/weather/weather_types/ash_storm.dm`
- `code/datums/weather/weather_types/radiation_storm.dm`
- `code/game/area/Space_Station_13_areas.dm`
- `code/game/area/ai_monitored.dm`
- `code/game/gamemodes/brother/traitor_bro.dm`
- `code/game/gamemodes/events.dm`
- `code/game/gamemodes/events/event.dm`
- `code/game/gamemodes/gangs/gangs.dm`
- `code/game/gamemodes/incursion/incursion.dm`
- `code/game/gamemodes/objective.dm`
- `code/game/gamemodes/objective_items.dm`
- `code/game/gamemodes/overthrow/overthrow.dm`
- `code/game/machinery/announcement_system.dm`
- `code/game/machinery/computer/security.dm`
- `code/game/machinery/doppler_array.dm`
- `code/game/objects/items/cardboard_cutouts.dm`
- `code/game/objects/items/religion.dm`
- `code/game/objects/items/storage/backpack.dm`
- `code/modules/antagonists/blob/blob.dm`
- `code/modules/antagonists/blob/blob_mobs.dm`
- `code/modules/antagonists/blob/blobstrains/_blobstrain.dm`
- `code/modules/antagonists/blob/blobstrains/blazing_oil.dm`
- `code/modules/antagonists/blob/blobstrains/cryogenic_poison.dm`
- `code/modules/antagonists/blob/blobstrains/electromagnetic_web.dm`
- `code/modules/antagonists/blob/blobstrains/energized_jelly.dm`
- `code/modules/antagonists/blob/blobstrains/explosive_lattice.dm`
- `code/modules/antagonists/blob/blobstrains/networked_fibers.dm`
- `code/modules/antagonists/blob/blobstrains/pressurized_slime.dm`
- `code/modules/antagonists/blob/blobstrains/reactive_spines.dm`
- `code/modules/antagonists/blob/blobstrains/regenerative_materia.dm`
- `code/modules/antagonists/blob/blobstrains/replicating_foam.dm`
- `code/modules/antagonists/blob/blobstrains/shifting_fragments.dm`
- `code/modules/antagonists/blob/blobstrains/synchronous_mesh.dm`
- `code/modules/antagonists/blob/blobstrains/zombifying_pods.dm`
- `code/modules/antagonists/blob/overmind.dm`
- `code/modules/antagonists/blob/structures/_blob.dm`
- `code/modules/antagonists/blob/structures/core.dm`
- `code/modules/antagonists/blob/structures/factory.dm`
- `code/modules/antagonists/blob/structures/node.dm`
- `code/modules/antagonists/blob/structures/resource.dm`
- `code/modules/antagonists/blob/structures/shield.dm`
- `code/modules/antagonists/official/official.dm`
- `code/modules/atmospherics/machinery/components/unary_devices/cryo.dm`
- `code/modules/cargo/orderconsole.dm`
- `code/modules/client/preferences2/character_save.dm`
- `code/modules/clothing/masks/hailer.dm`
- `code/modules/crew_objectives/_crew_objectives.dm`
- `code/modules/crew_objectives/cargo_objectives.dm`
- `code/modules/crew_objectives/command_objectives.dm`
- `code/modules/crew_objectives/engineering_objectives.dm`
- `code/modules/crew_objectives/medical_objectives.dm`
- `code/modules/crew_objectives/security_objectives.dm`
- `code/modules/events/grid_check.dm`
- `code/modules/events/shuttle_loan.dm`
- `code/modules/mob/living/carbon/emote.dm`
- `code/modules/mob/living/emote.dm`
- `code/modules/mob/living/simple_animal/friendly/drone/_drone.dm`
- `code/modules/mob/living/simple_animal/friendly/drone/drones_as_items.dm`
- `code/modules/mob/living/simple_animal/friendly/drone/extra_drone_types.dm`
- `code/modules/mob/living/simple_animal/hostile/retaliate/ghost.dm`
- `code/modules/modular_computers/computers/item/role_tablet_presets.dm`
- `code/modules/projectiles/boxes_magazines/external/rifle.dm`
- `code/modules/reagents/chemistry/machinery/pandemic.dm`
- `code/modules/shuttle/emergency.dm`
- `code/modules/vending/_vending.dm`
- `code/modules/vending/boozeomat.dm`
- `code/modules/vending/cigarette.dm`
- `code/modules/vending/coffee.dm`
- `code/modules/vending/cola.dm`
- `code/modules/vending/drinnerware.dm`
- `code/modules/vending/games.dm`
- `code/modules/vending/liberation_toy.dm`
- `code/modules/vending/magivend.dm`
- `code/modules/vending/medical.dm`
- `code/modules/vending/megaseed.dm`
- `code/modules/vending/mining.dm`
- `code/modules/vending/modularpc.dm`
- `code/modules/vending/nutrimax.dm`
- `code/modules/vending/security.dm`
- `code/modules/vending/snack.dm`
- `code/modules/vending/sovietsoda.dm`
- `code/modules/vending/sustenance.dm`
- `code/modules/vending/toys.dm`
- `nsv13/code/controllers/subsystem/overmap_mode.dm`
- `nsv13/code/game/area/aetherwhisp.dm`
- `nsv13/code/game/area/areas.dm`
- `nsv13/code/game/area/boarding_areas.dm`
- `nsv13/code/game/area/hammerhead.dm`
- `nsv13/code/game/area/hammurabi.dm`
- `nsv13/code/game/area/pegasus.dm`
- `nsv13/code/game/gamemodes/overmap/courier.dm`
- `nsv13/code/game/gamemodes/overmap/shakedown.dm`
- `nsv13/code/game/objects/items/custom_guns.dm`
- `nsv13/code/modules/antagonists/simple_teamchat.dm`
- `nsv13/code/modules/mob/living/carbon/human/species_types/catgirl.dm`
- `nsv13/code/modules/mob/living/carbon/human/species_types/other_knpc.dm`
- `nsv13/code/modules/mob/living/carbon/human/species_types/spacepirate_knpc.dm`
- `nsv13/code/modules/mob/living/carbon/human/species_types/syndicate_knpc.dm`
- `nsv13/code/modules/mob/living/simple_animal/bot/catmed.dm`
- `nsv13/code/modules/overmap/FTL/ftl_jump.dm`
- `nsv13/code/modules/overmap/factions.dm`
- `nsv13/code/modules/overmap/fleet_combat/combat_handling.dm`
- `nsv13/code/modules/overmap/overmap.dm`
- `nsv13/code/modules/overmap/weapons/damage.dm`

</details>

<details><summary>Localization and resource swaps only (9)</summary>

- `code/controllers/subsystem/communications.dm`
- `code/datums/brain_damage/special.dm`
- `code/game/objects/items/devices/scanners.dm`
- `code/modules/antagonists/traitor/equipment/Malf_Modules.dm`
- `code/modules/flufftext/Hallucination.dm`
- `code/modules/mob/living/silicon/robot/emote.dm`
- `code/modules/mob/living/simple_animal/bot/SuperBeepsky.dm`
- `code/modules/mob/living/simple_animal/bot/secbot.dm`
- `code/modules/mob/living/simple_animal/hostile/netherworld.dm`

</details>

<details><summary>Added by Aquila (60)</summary>

- `code/controllers/subsystem/processing/gravity_aura.dm`
- `code/datums/components/gravity_aura.dm`
- `code/datums/weather/weather_types/void_storm.dm`
- `code/modules/antagonists/heretic/heretic_antag.dm`
- `code/modules/antagonists/heretic/heretic_focus.dm`
- `code/modules/antagonists/heretic/heretic_knowledge.dm`
- `code/modules/antagonists/heretic/heretic_living_heart.dm`
- `code/modules/antagonists/heretic/heretic_monsters.dm`
- `code/modules/antagonists/heretic/influences.dm`
- `code/modules/antagonists/heretic/items/crucifix.dm`
- `code/modules/antagonists/heretic/items/eldritch_flask.dm`
- `code/modules/antagonists/heretic/items/forbidden_book.dm`
- `code/modules/antagonists/heretic/items/heretic_armor.dm`
- `code/modules/antagonists/heretic/items/heretic_blades.dm`
- `code/modules/antagonists/heretic/items/heretic_necks.dm`
- `code/modules/antagonists/heretic/items/madness_mask.dm`
- `code/modules/antagonists/heretic/knowledge/ash_lore.dm`
- `code/modules/antagonists/heretic/knowledge/flesh_lore.dm`
- `code/modules/antagonists/heretic/knowledge/general_side.dm`
- `code/modules/antagonists/heretic/knowledge/rust_lore.dm`
- `code/modules/antagonists/heretic/knowledge/sacrifice_knowledge/sacrifice_buff.dm`
- `code/modules/antagonists/heretic/knowledge/sacrifice_knowledge/sacrifice_knowledge.dm`
- `code/modules/antagonists/heretic/knowledge/sacrifice_knowledge/sacrifice_map.dm`
- `code/modules/antagonists/heretic/knowledge/sacrifice_knowledge/sacrifice_moodlets.dm`
- `code/modules/antagonists/heretic/knowledge/side_ash_flesh.dm`
- `code/modules/antagonists/heretic/knowledge/side_flesh_void.dm`
- `code/modules/antagonists/heretic/knowledge/side_rust_ash.dm`
- `code/modules/antagonists/heretic/knowledge/side_void_rust.dm`
- `code/modules/antagonists/heretic/knowledge/starting_lore.dm`
- `code/modules/antagonists/heretic/knowledge/void_lore.dm`
- `code/modules/antagonists/heretic/magic/aggressive_spread.dm`
- `code/modules/antagonists/heretic/magic/ash_ascension.dm`
- `code/modules/antagonists/heretic/magic/ash_jaunt.dm`
- `code/modules/antagonists/heretic/magic/blood_cleave.dm`
- `code/modules/antagonists/heretic/magic/blood_siphon.dm`
- `code/modules/antagonists/heretic/magic/eldritch_blind.dm`
- `code/modules/antagonists/heretic/magic/eldritch_emplosion.dm`
- `code/modules/antagonists/heretic/magic/eldritch_shapeshift.dm`
- `code/modules/antagonists/heretic/magic/eldritch_telepathy.dm`
- `code/modules/antagonists/heretic/magic/flesh_ascension.dm`
- `code/modules/antagonists/heretic/magic/madness_touch.dm`
- `code/modules/antagonists/heretic/magic/manse_link.dm`
- `code/modules/antagonists/heretic/magic/mansus_grasp.dm`
- `code/modules/antagonists/heretic/magic/nightwatcher_rebirth.dm`
- `code/modules/antagonists/heretic/magic/rust_wave.dm`
- `code/modules/antagonists/heretic/magic/void_phase.dm`
- `code/modules/antagonists/heretic/magic/void_pull.dm`
- `code/modules/antagonists/heretic/rust_effect.dm`
- `code/modules/antagonists/heretic/structures/carving_knife.dm`
- `code/modules/antagonists/heretic/structures/mawed_crucible.dm`
- `code/modules/antagonists/heretic/transmutation_rune.dm`
- `code/modules/antagonists/space_dragon/carp_rift.dm`
- `code/modules/food_and_drinks/food/snacks_cheese.dm`
- `code/modules/mob/living/simple_animal/heretic_monsters.dm`
- `code/modules/mob/living/simple_animal/hostile/space_dragon.dm`
- `code/modules/unit_tests/heretic_knowledge.dm`
- `code/modules/unit_tests/heretic_rituals.dm`

</details>

<details><summary>Deleted by Aquila (13)</summary>

- `code/game/machinery/dance_machine.dm`
- `code/modules/antagonists/disease/disease_abilities.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_antag.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_book.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_effects.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_items.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_knowledge.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_magic.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_monster_antag.dm`
- `code/modules/antagonists/eldritch_cult/knowledge/ash_lore.dm`
- `code/modules/antagonists/eldritch_cult/knowledge/flesh_lore.dm`
- `code/modules/antagonists/eldritch_cult/knowledge/rust_lore.dm`
- `code/modules/mob/living/simple_animal/eldritch_demons.dm`

</details>

<details><summary>Logic changes with AQ markers (182)</summary>

- `code/__DEFINES/DNA.dm`
- `code/__DEFINES/contracts.dm`
- `code/__DEFINES/dcs/signals/signals_global.dm`
- `code/__DEFINES/misc.dm`
- `code/__DEFINES/mobs.dm`
- `code/__DEFINES/nanites.dm`
- `code/__DEFINES/preferences.dm`
- `code/__DEFINES/role_preferences.dm`
- `code/__DEFINES/say.dm`
- `code/__DEFINES/sound.dm`
- `code/__DEFINES/traits.dm`
- `code/__HELPERS/global_lists.dm`
- `code/__HELPERS/names.dm`
- `code/__HELPERS/roundend.dm`
- `code/__HELPERS/text.dm`
- `code/_globalvars/lists/ambience.dm`
- `code/_globalvars/lists/flavor_misc.dm`
- `code/_globalvars/lists/names.dm`
- `code/_globalvars/lists/poll_ignore.dm`
- `code/_globalvars/traits.dm`
- `code/controllers/configuration/configuration.dm`
- `code/controllers/subsystem/fire_burning.dm`
- `code/controllers/subsystem/input.dm`
- `code/controllers/subsystem/job.dm`
- `code/controllers/subsystem/mapping.dm`
- `code/datums/brain_damage/severe.dm`
- `code/datums/brain_damage/split_personality.dm`
- `code/datums/components/nanites.dm`
- `code/datums/diseases/advance/advance.dm`
- `code/datums/diseases/advance/symptoms/heal.dm`
- `code/datums/diseases/advance/symptoms/macrophage.dm`
- `code/datums/hud.dm`
- `code/datums/keybinding/_defines.dm`
- `code/datums/map_config.dm`
- `code/datums/mutations/speech.dm`
- `code/game/atoms_movable.dm`
- `code/game/gamemodes/devil/objectives.dm`
- `code/game/machinery/computer/_computer.dm`
- `code/game/machinery/computer/communications.dm`
- `code/game/machinery/computer/prisoner/gulag_teleporter.dm`
- `code/game/machinery/fabricators/modular_fabricator.dm`
- `code/game/machinery/lightswitch.dm`
- `code/game/machinery/newscaster.dm`
- `code/game/machinery/stasis.dm`
- `code/game/machinery/suit_storage_unit.dm`
- `code/game/machinery/telecomms/broadcasting.dm`
- `code/game/mecha/mecha.dm`
- `code/game/objects/effects/contraband.dm`
- `code/game/objects/effects/decals/cleanable.dm`
- `code/game/objects/effects/decals/cleanable/humans.dm`
- `code/game/objects/effects/decals/misc.dm`
- `code/game/objects/effects/spawners/lootdrop.dm`
- `code/game/objects/effects/spawners/mailspawner.dm`
- `code/game/objects/effects/spawners/roomspawner.dm`
- `code/game/objects/items.dm`
- `code/game/objects/items/cards_ids.dm`
- `code/game/objects/items/crayons.dm`
- `code/game/objects/items/devices/megaphone.dm`
- `code/game/objects/items/devices/powersink.dm`
- `code/game/objects/items/dna_injector.dm`
- `code/game/objects/items/flamethrower.dm`
- `code/game/objects/items/holy_weapons.dm`
- `code/game/objects/items/implants/implant_storage.dm`
- `code/game/objects/items/stacks/medical.dm`
- `code/game/objects/items/storage/boxes.dm`
- `code/game/objects/items/storage/firstaid.dm`
- `code/game/objects/items/storage/storage.dm`
- `code/game/objects/items/storage/uplink_kits.dm`
- `code/game/objects/obj_defense.dm`
- `code/game/objects/structures/aliens.dm`
- `code/game/objects/structures/crates_lockers/closets/secure/security.dm`
- `code/game/objects/structures/watercloset.dm`
- `code/game/sound.dm`
- `code/game/turfs/closed/walls.dm`
- `code/modules/admin/admin.dm`
- `code/modules/admin/admin_verbs.dm`
- `code/modules/admin/topic.dm`
- `code/modules/admin/verbs/one_click_antag.dm`
- `code/modules/antagonists/cult/runes.dm`
- `code/modules/antagonists/devil/sintouched/sintouched.dm`
- `code/modules/antagonists/hivemind/hivemind.dm`
- `code/modules/antagonists/nukeop/equipment/nuclear_challenge.dm`
- `code/modules/assembly/mousetrap.dm`
- `code/modules/cargo/exports.dm`
- `code/modules/cargo/packs.dm`
- `code/modules/client/verbs/input_box.dm`
- `code/modules/clothing/head/_head.dm`
- `code/modules/clothing/masks/_masks.dm`
- `code/modules/clothing/shoes/_shoes.dm`
- `code/modules/clothing/spacesuits/hardsuit.dm`
- `code/modules/clothing/under/_under.dm`
- `code/modules/food_and_drinks/drinks/drinks.dm`
- `code/modules/food_and_drinks/food/snacks.dm`
- `code/modules/food_and_drinks/food/snacks_pastry.dm`
- `code/modules/food_and_drinks/kitchen_machinery/processor.dm`
- `code/modules/hydroponics/hydroponics.dm`
- `code/modules/hydroponics/plant_genes.dm`
- `code/modules/jobs/job_types/brig_physician.dm`
- `code/modules/jobs/job_types/captain.dm`
- `code/modules/jobs/job_types/head_of_security.dm`
- `code/modules/jobs/job_types/research_director.dm`
- `code/modules/jobs/job_types/scientist.dm`
- `code/modules/jobs/job_types/security_officer.dm`
- `code/modules/jobs/job_types/warden.dm`
- `code/modules/language/language_holder.dm`
- `code/modules/mapping/random_rooms.dm`
- `code/modules/mining/machine_redemption.dm`
- `code/modules/mob/camera/camera.dm`
- `code/modules/mob/dead/observer/observer.dm`
- `code/modules/mob/emote.dm`
- `code/modules/mob/living/blood.dm`
- `code/modules/mob/living/carbon/carbon.dm`
- `code/modules/mob/living/carbon/carbon_movement.dm`
- `code/modules/mob/living/carbon/human/emote.dm`
- `code/modules/mob/living/carbon/human/examine.dm`
- `code/modules/mob/living/carbon/human/human.dm`
- `code/modules/mob/living/carbon/human/human_defense.dm`
- `code/modules/mob/living/carbon/human/human_defines.dm`
- `code/modules/mob/living/carbon/human/human_helpers.dm`
- `code/modules/mob/living/carbon/human/physiology.dm`
- `code/modules/mob/living/carbon/human/species.dm`
- `code/modules/mob/living/carbon/human/species_types/IPC.dm`
- `code/modules/mob/living/carbon/human/species_types/abductors.dm`
- `code/modules/mob/living/carbon/human/species_types/android.dm`
- `code/modules/mob/living/carbon/human/species_types/dullahan.dm`
- `code/modules/mob/living/carbon/human/species_types/ethereal.dm`
- `code/modules/mob/living/carbon/human/species_types/plasmamen.dm`
- `code/modules/mob/living/carbon/human/species_types/skeletons.dm`
- `code/modules/mob/living/carbon/human/species_types/supersoldier.dm`
- `code/modules/mob/living/carbon/human/species_types/zombies.dm`
- `code/modules/mob/living/carbon/monkey/monkey.dm`
- `code/modules/mob/living/say.dm`
- `code/modules/mob/living/silicon/robot/robot.dm`
- `code/modules/mob/living/silicon/robot/robot_modules.dm`
- `code/modules/mob/living/silicon/silicon.dm`
- `code/modules/mob/living/simple_animal/bot/medbot.dm`
- `code/modules/mob/living/simple_animal/friendly/cat.dm`
- `code/modules/mob/living/simple_animal/friendly/dog.dm`
- `code/modules/mob/living/simple_animal/friendly/mouse.dm`
- `code/modules/mob/living/simple_animal/hostile/alien.dm`
- `code/modules/mob/living/simple_animal/hostile/megafauna/bubblegum.dm`
- `code/modules/mob/mob.dm`
- `code/modules/mob/mob_helpers.dm`
- `code/modules/power/generator.dm`
- `code/modules/power/rtg.dm`
- `code/modules/power/singularity/particle_accelerator/particle_control.dm`
- `code/modules/projectiles/projectile/bullets.dm`
- `code/modules/projectiles/projectile/energy/stun.dm`
- `code/modules/projectiles/projectile/special/hallucination.dm`
- `code/modules/reagents/chemistry/machinery/chem_dispenser.dm`
- `code/modules/reagents/chemistry/machinery/smoke_machine.dm`
- `code/modules/reagents/chemistry/reagents/alcohol_reagents.dm`
- `code/modules/reagents/chemistry/reagents/drink_reagents.dm`
- `code/modules/reagents/chemistry/reagents/food_reagents.dm`
- `code/modules/reagents/reagent_containers/glass.dm`
- `code/modules/reagents/reagent_containers/pill.dm`
- `code/modules/requests/request.dm`
- `code/modules/research/machinery/_production.dm`
- `code/modules/research/nanites/nanite_programs.dm`
- `code/modules/research/nanites/nanite_programs/utility.dm`
- `code/modules/research/techweb/all_nodes.dm`
- `code/modules/security_levels/security_levels.dm`
- `code/modules/shuttle/syndicate.dm`
- `code/modules/spells/spell_types/devil.dm`
- `code/modules/spells/spell_types/voice_of_god.dm`
- `code/modules/surgery/organs/tongue.dm`
- `code/modules/tgui/status_composers.dm`
- `code/modules/vending/autodrobe.dm`
- `code/modules/vending/clothesmate.dm`
- `code/modules/vending/plasmaresearch.dm`
- `code/modules/vending/wardrobes.dm`
- `nsv13/code/game/machinery/dance_machine.dm`
- `nsv13/code/game/machinery/lore_terminal.dm`
- `nsv13/code/game/machinery/munitions_machinery.dm`
- `nsv13/code/game/objects/items/bloody_eye.dm`
- `nsv13/code/modules/clothing/masks/_masks.dm`
- `nsv13/code/modules/jobs/job_types/marine/military_police.dm`
- `nsv13/code/modules/jobs/security/weapons.dm`
- `nsv13/code/modules/munitions/munitions_trolley.dm`
- `nsv13/code/modules/overmap/FTL/components/drive.dm`
- `nsv13/code/modules/power/stormdrive.dm`
- `nsv13/code/modules/research/astrometrics.dm`

</details>
