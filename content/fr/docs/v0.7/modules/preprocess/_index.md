---
title: "Preprocess"
description: "Documentation détaillée du module Preprocess d'ALS"
author: "ALS Team"
lastmod: 2024-12-30T08:47:09Z
keywords: [ "ALS preprocess" ]
draft: false
type: "docs"
categories: [ "guide utilisateur" ]
tags: [ "module", "Preprocess" ]
weight: 352
---

# Présentation

Le module **Preprocess** prend en charge les traitements de **calibration** de brutes

# Configuration

Le module **Preprocess** lui-même n'a besoin d'aucune configuration.

La configuration des traitements de **calibration** est gérée par les **traitements** eux-mêmes.
Voir section [Comportement](#behavior) ci-dessous.

# Contrôle

Le module **Preprocess** est lancé au démarrage d'ALS et **ne subit plus aucune influence extérieure** à part l'arrivée
des images dans sa file d'attente.

# Entrée

| Type  | Description                      |
|-------|----------------------------------|
| Image | brute présente en file d'attente |

# Comportement {#behavior}

Applique les traitements de **calibration** à la brute :

1. [Suppression des pixels chauds](hot_remove/)
2. [Soustraction de dark](dark_remove/)
3. [Dématriçage](debayer/)

# Sortie

La brute calibrée est transmise au module **Stack** 