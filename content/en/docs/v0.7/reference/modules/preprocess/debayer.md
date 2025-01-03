---
title: "Debayering"
description: "Detailed documentation of the ALS Debayer process"
author: "ALS Team"
lastmod: 2024-12-31T21:07:16Z
keywords: [ "ALS debayer", "ALS debayering" ]
draft: false
type: "docs"
categories: [ "detailed documentations" ]
tags: [ "process", "debayer", "calibration" ]
weight: 355
---

# Overview

The **Debayer** process is used on **color** images in **FITS** or **Raw** format.

It generates a color image from the raw image and the description of the Bayer pattern installed on the sensor that
generated the image.

Its configuration is managed via ALS preferences page.

# Configuration

| Source                                                                  | Parameter     | Data Type | Required | Default Value |
|-------------------------------------------------------------------------|---------------|-----------|----------|---------------|
| [Preferences: Processing Tab](../../../userguide/preferences/processing/#debayer) | Bayer pattern | choice: <br>- AUTO<br>- GRBG<br>- RGGB<br>- GBRG<br>- BGGR | YES      | AUTO          |


# Control

This process is triggered by the **Preprocess** module.

# Input

| Type  | Description                                   |
|-------|-----------------------------------------------|
| Image | image received from the **Preprocess** module |

# Behavior

The raw image is converted to a color image using the configured Bayer pattern.

# Output

The modified image is sent back to the **Preprocess** module.