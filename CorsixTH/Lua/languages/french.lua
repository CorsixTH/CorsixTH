--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. --]]

Language("french" , "fr", "fre", "fra")
Inherit("english")
Inherit("original_strings", 1)

-- override
adviser.warnings.money_low = "Vous n'avez presque plus d'argent !" -- Funny. Exists in German translation, but not existent in english?
-- TODO: tooltip.graphs.reputation -- this tooltip talks about hospital value. Actually it should say reputation.
-- TODO: tooltip.status.close -- it's called status window, not overview window.

-- new strings
object.litter = "Déchet"

menu_options.lock_windows = "  FIGER LES FENETRES  "
menu_options_game_speed.pause = "  PAUSE  "

menu_debug = {
  transparent_walls           = "  MURS TRANSPARENTS  ",
  limit_camera                = "  LIMITER LA CAMERA  ",
  disable_salary_raise        = "  DESACTIVER LES AUGMENTATIONS DE SALAIRE  ",
  make_debug_patient          = "  CREER UN PATIENT DE TEST  ",
  spawn_patient               = "  FAIRE ARRIVER DES PATIENTS  ",
  make_adviser_talk           = "  FAIRE PARLER LE CONSEILLER  ",
  show_watch                  = "  AFFICHER LE COMPTE A REBOUR  ",
  place_objects               = "  PLACER DES OBJETS  ",
  dump_strings                = "  DUMP STRINGS  ",
  map_overlay                 = "  MAP OVERLAY  ",
  sprite_viewer               = "  VISIONNEUSE DE SPRITES  ",
}
menu_debug_overlay = {
  none                        = "  AUCUN  ",
  flags                       = "  DRAPEAUX  ",
  byte_0_1                    = "  OCTETS 0 & 1  ",
  byte_floor                  = "  OCTET SOL  ",
  byte_n_wall                 = "  OCTET MUR N  ",
  byte_w_wall                 = "  OCTET MUR O  ",
  byte_5                      = "  OCTET 5  ",
  byte_6                      = "  OCTET 6  ",
  byte_7                      = "  OCTET 7  ",
  parcel                      = "  PARCELLE  ",
}
adviser.room_forbidden_non_reachable_parts = utf8 "Placer la salle à cet endroit va empêcher des parties de l'hôpital d'être atteintes."

dynamic_info.patient.actions.no_gp_available = utf8 "Attente d'un bureau de généraliste"
dynamic_info.staff.actions.heading_for = "Va vers %s"

fax = {
  welcome = {
    beta1 = {
      "Bienvenue dans CorsixTH, un clone open source du jeu classique Theme Hospital par Bullfrog!",
      utf8 "Ceci est la beta 1 jouable de CorsixTH. Beaucoup de salles, maladies et fonctionnalités ont été implémentées, mais beaucoup de choses manquent",
      utf8 "Si vous aimez ce projet, vous pouvez nous aider, par ex. en rapportant des bogues ou en codant quelque-chose par vous-même.",
      utf8 "Mais maintenant, amusez-vous ! Pour ceux qui ne sont pas familier avec Theme Hospital : Commencez par construire un bureau de réception (menu objets) et un bureau de généraliste (salle de diagnostic). Des salles de traitement seront aussi nécessaires.",
      utf8 "-- L'équipe de CorsixTH, th.corsix.org",
      utf8 "PS: Trouverez-vous les surprises cachées ?",
    },
  },
  tutorial = {
    utf8 "Bienvenue dans votre premier hôpital!",
    "Souhaitez-vous un petit tutoriel ?",
    "Oui, montre-moi les bases STP.",
    utf8 "Non, je sais déjà comment faire.",
  },
}
