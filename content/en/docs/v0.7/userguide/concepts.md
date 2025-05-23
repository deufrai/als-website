---
title: "Concepts"
description: "The basic concepts of ALS"
author: "ALS Team"

lastmod: 2025-04-21T21:20:55Z
keywords: [ "ALS concepts" ]
draft: false
type: "docs"
categories: [ "beginner's guide" ]
tags: [ "module", "stack", "process", "session","output", "scan folder", "work folder", "web folder", "server", "scanner", "save", "calibration", "profile" ]
weight: 315
---

# Introduction

By the end of this chapter, the basic concepts of ALS will be familiar to you.

You will understand what ALS does and how it does it.

# Stacking {#stacking}

Stacking is the process of combining multiple subs of the same target to generate a more detailed and contrasted image than a single sub.

The quality of the result increases as more subs are used.

{{< center >}}
{{< figure
src="/images/stacking.png"
width="1203px" height="456px"
caption="Comparison of 8 stacking results<br>The number of stacked subs is indicated at the top left of each image"
alt="A sequence of eight nebula images, each labeled with the number of subs used: 1, 2, 4, 8 (top row) and 128, 64, 32, 16 (bottom row). The image improves as subs increase." >}}
{{< /center >}}

# The stack {#stack}

The **stack** is the set of subs on which ALS performs real-time stacking (livestacking).

# Livestacking with ALS

ALS monitors the destination folder of your image acquisition system.

When a new sub is detected, it is added to the **stack** and a new stacking result is generated.

# ALS modules {#modules}

ALS is architected into autonomous modules, divided into two families:

- **Main modules**

  Responsible for image processing:
    - **Preprocess**: Calibration
    - **Stacker**: Alignment and stacking
    - **Process**: Visual processing
    - **Save**: Disk saving

- **Utility modules**

  Responsible for auxiliary tasks:
    - **Scanner**: Monitoring the **scan folder**
    - **Server**: Sharing images over the network

## Image path {#image-path}

Images pass through ALS, module after module, from the scan folder, up to display and disk saving.

```mermaid
graph LR

    SCANNER(Scanner)
    PREPROCESS(Preprocess)
    STACKER(Stacker)
    PROCESS(Process)
    SAVE(Save)
    SCAN_FOLDER@{ shape: lin-cyl, label: "Scan Folder" }
    WORK_FOLDER@{ shape: lin-cyl, label: "Work Folder" }
    WEB_FOLDER@{ shape: lin-cyl, label: "Web Folder" }
    SERVER(Server) 
    GUI@{ shape: curv-trap, label: "Interface" }

    SCAN_FOLDER -.-> SCANNER
    SCANNER -.-> PREPROCESS
    PREPROCESS -.-> STACKER
    STACKER ---> PROCESS
    PROCESS --> SAVE
    SAVE --> WORK_FOLDER
    SAVE --> WEB_FOLDER
    WEB_FOLDER ---> SERVER
    PROCESS ---> GUI

    style SCANNER fill:#333,stroke:darkred,stroke-width:2px
    style PREPROCESS fill:#333,stroke:darkred,stroke-width:4px,color:#c6c6c6,font-family:'Poppins',sans-serif
    style STACKER fill:#333,stroke:darkred,stroke-width:4px,color:#c6c6c6,font-family:'Poppins',sans-serif
    style PROCESS fill:#333,stroke:darkred,stroke-width:4px,color:#c6c6c6,font-family:'Poppins',sans-serif
    style SAVE fill:#333,stroke:darkred,stroke-width:4px,color:#c6c6c6,font-family:'Poppins',sans-serif

    classDef module fill:#333,stroke:darkred,stroke-width:2px
    classDef main_module fill:#333,stroke:darkred,stroke-width:4px,color:#c6c6c6,font-family:'Poppins',sans-serif
    classDef folder fill:#555,stroke:#970,stroke-width:2px,color:#c6c6c6,font-family:'Poppins',sans-serif
    classDef display fill:#555,stroke:#222,stroke-width:2px,color:#c6c6c6,font-family:'Poppins',sans-serif
    
    class SCANNER module
    class SERVER module
    
    class PREPROCESS main_module
    class STACKER main_module
    class PROCESS main_module
    class SAVE main_module
    
    class SCAN_FOLDER folder
    class WORK_FOLDER folder
    class WEB_FOLDER folder
    
    class GUI display
```

<p class="figcaption">Image path in ALS</p>

- Your subs transit from the scan folder to the **Stacker** module.
- Images generated by ALS transit from the **Stacker** module to the outputs.

## Main Modules

These modules group and order image processing tasks.

Each module has its own queue and continuously performs the following actions:

1. Waits for a new image to appear in the queue.
2. Processes the image.
3. Provides the processing result to the application.

In case of an error during image processing:

1. The image processing is aborted
2. The disposal of the image is signaled to the application.
3. The module resumes listening to its queue.

### Preprocess {#preprocess-module}

{{% alert color="info" %}}
ℹ️ As soon as a new sub is detected by the **Scanner**, it is loaded and added to this module's queue.
{{% /alert %}}

The **preprocess** module groups the following **calibration** processes:

1. **Hot pixel removal**

   Replaces the value of hot pixels with the average value of neighboring pixels.

2. **Dark subtraction**

   Uses a master dark provided by you to subtract thermal noise from the image.

3. **Debayering**

   **Color** images in **FITS** or **Raw** format are converted to RGB color using the Bayer pattern described in the file headers.

You can find more information about the **Preprocess** module in its [detailed documentation](../../reference/modules/preprocess/).

### Stacker {#stack-module}

The **Stacker** module maintains the **stack** and processes each calibrated sub:

1. **Alignment**: 

   Aligns the sub to the session reference.

2. **Stacking**:
    - Adds the sub to the current stack.
    - Generates the stacking result based on the mode chosen by the user (_mean or sum_)

{{% alert color="info" %}}
ℹ️ Alignment is based on the search for star groups in the compared images. ALS can only align deep sky images. **Planet or Moon images cannot be aligned**.
{{% /alert %}}

You can find more information about the **Stacker** module in its [detailed documentation](../../reference/modules/stack/).

### Process {#process-module}

The **Process** module groups the visual processing applied to the stacking results:

1. **Auto stretch**

   Automatically adjusts the image levels for optimal viewing.

2. **Levels**

   Allows adjusting the black and white clipping, and the mid-tone level.

3. **RGB balance**

   Allows adjusting the color balance.

{{% alert color="info" %}}
ℹ️ The image displayed in ALS's **central area** is replaced by each image output from the **Process** module.
{{% /alert %}}

### Save {#save-module}

The **Save** module is in charge of saving to disk every processing result

The **Save** module saves images in two target folders:
- The **work folder** for storing processing results
- The **web folder** for sharing on the network via the **Server** module.

Each processing result is saved in 2 files:

1. Main output:
    - **Location**: work folder.
    - **Name**: stack_image (+ timestamp if requested).
    - **Format**: As defined in [Preferences](../preferences/output/#format). ℹ️ Default: JPEG.

2. Server output:
    - **Location**: web folder.
    - **Name**: web_image.
    - **Format**: JPEG.

{{% alert color="warning" %}}
⚠️ These 2 files are overwritten by every successive processing result.
{{% /alert %}}

{{% alert color="info" %}}
ℹ️ By default, the path of the **web folder** is the same as that of the **work folder**.

You can define a dedicated **web folder** in the [Preferences](../preferences/output/#web-folder).
{{% /alert %}}

You can find more information about the **Save** module in its [detailed documentation](../../reference/modules/save/).

## Utility Modules

ALS uses other modules that are not involved in image processing. However, they are essential for the proper functioning of the application:

### Scanner

This module is responsible for detecting new subs in the **scan folder** and transmitting them to the **Preprocess** module.

You can find more information about the **Scanner** module in its [detailed documentation](../../reference/modules/scanner/).

### Server

This module handles sharing the **server output** of the **Save** module over the network.

It is accessible from the network to which the machine running ALS is connected.

The served web page allows you to view the latest processing result and navigate it as in the graphical interface.

Everytime a new processing result is done, the image displayed on the web page is automatically updated.

{{% alert color="info" %}}
ℹ️ When the server is started, its address is displayed in the application and a QR code can be displayed on demand.
{{% /alert %}}

---

# The session {#session}

A **session** can be seen as the lifecycle of the pair formed by the **stack** and the **Scanner**.

1. **Session start**:
    - ALS clears the **stack** and starts the **Scanner**.

2. **Progress**:
    - Subs are loaded and flow through the application.
    - The first sub received by the **Stacker** module will serve as **alignment reference** throughout the session.
    - The session can be **paused**: ALS stops the **Scanner** and retains the **stack**.

      Resuming the session starts the **Scanner**. The next subs will be added to the current **stack**.

   At any time, the user can navigate the displayed image, zoom, adjust processing parameters...

3. **Session end**:
    - the **Scanner** is stopped.
    - the **Stacker** module will clear the **stack** at the next session start.

{{% alert color="info" %}}
ℹ️ ALS does not process images already present in the **scan folder** when a session starts.
{{% /alert %}}

---

# Profiles

ALS Profiles optimize system performance and task priorities to suit different imaging needs.

Two default profiles are available:

- **EAA Profile**: Focuses on real-time imaging workflows.

  - Prioritizes calibration and stacking processes
  - Optimizing scanner responsiveness and alignment speed. 

- **Astrophoto Profile**: Designed for producing high-quality outputs.

  - Prioritizes image processing
  - Optimizes large files handling and alignment quality

The active profile is displayed in the **status bar**, so you can always see which configuration is in use.

# Conclusion

You now have a clear understanding of the architecture and basic concepts of ALS.

Next step: the progress of an ALS session