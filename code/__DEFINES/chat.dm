/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

// AQ EDIT - chat reliability from BeeStation
/// How many chat payloads to keep in history
#define CHAT_RELIABILITY_HISTORY_SIZE 5
/// How many resends to allow before giving up
#define CHAT_RELIABILITY_MAX_RESENDS 3

#define MESSAGE_TYPE_SYSTEM "system"
#define MESSAGE_TYPE_LOCALCHAT "localchat"
#define MESSAGE_TYPE_RADIO "radio"
#define MESSAGE_TYPE_INFO "info"
#define MESSAGE_TYPE_WARNING "warning"
#define MESSAGE_TYPE_DEADCHAT "deadchat"
#define MESSAGE_TYPE_OOC "ooc"
#define MESSAGE_TYPE_ADMINPM "adminpm"
#define MESSAGE_TYPE_MENTORPM "mentorpm"
#define MESSAGE_TYPE_COMBAT "combat"
#define MESSAGE_TYPE_ADMINCHAT "adminchat"
#define MESSAGE_TYPE_MENTORCHAT "mentorchat"
#define MESSAGE_TYPE_EVENTCHAT "eventchat"
#define MESSAGE_TYPE_ADMINLOG "adminlog"
#define MESSAGE_TYPE_ATTACKLOG "attacklog"
#define MESSAGE_TYPE_DEBUG "debug"
/// Adds a generic box around whatever message you're sending in chat. Really makes things stand out.
#define EXAMINE_BLOCK(str) ("<div class='examine_block'>" + str + "</div>")

// AQ EDIT START - ramki czatu i ogłoszenia z tgstation (style w tgui/packages/tgui-panel/styles/tgchat/)
/// Ramka z ciemnym tłem i grubym lewym brzegiem
#define boxed_message(str) ("<div class='boxed_message'>" + str + "</div>")
/// Ramka z dodatkowymi klasami (kolory: red_box, green_box, blue_box, purple_box)
#define custom_boxed_message(classes, str) ("<div class='boxed_message " + classes + "'>" + str + "</div>")
/// Ramka z tytułem w zakładce na górnej krawędzi
#define fieldset_block(title, content, classes) ("<fieldset class='fieldset " + classes + "'><legend class='fieldset_legend'>" + title + "</legend>" + content + "</fieldset>")
/// Pozioma kreska z tekstem pośrodku
#define separator_hr(str) ("<div class='separator'>" + str + "</div>")

#define MAJOR_ANNOUNCEMENT_TITLE(string) ("<span class='major_announcement_title'>" + string + "</span>")
#define SUBHEADER_ANNOUNCEMENT_TITLE(string) ("<span class='subheader_announcement_text'>" + string + "</span>")
#define MAJOR_ANNOUNCEMENT_TEXT(string) ("<span class='major_announcement_text'>" + string + "</span>")
#define MINOR_ANNOUNCEMENT_TITLE(string) ("<span class='minor_announcement_title'>" + string + "</span>")
#define MINOR_ANNOUNCEMENT_TEXT(string) ("<span class='minor_announcement_text'>" + string + "</span>")
#define ANNOUNCEMENT_HEADER(string) ("<span class='announcement_header'>" + string + "</span>")
/// Pasiasta ramka ogłoszenia; kolory: default, green, blue, pink, yellow, orange, red, purple. Klasa chat_alert kieruje ogłoszenie do kart Radio w czacie
#define CHAT_ALERT_SPAN(color, string) ("<div class='chat_alert chat_alert_" + ((color) || "default") + "'>" + string + "</div>")
/// Znaczniki sekcji w examine człowieka (niewidoczne); układa je /mob/proc/aq_examine_html()
#define AQ_EXAMINE_STATUS_MARK "<span class='aq_examine_mark' data-mark='status'></span>"
#define AQ_EXAMINE_HUD_MARK "<span class='aq_examine_mark' data-mark='hud'></span>"
#define AQ_EXAMINE_HUD_END "<span class='aq_examine_mark' data-mark='hud_end'></span>"
// AQ EDIT END
