# TravelMate transparent logo

The active artwork is the user-supplied orange airplane/T and black M from `korena (12).png`. The original PNG already contained true alpha transparency. It was cropped to its visible artwork and resized for delivery; its lettering and colors were preserved. No generative redraw or background removal was used for this version.

The matching wordmark comes from the user-supplied `korena (14).png`, also already transparent. It replaces the plain brand text while retaining accessible TravelMate labels.

## Active files

- Transparent master: `app/public/branding/travelmate-logo-transparent.png` (1200×805).
- Wordmark: `app/public/branding/travelmate-wordmark-transparent.png` (1600×170).
- Favicon: `app/public/icons/travelmate-orange-64.png`.
- App icons: `app/public/icons/travelmate-orange-192.png` and `travelmate-orange-512.png`.
- The navigation/sidebar, login brand, footer and installation page use the transparent wordmark alongside the icon, with no navy CSS backing.
- The offline guide embeds the transparent mark so it can display without a network request.
- Manifest identity remains `/`. The current icons use purpose `any`; the old opaque maskable icon is no longer selected.

The transparent areas were checked in the delivered PNGs, including preservation of the opaque black M and orange airplane/T. Browser/Android launchers can apply their own backgrounds to app icons; the website and delivered PNG files themselves have no background.

Older SVG traces and navy icon files remain as unreferenced historical assets. Active UI and manifest references point to the transparent orange-and-black files.
