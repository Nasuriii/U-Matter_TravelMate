# Project archive

Old files have been moved here without deleting their contents.

| Folder | Contents |
| --- | --- |
| `notes/` | Former root Markdown notes, delivery logs, setup text, and test text |
| `docs/` | The previous documentation folder |
| `legacy-packages/` | Old ZIP deliveries and their unpacked files |
| `legacy-source/app-src-copy/` | The duplicate `app/src - Copy` source backup |

These documents describe earlier deliveries. Their references to `app/` and `database/` refer to the repository root, and their old verification statements are historical.

## Current working folders

- [app](../app/): the active React/Vite application, its tests, and public assets.
- [database](../database/): database migrations and recovery scripts.
- [design-assets](../design-assets/): existing graphics and design checks.
- `Images/`, `SupaBase/`, and `Xampp/`: existing project resources and backend files.
- [run-app.bat](../run-app.bat): the existing Windows launcher.

Run `npm run dev` or `npm run build` from `app/`. Keep `.env.local`, dependencies, build output, and local QA helpers out of commits.

Asset `LICENSE.txt` and `SOURCES.md` files stay beside their assets. Runtime files such as `robots.txt` stay where the application expects them.

## Public-page refresh

- The landing page reuses the existing beach photograph and destination pictures.
- Registration uses the existing sign-up handlers, with larger shadcn-style controls, inline validation, and password visibility controls.
- The supplied Andy Bold font lives in `app/public/fonts/andy/`. It accents short travel phrases; normal text and form controls use the existing sans-serif fonts.
- Public-page styling is scoped in `app/src/styles/public-pages.css`; it uses the existing Tailwind and shadcn setup and respects the app's color preferences.
