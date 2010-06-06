--[[ Copyright (c) 2010 Nicolas "MeV" Elie

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

-- override
adviser.information.promotion_to_specialist = "L'un de vos INTERNES est devenu MEDECIN." -- Fix the famous "Level 5 bug"

-- The originals of these two contain one space too much
trophy_room.sold_drinks.trophies[2] = utf8 "Vous recevez le prix Bubulles du Syndicat des Vendeurs de Limonade pour récompenser la quantité de sodas vendus dans votre hôpital au cours de l'année écoulée. "
fax.epidemic.declare_explanation_fine = utf8 "Si vous déclarez l'épidémie, vous aurez une amende de %d, un changement de réputation et tous les patients seront vaccinés automatiquement."
fax.diagnosis_failed.partial_diagnosis_percentage_name = utf8 "Il y a %d pour cent de chances que la maladie soit %s."
tooltip.status.percentage_cured = utf8 "Vous devez soigner %d%% des visiteurs de l'hôpital. Actuellement, vous en avez soigné %d%%"
tooltip.status.num_cured = utf8 "L'objectif est de soigner %d personnes. Pour le moment, vous en avez soigné %d"
dynamic_info.staff.actions.going_to_repair = utf8 "Pour réparer %s"
adviser.staff_place_advice.only_doctors_in_room = utf8 "Seuls les médecins peuvent travailler en %s"
adviser.staff_place_advice.nurses_cannot_work_in_room = utf8 "Les infermières ne peuvent travailler en %s"
room_descriptions.gp[2] = utf8 "C'est une salle de diagnostic fondamentale pour votre hôpital. Elle accueille les nouveaux patients pour les ausculter. Ils sont ensuite orientés vers une autre salle soit pour une autre diagnostic soit pour être soignés. Vous devriez construire un autre cabinet de médecine générale au cas où celui-ci serait débordé. Plus l'endroit est grand et plus vous pouvez y placer des équipements, sans compter que c'est bon pour le prestige du médecin. C'est valable pour toutes les salles, en fait.//"
room_descriptions.pharmacy[2] = utf8 "Les patients dont le mal a été diagnostiqué et dont le traitement est un médicament peuvent se rendre à la pharmacie. Comme la recherche découvre toujours de nouveaux traitements, l'activité de cette salle est en constante évolution. Vous aurez à construire une autre pharmacie plus tard.//"
room_descriptions.general_diag[3] = utf8 "La salle de diagnostic nécessite un médecin. Il faut également un agent de maintenance pour un entretien périodique. "
pay_rise.definite_quit = utf8 "Rien ne me fera rester ici. J'en ai assez. "
place_objects_window.confirm_or_buy_objects = utf8 "Vous pouvez valider ainsi ou bien soit acheter soit déplacer des objets."

-- new strings
object.litter = utf8 "Déchet"
tooltip.objects.litter = utf8 "Déchet: Laissé sur le sol par un patient car il n'a pas trouvé de poubelle où le jeter."

menu_options.lock_windows = "  FIGER LES FENETRES  "
menu_options.settings = "  PARAMETRES  "
menu_options_game_speed.pause = "  PAUSE  "

-- The demo does not contain this string
menu_file.restart = "  RELANCER  "

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
  dump_gamelog                = "  EXTRAIRE LE JOURNAL DE JEU  ",
  map_overlay                 = "  INCRUSTATIONS DE CARTE  ",
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

dynamic_info.patient.actions.no_gp_available = utf8 "Attente d'un cabinet de médecine générale"
dynamic_info.staff.actions.heading_for = "Va vers %s"

fax = {
  welcome = {
    beta1 = {
      "Bienvenue dans CorsixTH, un clone open source du jeu classique Theme Hospital par Bullfrog !",
      utf8 "Ceci est la beta 1 jouable de CorsixTH. Beaucoup de salles, maladies et fonctionnalités ont été implémentées, mais beaucoup de choses manquent",
      utf8 "Si vous aimez ce projet, vous pouvez nous aider, par ex. en rapportant des bogues ou en codant quelque-chose par vous-même.",
      utf8 "Mais maintenant, amusez-vous ! Pour ceux qui ne sont pas familier avec Theme Hospital : Commencez par construire un bureau de réception (menu objets) et un bureau de généraliste (salle de diagnostic). Des salles de traitement seront aussi nécessaires.",
      utf8 "-- L'équipe de CorsixTH, th.corsix.org",
      utf8 "PS: Trouverez-vous les surprises cachées ?",
    },
    beta2 = {
      "Bienvenue dans la seconde beta de CorsixTH, un clone open source du jeu classique Theme Hospital par Bullfrog !",
      utf8 "Beaucoup de nouvelles fonctionnalités ont été implémentées depuis la dernière publication. Regardez le changelog pour une liste non exhaustive.",
      utf8 "Mais d'abord, jouons! Il semble qu'un message vous attend. Fermez cette fenêtre et cliquez sur le point d'interrogation au dessus du tableau de bord.",
      utf8 "-- L'équipe de CorsixTH, th.corsix.org",
    },
  },
  tutorial = {
    utf8 "Bienvenue dans votre premier hôpital !",
    "Souhaitez-vous un petit tutoriel ?",
    "Oui, montrez-moi les bases SVP.",
    utf8 "Non, je sais déjà comment faire.",
  },
  choices = {
    return_to_main_menu = "Retourner au menu principal",
    accept_new_level = "Aller au niveau suivant",
    decline_new_level = utf8 "Continuer la partie encore un peu",
  },
}

letter = {
  dear_player = "Cher %s",
  custom_level_completed = utf8 "Félicitations ! Vous avez réussi tous les objectifs de ce niveau personnalisé !",
  return_to_main_menu = "Voulez-vous retourner au menu principal ou continuer la partie ?",
  level_lost = "Quelle poisse ! Vous avez raté le niveau. Vosu ferez mieux la prochaine fois !",
}

misc.not_yet_implemented = utf8 "(pas encore implémenté)"
misc.no_heliport = utf8 "Aucune maladie n'a été découverte pour l'instant, ou il n'y a pas d'héliport sur cette carte."

main_menu = {
  new_game = "Nouvelle Partie",
  custom_level = utf8 "Niveau personnalisé",
  load_game = "Charger une Partie",
  options = "Options",
  exit = "Quitter",
}

tooltip.main_menu = {
  new_game = "Commencer une partie totalement nouvelle",
  custom_level = utf8 "Construire votre hôpital dans un niveau personnalisé",
  load_game = utf8 "Charger une partie sauvegardée",
  options = utf8 "Modifier quelques paramètres",
  exit = "Non, non, SVP, ne quittez pas !",
}

load_game_window = {
  caption = "Charger une partie",
}

tooltip.load_game_window = {
  load_game = utf8 "Charger la partie %s",
  load_game_number = utf8 "Charger la partie %d",
  load_autosave = "Charger la sauvegarde automatique",
}

custom_game_window = {
  caption = "Niveau personnalisé",
}

tooltip.custom_game_window = {
  start_game_with_name = utf8 "Charger le niveau %s",
}

save_game_window = {
  caption = "Enregistrer la partie",
  new_save_game = "Nouvelle sauvegarde",
}

tooltip.save_game_window = {
  save_game = utf8 "Écraser la sauvegarde %s",
  new_save_game = "Entrez un nom pour la sauvegarde",
}

menu_list_window = {
  back = utf8 "Précédent",
}

tooltip.menu_list_window = {
  back = utf8 "Fermer cette fenêtre",
}

options_window = {
  fullscreen = utf8 "Plein écran",
  width = "Largeur",
  height = "Hauteur",
  change_resolution = utf8 "Changer la résolution",
  back = utf8 "Précédent",
}

tooltip.options_window = {
  fullscreen_button = utf8 "Basculer en mode plein écran/fenêtré",
  width = utf8 "Entrez la largeur désirée",
  height = utf8 "Entrez la hauteur désirée",
  change_resolution = utf8 "Changer la résolution pour les dimensions entrées à gauche",
  language = utf8 "Sélectionner %s comme langue",
  back = utf8 "Fermer la fenêtre des options",
}

errors = {
  dialog_missing_graphics = utf8 "Désolé, les données de démo ne contiennent pas ce dialogue.",
  save_prefix = "Erreur lors de la sauvegarde de la partie: ",
  load_prefix = "Erreur lors du chargement de la partie: ",
  map_file_missing = "Impossible de trouver le fichier de carte %s pour ce niveau !",
  minimum_screen_size = utf8 "Veuillez entrer une résolution d'au moins 640x480.",
}

confirmation = {
  needs_restart = utf8 "Changer ce paramètre requiert un redémarrage de CorsixTH. Tout progrès non sauvegardé sera perdu. Êtes-vous sûr de vouloir faire cela ?"
}

information = {
  custom_game = utf8 "Bienvenue dans CorsixTH. Amusez-vous bien avec cette carte personnalisée !",
  cannot_restart = utf8 "Malheureusement cette partie personnalisée a été sauvegardée avant que la fonctionnalité de redémarrage soit implémentée.",
}

tooltip.information = {
  close = utf8 "Fermer cette boîte de dialogue.",
}

totd_window = {
  tips = {
    utf8 "Chaque hôpital a besoin d'un bureau de réception et d'un cabinet de médecine générale. Après, tout dépend du type de patients qui visitent votre hôpital. Une pharmacie est toujours un bon choix malgré tout.",
    utf8 "Les machines telles que le Gonflage ont besoin de maintenance. Embauchez un ou deux agents de maintenance pour réparer vos machines, ou vous risquerez d'avoir des blessés parmi le personnel ou les patients.",
    utf8 "Après un certain temps, vos employés seront fatigués. Pensez à construire une salle de repos où ils pourront se détendre.",
    utf8 "Placez suffisamment de radiateurs pour garder vos employés et patients au chaud, ou ils deviendront mécontents.",
    utf8 "Le niveau de compétence d'un docteur influence beaucoup la qualité et la rapidité de ses diagnostics. Utilisez un médecin expérimenté comme généraliste et vous n'aurez plus besoin d'autant de salles de diagnostics.",
    utf8 "Les internes et les médecins peuvent augmenter leurs compétences auprès d'un consultant dans la salle de formation. Si le consultant a des qualifications pariculières (chirurgien, psyschiatre ou chercheur), il transférera ses connaissances à ses élèves.",
    utf8 "Avez-vous essayé d'entrer le numéro d'urgence Européen (112) dans le fax ? Vérifiez que vous avez du son !",
    utf8 "Le menu d'options n'est pas encore implémenté, mais vous pouvez ajuster les paramètres tels que la résolution ou la langue en éditant le fichier config.txt dans le dossier du jeu.",
    utf8 "Vous avez choisi une autre langue que l'anglais, mais il y du texte en anglais partout ? Aidez-nous à traduire les textes manquants dans votre langue !",
    utf8 "L'équipe de CorsixTH cherche du renfort ! Vous êtes intéressé par coder, traduire ou faire des graphismes pour CorsixTH ? Contactez-nous sur notre Forum, Liste de Diffusion ou Canal IRC (corsix-th sur freenode).",
    utf8 "Si vous avez trouvé un bug, SVP, reportez le sur notre gestionnaire de bugs: th-issues.corsix.org.",
    utf8 "Le saviez-vous ? CorsixTH a été rendu public pour la première fois le 24 juillet 2009. La première publication a été la beta 1 jouable le 24 décembre 2009. Après trois mois de plus, nous sommes fiers de vous présenter la beta 2 (publiée le 24 mars 2010).",
  },
  previous = utf8 "Astuce précédente",
  next = "Astuce suivante",
}

tooltip.totd_window = {
  previous = utf8 "Affiche l'astuce précédente",
  next = "Affiche l'astuce suivante",
}
