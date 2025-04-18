---
title: "Save"
description: "Detailed documentation of the ALS Save module"
author: "ALS Team"
lastmod: 2025-01-05T13:36:11Z
keywords: ["ALS image Saver"]
draft: false
type: "docs"
categories: ["detailed documentations"]
tags: ["module", "output", "web folder", "work folder", "save"]
weight: 362
---

# Overview

The **Save** module handles the saving on disk of all images generated by ALS.

Its configuration is managed via ALS preferences

# Configuration

|             | Source                                                                | Data type                              | Required | Default value |
|-------------|-----------------------------------------------------------------------|----------------------------------------|----------|---------------|
| work folder | Prefs: [Output Tab](../../userguide/preferences/output/#work-folder)  | path to a folder                       | Yes      | ∅             |
| web folder  | Prefs: [Output Tab](../../userguide/preferences/output/#web-folder)   | path to a folder                       | Yes      | = work folder |
| file format | Prefs: [Output Tab](../../userguide/preferences/output/#format)       | choices:<br>- TIFF<br>- PNG<br>- JPEG  | Yes      | JPEG          |

# Control

The **Save** module is launched in the background at ALS startup

# Input

| Data                | Type  |
|---------------------|-------|
| image at queue head | Image |

# Behavior

Save both outputs to disk:

| Output Type | File Name                              | File Location | File Format         |
|-------------|----------------------------------------|---------------|---------------------|
| Main        | stack_image (+ timestamp if requested) | work folder   | As configured       |
| Server      | web_image                              | web folder    | JPEG                |

# Output

Image files saved to disk