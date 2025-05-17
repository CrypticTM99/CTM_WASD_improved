# Improved WASD Input Module for RPG Maker VX Ace*

This Ruby script enhances the default directional input handling in your RPG Maker VX Ace project by allowing the use of **WASD keys** as an alternative to the arrow keys for movement controls.

---

## Features

- Supports WASD keys (W = Up, A = Left, S = Down, D = Right) in addition to default arrow keys.
- Works seamlessly with the original input system without breaking default functionality.
- Prevents WASD input from interfering with menu navigation by disabling it in menus.
- Handles multiple simultaneous key presses with sensible conflict resolution.
- Overrides `press?`, `trigger?`, and `repeat?` methods to include WASD keys.

---

## Installation

1. Copy the entire script into a new Ruby script file inside your RPG Maker project's `Scripts` folder.
2. Place it **above** the main script or below `Main` but **before** any scripts that depend on input methods.
3. Save and run your game.

---

## Usage

- Move your character using arrow keys or WASD.
- WASD keys provide a familiar layout for players used to PC gaming.
- The script respects the menu context and will not interfere with menu controls.

---

## Technical Details

- Uses method aliasing to extend existing input methods.
- Maps arrow keys (`Input::UP`, `Input::LEFT`, `Input::DOWN`, `Input::RIGHT`) to WASD keys (`Input::R`, `Input::X`, `Input::Y`, `Input::Z`).
- Calculates direction codes based on current pressed keys.
- Supports both 4-directional (`dir4`) and 8-directional (`dir8`) movement.

---

## License

This script is open for personal and commercial use. Credit to [CrypticTM] as original author.

---

## Contact

For support or improvements, reach out on [Cryptic's Github](https://github.com/CrypticTM99)].

---

Happy game developing! 🚀
