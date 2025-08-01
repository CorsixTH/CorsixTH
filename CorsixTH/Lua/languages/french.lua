--[[ Copyright (c) 2010-2015 Nicolas "MeV" Elie, 2013-2025 Antoine Lemaire, 2024 Sanndow

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

Language(utf8 "Français", "French", "fr", "fre", "fra")
Inherit("english")
Inherit("original_strings", 1)

--[[
  Notice: Theme Hospital's font lacks support for certain character types used in
  French, including '«' and '»'. See the "Localisation" page on the Wiki for more
  information.
--]]

----------------------------------------------------------- Override -----------------------------------------------------------
rooms_short.ward = "Salle des malades"
rooms_long.ward = "Salle des malades"

misc.save_failed = "ERREUR : partie non sauvegardée." -- Much more french
misc.cant_treat_emergency = "Votre hôpital ne peut pas traiter cette urgence car la maladie n'a pas été découverte. N'hésitez pas à réessayer."
tooltip.policy.diag_termination = "L'auscultation d'un patient continuera jusqu'à ce que les médecins soient sûrs à hauteur du pourcentage FIN PROCEDURE ou jusqu'à ce que toutes les machines de diagnostic aient été essayées. " -- Remove a superfluous word
adviser.goals = {
  win = { -- Why are these strings uppercase?
    reputation = "Portez votre réputation à %d pour pouvoir gagner.",
    value = "Portez la valeur de votre hôpital à %d."
  }
}
adviser.goals.lose.kill = "Tuez encore %d patients pour perdre !"

-- tooltip.staff_list.next_person, prev_person is rather next/prev page (also in german, maybe more languages?)
tooltip.staff_list.next_person = "Voir la page suivante"
tooltip.staff_list.prev_person = "Voir la page précédente"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "Visage - cliquez pour ouvrir la fenêtre de gestion"
tooltip.staff_window.center_view = "clic gauche pour focaliser sur la personne, pour faire défiler les membres du personnel"

-- Fix Winning texts
letter = {
  [1] = { -- Level one: Fix issue 329
    [1] = "Estimable %s",
    [2] = "Splendide ! Vous avez admirablement géré cet hôpital. Nous, pontes du Ministère de la Santé, souhaitons savoir si vous aimeriez prendre en charge un plus grand projet. Nous comptons sur vous. Le salaire serait de %d$ et ça vaut la peine d'y réfléchir.",
    [3] = "Que diriez-vous de travailler à l'hôpital de %s ?"
  },
  [2] = { -- Level two: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Formidable ! Vous avez fait de grands progrès dans votre hôpital. Nous vous avons trouvé un autre établissement pour exercer vos talents et relever des défis. Vous pouvez refuser mais ce serait dommage. Le salaire est de %d$.",
    [3] = "Acceptez-vous le poste à l'hôpital de %s ?"
  },
  [3] = { -- Level three: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Vous avez parfaitement réussi dans cet hôpital. C'est la raison pour laquelle nous vous proposons une nouvelle situation. Le salaire serait de %d$ et nous pensons que vous adorerez relever ce nouveau défi.",
    [3] = "Acceptez-vous de gérer l'hôpital de %s ?"
  },
  [4] = { -- Level four: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Félicitations ! Le Ministère de la Santé est très impressionné par vos capacités à gérer cet hôpital. Vous êtes un exemple de réussite dans ce domaine. Vous voudrez peut-être une situation plus élevée, toutefois. Vous seriez payé %d$, et la décision vous revient.",
    [3] = "Êtes-vous prêt à accepter un poste à l'hôpital de %s ?"
  },
  [5] = { -- Level five: Add missing spaces before punctuation marks and between words
    [1] = "Estimable %s",
    [2] = "Nouvelles salutations. Nous respectons votre souhait de ne pas quitter ce charmant hôpital, mais nous vous supplions d'y réfléchir. Nous vous proposons la coquette somme de %d$ pour accepter de diriger un autre hôpital avec autant de succès.",
    [3] = "Aimeriez-vous prendre la tête de l'hôpital de %s ?"
  },
  [6] = { -- Level six: Add missing spaces before punctuation marks, fix last string which contained an anglicism
    [1] = "Estimable %s",
    [2] = "Nous savons que vous êtes heureux de vous occuper de cette délicieuse institution mais nous pensons que vous devez penser à l'avenir. Vous pourriez prétendre au salaire de %d$ si vous acceptez de changer de situation. Pensez-y.",
    [3] = "Voulez-vous un poste à l'hôpital de %s ?"
  },
  [7] = { -- Level seven: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Le Ministère de la Santé souhaite que vous reconsidériez votre décision de rester dans cet hôpital. Nous savons que vous avez un charmant établissement mais il est temps de relever un nouveau défi, avec un salaire attrayant de %d$.",
    [3] = "Êtes-vous prêt à travailler à l'hôpital de %s ?"
  },
  [8] = { -- Level height: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Vous aviez donné une réponse négative à notre dernière lettre vous proposant un grand poste dans un nouvel hôpital, avec un coquet salaire de %d$. Nous pensons que vous devez revoir votre décision car nous avons pour vous un poste idéal.",
    [3] = "Voulez-vous bien accepter un poste à l'hôpital de %s ? S'il vous plaît !"
  },
  [9] = { -- Level nine: Add missing spaces before punctuation marks, fix some sentences, add missing diacritics
    [1] = "Estimable %s",
    [2] = "Vous vous êtes montré le meilleur directeur d'hôpital jamais connu dans la longue et mouvementée histoire de la médecine. Nous sommes fiers de vous offrir le poste de Chef Suprême des Hôpitaux. Ce titre honorifique vous garantit un salaire de %d$. On fera pour vous une parade pleine de serpentins et les gens vous baiseront les pieds.",
    [3] = "Merci pour tout ce que vous avez fait. Vous avez mérité cette semi-retraite."
  },
  [10] = { -- Level ten: Fix some sentences
    [1] = "Estimable %s",
    [2] = "Félicitations pour avoir réussi dans tous les hôpitaux que vous avez dirigés. Une telle performance fait de vous un héros. Vous recevrez une pension de %d$ plus une limousine. Tout ce que nous vous demandons, c'est d'aller de ville en ville rencontrer votre public en adoration et défendre le renom des hôpitaux.",
    [3] = "Nous sommes tous fiers de vous et notre coeur déborde de gratitude pour votre dévouement à sauver des vies."
  },
  [11] = { -- Level eleven: No change
    [1] = "Estimable %s",
    [2] = "Votre carrière est exemplaire et vous êtes une inspiration pour nous tous. Merci d'avoir géré tous ces hôpitaux avec autant de talent. Nous souhaitons vous offrir une rente à vie de %d$ pour simplement aller de ville en ville à bord d'une voiture de prestige pour saluer la foule et donner des conférences sur votre incroyable réussite.",
    [3] = "Vous êtes un exemple pour toute personne sensée et tout le monde, sans exception, vous considère comme un modèle absolu."
  },
  [12] = { -- Level twelve: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Votre carrière réussie en tant que meilleur directeur d'hôpital depuis la nuit des temps arrive à sa fin. Toutefois, vous avez eu sur le monde tranquille de la médecine une telle influence que le Ministre vous offre un salaire de %d$ uniquement pour paraître en public, faire des inaugurations, baptiser des navires et participer à des débats. Le monde entier vous acclame et c'est la meilleure des publicités pour le Ministère de la Santé !",
    [3] = "Veuillez accepter cette situation : ce n'est pas trop difficile et vous aurez, en plus, une escorte de police partout où vous irez."
  }
}

-- The originals of some of these string lack a space before punctuation marks and or between words
misc.balance = "Ajustage :"
tooltip.pay_rise_window.decline = "Ne payez pas, licenciez !"
tooltip.watch = {
  emergency = "Urgence : temps qui reste pour soigner les patients entrés en urgence.",
  hospital_opening = "Délai : ceci est le temps qui reste avant que votre hôpital soit ouvert. Cliquez sur GO pour l'ouvrir tout de suite.",
  epidemic = "Épidémie : temps qui reste pour arrêter l'épidémie. Si ce délai expire OU si un malade contagieux quitte l'hôpital, un inspecteur sanitaire viendra... Le bouton active ou désactive la vaccination. Cliquez sur un patient pour lancer la vaccination par une infirmière."
}
tooltip.objects = {
  chair = "Chaise : le patient s'y assied pour parler de ses symptômes.",
  sofa = "Sofa : c'est ce qui permet aux employés de se relaxer... sauf s'ils trouvent mieux...",
  bench = "Banc : pour que les patients puissent attendre confortablement.",
  video_game = "Jeu vidéo : l'équipe se relaxe en jouant à Hi-Octane.",
  lamp = "Lampe : vous avez déjà essayé de travailler dans le noir ?",
  door = "Porte : les gens aiment les ouvrir et les fermer.",
  auto_autopsy = "Autopsie : très utile pour la recherche.",
  tv = "TV : votre équipe ne doit pas manquer ses programmes favoris.",
  litter_bomb = "Bombe à détritus : pour saboter les hôpitaux concurrents.",
  inflator = "Gonfleur : pour soigner l'encéphalantiasis.",
  desk = "Bureau : essentiel pour poser un ordinateur.",
  pool_table = "Billard : pour la relaxation du personnel.",
  bed = "Lit : les cas graves ont besoin de rester couchés.",
  bookcase = "Étagère : pour les ouvrages de référence.",
  drinks_machine = "Distributeurs : contre la soif et pour ramasser des gros sous.",
  skeleton = "Squelette : utile pour l'enseignement et pour Halloween.",
  computer = "Ordinateur : une composante essentielle de la recherche.",
  bin = "Poubelle : les patients y jettent leurs détritus.",
  pharmacy_cabinet = "Pharmacie : c'est là qu'on dispense les médicaments.",
  radiator = "Radiateur : permet de garder l'hôpital au chaud.",
  atom_analyser = "Mélangeur : installé au Département Recherche, cette machine accélère tout le processus d'étude.",
  plant = "Plante : plaît aux patients et purifie l'air.",
  toilet = "Toilettes : les patients en ont, euh, besoin.",
  fire_extinguisher = "Extincteur : pour minimiser les dangers causés par des machines défectueuses.",
  lecture_chair = "Chaise : les médecins en formation s'asseyent là pour prendre des notes et s'ennuyer. Plus vous mettrez des chaises, plus vous pourrez former de médecins.",
  toilet_sink = "Lavabo : s'il n'y en a pas assez, les patients qui apprécient l'hygiène seront mécontents.",
  cabinet = "Placard : dossiers des patients, notes de recherche.",
  rathole = "Domicile d'une famille de rats qui a trouvé votre hôpital suffisamment sale pour y vivre."
}

room_descriptions = {
  gp = {
    [2] = "C'est une salle de diagnostic fondamentale pour votre hôpital. Elle accueille les nouveaux patients pour les ausculter. Ils sont ensuite orientés vers une autre salle, soit pour un autre diagnostic soit pour être soignés. Vous devriez construire un autre cabinet de médecine générale au cas où celui-ci serait débordé. Plus l'endroit est grand et plus vous pouvez y placer des équipements, sans compter que c'est bon pour le prestige du médecin. C'est valable pour toutes les salles, en fait."
  },
  pharmacy = {
    [2] = "Les patients dont le mal a été diagnostiqué et dont le traitement est un médicament peuvent se rendre à la pharmacie. Comme la recherche découvre toujours de nouveaux traitements, l'activité de cette salle est en constante évolution. Vous aurez à construire une autre pharmacie plus tard."
  },
  general_diag = {
    [3] = "La salle de diagnostic nécessite un médecin. Il faut également un agent de maintenance pour un entretien périodique. "
  },
  fracture_clinic = {
    [2] = "Les patients dont les os étaient en morceaux se rendront dans cette salle. Le déplâtreur dégagera les membres en ne causant qu'une faible douleur."
  },
  inflation = {
    [2] = "Les patients souffrant de l'affreuse-mais-si-drôle encéphalantiasis sont soignés à la salle de gonflage, où leur tête démesurée sera dégonflée puis regonflée à la bonne taille."
  },
  hair_restoration = {
    [2] = "Les patients souffrant de sévère calvitie se rendront dans cette salle équipée d'un moumouteur. Un médecin utilisera la machine pour donner aux patients une nouvelle chevelure."
  },
  electrolysis = {
    [2] = "Les patients souffrant de pilose viennent dans cette salle où une machine arrache les poils et scelle les pores selon un procédé qui n'est pas sans rappeler la cimentation."
  },
  staff_room = {
    [2] = "Votre équipe finit par se fatiguer et a besoin de cette salle pour se remettre. Une équipe fatiguée est lente, revendicatrice et peut même envisager de démissionner. De plus, elle risque de commettre des erreurs. Il est avisé de construire une salle de repos bien aménagée et de prévoir assez de place pour plusieurs membres à la fois."
  }
}

progress_report.too_hot = "Réglez le chauffage : on étouffe."
adviser.tutorial.build_pharmacy = "Félicitations ! Construisez maintenant une pharmacie et embauchez une infirmière."
adviser.epidemic.serious_warning = "Cette maladie contagieuse est dangereuse. Vous devez prendre des mesures d'urgence !"
adviser.staff_advice.too_many_doctors = "Il y a trop de médecins. Certains n'ont rien à faire !"
adviser.earthquake.ended = "Ouh là ! J'ai cru que c'était la fin ! C'était du %d sur l'échelle de Richter."
adviser.multiplayer.poaching = {
  not_interested = "Ha ! Ils ne veulent pas travailler pour vous, ils sont satisfaits comme ça.",
  already_poached_by_someone = "Eh non ! Quelqu'un s'intéresse déjà à cette personne."
}
adviser.vomit_wave.ended = "Ouf ! On dirait que le virus qui provoquait des nausées est enfin enrayé. Gardez l'hôpital propre, à l'avenir."
adviser.research.new_available = "Nouveau : un(e) %s est disponible."
adviser.research.drug_improved_1 = "Le traitement contre la %s a été amélioré par votre département de recherche."
adviser.placement_info.object_cannot_place = "Hé ! Vous ne pouvez pas placer cet objet ici."
adviser.information = {
  epidemic = "Une maladie contagieuse sévit dans votre hôpital. Vous devez l'enrayer immédiatement !",
  emergency = "C'est une urgence ! Vite ! Vite ! VITE !",
  initial_general_advice = {
    first_epidemic = "Il y a une épidémie dans votre hôpital ! A vous de voir si vous étouffez l'affaire ou si vous en parlez."
  },
  patient_leaving_too_expensive = "Un patient part sans payer la facture pour %s. Sacrée perte !",
  vip_arrived = "Attention ! %s arrive pour visiter votre hôpital ! Faites en sorte de lui faire bonne impression.",
  first_death = "Vous venez de tuer votre premier patient. Alors, heureux ?",
  promotion_to_doctor = "L'un de vos INTERNES est devenu MÉDECIN.", -- Fix the famous "Level 5 bug"
  promotion_to_specialist = "L'un de vos MÉDECINS est devenu SPÉCIALISTE."
}
buy_objects_window = {
  price = "Prix : ",
  total = "Total : "
}
fax = {
  epidemic_result = {
    close_text = "Hourra !",
    rep_loss_fine_amount = "Les journaux vont s'en donner à cœur joie avec cette affaire. Votre réputation va en prendre un coup ! Sans oublier l'amende de %d."
  },
  disease_discovered_patient_choice = {
    what_to_do_question = "Que voulez-vous faire du patient ?"
  },
  debug_fax = {
    close_text = "Ouais, ouais, ouais !"
  },
  diagnosis_failed = {
    what_to_do_question = "Que faire du patient ?",
    partial_diagnosis_percentage_name = "Il y a %d pour cent de chances que la maladie soit %s."
  },
  epidemic = {
    declare_explanation_fine = "Si vous déclarez l'épidémie, vous aurez une amende de %d, un changement de réputation et tous les patients seront vaccinés automatiquement."
  },
  emergency = {
    num_disease = "Il y a %d personnes atteintes de %s qui ont besoin de soins immédiats."
  },
  vip_visit_result = {
    telegram = "Télégramme !",
    vip_remarked_name = "Après avoir visité votre hôpital, %s a dit : ",
    remarks = {
      free_build = {"C'est vraiment un bel hôpital que vous avez là ! Pas trop difficile d'y arriver sans limite d'argent, hein ?", "Je ne suis pas économiste, mais je pense que je pourrais faire tourner cet hôpital aussi si vous voyez ce que je veux dire...", "Un hôpital très bien tenu. Cependant, attention à la récession ! Ah oui... vous n'avez pas à vous soucier de cela."},
    },
  },
  diagnosis_failed = {
    what_to_do_question = "Que faire du patient ?",
    partial_diagnosis_percentage_name = "Il y a %d pour cent de chances que la maladie soit %s."
  },
  diagnosis_failed = {
    what_to_do_question = "Que faire du patient ?",
    partial_diagnosis_percentage_name = "Il y a %d pour cent de chances que la maladie soit %s."
  }
}

dynamic_info = {
  patient = {
    actions = {
      prices_too_high = "C'est trop cher : je rentre chez moi.",
      no_diagnoses_available = "Plus de diagnostic : je rentre chez moi.",
      cured = "Guéri !",
      no_treatment_available = "Pas de traitement : je rentre chez moi."
    },
    diagnosed = "Ausculté : %s"
  }
}

transactions = {
  cure_colon = "Guérison :",
  final_treat_colon = "Trait final :",
  treat_colon = "Trait :",
  advance_colon = "Avance :",
  insurance_colon = "Assurance :",
  remove_room = "Construction : Supprimer la salle détruite"
}
diseases = {
  third_degree_sideburns = {
    cause = "Cause : regret pathologique des années 70.",
    cure = "Traitement : un psychiatre doit faire comprendre au patient qu'il faut changer d'époque comme de chemise.",
    name = "Rétrostalgie",
    symptoms = "Symptômes : passion immodérée des pantalons à pattes d'éléphant et des paillettes."
  },
  discrete_itching = {
    cause = "Cause : petits bestioles à dents aiguës.",
    cure = "Traitement : un sirop gluant est administré pour empêcher les démangeaisons.",
    name = "Morpionnite",
    symptoms = "Symptômes : le patient se gratte jusqu'au sang."
  },
  the_squits = {
    cause = "Cause : avoir mangé de la pizza ramassée derrière la cuisinière.",
    cure = "Traitement : un mélange gluant de diverses substances synthétiques est administré au patient pour solidifier son, euh, contenu.",
    name = "Courante",
    symptoms = "Symptômes : hum. Vous voyez le genre."
  },
  spare_ribs = {
    cause = "Cause : trop de temps passé sur un sol froid.",
    cure = "Traitement : deux chirurgiens retirent les côtes flottantes et les donnent au patient dans un sac à emporter.",
    name = "Excès costal",
    symptoms = "Symptômes : déplaisante sensation de flottement."
  },
  diag_blood_machine = {
    name = "Diag Sanguimachine"
  },
  king_complex = {
    cause = "Cause : l'esprit du King s'est emparé de celui du patient et l'a envahi.",
    cure = "Traitement : un psychiatre explique au patient à quel point tout ceci est ridicule.",
    name = "Syndrome du King",
    symptoms = "Symptômes : passion pour les chaussures en daim bleu et pour les cheeseburgers."
  },
  diag_x_ray = {
    name = "Diag Rayons X"
  },
  pregnancy = {
    cause = "Cause : pannes de courant en zones urbaines.",
    cure = "Traitement : le bébé est prélevé en salle d'opération puis soigneusement nettoyé pour faire son entrée dans le monde.",
    name = "Grossesse",
    symptoms = "Symptômes : gloutonnerie avec hypertrophie du ventre."
  },
  fake_blood = {
    cause = "Cause : avoir été victime d'une très mauvaise plaisanterie.",
    cure = "Traitement : seule une cure psychiatrique peut calmer le patient.",
    name = "Sang factice",
    symptoms = "Symptômes : le patient voit son sang s'évaporer."
  },
  diag_psych = {
    name = "Diag Psychiatre"
  },
  invisibility = {
    cause = "Cause : morsure par une fourmi radioactive (et invisible).",
    cure = "Traitement : il suffit de faire boire au patient un liquide coloré dispensé à la pharmacie pour le rendre pleinement observable.",
    name = "Invisibilité",
    symptoms = "Symptômes : le patient ne souffre pas mais a une forte propension à utiliser son état pour faire des farces à son entourage."
  },
  golf_stones = {
    cause = "Cause : exposition au gaz empoisonné contenu dans les balles de golf.",
    cure = "Traitement : résection des surplus par une équipe de deux chirurgiens.",
    name = "Pierres de golf",
    symptoms = "Symptômes : formation nodules excédentaires."
  },
  diag_general_diag = {
    name = "Diag Généraliste"
  },
  infectious_laughter = {
    cause = "Cause : exposition à un comique de situation.",
    cure = "Traitement : un psychiatre doit faire comprendre au patient à quel point son état est sérieux.",
    name = "Fou rire",
    symptoms = "Symptômes : gloussement irrépressible et répétition compulsive d'accroches même pas drôles."
  },
  general_practice = {
    name = "Généraliste"
  },
  baldness = {
    cause = "Cause : avoir raconté trop de mensonges pour se rendre intéressant.",
    cure = "Traitement : pose très douloureuse de cheveux à l'aide d'un moumouteur.",
    name = "Calvitie",
    symptoms = "Symptômes : tête en boule de billard et gros complexe."
  },
  heaped_piles = {
    cause = "Cause : s'être assis sur un jet de jacuzzi.",
    cure = "Traitement : une potion agréable bien que puissamment acide dissout les rectoïdes de l'intérieur.",
    name = "Rectoïdes",
    symptoms = "Symptômes : le patient a l'impression de s'asseoir sur un sac de billes."
  },
  unexpected_swelling = {
    cause = "Cause : n'importe quoi d'inattendu.",
    cure = "Traitement : le dégonflement est obtenu par une délicate opération pratiquée par deux chirurgiens.",
    name = "Bouffissure",
    symptoms = "Symptômes : bouffissure généralisée."
  },
  jellyitis = {
    cause = "Cause : abus de produits riches en gélifiant et trop d'exercice.",
    cure = "Traitement : le patient est immergé dans un dégélifiant.",
    name = "Gélatine",
    symptoms = "Symptômes : grande mollesse et tendance à l'écroulement."
  },
  hairyitis = {
    cause = "Cause : exposition prolongée au clair de lune.",
    cure = "Traitement : on fait disparaître les poils avec un électrolyseur et les pores sont scellés.",
    name = "Pilose",
    symptoms = "Symptômes : le patient développe un odorat accru."
  },
  alien_dna = {
    cause = "Cause : agrippeurs faciaux munis de sang extraterrestre intelligent.",
    cure = "Traitement : l'ADN est retiré par un correcteur pour être nettoyé puis restitué rapidement.",
    name = "ADN Alien",
    symptoms = "Symptômes : le patient se métamorphose progressivement en sale machin d'outre-espace et veut tout détruire."
  },
  bloaty_head = {
    cause = "Cause : avoir reniflé du fromage et bu de l'eau de pluie.",
    cure = "Traitement : la tête est éclatée puis regonflée à la bonne dimension à l'aide d'une astucieuse machine.",
    name = "Encéphalantiasis",
    symptoms = "Symptômes : affreux maux de tête."
  },
  gastric_ejections = {
    cause = "Cause : nourriture mexicaine ou indienne très épicée.",
    cure = "Traitement : administration par voie orale d'une solution spéciale pour endiguer les rejets.",
    name = "Éjections gastriques",
    symptoms = "Symptômes : le patient rejette par accès des bribes de nourriture mal digérée."
  },
  uncommon_cold = {
    cause = "Cause : divers trucmuches volant dans l'air",
    cure = "Traitement : absorption d'une grande rasade d'un sirop spécial élaboré à la pharmacie.",
    name = "Catarhume",
    symptoms = "Symptômes : nez qui coule, éternuements, poumons décolorés."
  },
  corrugated_ankles = {
    cause = "Cause : avoir roulé trop vite sur des ralentisseurs.",
    cure = "Traitement : le patient doit absorber un mélange d'herbes et d'épices légèrement toxique dont l'effet redressera illico les chevilles.",
    name = "Chevilles ondulées",
    symptoms = "Symptômes : les chaussures ne s'ajustent plus."
  },
  sleeping_illness = {
    cause = "Cause : hypertrophie de la glande palatale de Morphée.",
    cure = "Traitement : une infirmière administre une forte dose d'un puissant stimulant.",
    name = "Roupillance",
    symptoms = "Symptômes : tendance irrépressible à tomber de sommeil."
  },
  sweaty_palms = {
    cause = "Cause : terreur des entretiens d'embauche.",
    cure = "Traitement : un psychiatre détend le patient en lui racontant celle du fou qui repeint son plafond.",
    name = "Mains moites",
    symptoms = "Symptômes : serrer la main du patient revient à presser une éponge détrempée."
  },
  serious_radiation = {
    cause = "Cause : avoir pris du plutonium pour des bonbons.",
    cure = "Traitement : le patient est passé à la douche de décontamination et consciencieusement récuré.",
    name = "Radionite",
    symptoms = "Symptômes : le patient ne se sent vraiment, vraiment pas bien."
  },
  diag_cardiogram = {
    name = "Diag Cardio"
  },
  diag_scanner = {
    name = "Diag Scanner"
  },
  gut_rot = {
    cause = "Cause : la Bonne Vieille Bibine de la Mère Sam.",
    cure = "Traitement : une infirmière doit administrer diverses substances chimiques pour tenter de colmater le tout.",
    name = "Tripurulente",
    symptoms = "Symptômes : aucun microbe mais plus de paroi intestinale non plus."
  },
  iron_lungs = {
    cause = "Cause : pollution atmosphérique combinée aux remugles de kébab.",
    cure = "Traitement : deux chirurgiens enlèvent le blindage en salle d'opération.",
    name = "Poumons de fer",
    symptoms = "Symptômes : envie de respirer du feu et de hurler sous l'eau."
  },
  broken_wind = {
    cause = "Cause : utilisation d'un appareil de musculation juste après un repas.",
    cure = "Traitement : une mixture d'eau lourde est administrée à la pharmacie.",
    name = "Pétomanie",
    symptoms = "Symptômes : pollution de l'air des personnes situées derrière le patient."
  },
  kidney_beans = {
    cause = "Cause : avoir croqué les glaçons de son cocktail.",
    cure = "Traitement : deux chirurgiens extraient les cristaux sans endommager le rein.",
    name = "Cristaux rénaux",
    symptoms = "Symptômes : douleur et fréquentes visites aux toilettes."
  },
  transparency = {
    cause = "Cause : avoir léché le yaourt adhérent au couvercle à l'ouverture d'un pot.",
    cure = "Traitement : administration d'une potion fraîche et colorée préparée à la pharmacie.",
    name = "Transparence",
    symptoms = "Symptômes : la chair est horrible et transparente."
  },
  broken_heart = {
    cause = "Cause : avoir croisé quelqu'un de plus riche, plus jeune et plus beau.",
    cure = "Traitement : deux chirurgiens ouvrent la poitrine et réparent doucement le coeur en retenant leur souffle.",
    name = "Coeur brisé",
    symptoms = "Symptômes : pleurnicheries et crampes causées par des heures à regarder de vieilles photos de vacances."
  },
  slack_tongue = {
    cause = "Cause : trop de discussion à propos des romans-feuilletons.",
    cure = "Traitement : la langue est placée dans un taille-langue puis elle est coupée rapidement, efficacement et douloureusement.",
    name = "Hyperlangue",
    symptoms = "Symptômes : la langue s'étire jusqu'à cinq fois sa longueur normale."
  },
  tv_personalities = {
    cause = "Cause : avoir abusé des programmes télévisés.",
    cure = "Traitement : un psychiatre doit convaincre le patient d'échanger sa télévision contre une radio.",
    name = "Téléincarnation",
    symptoms = "Symptômes : le patient a l'illusion d'être capable de présenter une émission de cuisine."
  },
  ruptured_nodules = {
    cause = "Cause : saut à l'élastique par temps froid.",
    cure = "Traitement : deux chirurgiens doivent réajuster les parties concernées d'une main sûre.",
    name = "Casse-boules",
    symptoms = "Symptômes : impossibilité de s'asseoir confortablement."
  },
  fractured_bones = {
    cause = "Cause : chute spectaculaire sur du béton.",
    cure = "Traitement : un plâtre est posé puis ôté à l'aide d'un équipement au laser.",
    name = "Fractures",
    symptoms = "Symptômes : affreux craquement et incapacité à utiliser les membres touchés."
  },
  chronic_nosehair = {
    cause = "Cause : avoir reniflé avec dédain à la vue de plus malheureux que soi.",
    cure = "Traitement : une épouvantable potion dépilatoire est administrée par une infirmière à la pharmacie.",
    name = "Poilonisme",
    symptoms = "Symptômes : poils au nez si drus qu'un oiseau pourrait y nicher."
  }
}

confirmation = {
  quit = "Vous avez choisi Quitter. Voulez-vous vraiment quitter le jeu ?",
  return_to_blueprint = "Êtes-vous sûr de vouloir revenir au mode Tracé ?",
  restart_level = "Êtes-vous sûr de vouloir relancer ce niveau ?",
  overwrite_save = "Il y a déjà une partie sauvegardée ici. Êtes-vous sûr de vouloir l'écraser ?",
  delete_room = "Voulez-vous vraiment détruire cette salle ?",
  sack_staff = "Êtes-vous sûr de vouloir licencier ?",
  replace_machine = "Voulez-vous vraiment remplacer cette machine ?"
}

-- The originals of these strings contain one space too much
trophy_room.sold_drinks.trophies[2] = "Vous recevez le prix Bubulles du Syndicat des Vendeurs de Limonade pour récompenser la quantité de sodas vendus dans votre hôpital au cours de l'année écoulée."

tooltip.status.percentage_cured = "Vous devez soigner %d%% des visiteurs de l'hôpital. Actuellement, vous en avez soigné %d%%"
tooltip.status.num_cured = "L'objectif est de soigner %d personnes. Pour le moment, vous en avez soigné %d"
dynamic_info.staff.actions.going_to_repair = "Pour réparer %s"
adviser.staff_place_advice = {
  only_doctors_in_room = "Seuls les médecins peuvent travailler en %s",
  nurses_cannot_work_in_room = "Les infirmières ne peuvent travailler en %s",
  not_enough_lecture_chairs = "Chaque étudiant en médecine a besoin d'une chaise de conférence pour s'asseoir !"
}
pay_rise.definite_quit = "Rien ne me fera rester ici. J'en ai assez."
place_objects_window.confirm_or_buy_objects = "Vous pouvez valider ainsi ou bien soit acheter soit déplacer des objets."

----------------------------------------------------------- New strings -----------------------------------------------------------

date_format = {
  daymonth = "%1% %2:months%"
}

-- Objects
object.rathole = "Trou à rats."
object.litter = "Déchet"
tooltip.objects.litter = "Déchet : laissé sur le sol par un patient car il n'a pas trouvé de poubelle où le jeter."

tooltip.fax.close = "Fermer cette fenêtre sans supprimer le message"
tooltip.message.button = "clic gauche pour ouvrir le message"
tooltip.message.button_dismiss = "clic gauche pour ouvrir le message, clic droit pour le rejeter"
tooltip.casebook.cure_requirement.hire_staff = "Vous devez embaucher du personnel pour gérer ce traitement"
tooltip.casebook.cure_type.unknown = "Vous ne savez pas encore comment traiter cette maladie"
tooltip.research_policy.no_research = "Aucune recherche n'est actuellement effectuée dans cette catégorie"
tooltip.research_policy.research_progress = "Progrès vers la prochaine découverte dans cette catégorie : %1%/%2%"

menu_file = {
  load = " (%1%) CHARGER   ",
  save = " (%1%) ENREGISTRER   ",
  restart = " (%1%) RELANCER",
  quit = " (%1%) QUITTER   "
}

-- Options menu
menu_options = {
  lock_windows = "  FIGER LES FENETRES  ",
  edge_scrolling = "  DEFILEMENT PAR BORD  ",
  adviser_disabled = "  (%1%) ASSISTANT  ",
  warmth_colors = "  COULEURS CHAUDES  ",
  wage_increase = " AUGMENTATION DE SALAIRE ",
  twentyfour_hour_clock = " HORLOGE 24 HEURES ",
  capture_mouse = "  CAPTURER LE CURSEUR  "
}

menu_options_game_speed = {
  pause = "  (%1%) PAUSE  ",
  slowest = "  (%1%) AU PLUS LENT  ",
  slower = "  (%1%) PLUS LENT  ",
  normal = "  (%1%) NORMAL  ",
  max_speed = "  (%1%) VITESSE MAXI  ",
  and_then_some_more = "  (%1%) ET ENCORE PLUS  "
}

menu_options_warmth_colors = {
  choice_1 = "  ROUGE  ",
  choice_2 = "  BLEU VERT ROUGE  ",
  choice_3 = "  JAUNE ORANGE ROUGE  "
}

menu_options_wage_increase = {
  grant = " ACCORDER ",
  deny = " REFUSER "
}

-- Charts Menu ' Temporary; must see in-game for correct translation
menu_charts = {
  bank_manager = "  (%1%) GESTION BANCAIRE  ",
  statement = "  (%1%) DECLARATION  ",
  staff_listing = "  (%1%) LISTE DU PERSONNEL  ",
  town_map = "  (%1%) CARTE DE LA VILLE  ",
  casebook = "  (%1%) MALLETTE  ",
  research = "  (%1%) RECHERCHE  ",
  status = "  (%1%) STATUTS  ",
  graphs = "  (%1%) GRAPHIQUES  ",
  policy = "  (%1%) POLITIQUE "
}

-- Debug menu
menu_debug = {
  jump_to_level = "  ALLER AU NIVEAU  ",
  connect_debugger = "  (%1%) CONNECTER AU SERVEUR DE DÉBOGUAGE ",
  transparent_walls = "  (%1%) MURS TRANSPARENTS  ",
  limit_camera = "  LIMITER LA CAMERA  ",
  disable_salary_raise = "  DÉSACTIVER LES AUGMENTATIONS DE SALAIRE  ",
  make_debug_fax = "  CRÉER UN FAX DE TEST  ",
  make_debug_patient = "  CRÉER UN PATIENT DE TEST  ",
  cheats = "  (%1%) TRICHES  ",
  lua_console = "  (%1%) CONSOLE LUA  ",
  debug_script = "  (%1%) ACTIVER LE DÉBOGUAGE PAR SCRIPT ",
  calls_dispatcher = "  RÉPARTITION DES TACHES  ", -- Â not supported by TH Font
  dump_strings = "  (%1%) EXTRAIRE LES TRADUCTIONS  ",
  dump_gamelog = "  (%1%) EXTRAIRE LE JOURNAL DE JEU  ",
  map_overlay = "  INCRUSTATIONS DE CARTE  ",
  sprite_viewer = "  VISIONNEUSE DE SPRITES  ",
  allow_blocking_off_areas = "  AUTORISER LE BLOCAGE DES ZONES  "
}

menu_debug_overlay = {
  none = "  AUCUN  ",
  flags = "  DRAPEAUX  ",
  positions = "  POSITIONS  ",
  heat = "  TEMPÉRATURE  ",
  byte_0_1 = "  OCTETS 0 & 1  ",
  byte_floor = "  OCTET SOL  ",
  byte_n_wall = "  OCTET MUR N  ",
  byte_w_wall = "  OCTET MUR O  ",
  byte_5 = "  OCTET 5  ",
  byte_6 = "  OCTET 6  ",
  byte_7 = "  OCTET 7  ",
  parcel = "  PARCELLE  "
}

menu_player_count = {
  players_1 = "  1 JOUEUR  ",
  players_2 = "  2 JOUEURS  ",
  players_3 = "  3 JOUEURS  ",
  players_4 = "  4 JOUEURS  "
}

-- Adviser
adviser = {
  room_forbidden_non_reachable_parts = "Placer la pièce à cet endroit rendrait inaccessibles certaines parties de l'hôpital",

  warnings = {
    no_desk = "Vous devriez construire un bureau de réception et engager une réceptionniste un de ces jours !",
    no_desk_1 = "Si vous voulez que des patients viennent dans votre hôpital, vous devez embaucher une réceptionniste et lui construire un bureau pour travailler !",
    no_desk_2 = "Bien joué, ça doit être un record : presque un an et pas de patient ! Si vous voulez continuer comme directeur de cet hôpital, vous devez embaucher une réceptionniste et lui construire un bureau pour travailler !",
    no_desk_3 = "C'est tout simplement génial, presque un an et vous n'avez pas embauché de réceptionniste ! Comment espérez obtenir le moindre patient ? Arrangez-ça et arrêtez de perdre votre temps !",
    no_desk_4 = "Une réceptionniste aura besoin d'un bureau pour accueillir des patients",
    no_desk_5 = "Il était temps, maintenant les patients devraient commencer à arriver bientôt !",
    no_desk_6 = "Vous avez une réceptionniste, peut-être il est temps de construire un bureau où elle peut travailler ?",
    no_desk_7 = "Maintenant, que vous avez une réception, que diriez-vous d'embaucher une réceptionniste également ? Vous n'aurez pas de patients avant de l'avoir fait !",
    cannot_afford = "Vous n'avez pas assez d'argent à la banque pour embaucher cette personne !", -- I can't see anything like this in the original strings
    cannot_afford_2 = "Vous n'avez pas assez d'argent à la banque pour effectuer l'achat !",
    research_screen_open_1 = "Vous devez construire une salle de recherche avant de pouvoir accéder à l'écran des recherches.",
    research_screen_open_2 = "La recherche est désactivée pour le niveau en cours.",
    researcher_needs_desk_1 = "Chaque chercheur a besoin d'un bureau pour travailler.",
    researcher_needs_desk_2 = "Vos chercheurs sont heureux d'obtenir une pause bien méritée. Si vous voulez que plusieurs chercheurs puissent travailler en même temps.",
    researcher_needs_desk_3 = "Un chercheur a toujours besoin d'un bureau.",
    nurse_needs_desk_1 = "Chaque infirmière a besoin de son propre bureau.",
    nurse_needs_desk_2 = "Votre infirmière est heureuse d'avoir une pause. Si vous comptez y faire travailler plusieurs personnes en même temps, vous devez leur construire un bureau à chacune.",
    low_prices = "Vous facturez trop peu pour %s. Ça va amener des gens dans votre hôpital, mais vous ne ferez pas beaucoup de profit sur chacun d'eux.",
    high_prices = "Votre tarif pour %s est trop élevé. Ça va générer plus de profit sur le court-terme, mais à la longue les gens vont fuir.",
    fair_prices = "Le prix pour %s semble juste et équilibré.",
    patient_not_paying = "Un patient est parti sans payer pour %s parce que c'est trop cher !",
    another_desk = "Vous devrez construire un autre bureau pour cette nouvelle réceptionniste.",
    money_low = "Les fonds sont en baisse !",
    no_patients_last_month = "Pas de nouveaux patients le mois dernier. Honteux !",
    machines_falling_apart = "Les machines tombent en panne. Faites-les réparer !",
    bankruptcy_imminent = "Hé ! Vous courez à la faillite. Attention !",
    too_many_plants = "Il y a bien trop de plantes. C'est la jungle, ici !",
    many_killed = "Vous avez laissé mourir %d personnes. Idiot ! Vous êtes censé les soigner.",
    falling_1 = "Hé ! Ce n'est pas drôle, regardez ou vous cliquez, quelqu'un pourrait être blessé !",
    falling_2 = "Arrêtez de faire n'importe quoi, qu'en penseriez-vous à leur place ?",
    falling_3 = "Aïe, ça doit faire mal,  qu'on appelle un médecin !",
    falling_4 = "C'est un hôpital, pas un parc d'attraction !",
    falling_5 = "Ce n'est pas un endroit pour bousculer les gens, ils sont malades vous savez ?",
    falling_6 = "Ce n'est pas un bowling, les gens malades ne devraient pas être traités comme ça !",
    handymen_tired = "Les agents de maintenance sont très fatigués. Laissez-les se reposer.", -- Add a missing letter
    cannot_afford_machine = "Vous avez besoin de au moins $%1% dans la banque pour pouvoir acheter: %2%!",
  },
  cheats = {
    th_cheat = "Félicitations, vous avez débloqué les triches !",
    roujin_on_cheat = "Défi de Roujin activé ! Bonne chance...",
    roujin_off_cheat = "Défi de Roujin désactivé.",
    norest_on_cheat = "Oh non ! Il semble que votre personnel ait trop consommé de caféine et n'ait plus besoin de se reposer.",
    norest_off_cheat = "Ouf ! On dirait que cette excitation s'est enfin dissipée. Votre personnel se reposera maintenant correctement."
  }
}

-- Dynamic information
dynamic_info.patient.actions.no_gp_available = "Attente d'un cabinet de médecine générale"
dynamic_info.staff.actions.heading_for = "Va vers %s"
dynamic_info.staff.actions.fired = "Renvoyé"
dynamic_info.patient.actions.epidemic_vaccinated = "Je ne suis plus contagieux"
dynamic_info.object.strength_extra_info = "Force %d (Améliorable jusqu'à %d)"
dynamic_info.staff.actions.vaccine = "Vaccination d'un patient"

-- Progress report
progress_report.free_build = "CONSTRUCTION LIBRE"

-- Fax messages
fax = {
  choices = {
    return_to_main_menu = "Retourner au menu principal",
    accept_new_level = "Aller au niveau suivant",
    decline_new_level = "Continuer la partie encore un peu"
  },
  emergency = {
    num_disease_singular = "Il y a 1 personne atteinte de %s qui a besoin de soins immédiats.",
    free_build = "Si vous réussissez votre réputation augmentera mais si vous échouez votre réputation sera sérieusement entachée."
  },
}

-- Winning texts
letter = {
  dear_player = "Cher %s",
  custom_level_completed = "Félicitations ! Vous avez réussi tous les objectifs de ce niveau personnalisé !",
  return_to_main_menu = "Voulez-vous retourner au menu principal ou continuer la partie ?",
  campaign_completed = "Incroyable ! Vous avez réussi à terminer tous les niveaux. Vous pouvez maintenant vous détendre et profiter de remplir des forums sur Internet de vos réalisations. Bonne chance !",
  campaign_level_missing = "Désolé, mais le prochain niveau de cette campagne semble manquer. (Nom: %s)",
  campaign_level_completed = "Bon travail ! Vous avez battu le niveau. Mais ce n'est pas fini !\n Aimeriez-vous un poste à l'hôpital %s ?"
}

-- Installation
install = {
  title = "----------------------------- Installation de CorsixTH -----------------------------",
  th_directory = "CorsixTH nécessite une copie des données du jeu Theme Hospital originel (ou la démo) pour fonctionner. Veuillez utiliser le sélecteur ci-dessous pour indiquer le dossier d'installation de Theme Hospital.",
  ok = "OK",
  exit = "Quitter",
  cancel = "Annuler"
}

-- Misc (some other misc strings also exist outside this section)
misc = {
  not_yet_implemented = "(pas encore implémenté)",
  no_heliport = "Aucune maladie n'a été découverte pour l'instant, ou il n'y a pas d'héliport sur cette carte.",
  epidemics_off = "Les épidémies sont désactivées",
  epidemics_on = "Les épidémies sont activées",
  epidemic_no_receptionist = "Impossible de créer une épidémie - il n'y a pas de réceptionniste",
  epidemic_no_diseases = "Impossible de créer une épidémie - il n'y a pas de maladie contagieuse disponible",
  epidemic_no_icon_to_toggle = "Impossible de montrer/cacher les icônes des infectés - il n'y a pas d'épidémies non-révélées",
  earthquakes_off = "Les tremblements de terre sont désactivés",
  earthquakes_on = "Les tremblements de terre sont activés"
}

-- Main menu
main_menu = {
  new_game = "Nouvelle partie",
  custom_level = "Niveau personnalisé",
  continue = "Continuer la partie",
  load_game = "Charger une partie",
  options = "Options",
  savegame_version = "Version de la sauvegarde : ",
  version = "Version : ",
  exit = "Quitter",
  map_edit = "Éditeur de carte",
  custom_campaign = "Campagne personnalisée",
  updates_off = "Ne pas vérifier les mises à jour"
}

tooltip.main_menu = {
  new_game = "Commencer une nouvelle partie",
  custom_level = "Construire votre hôpital dans un niveau personnalisé",
  continue = "Continuer la partie",
  load_game = "Charger une partie sauvegardée",
  options = "Modifier quelques paramètres",
  exit = "Non, non, SVP, ne quittez pas !",
  map_edit = "Créer une carte personnalisée",
  custom_campaign = "Jouer une campagne créée par la communauté"
}

-- Load game window
load_game_window = {
  caption = "Charger une partie"
}

tooltip.load_game_window = {
  load_game = "Charger la partie %s",
  load_game_number = "Charger la partie %d",
  load_autosave = "Charger la sauvegarde automatique"
}

-- Custom game window
custom_game_window = {
  caption = "Niveau personnalisé",
  free_build = "Construction libre",
  load_selected_level = "Démarrer"
}

tooltip.custom_game_window = {
  free_build = "Cochez cette case si vous souhaitez jouer sans limite d'argent et sans conditions de victoire ou de défaite",
  choose_game = "Cliquez sur un niveau pour en savoir plus",
  load_selected_level = "Charger et jouer le niveau sélectionné"
}

-- Custom campaign window
custom_campaign_window = {
  caption = "Campagne personnalisée",
  start_selected_campaign = "Démarrer la campagne"
}

tooltip.custom_campaign_window = {
  choose_campaign = "Choisissez une campagne pour en savoir plus à son sujet",
  start_selected_campaign = "Charger le premier niveau de cette campagne"
}

-- Save game window
save_game_window = {
  caption = "Enregistrer la partie",
  new_save_game = "Nouvelle sauvegarde"
}

tooltip.save_game_window = {
  save_game = "Écraser la sauvegarde %s",
  new_save_game = "Entrez un nom pour la sauvegarde"
}

save_map_window = {
  caption = "Sauvegarder la carte (%1%)",
  new_map = "Nouvelle carte"
}

tooltip.save_map_window = {
  map = "Ecraser la carte %s",
  new_map = "Entrez le nom pour une sauvegarde de la carte"
}

-- Menu list window
menu_list_window = {
  back = "Précédent",
  save_date = "Modifié",
  name = "Nom",
  ok = "OK"
}

tooltip.menu_list_window = {
  back = "Fermer cette fenêtre",
  save_date = "Cliquez ici pour classer la liste par date de dernière modification",
  name = "Cliquez ici pour classer la liste par par nom",
  ok = "Confirmer le choix"
}

-- Options window
options_window = {
  apply = "Appliquer",
  audio = "Audio Global",
  back = "Précédent",
  cancel = "Annuler",
  caption = "Paramètres",
  capture_mouse = "Capture de la souris",
  change_resolution = "Changer la résolution",
  check_for_updates = "Vérifier les mises à jour",
  custom_resolution = "Personnaliser...",
  customise = "Personnaliser",
  folder = "Dossier",
  fullscreen = "Plein Écran",
  height = "Hauteur",
  hotkey = "Touches de raccourci",
  language = "Langue du jeu",
  option_disabled = "Désactivé",
  option_enabled = "Activé",
  option_off = "Désactiver",
  option_on = "Activer",
  resolution = "Résolution",
  scrollspeed = "Vitesse de défilement",
  shift_scrollspeed = "Vitesse de défilement avec Maj",
  width = "Largeur",
  zoom_speed = "Vitesse de zoom",
  right_mouse_scrolling = "Défilement Souris",
  right_mouse_scrolling_option_middle = "Bouton Milieu",
  right_mouse_scrolling_option_right = "Bouton Droit",
  jukebox = "Jukebox"
}

tooltip.options_window = {
  fullscreen = "Mode plein écran ou mode fenêtré",
  fullscreen_button = "Basculer en mode plein écran/fenêtré",
  resolution = "La résolution vidéo pour le jeu",
  select_resolution = "Sélectionner une nouvelle résolution",
  width = "Entrez la largeur désirée",
  height = "Entrez la hauteur désirée",
  change_resolution = "Changer la résolution pour les dimensions entrées à gauche",
  language = "Utiliser la langue %s",
  back = "Fermer la fenêtre des options",
  cancel = "Retour sans changement de résolution",
  apply = "Appliquer la résolution choisie",
  language_dropdown_item = "Choisir %s comme langue",
  select_language = "Sélectionner la langue du jeu",
  audio_button = "Activer ou désactiver le système audio dans le jeu",
  audio_toggle = "Activer ou désactiver",
  folder_button = "Dossier des paramètres",
  customise_button = "Paramètres supplémentaires qui peuvent être modifiés pour personnaliser votre expérience de jeu",

  apply_shift_scrollspeed = "Appliquer la vitesse de défilement en mode Maj.",
  shift_scrollspeed = "Définir la vitesse de défilement lorsque la touche Maj est enfoncée. De 1 (la plus lente) à 10 (la plus rapide). La valeur par  défaut est 4.",
  hotkey = "Modifier les touches de raccourci du clavier.",
  check_for_updates = "Choisir si le jeu doit rechercher des mises à jour au démarrage.",
  zoom_speed = "Définir la vitesse de zoom de la caméra de 10 (la plus lente) à 1000 (la plus rapide). La valeur par défaut est 80.",
  cancel_zoomspeed = "Revenir sans changer la vitesse de zoom.",
  apply_zoomspeed = "Appliquer la vitesse de zoom choisie.",
  cancel_scrollspeed = "Revenir sans changer la vitesse de défilement.",
  cancel_shift_scrollspeed = "Revenir sans changer la vitesse de défilement de la touche Maj.",
  scrollspeed = "Réglez la vitesse de défilement de 1 (la plus lente) à 10 (la plus rapide). La valeur par défaut est 2.",
  apply_scrollspeed = "Appliquer la vitesse de défilement entrée.",
  capture_mouse = "Cliquez pour activer la capture du curseur dans la fenêtre du jeu.",
  language_dropdown_no_font = "Sélectionnez une police d'écriture dans les paramètres pour activer ce langage",
  right_mouse_scrolling = "Activer le bouton qui est utilisé pour faire défiler la carte",
  jukebox = "Ouvrir le Jukebox pour changer la musique"
}

customise_window = {
  caption = "Paramètres Supplémentaires",
  option_on = "Activer",
  option_off = "Désactiver",
  back = "Retour",
  movies = "Contrôle des cinématiques",
  intro = "Jouer la cinématique d'intro",
  paused = "Construction en pause",
  volume = "Touche de raccourci pour diminuer le volume",
  aliens = "Extraterrestres",
  fractured_bones = "Fractures",
  average_contents = "Achats mémorisés",
  remove_destroyed_rooms = "Supprimer les salles détruites"
}

tooltip.customise_window = {
  movies = "Sélectionnez si les cinématiques doivent être joués.",
  intro = "Passer la cinématique d'introduction lorsque vous démarrez le jeu. Le contrôle des cinématiques doit être activé si vous jouez la cinématique d'introduction à chaque fois que vous chargez CorsixTH",
  paused = "Dans Theme Hospital le joueur ne sera autorisé à utiliser le menu principal que si le jeu est en pause. C'est le paramètre par défaut dans CorsixTH aussi, mais en l'activant tout est permis pendant que le jeu est en pause",
  volume = "Si la touche de réduction du volume ouvre également le journal de médecine, activer cette option pour modifier le raccourci des dossiers médicaux à Maj + C",
  aliens = "Comme il y a des animations appropriées, nous avons fait de sorte que les patients avec l'ADN extraterrestre montrent seulement comme des situations d'urgence. Désactivez cette option pour obtenir cas de l'ADN extraterrestre visites régulières",
  fractured_bones = "En raison de la qualité faible de l'animation il n'y a pas de patientes avec des fractures. Désactivez cette option si vous désirez avoir des femmes avec des fractures.",
  average_contents = "Si vous voulez que le jeu se rappelle des articles supplémentaires que vous avez tendance à normalement magasiner pour une nouvelle salle, activer cette option",
  back = "Fermer ce menu et revenir au menu d'options",
  remove_destroyed_rooms = "Si vous souhaitez pouvoir retirer les salles détruites, moyennant paiement, activez cette option"
}

folders_window = {
  caption = "Paramètres de dossier",
  data_label = "Données de TH",
  font_label = "Police",
  music_label = "MP3",
  savegames_label = "Sauvegarde",
  screenshots_label = "Captures d'écran",
  -- next four are the captions for the browser window, which are called from the folder setting menu
  new_th_location = "Ici vous pouvez spécifier un nouveau répertoire d'installation de Theme Hospital. Dès que vous choisissez le nouveau répertoire, le jeu sera redémarré.",
  savegames_location = "Sélectionner le répertoire que vous voulez utiliser pour les sauvegardes",
  music_location = "Sélectionner le répertoire que vous voulez utiliser pour la musique",
  screenshots_location = "Sélectionner le répertoire que vous voulez utiliser pour les captures d'écran",
  back = "Retour"
}

tooltip.folders_window = {
  browse = "Parcourir l'emplacement du dossier",
  data_location = "Le répertoire d'origine de l'installation de Theme Hospital, qui est requis pour faire fonctionner CorsixTH",
  font_location = "Emplacement d'un fichier de police qui est capable d'afficher des caractères Unicode requises par votre langue. Si aucun emplacement n'est spécifié vous ne serez pas en mesure de choisir des langues qui ont des caractères que le jeu original ne peut pas fournir. Exemple : Russe et Chinois",
  savegames_location = "Par défaut, le répertoire de sauvegardes est à côté du fichier de configuration et sera utilisé pour stocker les sauvegardes. Si cela n'est pas approprié vous pouvez modifier ce répertoire.",
  screenshots_location = "Par défaut, les captures d'écran sont stockés dans un dossier avec le fichier de configuration. Si cela ne convient pas vous pouvez choisir votre propre dossier.",
  music_location = "Sélectionnez un emplacement pour vos fichiers MP3.",
  browse_data = "Parcourir un autre emplacement d'une installation de Theme Hospital (emplacement actuel : %1%)",
  browse_font = "Parcourir un autre fichier de police (emplacement actuel : %1%)",
  browse_saves = "Parcourir un autre répertoire de sauvegardes (emplacement actuel : %1%)",
  browse_screenshots = "Parcourir un autre répertoire de captures d'écrans (emplacement actuel : %1%)",
  browse_music = "Parcourir un autre répertoire de musique (emplacement actuel : %1%)",
  no_font_specified = "Aucun répertoire de police spécifié !",
  not_specified = "Aucun répertoire spécifié !",
  default = "Emplacement par défaut",
  reset_to_default = "Réinitialiser le répertoire à son emplacement par défaut",
  back = "Fermer ce menu et revenir au menu Paramètres"
}

font_location_window = {
  caption = "Choisir une police (%1%)"
}

-- Handyman window
handyman_window = {
  all_parcels = "Partout",
  parcel = "Parcelle"
}

tooltip.handyman_window = {
  parcel_select = "Les parcelles où les agents de maintenance peuvent travailler : cliquez pour changer le paramètre."
}

--- New game window
new_game_window = {
  easy = "Interne (Facile)",
  medium = "Médecin (Moyen)",
  hard = "Consultant (Difficile)",
  tutorial = "Tutoriel",
  cancel = "Annuler",
  option_on = "Activer",
  option_off = "Désactiver",
  difficulty = "Difficulté",
  caption = "Campagne",
  player_name = "Nom du joueur",
  start = "Démarrer"
}

tooltip.new_game_window = {
  easy = "Si vous jouez pour la première fois à un jeu de simulation, cette option est pour vous",
  medium = "C'est la voie du milieu à prendre si vous ne savez pas quoi choisir",
  hard = "Si vous êtes habitué à ce genre de jeu et que vous souhaitez plus d'un défi, choisissez cette option",
  tutorial = "Si vous voulez un peu d'aide pour démarrer une fois dans le jeu, cochez cette case",
  cancel = "Oh, je n'avais pas vraiment l'intention de commencer une nouvelle partie !",
  difficulty = "Sélectionnez le niveau de difficulté que vous voulez dans le jeu",
  start = "Démarrer le jeu avec les paramètres sélectionnés",
  player_name = "Entrez le nom par lequel vous voulez être appelé dans le jeu"
}

-- Lua Console
lua_console = {
  execute_code = "Exécuter",
  close = "Fermer"
}

tooltip.lua_console = {
  textbox = "Entrez du code Lua à exécuter ici",
  execute_code = "Exécuter le code que vous avez entré",
  close = "Fermer la console"
}

-- Errors
errors = {
  dialog_missing_graphics = "Désolé, les données de démo ne contiennent pas cette boîte de dialogue.",
  save_prefix = "Erreur lors de la sauvegarde de la partie : ",
  load_prefix = "Erreur lors du chargement de la partie : ",
  load_map_prefix = "Erreur pendant le chargement de la carte: ",
  load_level_prefix = "Erreur pendant le chargement du niveau: ",
  no_games_to_contine = "Pas de parties sauvegardées.",
  map_file_missing = "Impossible de trouver le fichier de carte %s pour ce niveau !",
  minimum_screen_size = "Veuillez entrer une résolution supérieure à 640x480.",
  unavailable_screen_size = "La résolution que vous avez demandée n'est pas disponible en plein écran.",
  alien_dna = "NOTE : Il n'y a pas d'animations pour les patients étrangers pour s'asseoir, ouvrir ou de frapper aux portes, etc. Donc, comme avec Theme Hospital pour faire ces choses, ils semblent changer à la normale et ensuite changer de nouveau. Les patients avec l'ADN Alien apparaîtront seulement s'ils sont définis dans le fichier de niveau.",
  fractured_bones = "NOTE : L'animation pour les patients de sexe féminin avec des os fracturés n'est pas parfaite.",
  load_quick_save = "Erreur, impossible de charger la sauvegarde rapide car elle n'existe pas, ne vous inquiétez pas nous avons créé une pour vous !",
  could_not_find_first_campaign_level = "Impossible de trouver le premier niveau de cette campagne : %s",
  save_to_tmp = "Le fichier à l'emplacement %s n'a pas pu être utilisé. Le jeu a été enregistré sous %s. Erreur : %s",
  could_not_load_campaign = "Échec du chargement de la campagne : %s",
  dialog_empty_queue = "Désolé, un être humain vient d'avoir une file d'actions vide, ce qui signifie qu'il ne savait pas quoi faire ensuite. Veuillez consulter la fenêtre de commande pour des informations plus détaillées. Un dialogue avec l'individu fautif a été ouvert. Souhaitez-vous qu'il quitte l'hôpital ?",

  compatibility_error = {
    new_in_old = "Désolé, cette sauvegarde a été créée avec une version plus récente de CorsixTH et n'est pas compatible. Veuillez mettre à jour vers une version plus récente.",
    full_in_demo = "Désolé, vous ne pouvez pas ouvrir une sauvegarde de jeu complet avec les fichiers de démonstration chargés. Veuillez mettre à jour votre paramètre de dossier TH Data.",
    demo_in_full = "Désolé, vous ne pouvez pas ouvrir une sauvegarde de démonstration avec les fichiers de jeu complet chargés. Veuillez mettre à jour votre paramètre de dossier TH Data."
  }
}

-- Confirmation dialog
confirmation = {
  needs_restart = "Changer ce paramètre va nécessiter un redémarrage de CorsixTH. Tout progrès non sauvegardé sera perdu. Êtes-vous sûr de vouloir faire cela ?",
  abort_edit_room = "Vous êtes actuellement en train de construire ou d'éditer une pièce. Si tous les objets requis sont placés, elle sera validée, mais sinon elle sera détruite. Continuer ?",
  maximum_screen_size = "La taille de l'écran que vous avez entrée est supérieure à 3000 x 2000. Des plus hautes résolutions sont possibles, mais il faudra un meilleur matériel afin de maintenir un taux de trame jouable. Êtes-vous sûr de vouloir continuer?",
  remove_destroyed_room = "Souhaitez-vous supprimer la salle pour %d $ ?",
  replace_machine_extra_info = "La nouvelle machine aura une puissance de %d (actuellement %d).",
  very_old_save = "Il y a eu de nombreuses mises à jour du jeu depuis que vous avez commencé. Pour être sûr que toutes les fonctionnalités fonctionnent comme prévu, voudriez-vous recommencer ce niveau maintenant ?//"..
  "Votre ancienne sauvegarde ne sera pas supprimée à moins que vous ne l'écrasiez."
}

-- Information dialog
information = {
  custom_game = "Bienvenue dans CorsixTH. Amusez-vous bien avec cette carte personnalisée !",
  no_custom_game_in_demo = "Désolé, mais dans la version démo vous ne pouvez jouer avec aucune des cartes personnalisées.",
  cannot_restart = "Malheureusement cette partie personnalisée a été sauvegardée avant que la fonctionnalité de redémarrage soit implémentée.",
  very_old_save = "Il y a eu beaucoup de mises à jour du jeu depuis que vous avez commencé ce niveau. Pour être sûr que tout fonctionne comme prévu, pensez à recommencer le niveau.",
  cheat_not_possible = "Vous ne pouvez pas utiliser ce code de triche dans ce niveau.",
  level_lost = {
    "Quelle poisse ! Vous avez raté le niveau. Vous ferez mieux la prochaine fois !",
    "Voilà pourquoi vous avez perdu : ",
    reputation = "Votre réputation est tombée en dessous de %d.",
    balance = "Votre solde bancaire est tombé en dessous %d.",
    percentage_killed = "Vous avez tué plus de %d pourcents de vos patients.",
    cheat = "J'espère que vous n'avez pas cliqué sur le bouton \" Perdre le niveau \" par accident !"
  }
}

tooltip.information = {
  close = "Fermer cette boîte de dialogue."
}

-- "Tip of the day" window
totd_window = {
  tips = {
    "Chaque hôpital a besoin d'un bureau de réception et d'un cabinet de médecine générale. Après, tout dépend du type de patients qui visitent votre hôpital. Une pharmacie est toujours un bon choix malgré tout.",
    "Les machines telles que le Gonflage ont besoin de maintenance. Embauchez un ou deux agents de maintenance pour réparer vos machines, ou vous risquerez d'avoir des blessés parmi le personnel ou les patients.",
    "Après un certain temps, vos employés seront fatigués. Pensez à construire une salle de repos où ils pourront se détendre.",
    "Placez suffisamment de radiateurs pour garder vos employés et patients au chaud, ou ils deviendront mécontents. Utilisez la carte de la ville pour localiser les endroits de votre hôpital qui nécessitent plus de chauffage.",
    "Le niveau de compétence d'un docteur influence beaucoup la qualité et la rapidité de ses diagnostiques. Utilisez un médecin expérimenté comme généraliste et vous n'aurez plus besoin d'autant de salles de diagnostiques.",
    "Les internes et les médecins peuvent augmenter leurs compétences auprès d'un consultant dans la salle de formation. Si le consultant a des qualifications particulières (chirurgien, psychiatre ou chercheur), il transférera ses connaissances à ses élèves.",
    "Avez-vous essayé d'entrer le numéro d'urgence Européen (112) dans le fax ? Vérifiez que vous avez du son !",
    "Vous pouvez ajuster certains paramètres tels que la résolution et la langue dans la fenêtre d'options accessible à la fois depuis le menu principal et pendant le jeu.",
    "Vous avez choisi une autre langue que l'anglais, mais il y du texte en anglais partout ? Aidez-nous à traduire les textes manquants dans votre langue !",
    "L'équipe de CorsixTH cherche du renfort ! Vous êtes intéressé à coder, traduire ou faire des graphismes pour CorsixTH ? Contactez-nous sur notre serveur Discord, Sub-Reddit or serveur Matrix. Les liens sont sur notre site internet (CorsixTH.com).",
    "Chaque niveau possède des objectifs qu'il vous faudra remplir pour pouvoir passer au suivant. Vérifiez la fenêtre de statuts pour voir votre progression dans les objectifs du niveau.",
    "Si vous voulez éditer ou détruire une pièce, vous pouvez le faire avec le bouton d'édition situé sur la barre d'outils en bas.",
    "Dans un groupe de patients en attente, vous pouvez rapidement découvrir lesquels attendent une pièce particulière en survolant cette pièce avec votre curseur de souris.",
    "Cliquez sur la porte d'une pièce pour visualiser sa file d'attente. Vous pouvez faire des réglages très utiles ici, comme réorganiser la file d'attente ou envoyer un patient vers une autre pièce.",
    "Le personnel mécontent vous demandera des augmentations de salaires fréquemment. Assurez-vous de leur offrir un environnement de travail confortable pour éviter cela.",
    "Les patients auront soif en attendant dans votre hôpital, encore plus si vous augmentez le chauffage ! Placez des distributeurs automatiques dans les points stratégiques pour un revenu d'appoint.",
    "Vous pouvez interrompre le processus de diagnostic d'un patient et proposer un traitement, si vous avez déjà rencontré la maladie. Notez que cela peut accroître le risque d'erreur de traitement, et provoquer la mort du patient.",
    "Les urgences peuvent être une bonne source de revenus additionnels, à condition que vous ayez les capacités suffisantes pour traiter les patients à temps.",
    "Saviez-vous que vous pouvez affecter des Agents d'entretien à des parcelles spécifiques ? Cliquez simplement sur le texte 'Toutes les parcelles' dans leur profil du personnel pour les parcourir !",
    "Saviez-vous que vous pouvez attribuer des Agents de Maintenance a bouts de terrain spécifiques ? Il suffit de cliquer sur la mention Tous bouts de terrain sur son profil d'employé pour faire le tour!"
  },
  previous = "Astuce précédente",
  next = "Astuce suivante"
}

tooltip.totd_window = {
  previous = "Afficher l'astuce précédente",
  next = "Afficher l'astuce suivante"
}

-- Debug patient window
tooltip.debug_patient_window.item = "Créer un patient de débogage avec %s"
debug_patient_window = {
  caption = "Patient de test"
}

-- Cheats window
cheats_window = {
  caption = "Triches",
  warning = "Attention : vous n'aurez aucun point de bonus à la fin du niveau si vous trichez !",
  cheated = {
    no = "Triches utilisées : non",
    yes = "Triches utilisées : oui"
  },
  cheats = {
    money = "Plus d'argent",
    all_research = "Toutes les recherches",
    emergency = "Créer une situation d'urgence",
    vip = "Créer un VIP",
    earthquake = "Créer un tremblement de terre",
    create_patient = "Créer un patient",
    end_month = "Fin du mois",
    end_year = "Fin de l'année",
    lose_level = "Perdre le niveau",
    win_level = "Gagner le niveau",
    epidemic = "Reproduire des patients contagieux",
    toggle_infected = "Faire apparaître des patients contagieux.",
    increase_prices = "Augmenter les prix",
    decrease_prices = "Diminuer les prix",
    reset_death_count = "Remettre à zéro le nombre de décès",
    toggle_epidemic = "Active la possibilité d'épidémies",
    show_infected = "Montrer les icônes des infectés",
    toggle_earthquake = "Activer les tremblements de terre",
    max_reputation = "Réputation de l'hôpital au maximum"
  },
  close = "Fermer"
}

tooltip.cheats_window = {
  close = "Fermer le dialogue de triches",
  cheats = {
    money = "Ajoute $10.000 à votre solde bancaire.",
    all_research = "Termine toutes les recherches.",
    emergency = "Crée une situation d'urgence.",
    vip = "Crée un VIP.",
    earthquake = "Crée un tremblement de terre.",
    create_patient = "Crée un patient au bord de la carte.",
    end_month = "Va directement à la fin du mois.",
    end_year = "Va directement à la fin de l'année.",
    lose_level = "Vous fait perdre le niveau actuel.",
    win_level = "Vous fait gagner le niveau actuel.",
    epidemic = "Crée un patient contagieux qui peut causer une épidémie.",
    toggle_infected = "Bascule les icônes infectés pour l'épidémie, découverte active.",
    increase_prices = "Augmenter tous les prix de 50% (max. 200%)",
    decrease_prices = "Diminuer tous les prix de 50% (min. 50%)",
    reset_death_count = "Remettre à zéro le nombre de décès à l'hôpital",
    toggle_epidemic = "Active la possibilité d'épidémies",
    show_infected = "Montrer/cacher les icônes des infectés pour les épidémies découvertes et actives",
    toggle_earthquake = "Activer les tremblements de terre",
    max_reputation = "Mettre la réputation de l'hôpital au maximum"
  }
}

tooltip.hotkey_window = {
  button_accept = "Accepter et enregistrer les assignations des touches de raccourci",
  button_recallPosKeys = "Ouvrir la fenêtre pour définir les touches pour stocker et rappeler les positions de la caméra",
  button_defaults = "Réinitialiser toutes les touches de raccourci aux valeurs par défaut du programme",
  button_cancel = "Annuler l'assignation et revenir au menu des options",
  button_back_02 = "Retourner à la fenêtre principale des touches de raccourci. Les touches de raccourci modifiées dans cette fenêtre ,peuvent y être acceptées",
  caption_panels = "Ouvrir la fenêtre pour attribuer les touches des panneaux",
  button_gameSpeedKeys = "Ouvrir la fenêtre pour définir les touches pour contrôler la vitesse du jeu"
}

-- Introduction Texts
introduction_texts = {
  demo = "Bienvenue dans l'hôpital de démonstration !// " .. "Malheureusement, la version démo ne contient que ce niveau. Malgré tout, il y a assez à faire ici pour vous occuper un moment !" .. "Vous allez rencontrer différentes maladies qui nécessitent des salles pour les soigner. De temps en temps, des urgences peuvent se produire. Et vous aurez besoin d'une salle de recherche pour trouver des nouvelles salles. " ..
      "Votre but est de gagner 100,000$, de faire monter la valeur de votre hôpital à 70,000$ et d'obtenir une réputation de 700, tout en ayant soigné au moins 75% de vos patients. " .. "Veillez à ce que votre réputation ne tombe pas en dessous de 300 et de ne pas tuer plus de 40% de vos patients, ou vous perdrez.//" .. "Bonne chance !",
  level1 = "Bienvenue dans votre premier hôpital !//Démarrez l'activité en installant un bureau de réception et " .. "en construisant un cabinet de médecine générale. Embauchez une réceptionniste et un médecin. Il vous " .. "suffit d'attendre des admissions. Il serait bon de construire un cabinet de psychiatrie et d'embaucher " .. "un médecin formé dans ce domaine. Une pharmacie et une infirmière sont également indispensables pour soigner " ..
      "les patients. Attention aux cas d'encéphalantiasis : une salle de gonflage suffit pour traiter cette maladie. " .. "Il vous faut soigner 10 personnes et vous assurer que votre réputation ne tombe pas en-dessous de 200",
  level8 = "A vous de gérer l'hôpital le plus efficace et le plus rentable possible.//Les gens du coin sont bien nantis alors " .. "pompez-leur tout le fric que vous pourrez. Soigner les gens c'est bien joli mais vous avez BESOIN de l'argent que ça " .. "rapporte. Ratissez tous ces malades ! Amassez un joli paquet de $300.000 pour terminer ce niveau.",
  level12 = "Côté défi, vous allez être servi ! Impressionné par votre succès, le Ministère veut vous assigner une mission de confiance. " .. "Vous devrez construire un autre hôpital de pointe, gagner des sommes scandaleuses et vous faire une réputation fabuleuse. " .. "Vous devrez également acheter tout le terrain possible, soigner toutes les maladies (nous avons bien dit TOUTES) et remporter " ..
      "toutes les récompenses. Alors, heureux ? Gagnez $650.000, soignez 750 personnes et affichez une réputation de 800 pour gagner ce niveau.",
  level13 = "Votre incroyable talent en tant que directeur d'hôpital a attiré l'attention de la Division Spéciale Secrète des " .. "Services Spéciaux Secrets. On vous propose un bonus : il y a un hôpital infesté de rats qui réclame un Nettoyeur efficace. " .. "Vous devez descendre le plus de rats possible avant que les agents de maintenance fassent leur boulot. Vous pensez y arriver ?",
  level14 = "Et encore un défi ! Eh oui, voici l'hôpital-surprise ! Si vous réussissez cette épreuve, vous serez le gagnant des gagnants. " .. "Mais ça ne sera pas du gâteau car vous n'aviez encore rien vu de pareil... Bonne chance !",
  level17 = "Un bon conseil : veillez à votre réputation car c'est elle qui vous garantira une clientèle. Si vous ne tuez pas trop de " .. "gens et les gardez raisonnablement satisfaits, vous n'aurez pas trop de difficultés à ce niveau. //A vous de jouer, maintenant. " .. "Bonne chance et tout ça, quoi !"
}

-- Calls Dispatcher Dialog
calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d appels; %d assignés",
  staff = "%s - %s",
  watering = "Arrose @ %d,%d",
  repair = "Répare %s",
  close = "Fermer"
}

tooltip.calls_dispatcher = {
  task = "Liste des tâches - cliquez sur une tâche pour ouvrir la fenêtre du membre du personnel à qui elle est assignée et aller jusqu'à l'endroit où a lieu la tâche.",
  assigned = "Cette case est cochée si la tâche est assignée à quelqu'un.",
  close = "Ferme la boîte de dialogue de répartitions des tâches"
}

-- Updates
update_window = {
  caption = "Une mise à jour est disponible !",
  new_version = "Nouvelle version :",
  current_version = "Version actuelle :",
  download = "Aller à la page de téléchargement",
  ignore = "Sauter et aller au menu principal"
}

tooltip.update_window = {
  download = "Accédez à la page de téléchargement pour la toute dernière version de CorsixTH",
  ignore = "Ignorer cette mise à jour pour l'instant. Vous serez averti à nouveau lorsque vous ouvrez CorsixTH de nouveau"
}

tooltip.machine_window = {
  toggle_machine_menu = "Cliquez pour afficher le menu des machines",
}

map_editor_window = {
  pages = {
    inside = "À l'intérieur",
    outside = "À l'extérieur",
    foliage = "Feuillage",
    hedgerow = "Haie",
    pond = "Étang",
    road = "Route",
    north_wall = "Mur nord",
    west_wall = "Mur ouest",
    helipad = "Héliport",
    delete_wall = "Supprimer des murs",
    parcel = "Parcelle %d",
    parcel_0 = "Parcelle 0",
    parcel_1 = "Parcelle 1",
    parcel_2 = "Parcelle 2",
    parcel_3 = "Parcelle 3",
    parcel_4 = "Parcelle 4",
    parcel_5 = "Parcelle 5",
    parcel_6 = "Parcelle 6",
    parcel_7 = "Parcelle 7",
    parcel_8 = "Parcelle 8",
    parcel_9 = "Parcelle 9",
    camera_1 = "Caméra 1",
    camera_2 = "Caméra 2",
    camera_3 = "Caméra 3",
    camera_4 = "Caméra 4",
    heliport_1 = "Héliport 1",
    heliport_2 = "Héliport 2",
    heliport_3 = "Héliport 3",
    heliport_4 = "Héliport 4",
    paste = "Coller la zone",
    set_parcel_tooltip = "Choissisez un chiffre et appuyez sur Entrée.",
    set_parcel = "Choisir le chiffre de la parcelle",
  },
  checks = {
    spawn_points_and_path = "Attention: les patients ne peuvent pas arriver à l'hôpital. Ils ont besoin de carreaux 'route' ou carreaux gris 'dehors' au bord de la carte et un chemin avec ces carreaux jusqu'à l'entrée de l'hôpital."
  }
}

menu.player_count = "COMPTE DE JOUEURS"
warnings.levelfile_variable_is_deprecated = "Remarque: Le niveau '%s' contient une définition de variable obsolète dans le fichier de niveau. '%LevelFile' a été renommé '%MapFile'. Veuillez aviser le créateur de la carte pour mettre à jour le niveau."
warnings.newersave = "Avertissement, vous avez chargé une sauvegarde d'une version plus récente de CorsixTH. Il n'est pas recommandé de continuer car des plantages peuvent survenir. Jouez à vos propres risques."

hotkeys_file_err = {
  file_err_02 = ", ou utilisez l'option de ligne de commande --hotkeys-file=nomdufichier pour spécifier un fichier inscriptible. Pour référence, l'erreur lors du chargement du fichier de raccourcis était : ",
  file_err_01 = "Impossible de charger le fichier hotkeys.txt. Assurez-vous que CorsixTH a l'autorisation de lecture/écriture "
}

hotkey_window = {
  button_accept = "Accepter",
  button_back = "Retour",
  button_cancel = "Annuler",
  button_defaults = "Réinitialiser aux valeurs par défaut",
  button_gameSpeedKeys = "Touches de vitesse du jeu",
  button_recallPosKeys = "Touches de rappel de position",
  button_toggleKeys = "Activer/désactiver les touches",
  caption_main = "Assignation des touches de raccourci",
  caption_panels = "Touches des panneaux",
  global_cancel = "Annuler",
  global_cancel_alt = "Annuler Alt",
  global_confirm = "Confirmer",
  global_confirm_alt = "Confirmer Alt",
  global_connectDebugger = "Débogueur",
  global_exitApp = "Quitter l'application",
  global_fullscreen_toggle = "Plein écran",
  global_releaseMouse = "Relâcher la souris",
  global_resetApp = "Réinitialiser l'application",
  global_runDebugScript = "Script de débogage",
  global_screenshot = "Capture d'écran",
  global_showLuaConsole = "Console Lua",
  global_stop_movie_alt = "Arrêter le film",
  global_window_close_alt = "Fermer la fenêtre",
  ingame_gamespeed_max = "Max",
  ingame_gamespeed_normal = "Normal",
  ingame_gamespeed_slower = "Plus lent",
  ingame_gamespeed_slowest = "Le plus lent",
  ingame_gamespeed_speedup = "Accélérer",
  ingame_gamespeed_thensome = "Ensuite plus encore",
  ingame_jukebox = "Jukebox",
  ingame_loadMenu = "Charger le jeu",
  ingame_openFirstMessage = "Message du niveau",
  ingame_panel_bankManager = "Gestionnaire de la banque",
  ingame_panel_bankStats = "Statistiques de la banque",
  ingame_panel_buildRoom = "Construire une salle",
  ingame_panel_casebook = "Dossier médical",
  ingame_panel_casebook_alt = "Casebook 2",
  ingame_panel_casebook_alt02 = "Casebook 3",
  ingame_panel_charts = "Graphiques",
  ingame_panel_editRoom = "Éditer la salle",
  ingame_panel_furnishCorridor = "Meubler le couloir",
  ingame_panel_hireStaff = "Embaucher du personnel",
  ingame_panel_map_alt = "Carte de la ville 2",
  ingame_panel_policy = "Politique",
  ingame_panel_research = "Recherche",
  ingame_panel_research_alt = "Recherche 2",
  ingame_panel_staffManage = "Gérer le personnel",
  ingame_panel_status = "Statut",
  ingame_panel_townMap = "Carte de la ville",
  ingame_patient_gohome = "Renvoyer chez lui",
  ingame_pause = "Pause",
  ingame_poopLog = "Journal des incidents",
  ingame_poopStrings = "Vider les chaînes",
  ingame_quickLoad = "Chargement rapide",
  ingame_quickSave = "Sauvegarde rapide",
  ingame_quitLevel = "Quitter le niveau",
  ingame_recallPosition_0 = "10",
  ingame_recallPosition_1 = "1",
  ingame_recallPosition_2 = "2",
  ingame_recallPosition_3 = "3",
  ingame_recallPosition_4 = "4",
  ingame_recallPosition_5 = "5",
  ingame_recallPosition_6 = "6",
  ingame_recallPosition_7 = "7",
  ingame_recallPosition_8 = "8",
  ingame_recallPosition_9 = "9",
  ingame_reset_zoom = "Réinitialiser le zoom",
  ingame_restartLevel = "Redémarrer le niveau",
  ingame_rotateobject = "Faire pivoter l'objet",
  ingame_saveMenu = "Sauvegarder le jeu",
  ingame_scroll_down = "Défiler vers le bas",
  ingame_scroll_left = "Défilement gauche",
  ingame_scroll_right = "Défilement droite",
  ingame_scroll_shift = "Défilement rapide",
  ingame_scroll_up = "Défiler vers le haut",
  ingame_setTransparent = "Transparent",
  ingame_showCheatWindow = "Menu de triche",
  ingame_showmenubar = "Afficher la barre de menu",
  ingame_storePosition_0 = "10",
  ingame_storePosition_1 = "1",
  ingame_storePosition_2 = "2",
  ingame_storePosition_3 = "3",
  ingame_storePosition_4 = "4",
  ingame_storePosition_5 = "5",
  ingame_storePosition_6 = "6",
  ingame_storePosition_7 = "7",
  ingame_storePosition_8 = "8",
  ingame_storePosition_9 = "9",
  ingame_toggleAdvisor = "Conseiller",
  ingame_toggleAnnouncements = "Annonces",
  ingame_toggleInfo = "Info",
  ingame_toggleMusic = "Musique",
  ingame_toggleSounds = "Sons",
  ingame_zoom_in = "Zoom avant",
  ingame_zoom_in_more = "Zoom avant plus",
  ingame_zoom_out = "Zoom arrière",
  ingame_zoom_out_more = "Zoom arrière plus",
  panel_altPanelKeys = "Touches de panneaux alternatifs",
  panel_debugKeys = "Touches de débogage",
  panel_gameSpeedKeys = "Touches de vitesse du jeu",
  panel_generalInGameKeys = "Touches générales en jeu",
  panel_globalKeys = "Touches globales",
  panel_recallPosKeys = "Touches de rappel de position",
  panel_scrollKeys = "Touches de défilement",
  panel_storePosKeys = "Touches de stockage de position",
  panel_toggleKeys = "Touches d'activation/désactivation",
  panel_zoomKeys = "Touches de zoom"
}

level_progress.hospital_value_enough = "Maintenez la valeur de votre hôpital au-dessus de %d et gérez vos autres problèmes pour remporter le niveau."
level_progress.cured_enough_patients = "Vous avez guéri suffisamment de patients, mais vous devez améliorer votre hôpital pour remporter le niveau."

-- Off you go, warnings

-- Looking at the code it's doesn't seem to be needed, but it's shown as missing by the extract string process
disease_discovered_patient_choice.need_to_employ = "Employez un(e) %s pour pouvoir gérer cette situation."
multiplayer.everyone_failed = "Tout le monde a échoué à satisfaire le dernier objectif. Donc, tout le monde peut continuer à jouer !"
multiplayer.players_failed = "Le(s) joueur(s) suivant(s) n'ont pas réussi à atteindre le dernier objectif :"
original_credits[299] = " "
original_credits[300] = " "
original_credits[301] = ":Opérations"
original_credits[302] = ","
original_credits[303] = "Steve Fitton"
original_credits[304] = " "
original_credits[305] = " "
original_credits[306] = " "
original_credits[307] = ":Administration de la société"
original_credits[308] = ","
original_credits[309] = "Audrey Adams"
original_credits[310] = "Annette Dabb"
original_credits[311] = "Emma Gibbs"
original_credits[312] = "Lucia Gobbo"
original_credits[313] = "Jo Goodwin"
original_credits[314] = "Sian Jones"
original_credits[315] = "Kathy McEntee"
original_credits[316] = "Louise Ratcliffe"
original_credits[317] = " "
original_credits[318] = " "
original_credits[319] = " "
original_credits[320] = ":Gestion de la société"
original_credits[321] = ","
original_credits[322] = "Les Edgar"
original_credits[323] = "Peter Molyneux"
original_credits[324] = "David Byrne"
original_credits[325] = " "
original_credits[326] = " "
original_credits[327] = ":Toute l'équipe de Bullfrog Productions"
original_credits[328] = " "
original_credits[329] = " "
original_credits[330] = " "
original_credits[331] = ":Remerciements spéciaux à"
original_credits[332] = ","
original_credits[333] = "Tous ceux de l'hôpital de Frimley Park"
original_credits[334] = " "
original_credits[335] = ":Particulièrement"
original_credits[336] = ","
original_credits[337] = "Beverley Cannell"
original_credits[338] = "Doug Carlisle"
original_credits[339] = " "
original_credits[340] = " "
original_credits[341] = " "
original_credits[342] = ":Continuez à réfléchir"
original_credits[343] = " "
original_credits[344] = " "
original_credits[345] = " "
original_credits[346] = " "
original_credits[347] = " "
original_credits[348] = " "
original_credits[349] = " "
original_credits[350] = " "
original_credits[351] = " "
original_credits[352] = " "
original_credits[353] = " "
original_credits[354] = " "
original_credits[355] = " "
original_credits[356] = " "
original_credits[357] = " "
original_credits[358] = " "
original_credits[359] = " "
original_credits[360] = " "
original_credits[361] = "."
