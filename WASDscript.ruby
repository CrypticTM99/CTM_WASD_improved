# Author: [CrypticTM] - Improved WASD script for my RPG game (DBRPG*)

module Input
  class << self
    alias_method :wasd_original_dir4, :dir4
    alias_method :wasd_original_dir8, :dir8
    alias_method :wasd_original_press, :press?
    alias_method :wasd_original_trigger, :trigger?
    alias_method :wasd_original_repeat, :repeat?

    # Define WASD key mappings
    KEY_MAP = {
      Input::UP => Input::R,
      Input::LEFT => Input::X,
      Input::DOWN => Input::Y,
      Input::RIGHT => Input::Z
    }

    # Handle key presses
    def press?(key)
      return wasd_original_press(key) || wasd_original_press(KEY_MAP[key]) if KEY_MAP.key?(key)
      wasd_original_press(key)
    end

    def trigger?(key)
      return wasd_original_trigger(key) || wasd_original_trigger(KEY_MAP[key]) if KEY_MAP.key?(key)
      wasd_original_trigger(key)
    end

    def repeat?(key)
      return wasd_original_repeat(key) || wasd_original_repeat(KEY_MAP[key]) if KEY_MAP.key?(key)
      wasd_original_repeat(key)
    end

    # Direction handling with menu safeguard
    def dir4
      return wasd_original_dir4 if SceneManager.scene_is?(Scene_Menu)
      handle_wasd_direction(:dir4)
    end

    def dir8
      return wasd_original_dir8 if SceneManager.scene_is?(Scene_Menu)
      handle_wasd_direction(:dir8)
    end

    private

    # Process directional input
    def handle_wasd_direction(mode)
      direction = send("wasd_original_#{mode}")
      return direction unless direction.zero?

      up_press = press?(Input::R)
      left_press = press?(Input::X)
      down_press = press?(Input::Y)
      right_press = press?(Input::Z)

      count = press_count(up_press, left_press, right_press, down_press)
      calculate_direction(count, up_press, left_press, down_press, right_press)
    end

    # Count the number of keys pressed
    def press_count(*presses)
      presses.count(true)
    end

    # Calculate direction based on active keys
    def calculate_direction(count, up_press, left_press, down_press, right_press)
      case count
      when 3
        # Opposite of unpressed direction
        return 8 unless down_press
        return 4 unless right_press
        return 2 unless up_press
        return 6 unless left_press
      when 2
        # Handle conflicting directions
        return 0 if (up_press && down_press) || (left_press && right_press)
        return up_press ? 8 : left_press ? 4 : down_press ? 2 : 6
      when 1
        # Single key determines direction
        return up_press ? 8 : left_press ? 4 : down_press ? 2 : 6
      end
      0
    end
  end
end
