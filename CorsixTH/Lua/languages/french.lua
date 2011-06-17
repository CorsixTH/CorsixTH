--[[ Copyright (c) 2010-2011 Nicolas "MeV" Elie

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

----------------------------------------------------------- Override -----------------------------------------------------------
adviser.information.promotion_to_specialist = "L'un de vos INTERNES est devenu MEDECIN." -- Fix the famous "Level 5 bug"
misc.save_failed = "ERREUR : Partie non sauvegardée" -- Much more french
tooltip.policy.diag_termination = "L'auscultation d'un patient continuera jusqu'à ce que les médecins soient sûrs à hauteur du pourcentage FIN PROCEDURE ou jusqu'à ce que toutes les machines de diagnostic aient été essayées. " -- Remove a superfluous word
room_descriptions.gp[2] = "C'est une salle de diagnostic fondamentale pour votre hôpital. Elle accueille les nouveaux patients pour les ausculter. Ils sont ensuite orientés vers une autre salle soit pour un autre diagnostic soit pour Etre soignés. Vous devriez construire un autre cabinet de médecine générale au cas où celui-ci serait débordé. Plus l'endroit est grand et plus vous pouvez y placer des équipements, sans compter que c'est bon pour le prestige du médecin. C'est valable pour toutes les salles, en fait."
room_descriptions.staff_room[2] = "Votre équipe finit par se fatiguer et a besoin de cette salle pour se remettre. Une équipe fatiguée est lente, revendicatrice et peut même envisager de démissionner. De plus, elle risque de commettre des erreurs. Il est avisé de construire une salle de repos bien aménagée et de prévoir assez de place pour plusieurs membres à la fois."
adviser.goals.win = { -- Why are this strings upcase?
  reputation = "Portez votre réputation à %d pour pouvoir gagner",
  value = "Portez la valeur de votre hôpital à %d",
}
adviser.warnings.handymen_tired = "Les agents de maintenance sont très fatigués. Laissez-les se reposer." -- Add a missing letter

-- tooltip.staff_list.next_person, prev_person is rather next/prev page (also in german, maybe more languages?)
tooltip.staff_list.next_person = "Voir la page suivante"
tooltip.staff_list.prev_person = "Voir la page précédente"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "Visage - cliquez pour ouvrir la fenêtre de gestion"
tooltip.staff_window.center_view = "Clic gauche pour focaliser sur la personne, pour faire défiler les membres du personnel"

-- Fix Winning texts
letter = {
  [1] = { -- Level one: Fix issue 329
    [1] = "Estimable %s",
    [2] = "Splendide ! Vous avez admirablement géré cet hôpital. Nous, pontes du Ministère de la Santé, souhaitons savoir si vous aimeriez prendre en charge un plus grand projet. Nous comptons sur vous. Le salaire serait de %d$ et ça vaut la peine d'y réfléchir.",
    [3] = "Que diriez-vous de travailler à l'hôpital de %s ?",
  },
  [2] = { -- Level two: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Formidable ! Vous avez fait de grands progrès dans votre hôpital. Nous vous avons trouvé un autre établissement pour exercer vos talents et relever des défis. Vous pouvez refuser mais ce serait dommage. Le salaire est de %d$.",
    [3] = "Acceptez-vous le poste à l'hôpital de %s ?",
  },
  [3] = { -- Level three: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Vous avez parfaitement réussi dans cet hôpital. C'est la raison pour laquelle nous vous proposons une nouvelle situation. Le salaire serait de %d$ et nous pensons que vous adorerez relever ce nouveau défi.",
    [3] = "Acceptez-vous de gérer l'hôpital de %s ?",
  },
  [4] = { -- Level four: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Félicitations ! Le Ministère de la Santé est très impressionné par vos capacités à gérer cet hôpital. Vous Etes un exemple de réussite dans ce domaine. Vous voudrez peut-être une situation plus élevée, toutefois. Vous seriez payé %d$, et la décision vous revient.",
    [3] = "Etes-vous prêt à accepter un poste à l'hôpital de %s ?",
  },
  [5] = { -- Level five: Add missing spaces before punctuation marks and between words
    [1] = "Estimable %s",
    [2] = "Nouvelles salutations. Nous respectons votre souhait de ne pas quitter ce charmant hôpital, mais nous vous supplions d'y réfléchir. Nous vous proposons la coquette somme de %d$ pour accepter de diriger un autre hôpital avec autant de succès.",
    [3] = "Aimeriez-vous prendre la tête de l'hôpital de %s ?",
  },
  [6] = { -- Level six: Add missing spaces before punctuation marks, fix last string which contained an anglicism
    [1] = "Estimable %s",
    [2] = "Nous savons que vous Etes heureux de vous occuper de cette délicieuse institution mais nous pensons que vous devez penser à l'avenir. Vous pourriez prétendre au salaire de %d$ si vous acceptez de changer de situation. Pensez-y.",
    [3] = "Voulez-vous un poste à l'hôpital de %s ?",
  },
  [7] = { -- Level seven: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Le Ministère de la Santé souhaite que vous reconsidériez votre décision de rester dans cet hôpital. Nous savons que vous avez un charmant établissement mais il est temps de relever un nouveau défi, avec un salaire attrayant de %d$.",
    [3] = "Etes-vous prêt à travailler à l'hôpital de %s ?",
  },
  [8] = { -- Level height: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Vous aviez donné une réponse négative à notre dernière lettre vous proposant un grand poste dans un nouvel hôpital, avec un coquet salaire de %d$. Nous pensons que vous devez revoir votre décision car nous avons pour vous un poste idéal.",
    [3] = "Voulez-vous bien accepter un poste à l'hôpital de %s ? S'il vous plaît !",
  },
  [9] = { -- Level nine: Add missing spaces before punctuation marks, fix some sentences, add missing diacritics
    [1] = "Estimable %s",
    [2] = "Vous vous êtes montré le meilleur directeur d'hôpital jamais connu dans la longue et mouvementée histoire de la médecine. Nous sommes fiers de vous offrir le poste de Chef Suprême des Hôpitaux. Ce titre honorifique vous garantit un salaire de %d$. On fera pour vous une parade pleine de serpentins et les gens vous baiseront les pieds.",
    [3] = "Merci pour tout ce que vous avez fait. Vous avez mérité cette semi-retraite.",
  },
  [10] = { -- Level ten: Fix some sentences
    [1] = "Estimable %s",
    [2] = "Félicitations pour avoir réussi dans tous les hôpitaux que vous avez dirigé. Une telle performance fait de vous un héros. Vous recevrez une pension de %d$ plus une limousine. Tout ce que nous vous demandons, c'est d'aller de ville en ville rencontrer votre public en adoration et défendre le renom des hôpitaux.",
    [3] = "Nous sommes tous fiers de vous et notre coeur déborde de gratitude pour votre dévouement à sauver des vies.",
  },
  [11] = { -- Level eleven: No change
    [1] = "Estimable %s",
    [2] = "Votre carrière est exemplaire et vous êtes une inspiration pour nous tous. Merci d'avoir géré tous ces hôpitaux avec autant de talent. Nous souhaitons vous offrir une rente à vie de %d$ pour simplement aller de ville en ville à bord d'une voiture de prestige pour saluer la foule et donner des conférences sur votre incroyable réussite.",
    [3] = "Vous êtes un exemple pour toute personne sensée et tout le monde, sans exception, vous considère comme un modèle absolu.",
  },
  [12] = { -- Level twelve: Add missing spaces before punctuation marks
    [1] = "Estimable %s",
    [2] = "Votre carrière réussie en tant que meilleur directeur d'hôpital depuis la nuit des temps arrive à sa fin. Toutefois, vous avez eu sur le monde tranquille de la médecine une telle influence que le Ministre vous offre un salaire de %d$ uniquement pour paraître en public, faire des inaugurations, baptiser des navires et participer à des débats. Le monde entier vous acclame et c'est la meilleure des publicités pour le Ministère de la Santé !",
    [3] = "Veuillez accepter cette situation : ce n'est pas trop difficile et vous aurez, en plus, une escorte de police partout où vous irez.",
  },
}

-- The originals of these string lacks space before punctuation marks and or between words
misc.balance = "Ajustage :"
tooltip.pay_rise_window.decline = "Ne payez pas, licenciez !"
tooltip.watch = {
  emergency = "Urgence : temps qui reste pour soigner les patients entrés en urgence.",
  hospital_opening = "Délai : ceci est le temps qui reste avant que votre hôpital soit ouvert. Cliquez sur GO pour l'ouvrir tout de suite.",
  epidemic = "Epidémie : temps qui reste pour arrêter l'épidémie. Si ce délai expire OU si un malade contagieux quitte l'hôpital, un inspecteur sanitaire viendra... Le bouton active ou désactive la vaccination. Cliquez sur un patient pour lancer la vaccination par une infermière.",
}
tooltip.objects = {
  chair = "Chaise : le patient s'y assied pour parler de ses symptômes.",
  sofa = "Sofa : c'est ce qui permet aux employés de se relaxer... sauf s'ils trouvent mieux...",
  bench = "Banc : pour que les patients puissent attendre confortablement.",
  video_game = "Jeu vidéo : l'équipe se relaxe en jouant à Hi-Octane.",
  lamp = "Lampe : vous avez déjà essayé de travailler dans le noir ?",
  door = "Porte : les gens aiment les ouvrir et les fermer.",
  auto_autopsy = "Autopsie : très utile pour la recherche",
  tv = "TV : votre équipe ne doit pas manquer ses programmes favoris.",
  litter_bomb = "Bombe à détritus: pour saboter les hôpitaux concurrents",
  inflator = "Gonfleur : pour soigner l'encéphalantiasis.",
  desk = "Bureau : essentiel pour poser un ordinateur.",
  pool_table = "Billard : pour la relaxation du personnel.",
  bed = "Lit : les cas graves ont besoin de rester couchés.",
  bookcase = "Etagère : pour les ouvrages de référence.",
  drinks_machine = "Distributeurs : contre la soif et pour ramasser des gros sous.",
  skeleton = "Squelette : utile pour l'enseignement et pour Halloween.",
  computer = "Ordinateur : une composante essentielle de la recherche",
  bin = "Poubelle : les patients y jettent leurs détritus.",
  pharmacy_cabinet = "Pharmacie: c'est là qu'on dispense les médicaments",
  radiator = "Radiateur : permet de garder l'hôpital au chaud.",
  atom_analyser = "Mélangeur : installé au Département Recherche, cette machine accélère tout le processus d'étude.",
  plant = "Plante : plaît aux patients et purifie l'air.",
  toilet = "Toilettes : les patients en ont, euh, besoin.",
  fire_extinguisher = "Extincteur : pour minimiser les dangers causés par des machines défectueuses.",
  lecture_chair = "Chaise : les médecins en formation s'asseyent là pour prendre des notes et s'ennuyer. Plus vous mettrez des chaises, plus vous pourrez former de médecins.",
  toilet_sink = "Lavabo : s'il n'y en a pas assez, les patients qui apprécient l'hygiène seront mécontents.",
  cabinet = "Placard : dossiers des patients, notes de recherche.",
}
room_descriptions.fracture_clinic[2] = "Les patients dont les os étaient en morceaux se rendront dans cette salle. Le déplâtreur dégagera les membres en ne causant qu'une faible douleur."
room_descriptions.inflation[2] = "Les patients souffrant de l'affreuse-mais-si-drôle encéphalantiasis sont soignés à la salle de gonflage, où leur tête démesurée sera dégonflée puis regonflée à la bonne taille."
room_descriptions.hair_restoration[2] = "Les patients souffrant de sévère calvitie se rendront dans cette salle équipée d'un moumouteur. Un médecin utilisera la machine pour donner aux patients une nouvelle chevelure."
room_descriptions.electrolysis[2] = "Les patients souffrant de pilose viennent dans cette salle où une machine arrache les poils et scelle les pores selon un procédé qui n'est pas sans rappeler la cimentation."
progress_report.too_hot = "Réglez le chauffage : on étouffe."
adviser.tutorial.build_pharmacy = "Félicitations ! Construisez maintenant une pharmacie et embauchez une infermière."
adviser.epidemic.serious_warning = "Cette maladie contagieuse est dangereuse. Vous devez prendre des mesures d'urgence !"
adviser.staff_advice.too_many_doctors = "Il y a trop de médecins. Certains n'ont rien à faire !."
adviser.earthquake.ended = "Ouh là ! J'ai cru que c'était la fin! C'était du %d sur l'échelle de Richter."
adviser.multiplayer.poaching = {
  not_interested = "Ha ! Ils ne veulent pas travailler pour vous, ils sont satisfaits comme ça.",
  already_poached_by_someone = "Eh non ! Quelqu'un s'intéresse déjà à cette personne.",
}
adviser.vomit_wave.ended = "Ouf ! On dirait que le virus qui provoquait des nausées est enfin enrayé. Gardez l'hôpital propre, à l'avenir."
adviser.research.new_available = "Nouveau : un(e) %s est disponible."
adviser.goals.lose.kill = "Tuez encore %d patients pour perdre !"
adviser.warnings = {
  money_low = "Les fonds sont en baisse !",
  no_patients_last_month = "Pas de nouveaux patients le mois dernier. Honteux !",
  machines_falling_apart = "Les machines tombent en panne. Faites-les réparer !",
  bankruptcy_imminent = "Hé ! Vous courez à la faillite. Attention !",
  too_many_plants = "Il y a bien trop de plantes. C'est la jungle, ici !",
  many_killed = "Vous avez laissé mourir %d personnes. Idiot ! Vous êtes censé les soigner.",
}
adviser.placement_info.object_cannot_place = "Hé ! Vous ne pouvez pas mettre cet objet ici."
adviser.information = {
  epidemic = "Une maladie contagieuse sévit dans votre hôpital. Vous devez l'enrayer immédiatement !",
  emergency = "C'est une urgence ! Vite ! Vite ! VITE !",
  initial_general_advice = {
    first_epidemic = "Il y a une épidémie dans votre hôpital ! A vous de voir si vous étouffez l'affaire ou si vous en parlez.",
  },
  patient_leaving_too_expensive = "Un patient part sans payer la facture pour %s. Sacrée perte !",
  vip_arrived = "Attention ! %s arrive pour visiter votre hôpital ! Faites en sorte de lui faire bonne impression.",
  first_death = "Vous venez de tuer votre premier patient. Alors, heureux ?",
}
buy_objects_window = {
  price = "Prix : ",
  total = "Total : ",
}
fax = {
  epidemic_result = {
    close_text = "Hourrah !",
    rep_loss_fine_amount = "Les journaux vont s'en donner à coeur joie avec cette affaire. Votre réputation va en prendre un coup ! Sans oublier l'amende de %d.",
    },
  vip_visit_result = {
    telegram = "Télégramme !",
    vip_remarked_name = "Après avoir visité votre hôpital, %s a dit :",
    remarks = {
      very_bad = {
        [1] = "Quelle déception ! On devrait fermer cet endroit.",
        [2] = "Je n'ai jamais vu ça. Quelle honte !",
        [3] = "Je suis sous le choc. Et on appelle ça un hôpital ! Il me faut un verre pour m'en remettre.",
      },
      bad = {
        [2] = "Ce que j'ai vu est révoltant. Ce n'est pas un hôpital, c'est une porcherie !",
        [3] = "J'en ai assez de devoir faire des visites officielles dans des trous puants comme celui-ci. Je démissionne !",
      },
    },
  },
  disease_discovered_patient_choice = {
    what_to_do_question = "Que voulez-vous faire du patient ?",
  },
  debug_fax = {
    close_text = "Ouais, ouais, ouais !",
  },
  diagnosis_failed = {
    what_to_do_question = "Que faire du patient ?",
  },
}
dynamic_info = {
  patient = {
    actions = {
      prices_too_high = "C'est trop cher : je rentre chez moi",
      no_diagnoses_available = "Plus de diagnostic : je rentre chez moi",
      cured = "Guéri !",
      no_treatment_available = "Pas de traitement : je rentre chez moi",
    },
    diagnosed = "Ausculté : %s",
  } 
}
introduction_texts = {
  level1 = {
    [1] = "Bienvenue dans votre premier hôpital !",
  },
  level8 = {
    [4] = "Ratissez tous ces malades !",
  },
  level12 = {
    [1] = "Côté défi, vous allez être servi !",
    [4] = "Alors, heureux ?",
  },
  level13 = {
    [4] = "Vous pensez y arriver ?",
  },
  level14 = {
    [1] = "Et encore un défi ! Eh oui, voici l'hôpital-surprise !",
    [4] = "Bonne chance !",
  },
  level17 = {
    [3] = "A vous de jouer, maintenant. Bonne chance et tout ça, quoi !",
  }
}
transactions = {
  cure_colon = "Guérison :",
  final_treat_colon = "Trait final :",
  treat_colon = "Trait :",
  advance_colon = "Avance :",
  insurance_colon = "Assurance :",
}
diseases = {
  third_degree_sideburns = {
    cause = "Cause : regret pathologique des années 70.",
    cure = "Traitement : un psychiatre doit faire comprendre au patient qu'il faut changer d'époque comme de chemise.",
    name = "Rétrostalgie",
    symptoms = "Symptômes : passion immodérée des pantalons à pattes d'éléphant et des paillettes.",
  },
  discrete_itching = {
    cause = "Cause : petits bestioles à dents aiguës.",
    cure = "Traitement : un sirop gluant est administré pour empêcher les démangeaisons.",
    name = "Morpionnite",
    symptoms = "Symptômes: le patient se gratte jusqu'au sang.",
  },
  the_squits = {
    cause = "Cause: avoir mangé de la pizza ramassée derrière la cuisinière.",
    cure = "Traitement: un mélange gluant de diverses substances synthétiques est administré au patient pour solidifier son, euh, contenu.",
    name = "Courante",
    symptoms = "Symptômes: Hum. Vous voyez le genre.",
  },
  spare_ribs = {
    cause = "Cause: trop de temps passé sur un sol froid.",
    cure = "Traitement: deux chirurgiens retirent les côtes flottantes et les donnent au patient dans un sac à emporter.",
    name = "Excès costal",
    symptoms = "Symptômes: déplaisante sensation de flottement.",
  },
  diag_blood_machine = {
    name = "Diag Sanguimachine",
  },
  king_complex = {
    cause = "Cause: l'esprit du King s'est emparé de celui du patient et l'a envahi.",
    cure = "Traitement: un psychiatre explique au patient à quel point tout ceci est ridicule.",
    name = "Syndrome du King",
    symptoms = "Symptômes: passion pour les chaussures en daim bleu et pour les cheeseburgers.",
  },
  diag_x_ray = {
    name = "Diag Rayons X",
  },
  pregnancy = {
    cause = "Cause: pannes de courant en zones urbaines.",
    cure = "Traitement: le bébé est prélevé en salle d'opération puis soigneusement nettoyé pour faire son entrée dans le monde.",
    name = "Grossesse",
    symptoms = "Symptômes: gloutonnerie avec hypertrophie du ventre.",
  },
  fake_blood = {
    cause = "Cause: avoir été victime d'une très mauvaise plaisanterie.",
    cure = "Traitement: seule une cure psychiatrique peut calmer le patient.",
    name = "Sang factice",
    symptoms = "Symptômes: le patient voit son sang s'évaporer.",
  },
  diag_psych = {
    name = "Diag Psychiatre",
  },
  invisibility = {
    cause = "Cause: morsure par une fourmi radioactive (et invisible).",
    cure = "Traitement: il suffit de faire boire au patient un liquide coloré dispensé à la pharmacie pour le rendre pleinement observable.",
    name = "Invisibilité",
    symptoms = "Symptômes: le patient ne souffre pas mais a une forte propension à utiliser son état pour faire des farces à son entourage.",
  },
  golf_stones = {
    cause = "Cause: exposition au gaz empoisonné contenu dans les balles de golf.",
    cure = "Traitement: résection des surplus par une équipe de deux chirurgiens.",
    name = "Pierres de golf",
    symptoms = "Symptômes: formation nodules excédentaires.",
  },
  diag_general_diag = {
    name = "Diag Généraliste",
  },
  infectious_laughter = {
    cause = "Cause: exposition à un comique de situation.",
    cure = "Traitement: un psychiatre doit faire comprendre au patient à quel point son état est sérieux.",
    name = "Fou rire",
    symptoms = "Symptômes: gloussement irrépressible et répétition compulsive d'accroches même pas drôles.",
  },
  general_practice = {
    name = "Généraliste",
  },
  baldness = {
    cause = "Cause: avoir raconté trop de mensonges pour se rendre intéressant.",
    cure = "Traitement: pose très douloureuse de cheveux à l'aide d'un moumouteur.",
    name = "Calvitie",
    symptoms = "Symptômes: tête en boule de billard et gros complexe.",
  },
  heaped_piles = {
    cause = "Cause: s'être assis sur un jet de jacuzzi.",
    cure = "Traitement: un potion agréable bien que puissamment acide dissout les rectoïdes de l'intérieur.",
    name = "Rectoïdes",
    symptoms = "Symptômes: le patient a l'impression de s'asseoir sur un sac de billes.",
  },
  unexpected_swelling = {
    cause = "Cause: n'importe quoi d'inattendu.",
    cure = "Traitement: le dégonflement est obtenu par une délicate opération pratiquée par deux chirurgiens.",
    name = "Bouffissure",
    symptoms = "Symptômes: bouffissure généralisée.",
  },
  jellyitis = {
    cause = "Cause: abus de produits riches en gélifiant et trop d'exercice.",
    cure = "Traitement: le patient est immergé dans un dégélifiant.",
    name = "Gélatine",
    symptoms = "Symptômes: grande mollesse et tendance à l'écroulement.",
  },
  hairyitis = {
    cause = "Cause: exposition prolongée au clair de lune.",
    cure = "Traitement: on fait disparaître les poils avec un électrolyseur et les pores sont scellés.",
    name = "Pilose",
    symptoms = "Symptômes: le patient développe un odorat accru.",
  },
  alien_dna = {
    cause = "Cause: agrippeurs faciaux munis de sang extraterrestre intelligent.",
    cure = "Traitement: l'ADN est retiré par un correcteur pour être nettoyé puis restitué rapidement.",
    name = "ADN Alien",
    symptoms = "Symptômes: le patient se métamorphose progressivement en sale machin d'outre-espace et veut tout détruire.",
  },
  bloaty_head = {
    cause = "Cause: avoir reniflé du fromage et bu de l'eau de pluie.",
    cure = "Traitement: la tête est éclatée puis regonflée à la bonne dimension à l'aide d'une astucieuse machine.",
    name = "Encéphalantiasis",
    symptoms = "Symptômes: affreux maux de tête.",
  },
  gastric_ejections = {
    cause = "Cause: nourriture mexicaine ou indienne très épicée.",
    cure = "Traitement: administration par voie orale d'une solution spéciale pour endiguer les rejets.",
    name = "Ejections gastriques",
    symptoms = "Symptômes: le patient rejette par accès des bribes de nourriture mal digérée.",
  },
  uncommon_cold = {
    cause = "Cause: divers trucmuches volant dans l'air",
    cure = "Traitement: absorption d'une grande rasade d'un sirop spécial élaboré à la pharmacie.",
    name = "Catarhume",
    symptoms = "Symptômes: nez qui coule, éternuements, poumons décolorés.",
  },
  corrugated_ankles = {
    cause = "Cause: avoir roulé trop vite sur des ralentisseurs.",
    cure = "Traitement: le patient doit absorber un mélange d'herbes et d'épices légèrement toxique dont l'effet redressera illico les chevilles.",
    name = "Chevilles ondulées",
    symptoms = "Symptômes: les chaussures ne s'ajustent plus.",
  },
  sleeping_illness = {
    cause = "Cause: hypertrophie de la glande palatale de Morphée.",
    cure = "Traitement: une infermière administre une forte dose d'un puissant stimulant.",
    name = "Roupillance",
    symptoms = "Symptômes: tendance irrépressible à tomber de sommeil.",
  },
  sweaty_palms = {
    cause = "Cause: terreur des entretiens d'embauche.",
    cure = "Traitement: un psychiatre détend le patient en lui racontant celle du fou qui repeint son plafond.",
    name = "Mains moites",
    symptoms = "Symptômes: serrer la main du patient revient à presser une éponge détrempée.",
  },
  serious_radiation = {
    cause = "Cause: avoir pris du plutonium pour des bonbons.",
    cure = "Traitement: le patient est passé à la douche de décontamination et consciencieusement récuré.",
    name = "Radionite",
    symptoms = "Symptômes: le patient se sent vraiment, vraiment pas bien.",
  },
  diag_cardiogram = {
    name = "Diag Cardio",
  },
  diag_scanner = {
    name = "Diag Scanner",
  },
  gut_rot = {
    cause = "Cause: la Bonne Vieille Bibine de la Mère Sam.",
    cure = "Traitement: une infermière doit administrer diverses substances chimiques pour tenter de colmater le tout.",
    name = "Tripurulente",
    symptoms = "Symptômes: aucun microbe mais plus de paroi intestinale non plus.",
  },
  iron_lungs = {
    cause = "Cause: pollution atmosphérique combinée aux remugles de kébab.",
    cure = "Traitement: deux chirurgiens enlèvent le blindage en salle d'opération.",
    name = "Poumons de fer",
    symptoms = "Symptômes: envie de respirer du feu et de hurler sous l'eau.",
  },
  broken_wind = {
    cause = "Cause: utilisation d'un appareil de musculation juste après un repas.",
    cure = "Traitement: une mixture d'eau lourde est administrée à la pharmacie.",
    name = "Pétomanie",
    symptoms = "Symptômes: pollution de l'air des personnes situées derrière le patient.",
  },
  kidney_beans = {
    cause = "Cause: avoir croqué les glaçons de son cocktail.",
    cure = "Traitement: deux chirurgiens extraient les cristaux sans endommager le rein.",
    name = "Cristaux rénaux",
    symptoms = "Symptômes: douleur et fréquentes visites aux toilettes.",
  },
  transparency = {
    cause = "Cause: avoir léché le yaourt adhérent au couvercle à l'ouverture d'un pot.",
    cure = "Traitement: administration d'une potion fraîche et colorée préparée à la pharmacie.",
    name = "Transparence",
    symptoms = "Symptômes: la chair est horrible et transparente.",
  },
  broken_heart = {
    cause = "Cause: avoir croisé quelqu'un de plus riche, plus jeune et plus beau.",
    cure = "Traitement: deux chirurgiens ouvrent la poitrine et réparent doucement le coeur en retenant leur souffle.",
    name = "Coeur brisé",
    symptoms = "Symptômes: pleurnicheries et crampes causées par des heures à regarder de vieilles photos de vacances.",
  },
  slack_tongue = {
    cause = "Cause: trop de discussion à propos des romans-feuilletons.",
    cure = "Traitement: la langue est placée dans un taille-langue puis elle est coupée rapidement, efficacement et douloureusement.",
    name = "Hyperlangue",
    symptoms = "Symptômes: la langue s'étire jusqu'à cinq fois sa longueur normale.",
  },
  tv_personalities = {
    cause = "Cause: avoir abusé des programmes télévisés.",
    cure = "Traitement: un psychiatre doit convaincre le patient d'échanger sa télévision contre une radio.",
    name = "Téléincarnation",
    symptoms = "Symptômes: le patient a l'illusion d'être capable de présenter une émission de cuisine.",
  },
  ruptured_nodules = {
    cause = "Cause: saut à l'élastique par temps froid.",
    cure = "Traitement: deux chirurgiens doivent réajuster les parties concernées d'une main sûre.",
    name = "Casse-boules",
    symptoms = "Symptômes: impossibilité de s'asseoir confortablement.",
  },
  fractured_bones = {
    cause = "Cause: chute spectaculaire sur du béton.",
    cure = "Traitement: un plâtre est posé puis ôté à l'aide d'un équipement au laser.",
    name = "Fractures",
    symptoms = "Symptômes: affreux craquement et incapacité à utiliser les membres touchés.",
  },
  chronic_nosehair = {
    cause = "Cause: avoir reniflé avec dédain à la vue de plus malheureux que soi.",
    cure = "Traitement: une épouvantable potion dépilatoire est administrée par une infermière à la pharmacie.",
    name = "Poilonisme",
    symptoms = "Symptômes: poils au nez si drus qu'un oiseau pourrait y nicher.",
  },
}

confirmation = {
  quit = "Vous avez choisi Quitter. Voulez-vous vraiment quitter le jeu ?",
  return_to_blueprint = "Etes-vous sûr de vouloir revenir au mode Tracé ?",
  restart_level = "Etes-vous sûr de vouloir relancer ce niveau ?",
  overwrite_save = "Il y a déjà une partie sauvegardée ici. Etes-vous sûr de vouloir l'écraser ?",
  delete_room = "Voulez-vous vraiment détruire cette salle ?",
  sack_staff = "Etes-vous sûr de vouloir licencier ?",
  replace_machine = "Voulez-vous vraiment remplacer cette machine ?",
}

-- The originals of these strings contain one space too much
trophy_room.sold_drinks.trophies[2] = "Vous recevez le prix Bubulles du Syndicat des Vendeurs de Limonade pour récompenser la quantité de sodas vendus dans votre hôpital au cours de l'année écoulée. "
fax.epidemic.declare_explanation_fine = "Si vous déclarez l'épidémie, vous aurez une amende de %d, un changement de réputation et tous les patients seront vaccinés automatiquement."
fax.diagnosis_failed.partial_diagnosis_percentage_name = "Il y a %d pour cent de chances que la maladie soit %s."
tooltip.status.percentage_cured = "Vous devez soigner %d%% des visiteurs de l'hôpital. Actuellement, vous en avez soigné %d%%"
tooltip.status.num_cured = "L'objectif est de soigner %d personnes. Pour le moment, vous en avez soigné %d"
dynamic_info.staff.actions.going_to_repair = "Pour réparer %s"
adviser.staff_place_advice.only_doctors_in_room = "Seuls les médecins peuvent travailler en %s"
adviser.staff_place_advice.nurses_cannot_work_in_room = "Les infermières ne peuvent travailler en %s"
room_descriptions.gp[2] = "C'est une salle de diagnostic fondamentale pour votre hôpital. Elle accueille les nouveaux patients pour les ausculter. Ils sont ensuite orientés vers une autre salle soit pour une autre diagnostic soit pour Etre soignés. Vous devriez construire un autre cabinet de médecine générale au cas où celui-ci serait débordé. Plus l'endroit est grand et plus vous pouvez y placer des équipements, sans compter que c'est bon pour le prestige du médecin. C'est valable pour toutes les salles, en fait."
room_descriptions.pharmacy[2] = "Les patients dont le mal a été diagnostiqué et dont le traitement est un médicament peuvent se rendre à la pharmacie. Comme la recherche découvre toujours de nouveaux traitements, l'activité de cette salle est en constante évolution. Vous aurez à construire une autre pharmacie plus tard."
room_descriptions.general_diag[3] = "La salle de diagnostic nécessite un médecin. Il faut également un agent de maintenance pour un entretien périodique. "
pay_rise.definite_quit = "Rien ne me fera rester ici. J'en ai assez."
place_objects_window.confirm_or_buy_objects = "Vous pouvez valider ainsi ou bien soit acheter soit déplacer des objets."
fax.emergency.num_disease = "Il y a %d personnes atteintes de %s qui ont besoin de soins immédiats."
fax.emergency.num_disease_singular = "Il y a 1 personne atteinte de %s qui a besoin de soins immédiats."

-- The demo does not contain this string
menu_file.restart = "  RELANCER  "

----------------------------------------------------------- New strings -----------------------------------------------------------

date_format = {
  daymonth = "%1% %2:months%",
}

-- Objects
object.litter = "Déchet"
tooltip.objects.litter = "Déchet : Laissé sur le sol par un patient car il n'a pas trouvé de poubelle où le jeter."

-- Adviser
adviser = {
  room_forbidden_non_reachable_parts = "Placer la pièce à cet endroit va empêcher des parties de l'hôpital d'être atteintes.",

  cheats = {
    th_cheat = "Félicitations, vous avez débloquer les triches !",
    crazy_on_cheat = "Oh non ! Tous les médecins sont devenus fous !",
    crazy_off_cheat = "Ouf... les médecins ont retrouvé leur santé mentale.",
    roujin_on_cheat = "Défi de Roujin activé ! Bonne chance...",
    roujin_off_cheat = "Défi de Roujin désactivé.",
    hairyitis_cheat = "Triche Pilose activée !",
    hairyitis_off_cheat = "Triche Pilose désactivée.",
    bloaty_cheat = "Triche Encéphalantiasis activée !",
    bloaty_off_cheat = "Triche Encéphalantiasis désactivée.",
  },
}


-- Dynamic information
dynamic_info.patient.actions.no_gp_available = "Attente d'un cabinet de médecine générale"
dynamic_info.staff.actions.heading_for = "Va vers %s"
dynamic_info.staff.actions.fired = "Renvoyé"

-- Misc
misc.not_yet_implemented = "(pas encore implémenté)"
misc.no_heliport = "Aucune maladie n'a été découverte pour l'instant, ou il n'y a pas d'héliport sur cette carte."

-- Options menu
menu_options = {
  lock_windows = "  FIGER LES FENETRES  ",
  edge_scrolling = "  DEFILEMENT PAR BORD  ",
  settings = "  PARAMETRES  ",
}

menu_options_game_speed = {
  pause               = "  (P) PAUSE  ",
  slowest             = "  (1) AU PLUS LENT  ",
  slower              = "  (2) PLUS LENT  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) VITESSE MAXI  ",
  and_then_some_more  = "  (5) ET ENCORE PLUS  ",
}
menu_options_game_speed.pause = "  PAUSE  "

-- Debug menu
menu_debug = {
  jump_to_level               = "  ALLER AU NIVEAU  ",
  transparent_walls           = "  (X) MURS TRANSPARENTS  ",
  limit_camera                = "  LIMITER LA CAMERA  ",
  disable_salary_raise        = "  DESACTIVER LES AUGMENTATIONS DE SALAIRE  ",
  make_debug_fax              = "  (F8) CREER UN FAX DE TEST  ",
  make_debug_patient          = "  (F9) CREER UN PATIENT DE TEST  ",
  cheats                      = "  (F11) TRICHES  ",
  lua_console                 = "  (F12) CONSOLE LUA  ",
  calls_dispatcher            = "  REPARTITION DES TACHES  ",
  dump_strings                = "  EXTRAIRE LES TEXTES  ",
  dump_gamelog                = "  (CTRL+D) EXTRAIRE LE JOURNAL DE JEU  ",
  map_overlay                 = "  INCRUSTATIONS DE CARTE  ",
  sprite_viewer               = "  VISIONNEUSE DE SPRITES  ",
}
menu_debug_overlay = {
  none                        = "  AUCUN  ",
  flags                       = "  DRAPEAUX  ",
  positions                   = "  POSITIONS  ",
  heat                        = "  TEMPERATURE  ",
  byte_0_1                    = "  OCTETS 0 & 1  ",
  byte_floor                  = "  OCTET SOL  ",
  byte_n_wall                 = "  OCTET MUR N  ",
  byte_w_wall                 = "  OCTET MUR O  ",
  byte_5                      = "  OCTET 5  ",
  byte_6                      = "  OCTET 6  ",
  byte_7                      = "  OCTET 7  ",
  parcel                      = "  PARCELLE  ",
}

-- Main menu
main_menu = {
  new_game = "Nouvelle partie",
  custom_level = "Niveau personnalisé",
  load_game = "Charger une partie",
  options = "Options",
  exit = "Quitter",
}

tooltip.main_menu = {
  new_game = "Commencer une partie totalement nouvelle",
  custom_level = "Construire votre hôpital dans un niveau personnalisé",
  load_game = "Charger une partie sauvegardée",
  options = "Modifier quelques paramètres",
  exit = "Non, non, SVP, ne quittez pas !",
}

--- New game window
new_game_window = {
  easy = "Interne (Facile)",
  medium = "Médecin (Moyen)",
  hard = "Consultant (Difficile)",
  tutorial = "Tutoriel",
  cancel = "Annuler",
}

tooltip.new_game_window = {
  easy = "Si vous jouez pour la première fois à un jeu de simulation, cette option est pour vous",
  medium = "C'est la voie du milieu à prendre si vous ne savez pas quoi choisir",
  hard = "Si vous êtes habitué à ce genre de jeu et que vous souhaitez plus d'un défi, choisissez cette option",
  tutorial = "Si vous voulez un peu d'aide pour démarrer une fois dans le jeu, cochez cette case",
  cancel = "Oh, je n'avais pas vraiment l'intention de commencer une nouvelle partie !",
}

-- Load game window
load_game_window = {
  caption = "Charger une partie",
}

tooltip.load_game_window = {
  load_game = "Charger la partie %s",
  load_game_number = "Charger la partie %d",
  load_autosave = "Charger la sauvegarde automatique",
}

-- Custom game window
custom_game_window = {
  caption = "Niveau personnalisé",
}

tooltip.custom_game_window = {
  start_game_with_name = "Charger le niveau %s",
}

-- Save game window
save_game_window = {
  caption = "Enregistrer la partie",
  new_save_game = "Nouvelle sauvegarde",
}

tooltip.save_game_window = {
  save_game = "Écraser la sauvegarde %s",
  new_save_game = "Entrez un nom pour la sauvegarde",
}

-- Menu list window
menu_list_window = {
  back = "Précédent",
}

tooltip.menu_list_window = {
  back = "Fermer cette fenêtre",
}

-- Options window
options_window = {
  fullscreen = "Plein écran",
  width = "Largeur",
  height = "Hauteur",
  change_resolution = "Changer la résolution",
  browse = "Parcourir...",
  new_th_directory = "Ici, vous pouvez spécifier un nouveau dossier d'installation de Theme Hospital. Dès que vous aurez changé le répertoire, le jeu sera redémarré.",
  cancel = "Annuler",
  back = "Précédent",
}

tooltip.options_window = {
  fullscreen_button = "Basculer en mode plein écran/fenêtré",
  width = "Entrez la largeur désirée",
  height = "Entrez la hauteur désirée",
  change_resolution = "Changer la résolution pour les dimensions entrées à gauche",
  language = "Utiliser la langue %s",
  original_path = "Le dossier d'installation du Theme Hospital originel qui est actuellement sélectionné",
  browse = "Choisir un autre emplacement d'installation de Theme Hospital",
  back = "Fermer la fenêtre des options",
}

-- Debug patient window
debug_patient_window = {
  caption = "Patient de test",
}

-- Cheats window
cheats_window = {
  caption = "Triches",
  warning = "Attention : Vous n'aurez aucun point de bonus à la fin du niveau si vous trichez !",
  cheated = {
    no = "Triches utilisées : Non",
    yes = "Triches utilisées : Oui",
  },
  cheats = {
    money = "Plus d'argent",
    all_research = "Toutes les recherches",
    emergency = "Créer une urgence",
    create_patient = "Créer un patient",
    end_month = "Fin du mois",
    end_year = "Fin de l'année",
    lose_level = "Perdre le niveau",
    win_level = "Gagner le niveau",
  },
  close = "Fermer",
}

tooltip.cheats_window = {
  close = "Fermer le dialogue de triches",
  cheats = {
    money = "Ajoute 10.000 à votre solde bancaire.",
    all_research = "Termine toutes les recherches.",
    emergency = "Crée une urgence.",
    create_patient = "Crée un patient au bord de la carte.",
    end_month = "Va directement à la fin du mois.",
    end_year = "Va directement à la fin de l'année.",
    lose_level = "Vous fait perdre le niveau actuel.",
    win_level = "Vous fait gagner le niveau actuel.",
  }
}

-- "Tip of the day" window
totd_window = {
  tips = {
    "Chaque hôpital a besoin d'un bureau de réception et d'un cabinet de médecine générale. Après, tout dépend du type de patients qui visitent votre hôpital. Une pharmacie est toujours un bon choix malgré tout.",
    "Les machines telles que le Gonflage ont besoin de maintenance. Embauchez un ou deux agents de maintenance pour réparer vos machines, ou vous risquerez d'avoir des blessés parmi le personnel ou les patients.",
    "Après un certain temps, vos employés seront fatigués. Pensez à construire une salle de repos où ils pourront se détendre.",
    "Placez suffisamment de radiateurs pour garder vos employés et patients au chaud, ou ils deviendront mécontents. Utilisez la carte de la ville pour localiser les endroits de votre hôpital qui nécessitent plus de chauffage.",
    "Le niveau de compétence d'un docteur influence beaucoup la qualité et la rapidité de ses diagnostics. Utilisez un médecin expérimenté comme généraliste et vous n'aurez plus besoin d'autant de salles de diagnostics.",
    "Les internes et les médecins peuvent augmenter leurs compétences auprès d'un consultant dans la salle de formation. Si le consultant a des qualifications pariculières (chirurgien, psyschiatre ou chercheur), il transférera ses connaissances à ses élèves.",
    "Avez-vous essayé d'entrer le numéro d'urgence Européen (112) dans le fax ? Vérifiez que vous avez du son !",
    "Vous pouvez ajuster certains paramètres tels que la résolution et la langue dans la fenêtre d'options accessible à la fois depuis le menu principal et pendant le jeu.",
    "Vous avez choisi une autre langue que l'anglais, mais il y du texte en anglais partout ? Aidez-nous à traduire les textes manquants dans votre langue !",
    "L'équipe de CorsixTH cherche du renfort ! Vous êtes intéressé par coder, traduire ou faire des graphismes pour CorsixTH ? Contactez-nous sur notre Forum, Liste de Diffusion ou Canal IRC (corsix-th sur freenode).",
    "Si vous avez trouvé un bug, SVP, reportez le sur notre gestionnaire de bugs : th-issues.corsix.org.",
    "Chaque niveau possède des objectifs qu'il vous faudra remplir pour pouvoir passer au suivant. Vérifiez la fenêtre de status pour voir votre progression dans les objectifs du niveau.",
    "Si vous voulez éditer ou détruire une pièce, vous pouvez le faire avec le bouton d'édition situé sur la barre d'outil en bas.",
    "Dans un groupe de patients en attente, vous pouvez rapidement découvrir lesquels attendent une pièce particulière en survolant cette pièce avec votre curseur de souris.",
    "Cliquez sur la porte d'une pièce pour visualiser sa file d'attente. Vous pouvez faire des réglages très utilies ici, comme réorganiser la file d'attente ou envoyer un patient vers une autre pièce.",
    "Le personnel mécontent vous demandra des augmentations de salaires fréquemment. Assurez vous de leur offir un environnement de travail confortable pour éviter cela.",
    "Les patients auront soif en attendant dans votre hôpital, encore plus si vous augmentez le chauffage ! Placez des distributeurs automatiques dans les points stratégiques pour un revenu d'appoint.",
    "Vous pouvez interrompre le processus de diagnostic d'un patient et proposer un traitement, si vous avez déjà rencontré la maladie. Notez que cela peut accroître le risque d'erreur de traitement, et provoquer la mort du patient.",
    "Les urgences peuvent être une bonne source de revenus additionnels, à condition que vous ayez les capacités suffisantes pour traiter les patients à temps.",
  },
  previous = "Astuce précédente",
  next = "Astuce suivante",
}

tooltip.totd_window = {
  previous = "Afficher l'astuce précédente",
  next = "Afficher l'astuce suivante",
}

-- Lua Console
lua_console = {
  execute_code = "Éxécuter",
  close = "Fermer",
}

tooltip.lua_console = {
  textbox = "Entrez du code Lua à éxécuter ici",
  execute_code = "Éxécuter le code que vous avez entré",
  close = "Fermer la console",
}

-- Confirmation dialog
confirmation = {
  needs_restart = "Changer ce paramètre va nécessiter un redémarrage de CorsixTH. Tout progrès non sauvegardé sera perdu. Etes-vous sûr de vouloir faire cela ?",
  abort_edit_room = "Vous êtes actuellement en train de construire ou d'éditer une pièce. Si tous les objets requis sont placés, elle sera validée, mais sinon elle sera détruite. Continuer ?",
}

-- Information dialog
information = {
  custom_game = "Bienvenue dans CorsixTH. Amusez-vous bien avec cette carte personnalisée !",
  cannot_restart = "Malheureusement cette partie personnalisée a été sauvegardée avant que la fonctionnalité de redémarrage soit implémentée.",
  level_lost = {
    "Quelle poisse ! Vous avez raté le niveau. Vous ferez mieux la prochaine fois !",
    "Voilà pourquoi vous avez perdu :",
    reputation = "Votre réputation est tombée en dessous de %d.",
    balance = "Votre solde bancaire est tombé en dessous %d.",
    percentage_killed = "Vous avez tué plus de %d pourcents de vos patients.",
  },
}

tooltip.information = {
  close = "Fermer cette boîte de dialogue.",
}

-- Introduction Texts
introduction_texts = {
  demo = {
    "Bienvenue dans l'hôpital de démonstration !",
    "Malheureusement, la version démo ne contient que ce niveau (excepté les niveaux personnalisés). Malgré tout, il y a assez à faire ici pour vous occuper un moment !",
    "Vous allez rencontrer différentes maladies qui nécessitent des salles pour les soigner. De temps en temps, des urgences peuvent se produire. Et vous aurez besoin d'une salle de recherche pour trouver des nouvelles salles.",
    "Votre but est de gagner 100.000$, de faire monter la valeur de votre hôpital à 70.000$ et d'obtenir une réputation de 700, tout en ayant soigné au moins 75% de vos patients.",
    "Veillez à ce que votre réputation ne tombre pas en dessous de 300 et de ne pas tuer plus de 40% de vos patients, ou vous perdrez.",
    "Bonne chance !",
  },
}

-- Calls Dispatcher Dialog
calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d appels; %d assignés",
  staff = "%s - %s",
  watering = "Arrose @ %d,%d",
  repair = "Répare %s",
  close = "Fermer",
}

tooltip.calls_dispatcher = {
  task = "Liste des tâches - cliquez sur une tâche pour ouvrir la fenêtre du membre du personnel à qui elle est assignée et aller jusqu'à l'endroit où a lieu la tâche.",
  assigned = "Cette case est cochée si la tâche est assignée à quelqu'un.",
  close = "Ferme la boîte de dialogue de répartitions des tâches",
}

-- Fax messages
fax = {
  choices = {
    return_to_main_menu = "Retourner au menu principal",
    accept_new_level = "Aller au niveau suivant",
    decline_new_level = "Continuer la partie encore un peu",
  },
}

tooltip.fax.close = "Fermer cette fenêtre sans supprimer le message"
tooltip.message.button = "Clic gauche pour ouvrir le message"
tooltip.message.button_dismiss = "Clic gauche pour ouvrir le message, clic droit pour le rejeter"
tooltip.casebook.cure_requirement.hire_staff = "Vous devez embaucher du personnel pour gérer ce traitement"
tooltip.casebook.cure_type.unknown = "Vous ne savez pas encore comment traiter cette maladie"
tooltip.research_policy.no_research = "Aucune recherche n'est actuellement effectuée dans cette catégorie"
tooltip.research_policy.research_progress = "Progrès vers la prochaine découverte dans cette catégorie : %1%/%2%"

-- Winning texts
letter = {
  dear_player = "Cher %s",
  custom_level_completed = "Félicitations ! Vous avez réussi tous les objectifs de ce niveau personnalisé !",
  return_to_main_menu = "Voulez-vous retourner au menu principal ou continuer la partie ?",
}

-- Installation
install = {
  title = "----------------------------- Installation de CorsixTH -----------------------------",
  th_directory = "CorsixTH nécessite une copie des données du jeu Theme Hospital originel (ou la démo) pour fontionner. Veuillez utiliser le sélecteur ci-dessous pour indiquer le dossier d'installation de Theme Hospital.",
  exit = "Quitter",
}

-- Errors
errors = {
  dialog_missing_graphics = "Désolé, les données de démo ne contiennent pas cette boîte de dialogue.",
  save_prefix = "Erreur lors de la sauvegarde de la partie : ",
  load_prefix = "Erreur lors du chargement de la partie : ",
  map_file_missing = "Impossible de trouver le fichier de carte %s pour ce niveau !",
  minimum_screen_size = "Veuillez entrer une résolution supérieure à 640x480.",
  maximum_screen_size = "Veuillez entrer une résolution inférieure à 3000x2000.",
  unavailable_screen_size = "La résolution que vous avez demandé n'est pas disponible en plein écran.",
}
