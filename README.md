# NeoBoard

NeoBoard is a modern, lightweight web imageboard and textboard system inspired by classic internet forums and the aesthetics of retro interfaces. Built with Flutter for the frontend and PHP/MySQL for the backend, NeoBoard is designed to be easy to run locally or host for a small community.

## Features

- Fast, clean imageboard-style posting (threads and replies)
- Retro-inspired custom UI
- Multiple boards
- Thread and reply counts, automatic thread refresh
- Moderator dashboard with thread management and login
- Responsive design for web and desktop
- Simple, clean codebase with separation of frontend (Flutter) and backend (PHP/MySQL)

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev) (for web or desktop)
- PHP 7+ and MySQL (for backend)
- Internet browser, or run as a desktop app

### Setup

1. **Clone the repo:**
git clone https://github.com/yourusername/neoboard.git
cd neoboard

2. **Backend (PHP):**
- Create a MySQL database name imageboard and import the included `schema.sql` file.
- Edit `api/db.php` with your database credentials.
- Start the PHP server using the router file in the root directory:
  ```
  php -S localhost:8000 router.php
  ```

3. **Frontend (Flutter):**
- Run `flutter pub get` to fetch dependencies.
- Update the API base URL in your Dart code if needed (default: `http://127.0.0.1:3441/` for backend).
- Start the app:
  ```
  flutter run -d chrome
  ```
  Or build for your chosen platform.

4. **Log in as a moderator:**
- Use the demo credentials shown on the login screen or set up your own users via the DB.

## Folder Structure

- `lib/` — Flutter frontend code
- `api/` — PHP backend scripts (API endpoints and DB connection)
- `assets/` — Fonts, icons, etc.
- `README.md`, `schema.sql`, etc.

## Customization

- To adjust the theme or board list, edit `lib/theme/`, `lib/widgets/`, and `lib/screens/`.
- Add more boards by updating the `_boards` list and database.

## License

This project is open source, MIT licensed. Feel free to fork, contribute, and modify for your own use.

---

Enjoy a modern, hackable, retro imageboard experience with NeoBoard!

<br>
<img width="1346" height="729" alt="Screenshot 2025-08-19 at 15-41-13 NeoBoard" src="https://github.com/user-attachments/assets/980f5ba3-b8d8-41ce-b0fa-34d950e3f116" />
<br>
<img width="1346" height="729" alt="Screenshot 2025-08-19 at 15-41-28 NeoBoard" src="https://github.com/user-attachments/assets/cd9c786a-9939-45ae-92db-11fdfdbd41c1" />
<br>
<img width="1346" height="729" alt="Screenshot 2025-08-19 at 15-41-44 NeoBoard" src="https://github.com/user-attachments/assets/e26a580e-02aa-4425-bfb8-93f41774194c" />
<br>
<img width="1346" height="729" alt="Screenshot 2025-08-19 at 15-41-54 NeoBoard" src="https://github.com/user-attachments/assets/46dac5ce-cb72-49b1-8b57-7b9fc2f46986" />
<br>
<img width="1346" height="729" alt="Screenshot 2025-08-19 at 15-42-05 NeoBoard" src="https://github.com/user-attachments/assets/fd1595c8-9f11-4b47-9e25-fd0571d787be" />
