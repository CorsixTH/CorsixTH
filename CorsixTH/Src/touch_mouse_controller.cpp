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

#include "touch_mouse_controller.h"

namespace corsixth {

TouchMouseController::TouchMouseController(
    int drag_threshold, int tap_movement_threshold,
    std::uint32_t secondary_tap_timeout_ms)
    : drag_threshold_(drag_threshold),
      tap_movement_threshold_(tap_movement_threshold),
      secondary_tap_timeout_ms_(secondary_tap_timeout_ms) {}

std::int64_t TouchMouseController::squaredDistance(int x1, int y1, int x2,
                                                   int y2) {
  const std::int64_t dx = static_cast<std::int64_t>(x1) - x2;
  const std::int64_t dy = static_cast<std::int64_t>(y1) - y2;
  return dx * dx + dy * dy;
}

bool TouchMouseController::movedBeyond(const FingerState& finger,
                                       int threshold) const {
  return squaredDistance(finger.x, finger.y, finger.gesture_x,
                         finger.gesture_y) >
         static_cast<std::int64_t>(threshold) * threshold;
}

void TouchMouseController::appendClick(Actions& actions, ActionType down,
                                       ActionType up, int x, int y) const {
  actions.push_back({down, x, y, down == ActionType::primary_down});
  actions.push_back({up, x, y, false});
}

std::vector<TouchMouseController::Action> TouchMouseController::fingerDown(
    FingerId id, int x, int y, std::uint32_t timestamp) {
  Actions actions;
  if (fingers_.empty()) {
    reset();
    has_primary_ = true;
    primary_id_ = id;
    fingers_.emplace(id, FingerState{x, y, x, y, x, y});
    actions.push_back({ActionType::move, x, y, false});
    return actions;
  }

  fingers_.insert_or_assign(id, FingerState{x, y, x, y, x, y});
  suppress_until_all_up_ = true;

  if (fingers_.size() == 2) {
    secondary_click_candidate_ = !primary_is_down_;
    secondary_click_emitted_ = false;
    secondary_down_timestamp_ = timestamp;
    for (auto& [finger_id, finger] : fingers_) {
      static_cast<void>(finger_id);
      finger.gesture_x = finger.x;
      finger.gesture_y = finger.y;
    }

    if (primary_is_down_) {
      const auto primary = fingers_.find(primary_id_);
      if (primary != fingers_.end()) {
        actions.push_back({ActionType::primary_up, primary->second.x,
                           primary->second.y, false});
      }
      primary_is_down_ = false;
    }
  } else {
    secondary_click_candidate_ = false;
  }

  return actions;
}

std::vector<TouchMouseController::Action> TouchMouseController::fingerMove(
    FingerId id, int x, int y, std::uint32_t timestamp) {
  static_cast<void>(timestamp);
  Actions actions;
  const auto current = fingers_.find(id);
  if (current == fingers_.end()) {
    return actions;
  }

  const int xrel = x - current->second.x;
  const int yrel = y - current->second.y;
  current->second.x = x;
  current->second.y = y;

  if (suppress_until_all_up_) {
    if (secondary_click_candidate_ &&
        movedBeyond(current->second, tap_movement_threshold_)) {
      secondary_click_candidate_ = false;
    }
    return actions;
  }

  if (!has_primary_ || id != primary_id_) {
    return actions;
  }

  if (!primary_is_down_ &&
      squaredDistance(x, y, current->second.down_x, current->second.down_y) >
          static_cast<std::int64_t>(drag_threshold_) * drag_threshold_) {
    primary_is_down_ = true;
    actions.push_back({ActionType::primary_down, current->second.down_x,
                       current->second.down_y, true});
  }

  actions.push_back(
      {ActionType::move, x, y, primary_is_down_, xrel, yrel});
  return actions;
}

std::vector<TouchMouseController::Action> TouchMouseController::fingerUp(
    FingerId id, int x, int y, std::uint32_t timestamp) {
  Actions actions;
  const auto current = fingers_.find(id);
  if (current == fingers_.end()) {
    return actions;
  }

  const int xrel = x - current->second.x;
  const int yrel = y - current->second.y;
  current->second.x = x;
  current->second.y = y;

  if (suppress_until_all_up_) {
    if (secondary_click_candidate_ &&
        movedBeyond(current->second, tap_movement_threshold_)) {
      secondary_click_candidate_ = false;
    }

    if (secondary_click_candidate_ && !secondary_click_emitted_ &&
        timestamp - secondary_down_timestamp_ <=
            secondary_tap_timeout_ms_) {
      const auto primary = fingers_.find(primary_id_);
      const FingerState& target =
          primary != fingers_.end() ? primary->second : current->second;
      appendClick(actions, ActionType::secondary_down,
                  ActionType::secondary_up, target.x, target.y);
      secondary_click_emitted_ = true;
    }

    fingers_.erase(current);
    if (fingers_.empty()) {
      reset();
    }
    return actions;
  }

  if (has_primary_ && id == primary_id_) {
    actions.push_back(
        {ActionType::move, x, y, primary_is_down_, xrel, yrel});
    if (primary_is_down_) {
      actions.push_back({ActionType::primary_up, x, y, false});
    } else {
      appendClick(actions, ActionType::primary_down, ActionType::primary_up, x,
                  y);
    }
  }

  fingers_.erase(current);
  if (fingers_.empty()) {
    reset();
  }
  return actions;
}

std::vector<TouchMouseController::Action> TouchMouseController::cancel() {
  Actions actions;
  if (primary_is_down_) {
    const auto primary = fingers_.find(primary_id_);
    if (primary != fingers_.end()) {
      actions.push_back({ActionType::primary_up, primary->second.x,
                         primary->second.y, false});
    }
  }
  reset();
  return actions;
}

void TouchMouseController::reset() {
  fingers_.clear();
  primary_id_ = 0;
  has_primary_ = false;
  primary_is_down_ = false;
  suppress_until_all_up_ = false;
  secondary_click_candidate_ = false;
  secondary_click_emitted_ = false;
  secondary_down_timestamp_ = 0;
}

}  // namespace corsixth
