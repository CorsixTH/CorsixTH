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

Language(utf8 "Français", "French" , "fr", "fre", "fra")
Inherit("english")
Inherit("original_strings", 1)

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
  create_emergency            = "  CREER UNE URGENCE  ",
  place_objects               = "  PLACER DES OBJETS  ",
  dump_strings                = "  EXTRAIRE LES TEXTES  ",
  map_overlay                 = "  MAP OVERLAY  ",
  sprite_viewer               = "  VISIONNEUSE DE SPRITES  ",
}
menu_debug_overlay = {
  none                        = "  AUCUN  ",
  flags                       = "  DRAPEAUX  ",
  positions                   = "  POSITIONS  ",
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
    beta2 = {
      "Bienvenue dans la seconde beta de CorsixTH, un clone open source du jeu classique Theme Hospital par Bullfrog!",
      utf8 "Beaucoup de nouvelles fonctionnalités ont été implémentées depuis la dernière publication. Regardez le changelog pour une liste non exhaustive.",
      utf8 "Mais d'abord, jouons! Il semble qu'un message vous attend. Fermez cette fenêtre et cliquez sur le point d'interrogation au dessus du tableau de bord.",
      utf8 "-- L'équipe de CorsixTH, th.corsix.org",
    },
  },
  tutorial = {
    utf8 "Bienvenue dans votre premier hôpital!",
    "Souhaitez-vous un petit tutoriel ?",
    "Oui, montrez-moi les bases SVP.",
    utf8 "Non, je sais déjà comment faire.",
  },
}

misc.not_yet_implemented = utf8 "(pas encore implémenté)"
misc.no_heliport = utf8 "Aucune maladie n'a été découverte pour l'instant, ou il n'y a pas d'héliport sur cette carte."

main_menu = {
  new_game = "Nouvelle Partie",
  custom_level = utf8 "Niveau Personnalisé",
  load_game = "Charger une Partie",
  options = "Options",
  exit = "Quitter",
}

tooltip.main_menu = {
  new_game = "Commencer une partie totalement nouvelle",
  custom_level = utf8 "Construire votre hôpital dans un niveau personnalisé",
  load_game = utf8 "Charger une partie sauvegardée",
  options = utf8 "Modifier quelques paramètres",
  exit = "Non, non, SVP, ne quittez pas!",
}

load_game_window = {
  back = utf8 "Précédent",
}

tooltip.load_game_window = {
  load_game_number = "Charger la partie %d",
  load_autosave = utf8 "Charger la sauvegarde automatique",
  back = utf8 "Fermer la fenêtre de chargement de parties",
}

errors = {
  dialog_missing_graphics = utf8 "Désolé, les données de démo ne contiennent pas ce dialogue.",
  save_prefix = "Erreur lors de la sauvegarde de la partie: ",
  load_prefix = "Erreur lors du chargement de la partie: ",
}

totd_window = {
  tips = {
    utf8 "Chaque hôpital a besoin d'un bureau de réception et d'un bureau de généraliste. Après, tout dépend du type de patients qui visitent votre hôpital. Une pharmacie est toujours un bon choix malgré tout.",
    utf8 "Les machines telles que le Gonflage ont besoin de maintenance. Embauchez un ou deux agents de maintenance pour réparer vos machines, ou vous risquerez d'avoir des blessés parmi le personnel ou les patients.",
    utf8 "Après un certain temps, vos employés seront fatigués. Pensez à construire une salle de repos où ils pourront se détendre.",
    utf8 "Placez suffisamment de radiateurs pour garder vos employés et patients au chaud, ou ils deviendront mécontents.",
    utf8 "Le niveau de compétence d'un docteur influence beaucoup la qualité et la rapidité de ses diagnostics. Utilisez un médecin expérimenté comme généraliste et vous n'aurez plus besoin d'autant de salles de diagnostics.",
    utf8 "Les internes et les médecins peuvent augmenter leurs compétences auprès d'un consultant dans la salle de formation. Si le consultant a des qualifications pariculières (chirurgien, psyschiatre ou chercheur), il transférera ses connaissances à ses élèves.",
    utf8 "Avez-vous essayé d'entrer le numéro d'urgence Européen (112) dans le fax ? Vérifiez que vous avez du son !",
    utf8 "Le menu d'options n'est pas encore implémenté, mais vous pouvez ajuster les paramètres tels que la résolution ou la langue en éditant le fichier config.txt dans le dossier du jeu.",
    utf8 "Vous avez choisi une autre langue que l'anglais, mais il y du texte en anglais partout ? Aidez-nous à traduire les textes manquants dans votre langue!",
    utf8 "L'équipe de CorsixTH cherche du renfort ! Vous êtes intéressé par coder, traduire ou faire des graphismes pour CorsixTH ? Contactez-nous sur notre Forum, Liste de Diffusion ou Canal IRC (corsix-th sur freenode).",
    utf8 "Si vous avez trouvé un bug, SVP, reportez le sur notre gestionnaire de bugs: th-issues.corsix.org.",
    utf8 "Le saviez-vous ? CorsixTH a été rendu public pour la première fois le 24 juillet 2009. La première publication a été la beta 1 jouable le 24 décembre 2009. Après trois mois de plus, nous sommes fiers de vous présenter la beta 2 (publiée le 24 mars 2010).",
  },
  previous = utf8 "Astuce Précédente",
  next = "Astuce Suivante",
}

tooltip.totd_window = {
  previous = utf8 "Affiche l'astuce précédente",
  next = "Affiche l'astuce suivante",
}
