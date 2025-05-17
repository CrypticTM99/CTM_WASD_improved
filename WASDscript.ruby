#==============================================================================
# ** Enhanced WASD Input Module for RPG Maker VX Ace
#------------------------------------------------------------------------------
# Author: CrypticTM (improved and fully extended) originally made for Demonblade RPG
# Description:
#   This script extends the default Input module to allow WASD keys to be used
#   for player movement alongside arrow keys.
#   Supports 4 and 8 directional movement, disables WASD in menus/messages,
#   includes customizable key mapping, and helper methods.
#------------------------------------------------------------------------------
# Usage:
#   Place this script below Materials and above Main.
#   Controls:
#     W (Input::W) = Up
#     A (Input::A) = Left
#     S (Input::S) = Down
#     D (Input::D) = Right
#------------------------------------------------------------------------------
# Compatibility:
#   Compatible with RPG Maker VX Ace default scripts.
#==============================================================================

module Input
  # Original method aliasing to preserve default behavior
  class << self
    alias_method :original_dir4, :dir4
    alias_method :original_dir8, :dir8
    alias_method :original_press?, :press?
    alias_method :original_trigger?, :trigger?
    alias_method :original_repeat?, :repeat?
  end

  # Customizable Key Mapping (change here to other keys if needed)
  KEY_UP    = Input::W
  KEY_LEFT  = Input::A
  KEY_DOWN  = Input::S
  KEY_RIGHT = Input::D

  # Additional keys for convenience or extended functionality
  KEY_JUMP  = Input::J  # Example: Jump action key
  KEY_RUN   = Input::K  # Example: Run action key

  # List of keys to ignore WASD input on (for future expansion)
  IGNORED_SCENES = [Scene_Menu, Scene_Battle, Scene_Shop]

  class << self
    # Override press? to include WASD keys
    def press?(key)
      if wasd_key?(key)
        original_press?(key) || original_press?(wasd_equivalent(key))
      else
        original_press?(key)
      end
    end

    # Override trigger? to include WASD keys
    def trigger?(key)
      if wasd_key?(key)
        original_trigger?(key) || original_trigger?(wasd_equivalent(key))
      else
        original_trigger?(key)
      end
    end

    # Override repeat? to include WASD keys
    def repeat?(key)
      if wasd_key?(key)
        original_repeat?(key) || original_repeat?(wasd_equivalent(key))
      else
        original_repeat?(key)
      end
    end

    # Override dir4 to support WASD movement
    def dir4
      return original_dir4 if disable_wasd_input?

      direction = original_dir4
      return direction unless direction.zero?

      calculate_wasd_direction(false)
    end

    # Override dir8 to support WASD movement with diagonals
    def dir8
      return original_dir8 if disable_wasd_input?

      direction = original_dir8
      return direction unless direction.zero?

      calculate_wasd_direction(true)
    end

    # Returns true if the current scene should disable WASD input
    def disable_wasd_input?
      current_scene = SceneManager.scene
      IGNORED_SCENES.any? { |scene_class| current_scene.is_a?(scene_class) } ||
        (current_scene.respond_to?(:message_window) && current_scene.message_window&.visible?)
    end

    # Checks if a key is one of the WASD movement keys
    def wasd_key?(key)
      [Input::UP, Input::LEFT, Input::DOWN, Input::RIGHT].include?(key) ||
        [KEY_UP, KEY_LEFT, KEY_DOWN, KEY_RIGHT].include?(key)
    end

    # Maps arrow keys to WASD keys and vice versa
    def wasd_equivalent(key)
      case key
      when Input::UP then KEY_UP
      when Input::LEFT then KEY_LEFT
      when Input::DOWN then KEY_DOWN
      when Input::RIGHT then KEY_RIGHT
      when KEY_UP then Input::UP
      when KEY_LEFT then Input::LEFT
      when KEY_DOWN then Input::DOWN
      when KEY_RIGHT then Input::RIGHT
      else
        key
      end
    end

    # Calculate directional code based on WASD keys pressed
    # diagonal = true for 8 directions, false for 4 directions
    def calculate_wasd_direction(diagonal = false)
      up    = press?(KEY_UP)
      left  = press?(KEY_LEFT)
      down  = press?(KEY_DOWN)
      right = press?(KEY_RIGHT)

      # Count number of keys pressed
      count = [up, left, down, right].count(true)

      # Debug print (disable in production)
      # debug_wasd_state(up, left, down, right)

      case count
      when 4
        # All keys pressed - no movement, conflicting inputs
        0
      when 3
        # Three keys pressed: calculate opposite missing direction
        # This is a bit tricky: find which key not pressed and return opposite direction
        return 8 unless down
        return 4 unless right
        return 2 unless up
        return 6 unless left
      when 2
        # Two keys pressed: handle opposite conflicts or diagonals
        if (up && down) || (left && right)
          # Opposite directions cancel each other out
          0
        else
          if diagonal
            # Return diagonal directions if valid combinations
            return 7 if up && left    # Up-Left
            return 9 if up && right   # Up-Right
            return 1 if down && left  # Down-Left
            return 3 if down && right # Down-Right
          end
          # Otherwise single key direction
          return 8 if up
          return 4 if left
          return 2 if down
          return 6 if right
        end
      when 1
        # Single key pressed: return that direction
        return 8 if up
        return 4 if left
        return 2 if down
        return 6 if right
      else
        # No keys pressed
        0
      end
    end

    # Debug method to print WASD key states - for development only
    def debug_wasd_state(up, left, down, right)
      puts "WASD State => Up: #{up}, Left: #{left}, Down: #{down}, Right: #{right}"
    end
  end
end

#==============================================================================
# ** SceneManager Extension for WASD Input Context Awareness
#------------------------------------------------------------------------------
# This helps disable WASD input automatically in menu, battle, or other scenes
#==============================================================================

module SceneManager
  class << self
    # Alias original scene method
    alias_method :original_scene, :scene

    # Override scene accessor to cache current scene class
    def scene
      @scene ||= original_scene
    end

    # Clear cached scene when scene changes
    def run
      # Call original run method but clear scene cache first
      @scene = nil
      original_run
    end
  end
end

#==============================================================================
# ** Game_Player - Demonstrate WASD support
#------------------------------------------------------------------------------
# This section is optional and can be removed if you want only input module.
# It's here to show how WASD input works for player movement.
#==============================================================================

class Game_Player < Game_Character
  alias_method :original_move_by_input, :move_by_input

  def move_by_input
    # Use WASD-aware directional input first
    direction = Input.dir8
    if direction != 0
      move_straight(direction) if passable?(x, y, direction)
      return
    end

    # Otherwise fallback to original input handler
    original_move_by_input
  end
end

#==============================================================================
# ** Notes for Developers
#------------------------------------------------------------------------------
# - You can customize keybindings by changing KEY_UP, KEY_LEFT, etc. at the top.
# - The script automatically disables WASD input when in menu, battle, or shop.
# - To extend, add more keys like jump, run, attack mapped here.
# - Debug messages can be enabled by uncommenting debug lines.
# - This script is compatible with standard RPG Maker VX Ace movement system.
#==============================================================================

