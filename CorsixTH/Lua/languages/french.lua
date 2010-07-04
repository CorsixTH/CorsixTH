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

----------------------------------------------------------- Override -----------------------------------------------------------
adviser.information.promotion_to_specialist = utf8 "L'un de vos INTERNES est devenu MEDECIN." -- Fix the famous "Level 5 bug"
misc.save_failed = utf8 "ERREUR : Partie non sauvegardée" -- Much more french
tooltip.policy.diag_termination = utf8 "L'auscultation d'un patient continuera jusqu'à ce que les médecins soient sûrs à hauteur du pourcentage FIN PROCEDURE ou jusqu'à ce que toutes les machines de diagnostic aient été essayées. " -- Remove a superfluous word
room_descriptions.gp[2] = utf8 "C'est une salle de diagnostic fondamentale pour votre hôpital. Elle accueille les nouveaux patients pour les ausculter. Ils sont ensuite orientés vers une autre salle soit pour un autre diagnostic soit pour être soignés. Vous devriez construire un autre cabinet de médecine générale au cas où celui-ci serait débordé. Plus l'endroit est grand et plus vous pouvez y placer des équipements, sans compter que c'est bon pour le prestige du médecin. C'est valable pour toutes les salles, en fait."
room_descriptions.staff_room[2] = utf8 "Votre équipe finit par se fatiguer et a besoin de cette salle pour se remettre. Une équipe fatiguée est lente, revendicatrice et peut même envisager de démissionner. De plus, elle risque de commettre des erreurs. Il est avisé de construire une salle de repos bien aménagée et de prévoir assez de place pour plusieurs membres à la fois."
adviser.goals.win = { -- Why are this strings upcase?
  reputation = utf8 "Portez votre réputation à %d pour pouvoir gagner",
  value = utf8 "Portez la valeur de votre hôpital à %d",
}
adviser.warnings.handymen_tired = utf8 "Les agents de maintenance sont très fatigués. Laissez-les se reposer." -- Add a missing letter

-- Fix Winning texts
letter = {
  [1] = { -- Level one: Fix issue 329
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Splendide ! Vous avez admirablement géré cet hôpital. Nous, pontes du Ministère de la Santé, souhaitons savoir si vous aimeriez prendre en charge un plus grand projet. Nous comptons sur vous. Le salaire serait de %d$ et ça vaut la peine d'y réfléchir.",
    [3] = utf8 "Que diriez-vous de travailler à l'hôpital de %s ?",
  },
  [2] = { -- Level two: Add missing spaces before punctuation marks
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Formidable ! Vous avez fait de grands progrès dans votre hôpital. Nous vous avons trouvé un autre établissement pour exercer vos talents et relever des défis. Vous pouvez refuser mais ce serait dommage. Le salaire est de %d$.",
    [3] = utf8 "Acceptez-vous le poste à l'hôpital de %s ?",
  },
  [3] = { -- Level three: Add missing spaces before punctuation marks
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Vous avez parfaitement réussi dans cet hôpital. C'est la raison pour laquelle nous vous proposons une nouvelle situation. Le salaire serait de %d$ et nous pensons que vous adorerez relever ce nouveau défi.",
    [3] = utf8 "Acceptez-vous de gérer l'hôpital de %s ?",
  },
  [4] = { -- Level four: Add missing spaces before punctuation marks
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Félicitations ! Le Ministère de la Santé est très impressionné par vos capacités à gérer cet hôpital. Vous êtes un exemple de réussite dans ce domaine. Vous voudrez peut-être une situation plus élevée, toutefois. Vous seriez payé %d$, et la décision vous revient.",
    [3] = utf8 "Etes-vous prêt à accepter un poste à l'hôpital de %s ?",
  },
  [5] = { -- Level five: Add missing spaces before punctuation marks and between words
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Nouvelles salutations. Nous respectons votre souhait de ne pas quitter ce charmant hôpital, mais nous vous supplions d'y réfléchir. Nous vous proposons la coquette somme de %d$ pour accepter de diriger un autre hôpital avec autant de succès.",
    [3] = utf8 "Aimeriez-vous prendre la tête de l'hôpital de %s ?",
  },
  [6] = { -- Level six: Add missing spaces before punctuation marks, fix last string which contained an anglicism
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Nous savons que vous êtes heureux de vous occuper de cette délicieuse institution mais nous pensons que vous devez penser à l'avenir. Vous pourriez prétendre au salaire de %d$ si vous acceptez de changer de situation. Pensez-y.",
    [3] = utf8 "Voulez-vous un poste à l'hôpital de %s ?",
  },
  [7] = { -- Level seven: Add missing spaces before punctuation marks
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Le Ministère de la Santé souhaite que vous reconsidériez votre décision de rester dans cet hôpital. Nous savons que vous avez un charmant établissement mais il est temps de relever un nouveau défi, avec un salaire attrayant de %d$.",
    [3] = utf8 "Etes-vous prêt à travailler à l'hôpital de %s ?",
  },
  [8] = { -- Level height: Add missing spaces before punctuation marks
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Vous aviez donné une réponse négative à notre dernière lettre vous proposant un grand poste dans un nouvel hôpital, avec un coquet salaire de %d$. Nous pensons que vous devez revoir votre décision car nous avons pour vous un poste idéal.",
    [3] = utf8 "Voulez-vous bien accepter un poste à l'hôpital de %s ? S'il vous plaît !",
  },
  [9] = { -- Level nine: Add missing spaces before punctuation marks, fix some sentences, add missing diacritics
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Vous vous êtes montré le meilleur directeur d'hôpital jamais connu dans la longue et mouvementée histoire de la médecine. Nous sommes fiers de vous offrir le poste de Chef Suprême des Hôpitaux. Ce titre honorifique vous garantit un salaire de %d$. On fera pour vous une parade pleine de serpentins et les gens vous baiseront les pieds.",
    [3] = utf8 "Merci pour tout ce que vous avez fait. Vous avez mérité cette semi-retraite.",
  },
  [10] = { -- Level ten: Fix some sentences
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Félicitations pour avoir réussi dans tous les hôpitaux que vous avez dirigé. Une telle performance fait de vous un héros. Vous recevrez une pension de %d$ plus une limousine. Tout ce que nous vous demandons, c'est d'aller de ville en ville rencontrer votre public en adoration et défendre le renom des hôpitaux.",
    [3] = utf8 "Nous sommes tous fiers de vous et notre coeur déborde de gratitude pour votre dévouement à sauver des vies.",
  },
  [11] = { -- Level eleven: No change
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Votre carrière est exemplaire et vous êtes une inspiration pour nous tous. Merci d'avoir géré tous ces hôpitaux avec autant de talent. Nous souhaitons vous offrir une rente à vie de %d$ pour simplement aller de ville en ville à bord d'une voiture de prestige pour saluer la foule et donner des conférences sur votre incroyable réussite.",
    [3] = utf8 "Vous êtes un exemple pour toute personne sensée et tout le monde, sans exception, vous considère comme un modèle absolu.",
  },
  [12] = { -- Level twelve: Add missing spaces before punctuation marks
    [1] = utf8 "Estimable %s",
    [2] = utf8 "Votre carrière réussie en tant que meilleur directeur d'hôpital depuis la nuit des temps arrive à sa fin. Toutefois, vous avez eu sur le monde tranquille de la médecine une telle influence que le Ministre vous offre un salaire de %d$ uniquement pour paraître en public, faire des inaugurations, baptiser des navires et participer à des débats. Le monde entier vous acclame et c'est la meilleure des publicités pour le Ministère de la Santé !",
    [3] = utf8 "Veuillez accepter cette situation : ce n'est pas trop difficile et vous aurez, en plus, une escorte de police partout où vous irez.",
  },
}

-- The originals of these string lacks space before punctuation marks and or between words
misc.balance = utf8 "Ajustage :"
tooltip.pay_rise_window.decline = utf8 "Ne payez pas, licenciez !"
tooltip.casebook.hire_staff = utf8 "Il faut embaucher un(e) %s pour ce traitement"
tooltip.watch = {
  emergency = utf8 "Urgence : temps qui reste pour soigner les patients entrés en urgence.",
  hospital_opening = utf8 "Délai : ceci est le temps qui reste avant que votre hôpital soit ouvert. Cliquez sur GO pour l'ouvrir tout de suite.",
  epidemic = utf8 "Epidémie : temps qui reste pour arrêter l'épidémie. Si ce délai expire OU si un malade contagieux quitte l'hôpital, un inspecteur sanitaire viendra... Le bouton active ou désactive la vaccination. Cliquez sur un patient pour lancer la vaccination par une infermière.",
}
tooltip.objects = {
  chair = utf8 "Chaise : le patient s'y assied pour parler de ses symptômes.",
  sofa = utf8 "Sofa : c'est ce qui permet aux employés de se relaxer... sauf s'ils trouvent mieux...",
  bench = utf8 "Banc : pour que les patients puissent attendre confortablement.",
  video_game = utf8 "Jeu vidéo : l'équipe se relaxe en jouant à Hi-Octane.",
  lamp = utf8 "Lampe : vous avez déjà essayé de travailler dans le noir ?",
  door = utf8 "Porte : les gens aiment les ouvrir et les fermer.",
  auto_autopsy = utf8 "Autopsie : très utile pour la recherche",
  tv = utf8 "TV : votre équipe ne doit pas manquer ses programmes favoris.",
  litter_bomb = utf8 "Bombe à détritus: pour saboter les hôpitaux concurrents",
  inflator = utf8 "Gonfleur : pour soigner l'encéphalantiasis.",
  desk = utf8 "Bureau : essentiel pour poser un ordinateur.",
  pool_table = utf8 "Billard : pour la relaxation du personnel.",
  bed = utf8 "Lit : les cas graves ont besoin de rester couchés.",
  bookcase = utf8 "Etagère : pour les ouvrages de référence.",
  drinks_machine = utf8 "Distributeurs : contre la soif et pour ramasser des gros sous.",
  skeleton = utf8 "Squelette : utile pour l'enseignement et pour Halloween.",
  computer = utf8 "Ordinateur : une composante essentielle de la recherche",
  bin = utf8 "Poubelle : les patients y jettent leurs détritus.",
  pharmacy_cabinet = utf8 "Pharmacie: c'est là qu'on dispense les médicaments",
  radiator = utf8 "Radiateur : permet de garder l'hôpital au chaud.",
  atom_analyser = utf8 "Mélangeur : installé au Département Recherche, cette machine accélère tout le processus d'étude.",
  plant = utf8 "Plante : plaît aux patients et purifie l'air.",
  toilet = utf8 "Toilettes : les patients en ont, euh, besoin.",
  fire_extinguisher = utf8 "Extincteur : pour minimiser les dangers causés par des machines défectueuses.",
  lecture_chair = utf8 "Chaise : les médecins en formation s'asseyent là pour prendre des notes et s'ennuyer. Plus vous mettrez des chaises, plus vous pourrez former de médecins.",
  toilet_sink = utf8 "Lavabo : s'il n'y en a pas assez, les patients qui apprécient l'hygiène seront mécontents.",
  cabinet = utf8 "Placard : dossiers des patients, notes de recherche.",
}
room_descriptions.fracture_clinic[2] = utf8 "Les patients dont les os étaient en morceaux se rendront dans cette salle. Le déplâtreur dégagera les membres en ne causant qu'une faible douleur."
room_descriptions.inflation[2] = utf8 "Les patients souffrant de l'affreuse-mais-si-drôle encéphalantiasis sont soignés à la salle de gonflage, où leur tête démesurée sera dégonflée puis regonflée à la bonne taille."
room_descriptions.hair_restoration[2] = utf8 "Les patients souffrant de sévère calvitie se rendront dans cette salle équipée d'un moumouteur. Un médecin utilisera la machine pour donner aux patients une nouvelle chevelure."
room_descriptions.electrolysis[2] = utf8 "Les patients souffrant de pilose viennent dans cette salle où une machine arrache les poils et scelle les pores selon un procédé qui n'est pas sans rappeler la cimentation."
progress_report.too_hot = utf8 "Réglez le chauffage : on étouffe."
adviser.tutorial.build_pharmacy = utf8 "Félicitations ! Construisez maintenant une pharmacie et embauchez une infermière."
adviser.epidemic.serious_warning = utf8 "Cette maladie contagieuse est dangereuse. Vous devez prendre des mesures d'urgence !"
adviser.staff_advice.too_many_doctors = utf8 "Il y a trop de médecins. Certains n'ont rien à faire !."
adviser.earthquake.ended = utf8 "Ouh là ! J'ai cru que c'était la fin! C'était du %d sur l'échelle de Richter."
adviser.muliplayer = {
  not_interested = utf8 "Ha ! Ils ne veulent pas travailler pour vous, ils sont satisfaits comme ça.",
  already_poached_by_someone = utf8 "Eh non ! Quelqu'un s'intéresse déjà à cette personne.",
}
adviser.vomit_wave.ended = utf8 "Ouf ! On dirait que le virus qui provoquait des nausées est enfin enrayé. Gardez l'hôpital propre, à l'avenir."
adviser.research.new_available = utf8 "Nouveau : un(e) %s est disponible."
adviser.goals.lose.kill = utf8 "Tuez encore %d patients pour perdre !"
adviser.warnings = {
  money_low = utf8 "Les fonds sont en baisse !",
  no_patients_last_month = utf8 "Pas de nouveaux patients le mois dernier. Honteux !",
  machines_falling_apart = utf8 "Les machines tombent en panne. Faites-les réparer !",
  bankruptcy_imminent = utf8 "Hé ! Vous courez à la faillite. Attention !",
  too_many_plants = utf8 "Il y a bien trop de plantes. C'est la jungle, ici !",
  many_killed = utf8 "Vous avez laissé mourir %d personnes. Idiot ! Vous êtes censé les soigner.",
}
adviser.placement_info.object_cannot_place = utf8 "Hé ! Vous ne pouvez pas mettre cet objet ici."
adviser.information = {
  epidemic = utf8 "Une maladie contagieuse sévit dans votre hôpital. Vous devez l'enrayer immédiatement !",
  emergency = utf8 "C'est une urgence ! Vite ! Vite ! VITE !",
  initial_general_advice = {
    first_epidemic = utf8 "Il y a une épidémie dans votre hôpital ! A vous de voir si vous étouffez l'affaire ou si vous en parlez.",
  },
  patient_leaving_too_expensive = utf8 "Un patient part sans payer la facture pour %s. Sacrée perte !",
  vip_arrived = utf8 "Attention ! %s arrive pour visiter votre hôpital ! Faites en sorte de lui faire bonne impression.",
  first_death = utf8 "Vous venez de tuer votre premier patient. Alors, heureux ?",
}
buy_objects_window = {
  price = utf8 "Prix : ",
  total = utf8 "Total : ",
}
fax = {
  epidemic_result = {
    close_text = utf8 "Hourrah !",
    rep_loss_fine_amount = utf8 "Les journaux vont s'en donner à coeur joie avec cette affaire. Votre réputation va en prendre un coup ! Sans oublier l'amende de %d.",
    },
  vip_visit_result = {
    telegram = utf8 "Télégramme !",
    remarks = {
      [3] = utf8 "Charmant, cet hôpital. Bon, si on allait manger un curry ?",
    },
    bad = {
      [2] = utf8 "Ce que j'ai vu est révoltant. Ce n'est pas un hôpital, c'est une porcherie !",
    },
    bad = {
      [3] = utf8 "J'en ai assez de devoir faire des visites officielles dans des trous puants comme celui-ci. Je démissionne !",
    },
    very_bad = {
      [1] = utf8 "Quelle déception ! On devrait fermer cet endroit.",
      [2] = utf8 "Je n'ai jamais vu ça. Quelle honte !",
      [3] = utf8 "Je suis sous le choc. Et on appelle ça un hôpital ! Il me faut un verre pour m'en remettre.",
    },
  },
  vip_remarked_name = utf8 "Après avoir visité votre hôpital, %s a dit :",
  disease_discovered_patient_choice = {
    what_to_do_question = utf8 "Que voulez-vous faire du patient ?",
  },
  debug_fax = {
    close_text = utf8 "Ouais, ouais, ouais !",
  },
  diagnosis_failed = {
    what_to_do_question = utf8 "Que faire du patient ?",
  },
}
dynamic_info = {
  patient = {
    actions = {
      prices_too_high = utf8 "C'est trop cher : je rentre chez moi",
      no_diagnoses_available = utf8 "Plus de diagnostic : je rentre chez moi",
      cured = utf8 "Guéri !",
      no_treatment_available = utf8 "Pas de traitement : je rentre chez moi",
    },
    diagnosed = utf8 "Ausculté : %s",
  } 
}

introduction_texts = {
  level1 = {
    [1] = utf8 "Bienvenue dans votre premier hôpital !",
  },
  level8 = {
    [4] = utf8 "Ratissez tous ces malades !",
  },
  level12 = {
    [1] = utf8 "Côté défi, vous allez être servi !",
    [4] = utf8 "Alors, heureux ?",
  },
  level13 = {
    [4] = utf8 "Vous pensez y arriver ?",
  },
  level14 = {
    [1] = utf8 "Et encore un défi ! Eh oui, voici l'hôpital-surprise !",
    [4] = utf8 "Bonne chance !",
  },
  level17 = {
    [3] = utf8 "A vous de jouer, maintenant. Bonne chance et tout ça, quoi !",
  }
}
transactions = {
  cure_colon = utf8 "Guérison :",
  final_treat_colon = utf8 "Trait final :",
  treat_colon = utf8 "Trait :",
  advance_colon = utf8 "Avance :",
  insurance_colon = utf8 "Assurance :",
}
diseases = {
  third_degree_sideburns = {
    cause = utf8 "Cause : regret pathologique des années 70.",
    cure = utf8 "Traitement : un psychiatre doit faire comprendre au patient qu'il faut changer d'époque comme de chemise.",
    name = utf8 "Rétrostalgie",
    symptoms = utf8 "Symptômes : passion immodérée des pantalons à pattes d'éléphant et des paillettes.",
  },
  discrete_itching = {
    cause = utf8 "Cause : petits bestioles à dents aiguës.",
    cure = utf8 "Traitement : un sirop gluant est administré pour empêcher les démangeaisons.",
    name = "Morpionnite",
    symptoms = utf8 "Symptômes: le patient se gratte jusqu'au sang.",
  },
  the_squits = {
    cause = utf8 "Cause: avoir mangé de la pizza ramassée derrière la cuisinière.",
    cure = utf8 "Traitement: un mélange gluant de diverses substances synthétiques est administré au patient pour solidifier son, euh, contenu.",
    name = utf8 "Courante",
    symptoms = utf8 "Symptômes: Hum. Vous voyez le genre.",
  },
  spare_ribs = {
    cause = utf8 "Cause: trop de temps passé sur un sol froid.",
    cure = utf8 "Traitement: deux chirurgiens retirent les côtes flottantes et les donnent au patient dans un sac à emporter.",
    name = utf8 "Excès costal",
    symptoms = utf8 "Symptômes: déplaisante sensation de flottement.",
  },
  diag_blood_machine = {
    name = utf8 "Diag Sanguimachine",
  },
  king_complex = {
    cause = utf8 "Cause: l'esprit du King s'est emparé de celui du patient et l'a envahi.",
    cure = utf8 "Traitement: un psychiatre explique au patient à quel point tout ceci est ridicule.",
    name = utf8 "Syndrome du King",
    symptoms = utf8 "Symptômes: passion pour les chaussures en daim bleu et pour les cheeseburgers.",
  },
  diag_x_ray = {
    name = utf8 "Diag Rayons X",
  },
  pregnancy = {
    cause = utf8 "Cause: pannes de courant en zones urbaines.",
    cure = utf8 "Traitement: le bébé est prélevé en salle d'opération puis soigneusement nettoyé pour faire son entrée dans le monde.",
    name = utf8 "Grossesse",
    symptoms = utf8 "Symptômes: gloutonnerie avec hypertrophie du ventre.",
  },
  fake_blood = {
    cause = utf8 "Cause: avoir été victime d'une très mauvaise plaisanterie.",
    cure = utf8 "Traitement: seule une cure psychiatrique peut calmer le patient.",
    name = utf8 "Sang factice",
    symptoms = utf8 "Symptômes: le patient voit son sang s'évaporer.",
  },
  diag_psych = {
    name = utf8 "Diag Psychiatre",
  },
  invisibility = {
    cause = utf8 "Cause: morsure par une fourmi radioactive (et invisible).",
    cure = utf8 "Traitement: il suffit de faire boire au patient un liquide coloré dispensé à la pharmacie pour le rendre pleinement observable.",
    name = utf8 "Invisibilité",
    symptoms = utf8 "Symptômes: le patient ne souffre pas mais a une forte propension à utiliser son état pour faire des farces à son entourage.",
  },
  golf_stones = {
    cause = utf8 "Cause: exposition au gaz empoisonné contenu dans les balles de golf.",
    cure = utf8 "Traitement: résection des surplus par une équipe de deux chirurgiens.",
    name = utf8 "Pierres de golf",
    symptoms = utf8 "Symptômes: formation nodules excédentaires.",
  },
  diag_general_diag = {
    name = utf8 "Diag Généraliste",
  },
  infectious_laughter = {
    cause = utf8 "Cause: exposition à un comique de situation.",
    cure = utf8 "Traitement: un psychiatre doit faire comprendre au patient à quel point son état est sérieux.",
    name = utf8 "Fou rire",
    symptoms = utf8 "Symptômes: gloussement irrépressible et répétition compulsive d'accroches même pas drôles.",
  },
  general_practice = {
    name = utf8 "Généraliste",
  },
  baldness = {
    cause = utf8 "Cause: avoir raconté trop de mensonges pour se rendre intéressant.",
    cure = utf8 "Traitement: pose très douloureuse de cheveux à l'aide d'un moumouteur.",
    name = utf8 "Calvitie",
    symptoms = utf8 "Symptômes: tête en boule de billard et gros complexe.",
  },
  heaped_piles = {
    cause = utf8 "Cause: s'être assis sur un jet de jacuzzi.",
    cure = utf8 "Traitement: un potion agréable bien que puissamment acide dissout les rectoïdes de l'intérieur.",
    name = utf8 "Rectoïdes",
    symptoms = utf8 "Symptômes: le patient a l'impression de s'asseoir sur un sac de billes.",
  },
  unexpected_swelling = {
    cause = utf8 "Cause: n'importe quoi d'inattendu.",
    cure = utf8 "Traitement: le dégonflement est obtenu par une délicate opération pratiquée par deux chirurgiens.",
    name = utf8 "Bouffissure",
    symptoms = utf8 "Symptômes: bouffissure généralisée.",
  },
  jellyitis = {
    cause = utf8 "Cause: abus de produits riches en gélifiant et trop d'exercice.",
    cure = utf8 "Traitement: le patient est immergé dans un dégélifiant.",
    name = utf8 "Gélatine",
    symptoms = utf8 "Symptômes: grande mollesse et tendance à l'écroulement.",
  },
  hairyitis = {
    cause = utf8 "Cause: exposition prolongée au clair de lune.",
    cure = utf8 "Traitement: on fait disparaître les poils avec un électrolyseur et les pores sont scellés.",
    name = utf8 "Pilose",
    symptoms = utf8 "Symptômes: le patient développe un odorat accru.",
  },
  alien_dna = {
    cause = utf8 "Cause: agrippeurs faciaux munis de sang extraterrestre intelligent.",
    cure = utf8 "Traitement: l'ADN est retiré par un correcteur pour être nettoyé puis restitué rapidement.",
    name = utf8 "ADN Alien",
    symptoms = utf8 "Symptômes: le patient se métamorphose progressivement en sale machin d'outre-espace et veut tout détruire.",
  },
  bloaty_head = {
    cause = utf8 "Cause: avoir reniflé du fromage et bu de l'eau de pluie.",
    cure = utf8 "Traitement: la tête est éclatée puis regonflée à la bonne dimension à l'aide d'une astucieuse machine.",
    name = utf8 "Encéphalantiasis",
    symptoms = utf8 "Symptômes: affreux maux de tête.",
  },
  gastric_ejections = {
    cause = utf8 "Cause: nourriture mexicaine ou indienne très épicée.",
    cure = utf8 "Traitement: administration par voie orale d'une solution spéciale pour endiguer les rejets.",
    name = utf8 "Ejections gastriques",
    symptoms = utf8 "Symptômes: le patient rejette par accès des bribes de nourriture mal digérée.",
  },
  uncommon_cold = {
    cause = utf8 "Cause: divers trucmuches volant dans l'air",
    cure = utf8 "Traitement: absorption d'une grande rasade d'un sirop spécial élaboré à la pharmacie.",
    name = utf8 "Catarhume",
    symptoms = utf8 "Symptômes: nez qui coule, éternuements, poumons décolorés.",
  },
  corrugated_ankles = {
    cause = utf8 "Cause: avoir roulé trop vite sur des ralentisseurs.",
    cure = utf8 "Traitement: le patient doit absorber un mélange d'herbes et d'épices légèrement toxique dont l'effet redressera illico les chevilles.",
    name = utf8 "Chevilles ondulées",
    symptoms = utf8 "Symptômes: les chaussures ne s'ajustent plus.",
  },
  sleeping_illness = {
    cause = utf8 "Cause: hypertrophie de la glande palatale de Morphée.",
    cure = utf8 "Traitement: une infermière administre une forte dose d'un puissant stimulant.",
    name = utf8 "Roupillance",
    symptoms = utf8 "Symptômes: tendance irrépressible à tomber de sommeil.",
  },
  sweaty_palms = {
    cause = utf8 "Cause: terreur des entretiens d'embauche.",
    cure = utf8 "Traitement: un psychiatre détend le patient en lui racontant celle du fou qui repeint son plafond.",
    name = utf8 "Mains moites",
    symptoms = utf8 "Symptômes: serrer la main du patient revient à presser une éponge détrempée.",
  },
  serious_radiation = {
    cause = utf8 "Cause: avoir pris du plutonium pour des bonbons.",
    cure = utf8 "Traitement: le patient est passé à la douche de décontamination et consciencieusement récuré.",
    name = utf8 "Radionite",
    symptoms = utf8 "Symptômes: le patient se sent vraiment, vraiment pas bien.",
  },
  diag_cardiogram = {
    name = utf8 "Diag Cardio",
  },
  diag_scanner = {
    name = utf8 "Diag Scanner",
  },
  gut_rot = {
    cause = utf8 "Cause: la Bonne Vieille Bibine de la Mère Sam.",
    cure = utf8 "Traitement: une infermière doit administrer diverses substances chimiques pour tenter de colmater le tout.",
    name = utf8 "Tripurulente",
    symptoms = utf8 "Symptômes: aucun microbe mais plus de paroi intestinale non plus.",
  },
  iron_lungs = {
    cause = utf8 "Cause: pollution atmosphérique combinée aux remugles de kébab.",
    cure = utf8 "Traitement: deux chirurgiens enlèvent le blindage en salle d'opération.",
    name = utf8 "Poumons de fer",
    symptoms = utf8 "Symptômes: envie de respirer du feu et de hurler sous l'eau.",
  },
  broken_wind = {
    cause = utf8 "Cause: utilisation d'un appareil de musculation juste après un repas.",
    cure = utf8 "Traitement: une mixture d'eau lourde est administrée à la pharmacie.",
    name = utf8 "Pétomanie",
    symptoms = utf8 "Symptômes: pollution de l'air des personnes situées derrière le patient.",
  },
  kidney_beans = {
    cause = utf8 "Cause: avoir croqué les glaçons de son cocktail.",
    cure = utf8 "Traitement: deux chirurgiens extraient les cristaux sans endommager le rein.",
    name = utf8 "Cristaux rénaux",
    symptoms = utf8 "Symptômes: douleur et fréquentes visites aux toilettes.",
  },
  transparency = {
    cause = utf8 "Cause: avoir léché le yaourt adhérent au couvercle à l'ouverture d'un pot.",
    cure = utf8 "Traitement: administration d'une potion fraîche et colorée préparée à la pharmacie.",
    name = utf8 "Transparence",
    symptoms = utf8 "Symptômes: la chair est horrible et transparente.",
  },
  broken_heart = {
    cause = utf8 "Cause: avoir croisé quelqu'un de plus riche, plus jeune et plus beau.",
    cure = utf8 "Traitement: deux chirurgiens ouvrent la poitrine et réparent doucement le coeur en retenant leur souffle.",
    name = utf8 "Coeur brisé",
    symptoms = utf8 "Symptômes: pleurnicheries et crampes causées par des heures à regarder de vieilles photos de vacances.",
  },
  slack_tongue = {
    cause = utf8 "Cause: trop de discussion à propos des romans-feuilletons.",
    cure = utf8 "Traitement: la langue est placée dans un taille-langue puis elle est coupée rapidement, efficacement et douloureusement.",
    name = utf8 "Hyperlangue",
    symptoms = utf8 "Symptômes: la langue s'étire jusqu'à cinq fois sa longueur normale.",
  },
  tv_personalities = {
    cause = utf8 "Cause: avoir abusé des programmes télévisés.",
    cure = utf8 "Traitement: un psychiatre doit convaincre le patient d'échanger sa télévision contre une radio.",
    name = utf8 "Téléincarnation",
    symptoms = utf8 "Symptômes: le patient a l'illusion d'être capable de présenter une émission de cuisine.",
  },
  ruptured_nodules = {
    cause = utf8 "Cause: saut à l'élastique par temps froid.",
    cure = utf8 "Traitement: deux chirurgiens doivent réajuster les parties concernées d'une main sûre.",
    name = utf8 "Casse-boules",
    symptoms = utf8 "Symptômes: impossibilité de s'asseoir confortablement.",
  },
  fractured_bones = {
    cause = utf8 "Cause: chute spectaculaire sur du béton.",
    cure = utf8 "Traitement: un plâtre est posé puis ôté à l'aide d'un équipement au laser.",
    name = utf8 "Fractures",
    symptoms = utf8 "Symptômes: affreux craquement et incapacité à utiliser les membres touchés.",
  },
  chronic_nosehair = {
    cause = utf8 "Cause: avoir reniflé avec dédain à la vue de plus malheureux que soi.",
    cure = utf8 "Traitement: une épouvantable potion dépilatoire est administrée par une infermière à la pharmacie.",
    name = utf8 "Poilonisme",
    symptoms = utf8 "Symptômes: poils au nez si drus qu'un oiseau pourrait y nicher.",
  },
}

-- The originals of these strings contain one space too much
trophy_room.sold_drinks.trophies[2] = utf8 "Vous recevez le prix Bubulles du Syndicat des Vendeurs de Limonade pour récompenser la quantité de sodas vendus dans votre hôpital au cours de l'année écoulée. "
fax.epidemic.declare_explanation_fine = utf8 "Si vous déclarez l'épidémie, vous aurez une amende de %d, un changement de réputation et tous les patients seront vaccinés automatiquement."
fax.diagnosis_failed.partial_diagnosis_percentage_name = utf8 "Il y a %d pour cent de chances que la maladie soit %s."
tooltip.status.percentage_cured = utf8 "Vous devez soigner %d%% des visiteurs de l'hôpital. Actuellement, vous en avez soigné %d%%"
tooltip.status.num_cured = utf8 "L'objectif est de soigner %d personnes. Pour le moment, vous en avez soigné %d"
dynamic_info.staff.actions.going_to_repair = utf8 "Pour réparer %s"
adviser.staff_place_advice.only_doctors_in_room = utf8 "Seuls les médecins peuvent travailler en %s"
adviser.staff_place_advice.nurses_cannot_work_in_room = utf8 "Les infermières ne peuvent travailler en %s"
room_descriptions.gp[2] = utf8 "C'est une salle de diagnostic fondamentale pour votre hôpital. Elle accueille les nouveaux patients pour les ausculter. Ils sont ensuite orientés vers une autre salle soit pour une autre diagnostic soit pour être soignés. Vous devriez construire un autre cabinet de médecine générale au cas où celui-ci serait débordé. Plus l'endroit est grand et plus vous pouvez y placer des équipements, sans compter que c'est bon pour le prestige du médecin. C'est valable pour toutes les salles, en fait."
room_descriptions.pharmacy[2] = utf8 "Les patients dont le mal a été diagnostiqué et dont le traitement est un médicament peuvent se rendre à la pharmacie. Comme la recherche découvre toujours de nouveaux traitements, l'activité de cette salle est en constante évolution. Vous aurez à construire une autre pharmacie plus tard."
room_descriptions.general_diag[3] = utf8 "La salle de diagnostic nécessite un médecin. Il faut également un agent de maintenance pour un entretien périodique. "
pay_rise.definite_quit = utf8 "Rien ne me fera rester ici. J'en ai assez."
place_objects_window.confirm_or_buy_objects = utf8 "Vous pouvez valider ainsi ou bien soit acheter soit déplacer des objets."

-- The demo does not contain this string
menu_file.restart = utf8 "  RELANCER  "

----------------------------------------------------------- New strings -----------------------------------------------------------

-- Objects
object.litter = utf8 "Déchet"
tooltip.objects.litter = utf8 "Déchet : Laissé sur le sol par un patient car il n'a pas trouvé de poubelle où le jeter."

-- Adviser
adviser.room_forbidden_non_reachable_parts = utf8 "Placer la pièce à cet endroit va empêcher des parties de l'hôpital d'être atteintes."

-- Dynamic information
dynamic_info.patient.actions.no_gp_available = utf8 "Attente d'un cabinet de médecine générale"
dynamic_info.staff.actions.heading_for = utf8 "Va vers %s"

-- Misc
misc.not_yet_implemented = utf8 "(pas encore implémenté)"
misc.no_heliport = utf8 "Aucune maladie n'a été découverte pour l'instant, ou il n'y a pas d'héliport sur cette carte."

-- Options menu
menu_options = {
  lock_windows = utf8 "  FIGER LES FENETRES  ",
  edge_scrolling = utf8 "  DEFILEMENT PAR BORD  ",
  settings = utf8 "  PARAMETRES  ",
}
menu_options_game_speed.pause = utf8 "  PAUSE  "

-- Debug menu
menu_debug = {
  transparent_walls           = utf8 "  MURS TRANSPARENTS  ",
  limit_camera                = utf8 "  LIMITER LA CAMERA  ",
  disable_salary_raise        = utf8 "  DESACTIVER LES AUGMENTATIONS DE SALAIRE  ",
  make_debug_patient          = utf8 "  CREER UN PATIENT DE TEST  ",
  spawn_patient               = utf8 "  FAIRE ARRIVER DES PATIENTS  ",
  make_adviser_talk           = utf8 "  FAIRE PARLER LE CONSEILLER  ",
  show_watch                  = utf8 "  AFFICHER LE COMPTE A REBOUR  ",
  create_emergency            = utf8 "  CREER UNE URGENCE  ",
  place_objects               = utf8 "  PLACER DES OBJETS  ",
  dump_strings                = utf8 "  EXTRAIRE LES TEXTES  ",
  dump_gamelog                = utf8 "  EXTRAIRE LE JOURNAL DE JEU  ",
  map_overlay                 = utf8 "  INCRUSTATIONS DE CARTE  ",
  sprite_viewer               = utf8 "  VISIONNEUSE DE SPRITES  ",
}
menu_debug_overlay = {
  none                        = utf8 "  AUCUN  ",
  flags                       = utf8 "  DRAPEAUX  ",
  positions                   = utf8 "  POSITIONS  ",
  heat                        = utf8 "  TEMPERATURE  ",
  byte_0_1                    = utf8 "  OCTETS 0 & 1  ",
  byte_floor                  = utf8 "  OCTET SOL  ",
  byte_n_wall                 = utf8 "  OCTET MUR N  ",
  byte_w_wall                 = utf8 "  OCTET MUR O  ",
  byte_5                      = utf8 "  OCTET 5  ",
  byte_6                      = utf8 "  OCTET 6  ",
  byte_7                      = utf8 "  OCTET 7  ",
  parcel                      = utf8 "  PARCELLE  ",
}

-- Main menu
main_menu = {
  new_game = utf8 "Nouvelle Partie",
  custom_level = utf8 "Niveau personnalisé",
  load_game = utf8 "Charger une Partie",
  options = utf8 "Options",
  exit = utf8 "Quitter",
}

tooltip.main_menu = {
  new_game = utf8 "Commencer une partie totalement nouvelle",
  custom_level = utf8 "Construire votre hôpital dans un niveau personnalisé",
  load_game = utf8 "Charger une partie sauvegardée",
  options = utf8 "Modifier quelques paramètres",
  exit = utf8 "Non, non, SVP, ne quittez pas !",
}

-- Load game window
load_game_window = {
  caption = utf8 "Charger une partie",
}

tooltip.load_game_window = {
  load_game = utf8 "Charger la partie %s",
  load_game_number = utf8 "Charger la partie %d",
  load_autosave = utf8 "Charger la sauvegarde automatique",
}

-- Custom game window
custom_game_window = {
  caption = utf8 "Niveau personnalisé",
}

tooltip.custom_game_window = {
  start_game_with_name = utf8 "Charger le niveau %s",
}

-- Save game window
save_game_window = {
  caption = utf8 "Enregistrer la partie",
  new_save_game = utf8 "Nouvelle sauvegarde",
}

tooltip.save_game_window = {
  save_game = utf8 "Écraser la sauvegarde %s",
  new_save_game = utf8 "Entrez un nom pour la sauvegarde",
}

-- Menu list window
menu_list_window = {
  back = utf8 "Précédent",
}

tooltip.menu_list_window = {
  back = utf8 "Fermer cette fenêtre",
}

-- Options window
options_window = {
  fullscreen = utf8 "Plein écran",
  width = utf8 "Largeur",
  height = utf8 "Hauteur",
  change_resolution = utf8 "Changer la résolution",
  back = utf8 "Précédent",
}

tooltip.options_window = {
  fullscreen_button = utf8 "Basculer en mode plein écran/fenêtré",
  width = utf8 "Entrez la largeur désirée",
  height = utf8 "Entrez la hauteur désirée",
  change_resolution = utf8 "Changer la résolution pour les dimensions entrées à gauche",
  language = utf8 "Utiliser la langue %s",
  back = utf8 "Fermer la fenêtre des options",
}

-- "Tip of the day" window
totd_window = {
  tips = {
    utf8 "Chaque hôpital a besoin d'un bureau de réception et d'un cabinet de médecine générale. Après, tout dépend du type de patients qui visitent votre hôpital. Une pharmacie est toujours un bon choix malgré tout.",
    utf8 "Les machines telles que le Gonflage ont besoin de maintenance. Embauchez un ou deux agents de maintenance pour réparer vos machines, ou vous risquerez d'avoir des blessés parmi le personnel ou les patients.",
    utf8 "Après un certain temps, vos employés seront fatigués. Pensez à construire une salle de repos où ils pourront se détendre.",
    utf8 "Placez suffisamment de radiateurs pour garder vos employés et patients au chaud, ou ils deviendront mécontents. Utilisez la carte de la  ville pour localiser les endroits de votre hôpital qui nécessitent plus de chauffage.",
    utf8 "Le niveau de compétence d'un docteur influence beaucoup la qualité et la rapidité de ses diagnostics. Utilisez un médecin expérimenté comme généraliste et vous n'aurez plus besoin d'autant de salles de diagnostics.",
    utf8 "Les internes et les médecins peuvent augmenter leurs compétences auprès d'un consultant dans la salle de formation. Si le consultant a des qualifications pariculières (chirurgien, psyschiatre ou chercheur), il transférera ses connaissances à ses élèves.",
    utf8 "Avez-vous essayé d'entrer le numéro d'urgence Européen (112) dans le fax ? Vérifiez que vous avez du son !",
    utf8 "Vous pouvez ajuster certains paramètres tels que la résolution et la langue dans la fenêtre d'options accessible à la fois depuis le menu principal et pendant le jeu.",
    utf8 "Vous avez choisi une autre langue que l'anglais, mais il y du texte en anglais partout ? Aidez-nous à traduire les textes manquants dans votre langue !",
    utf8 "L'équipe de CorsixTH cherche du renfort ! Vous êtes intéressé par coder, traduire ou faire des graphismes pour CorsixTH ? Contactez-nous sur notre Forum, Liste de Diffusion ou Canal IRC (corsix-th sur freenode).",
    utf8 "Si vous avez trouvé un bug, SVP, reportez le sur notre gestionnaire de bugs : th-issues.corsix.org.",
    utf8 "Vous utilisez actuellement la troisième version beta de CorsixTH, publiée le 24 juin 2010.",
    utf8 "Chaque niveau possède des objectifs qu'il vous faudra remplir pour pouvoir passer au suivant. Vérifiez la fenêtre de status pour voir votre progression dans les objectifs du niveau.",
    utf8 "Si vous voulez éditer ou détruire une pièce, vous pouvez le faire avec le bouton d'édition situé sur la barre d'outil en bas.",
    utf8 "Dans un groupe de patients en attente, vous pouvez rapidement découvrir lesquels attendent une pièce particulière en survolant cette pièce avec votre curseur de souris.",
    utf8 "Cliquez sur la porte d'une pièce pour visualiser sa file d'attente. Vous pouvez faire des réglages très utilies ici, comme réorganiser la file d'attente ou envoyer un patient vers une autre pièce.",
    utf8 "Le personnel mécontent vous demandra des augmentations de salaires fréquemment. Assurez vous de leur offir un environnement de travail confortable pour éviter cela.",
    utf8 "Les patients auront soif en attendant dans votre hôpital, encore plus si vous augmentez le chauffage ! Placez des distributeurs automatiques dans les points stratégiques pour un revenu d'appoint.",
    utf8 "Vous pouvez interrompre le processus de diagnostic d'un patient et proposer un traitement, si vous avez déjà rencontré la maladie. Notez que cela peut accroître le risque d'erreur de traitement, et provoquer la mort du patient.",
    utf8 "Les urgences peuvent être une bonne source de revenus additionnels, à condition que vous ayez les capacités suffisantes pour traiter les patients à temps.",
  },
  previous = utf8 "Astuce précédente",
  next = utf8 "Astuce suivante",
}

tooltip.totd_window = {
  previous = utf8 "Affiche l'astuce précédente",
  next = utf8 "Affiche l'astuce suivante",
}

-- Confirmation dialog
confirmation = {
  needs_restart = utf8 "Changer ce paramètre requiert un redémarrage de CorsixTH. Tout progrès non sauvegardé sera perdu. Êtes-vous sûr de vouloir faire cela ?"
}

-- Information dialog
information = {
  custom_game = utf8 "Bienvenue dans CorsixTH. Amusez-vous bien avec cette carte personnalisée !",
  cannot_restart = utf8 "Malheureusement cette partie personnalisée a été sauvegardée avant que la fonctionnalité de redémarrage soit implémentée.",
}

tooltip.information = {
  close = utf8 "Fermer cette boîte de dialogue.",
}

-- Fax messages
fax = {
  welcome = {
    beta1 = {
      "Bienvenue dans CorsixTH, un clone open source du jeu classique Theme Hospital par Bullfrog !",
      utf8 "Ceci est la beta 1 jouable de CorsixTH. Beaucoup de salles, maladies et fonctionnalités ont été implémentées, mais beaucoup de choses manquent",
      utf8 "Si vous aimez ce projet, vous pouvez nous aider, par ex. en rapportant des bogues ou en codant quelque-chose par vous-même.",
      utf8 "Mais maintenant, amusez-vous ! Pour ceux qui ne sont pas familier avec Theme Hospital : Commencez par construire un bureau de réception (menu objets) et un bureau de généraliste (salle de diagnostic). Des salles de traitement seront aussi nécessaires.",
      utf8 "-- L'équipe de CorsixTH, th.corsix.org",
      utf8 "PS : Trouverez-vous les surprises cachées ?",
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
    utf8 "Souhaitez-vous un petit tutoriel ?",
    utf8 "Oui, montrez-moi les bases SVP.",
    utf8 "Non, je sais déjà comment faire.",
  },
  choices = {
    return_to_main_menu = utf8 "Retourner au menu principal",
    accept_new_level = utf8 "Aller au niveau suivant",
    decline_new_level = utf8 "Continuer la partie encore un peu",
  },
}


-- Winning texts
letter = {
  dear_player = utf8 "Cher %s",
  custom_level_completed = utf8 "Félicitations ! Vous avez réussi tous les objectifs de ce niveau personnalisé !",
  return_to_main_menu = utf8 "Voulez-vous retourner au menu principal ou continuer la partie ?",
  level_lost = utf8 "Quelle poisse ! Vous avez raté le niveau. Vous ferez mieux la prochaine fois !",
}

-- Installation
install = {
  title = utf8 "----------------------------- Installation de CorsixTH -----------------------------",
  th_directory = utf8 "CorsixTH nécessite une copie des données du jeu Theme Hospital original (ou la démo) pour fontionner. Veuillez utiliser le sélecteur ci-dessous pour indiquer le dossier d'installation de Theme Hospital.",
}

-- Errors
errors = {
  dialog_missing_graphics = utf8 "Désolé, les données de démo ne contiennent pas cette boîte de dialogue.",
  save_prefix = utf8 "Erreur lors de la sauvegarde de la partie : ",
  load_prefix = utf8 "Erreur lors du chargement de la partie : ",
  map_file_missing = utf8 "Impossible de trouver le fichier de carte %s pour ce niveau !",
  minimum_screen_size = utf8 "Veuillez entrer une résolution d'au moins 640x480.",
}
