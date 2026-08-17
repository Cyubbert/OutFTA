# OFTA

![status](https://img.shields.io/badge/status-in_progress-green)
![vue](https://img.shields.io/badge/Vue-3-42b883?logo=vue.js&logoColor=white)
![hosted](https://img.shields.io/badge/hosted_on-GitHub_Pages-181717?logo=github)

**[Live Site → ofta.dev](https://ofta.dev/#/)**

OFTA is a lore website for my ongoing Dungeons & Dragons campaign. It started out as a simple static reference page so my players would always have easy access to the base information about the world they're playing in, locations, factions, characters, history and has been growing ever since.

## About the Project

After my first semester at CODERS.BAY, I started hosting my own D&D campaign and wanted a central, always available place for my players to look things up without me repeating myself at the table. That grew into OFTA.

The site began as a static HTML/CSS page and has since been rebuilt around Vue, with routing to navigate between different sections of the world. It's an ongoing project, I add new lore as the campaign develops and I'm currently in the process of migrating parts of the content from static data into a proper database.

## Features

- Browsable world lore: locations, factions, characters and history
- Client side routing between sections via Vue Router
- Actively maintained and expanded alongside the ongoing campaign

## Tech Stack

<p align="left">
  <img src="https://cdn-icons-png.flaticon.com/512/5968/5968267.png" width="40" height="40" alt="HTML5" title="HTML5" />
  <img src="https://cdn-icons-png.flaticon.com/512/5968/5968242.png" width="40" height="40" alt="CSS" title="CSS" />
  <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ6w4IyaPjXNqLqcklxRH0JkReYUcdzItG3GBgBhB4ZGrewU56B9C8TS5Me&s=10" width="40" height="40" alt="JavaScript" title="JavaScript" />
  <img src="https://images.icon-icons.com/2107/PNG/512/file_type_vue_icon_130078.png" width="40" height="40" alt="Vue.js" title="Vue.js" />
  <img src="https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/collections/github-pages-examples/github-pages-examples.png" width="40" height="40" alt="GitHub Pages" title="GitHub Pages" />
  <img src="https://assets.streamlinehq.com/image/private/w_300,h_300,ar_1/f_auto/v1/icons/4/supabase-icon-kpjasdqlnu8exakst6f44r.png/supabase-icon-5uqgeeqeknngv9las8zeef.png?_a=DATAiZkSZAA0" width="40" height="40" alt="Supabase" title="Supabase" />
</p>

- **Frontend:** Vue.js, Vue Router, JavaScript, HTML5, CSS
- **Data:** static data files, gradually migrating to Supabase
- **Hosting:** GitHub Pages

## Project Status

🚧 Actively in progress. Content and features are being added continuously alongside the campaign and the migration from static data to a database is ongoing.

### Roadmap

- [ ] Finish migrating remaining lore content to the database
- [ ] Add User Login
- [ ] Anonymous Posting / Discussion Ground
- [ ] User Edit Gallery
- [ ] Personal Letter Storage

## Getting Started

Clone the repo and install dependencies:

```bash
git clone https://github.com/Cyubbert/OutFTA.git
cd OutFTA
npm install
```

Run the dev server:

```bash
npm run dev
```

Build for production:

```bash
npm run build
```

> Adjust the commands above if your project uses Vue CLI instead of Vite (`npm run serve` for dev) or a different package manager.

## Deployment
The site is deployed via GitHub Pages, built from the `main` branch.

## Contact

Questions or feedback about the project? Reach out at [divis.bindestrich@gmail.com](mailto:divis.bindestrich@gmail.com).