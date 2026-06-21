# AeroFresco

AeroFresco is a touchless digital art studio that lets you paint in the air using your hands. The project won the 2026 Swift Student Challenge by rethinking how we interact with screens and turning physical space into a responsive canvas.

By combining computer vision with native graphics rendering the app tracks your finger joints in real time and translates your movements directly into digital ink without ever touching the screen.

## Why I Built It This Way

The core philosophy behind AeroFresco was to push the boundaries of spatial computing using raw math and native tools rather than relying on third party game engines or messy workarounds.

Instead of creating a custom drawing engine from scratch, which often introduces rendering lag and unpolished paths, we chose to fuse Apple's Vision framework directly with PencilKit. This architecture gives us a massive advantage. Vision handles the complex machine learning pipelines on background threads while PencilKit provides beautiful and ultra smooth vector ink paths that scale flawlessly to any screen window.

A critical engineering challenge was dealing with the natural micro jitter of the human hand and the noise of a standard camera feed. We implemented custom mathematical smoothing filters to stabilize the tracking coordinates to ensure that drawing feels deliberate and natural rather than shaky.

Additionally because the app requires constant camera access privacy had to be a foundational constraint rather than an afterthought. The entire pipeline runs entirely on device. Camera frames are processed frame by frame in live memory to extract joint coordinates and are immediately discarded. No video data is ever written to disk, saved or sent over a network.

## How the Gestures Work

The tracking engine uses an intuitive gesture vocabulary designed to mimic real world drawing and tool selection without needing a physical keyboard or mouse.

### Drawing Lines

* Thin Brush: Point your index finger straight forward while keeping your other fingers curled. This activates a precise standard width pen for sketching and fine details.
* Bold Brush: Extend both your index and middle fingers together. The engine detects the secondary finger and automatically scales up the stroke width for thick expressive lines.

### Managing the Canvas

* Pause Ink: Extend your thumb upward and outward to form a pistol shape. This acts as a physical clutch to instantly cut off the ink flow. It allows you to move your hand freely through the air to reposition your starting point without leaving accidental lines across your artwork.
* Cycling Colors: While holding the Pause Ink gesture pinch your thumb and index finger together. Each distinct pinch tells the app to jump to the next color in your active palette making it easy to swap colors on the fly without looking away from your canvas.

## Shared Creativity

The underlying logic is completely decoupled from a single user mindset. The app tracks multiple hands simultaneously allowing for two distinct workflows.

* Symmetrical Mode: You can use both hands at the same time to manipulate multiple vectors and create complex geometric art.
* Cooperative Mode: You can stand side by side with a friend inside the camera frame to collaborate and paint together on the exact same canvas in real time.

## Technical Breakdown

* Frameworks: Vision, PencilKit, SwiftUI and Observation
* Target Platforms: Optimized natively for macOS via Mac Catalyst and iPadOS
* Processing: Local core tracking via CoreML and Vision with multi threaded queue handoff

Designed and developed by Elizbar Kheladze.
# AeroFresco

AeroFresco is a touchless digital art studio that lets you paint in the air using your hands. The project won the 2026 Swift Student Challenge by rethinking how we interact with screens and turning physical space into a responsive canvas.

By combining computer vision with native graphics rendering the app tracks your finger joints in real time and translates your movements directly into digital ink without ever touching the screen.

## Why I Built It This Way

The core philosophy behind AeroFresco was to push the boundaries of spatial computing using raw math and native tools rather than relying on third party game engines or messy workarounds.

Instead of creating a custom drawing engine from scratch, which often introduces rendering lag and unpolished paths, we chose to fuse Apple's Vision framework directly with PencilKit. This architecture gives us a massive advantage. Vision handles the complex machine learning pipelines on background threads while PencilKit provides beautiful and ultra smooth vector ink paths that scale flawlessly to any screen window.

A critical engineering challenge was dealing with the natural micro jitter of the human hand and the noise of a standard camera feed. We implemented custom mathematical smoothing filters to stabilize the tracking coordinates to ensure that drawing feels deliberate and natural rather than shaky.

Additionally because the app requires constant camera access privacy had to be a foundational constraint rather than an afterthought. The entire pipeline runs entirely on device. Camera frames are processed frame by frame in live memory to extract joint coordinates and are immediately discarded. No video data is ever written to disk, saved or sent over a network.

## How the Gestures Work

The tracking engine uses an intuitive gesture vocabulary designed to mimic real world drawing and tool selection without needing a physical keyboard or mouse.

### Drawing Lines

* Thin Brush: Point your index finger straight forward while keeping your other fingers curled. This activates a precise standard width pen for sketching and fine details.
* Bold Brush: Extend both your index and middle fingers together. The engine detects the secondary finger and automatically scales up the stroke width for thick expressive lines.

### Managing the Canvas

* Pause Ink: Extend your thumb upward and outward to form a pistol shape. This acts as a physical clutch to instantly cut off the ink flow. It allows you to move your hand freely through the air to reposition your starting point without leaving accidental lines across your artwork.
* Cycling Colors: While holding the Pause Ink gesture pinch your thumb and index finger together. Each distinct pinch tells the app to jump to the next color in your active palette making it easy to swap colors on the fly without looking away from your canvas.

## Shared Creativity

The underlying logic is completely decoupled from a single user mindset. The app tracks multiple hands simultaneously allowing for two distinct workflows.

* Symmetrical Mode: You can use both hands at the same time to manipulate multiple vectors and create complex geometric art.
* Cooperative Mode: You can stand side by side with a friend inside the camera frame to collaborate and paint together on the exact same canvas in real time.

## Technical Breakdown

* Frameworks: Vision, PencilKit, SwiftUI and Observation
* Target Platforms: Optimized natively for macOS via Mac Catalyst and iPadOS
* Processing: Local core tracking via CoreML and Vision with multi threaded queue handoff

Designed and developed by Elizbar Kheladze.
