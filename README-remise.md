# README de Manolo
## Table des matières
1. [Instruction d'installation](#instruction-dinstallation)
   1. [Récupérer le projet CorsixTH](#récupérer-le-projet-corsixth)
   2. [Configuration de la compilation](#configuration-de-la-compilation)
4. [Instruction d'utilisation](#instruction-dutilisation)
5. [Description des issues](#description-des-issues)
6. [Reference](#reference)
   1. [Installer Git pour Powershell](#installer-git-pour-powershell)
## Instruction d'installation
### Récupérer le projet CorsixTH
1. Se connecter sur [GitHub](https://github.com/) ou vous créer un compte
---
2. Aller chercher la page du jeu [CorsixTH](https://github.com/CorsixTH/CorsixTH)
---
3. Cliquer sur le bouton ```Code```![img_1.png](img_1.png)
---
4. Cliquer sur les petits carrés pour enregistrer le lien du projet ![img_2.png](img_2.png)
---
5. Ouvrir un dossier peu importe l'emplacement et écrire dans la barre de recherche ceci ![img_3.png](img_3.png)
---
6. Écrire dans le terminal ouvert ```git clone "adresse coller"```, ce qui devrait ressembler à ceci : ![img_4.png](img_4.png)
- PS: Pour coller ce que vous aviez copier tout à l'heure, appuyer sur le bouton ```CTRL + V``` pour coller dans le terminal.
- En cas de complication avec la commande git, veuillez-vous référer à ceci : [Git installation](#installer-git-pour-powershell)
---
7. C'est tout, normalement si tout est bon vous devriez avoir ce dossier ![img_6.png](img_6.png)

### Configuration de la compilation
1. Ouvrir le dossier où est cloner le projet dans un terminal en mode administrateur
---
2. Copier coller cette ligne dans le terminal pour installer le compilateur VCPKG ```git clone https://github.com/microsoft/vcpkg.git```
---
3. Après installation terminé, exécuter ces commandes dans l'ordre de présentation
- ```cd C:\[dossier contenant le projet]\CorsixTH```
- ```set VCPKG_ROOT=C:\dev\vcpkg```
- ```cmake --preset win-dev```
- ```cd build\dev```
- ```cmake --build . --config RelWithDebInfo```
---
4. Par la suite, trouver le chemin menant à ```corsix-th.exe``` ou l'executeur du jeu et copier son chemin. Nous en aurons besoin plus tard.
---
5. Dans votre IDEA de programmation, aller ajouter une configuration ![img_7.png](img_7.png)
---
6. Selectionner ```Native Executable``` ![img_8.png](img_8.png)
---
7. Remplissez les champs en rouge tel que présentés sur l'image ![img_9.png](img_9.png)
- ```Name:``` -> Mettre le nom que vous voulez
- ```Exe path:``` -> sera le chemin que nous avons copier tout à l'heure du ```.exe```
- ````Working directory:```` -> Devrait être détecter automatiquement, sinon aller copier le chemin. Normalement ce dossier se trouve dans ```[votredossier]/CorsixTH/build/dev/CorsixTH/RelWithDebInfo```
- Puis, cliquer sur ```Ok```
---
8. Normalement, lorsque vous lancerez votre configuration, le jeu devrait se lancer sans problème
## Instruction d'utilisation

## Description des issues

## Reference
### Installer Git pour Powershell
Suivre ce [Tutoriel](https://www.youtube.com/watch?v=ne5ACsz-k2o) pour l'installation