# Author: [CrypticTM] - Improved WASD script for my RPG game (DBRPG*)

module Input
  class << self
    alias_method :original_dir4, :dir4
    alias_method :original_dir8, :dir8
    alias_method :original_press?, :press?
    alias_method :original_trigger?, :trigger?
    alias_method :original_repeat?, :repeat?

    # WASD key mappings to directional input constants
    KEY_MAP = {
      Input::UP    => Input::R, # W key for UP
      Input::LEFT  => Input::X, # A key for LEFT
      Input::DOWN  => Input::Y, # S key for DOWN
      Input::RIGHT => Input::Z  # D key for RIGHT
    }.freeze

    # Override press? to include WASD keys
    def press?(key)
      if KEY_MAP.key?(key)
        original_press?(key) || original_press?(KEY_MAP[key])
      else
        original_press?(key)
      end
    end

    # Override trigger? to include WASD keys
    def trigger?(key)
      if KEY_MAP.key?(key)
        original_trigger?(key) || original_trigger?(KEY_MAP[key])
      else
        original_trigger?(key)
      end
    end

    # Override repeat? to include WASD keys
    def repeat?(key)
      if KEY_MAP.key?(key)
        original_repeat?(key) || original_repeat?(KEY_MAP[key])
      else
        original_repeat?(key)
      end
    end

    # Override dir4: use original direction unless zero,
    # fall back to WASD input unless in menu scene
    def dir4
      return original_dir4 if SceneManager.scene_is?(Scene_Menu)
      process_wasd_direction(:dir4)
    end

    # Override dir8 similarly
    def dir8
      return original_dir8 if SceneManager.scene_is?(Scene_Menu)
      process_wasd_direction(:dir8)
    end

    private

    # Process directional input for WASD keys
    def process_wasd_direction(mode)
      direction = send("original_#{mode}")
      return direction unless direction.zero?

      up    = press?(Input::R)
      left  = press?(Input::X)
      down  = press?(Input::Y)
      right = press?(Input::Z)

      pressed_count = [up, left, down, right].count(true)
      calculate_direction(pressed_count, up, left, down, right)
    end

    # Calculate the 4- or 8-direction code based on keys pressed
    def calculate_direction(count, up, left, down, right)
      case count
      when 3
        # Three keys pressed: return the direction opposite to the one not pressed
        return 8 unless down
        return 4 unless right
        return 2 unless up
        return 6 unless left
      when 2
        # Two keys pressed: check for opposite directions cancelling out
        return 0 if (up && down) || (left && right)
        return 8 if up
        return 4 if left
        return 2 if down
        return 6 if right
      when 1
        # Single key pressed: straightforward mapping
        return 8 if up
        return 4 if left
        return 2 if down
        return 6 if right
      else
        # No keys or invalid combination
        return 0
      end
    end
  end
end
