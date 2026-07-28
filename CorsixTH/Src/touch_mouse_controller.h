/*
Copyright (c) 2026 CorsixTH contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#ifndef CORSIXTH_TOUCH_MOUSE_CONTROLLER_H
#define CORSIXTH_TOUCH_MOUSE_CONTROLLER_H

#include <cstdint>
#include <unordered_map>
#include <vector>

namespace corsixth {

//! Converts direct touchscreen input into mouse-style actions.
/*!
    A single-finger tap becomes a primary click, a single-finger movement
    becomes a primary drag, and a quick second-finger tap becomes a secondary
    click at the first finger's position. Multi-finger movement is deliberately
    left for SDL's native gesture events.
*/
class TouchMouseController {
 public:
  using FingerId = std::int64_t;

  enum class ActionType {
    move,
    primary_down,
    primary_up,
    secondary_down,
    secondary_up,
  };

  struct Action {
    ActionType type;
    int x;
    int y;
    bool primary_is_down;
  };

  TouchMouseController(int drag_threshold = 12,
                       int tap_movement_threshold = 18,
                       std::uint32_t secondary_tap_timeout_ms = 500);

  std::vector<Action> fingerDown(FingerId id, int x, int y,
                                 std::uint32_t timestamp);
  std::vector<Action> fingerMove(FingerId id, int x, int y,
                                 std::uint32_t timestamp);
  std::vector<Action> fingerUp(FingerId id, int x, int y,
                               std::uint32_t timestamp);

  //! Releases an active primary drag and forgets all fingers.
  std::vector<Action> cancel();

 private:
  struct FingerState {
    int x;
    int y;
    int down_x;
    int down_y;
    int gesture_x;
    int gesture_y;
  };

  using Actions = std::vector<Action>;

  static std::int64_t squaredDistance(int x1, int y1, int x2, int y2);
  bool movedBeyond(const FingerState& finger, int threshold) const;
  void reset();
  void appendClick(Actions& actions, ActionType down, ActionType up, int x,
                   int y) const;

  std::unordered_map<FingerId, FingerState> fingers_;
  FingerId primary_id_{0};
  bool has_primary_{false};
  bool primary_is_down_{false};
  bool suppress_until_all_up_{false};
  bool secondary_click_candidate_{false};
  bool secondary_click_emitted_{false};
  std::uint32_t secondary_down_timestamp_{0};
  int drag_threshold_;
  int tap_movement_threshold_;
  std::uint32_t secondary_tap_timeout_ms_;
};

}  // namespace corsixth

#endif  // CORSIXTH_TOUCH_MOUSE_CONTROLLER_H
