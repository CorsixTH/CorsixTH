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

#include <cassert>
#include <initializer_list>
#include <vector>

using corsixth::TouchMouseController;

namespace {

using Action = TouchMouseController::Action;
using ActionType = TouchMouseController::ActionType;

void expectTypes(const std::vector<Action>& actions,
                 std::initializer_list<ActionType> expected) {
  assert(actions.size() == expected.size());
  auto action = actions.begin();
  auto type = expected.begin();
  for (; action != actions.end(); ++action, ++type) {
    assert(action->type == *type);
  }
}

void testPrimaryTap() {
  TouchMouseController controller;
  expectTypes(controller.fingerDown(1, 100, 80, 0), {ActionType::move});
  const auto actions = controller.fingerUp(1, 102, 81, 100);
  expectTypes(actions, {ActionType::move, ActionType::primary_down,
                        ActionType::primary_up});
  assert(actions[1].x == 102);
  assert(actions[1].y == 81);
}

void testPrimaryDrag() {
  TouchMouseController controller;
  controller.fingerDown(1, 100, 80, 0);
  expectTypes(controller.fingerMove(1, 106, 84, 20), {ActionType::move});

  const auto start_drag = controller.fingerMove(1, 120, 90, 40);
  expectTypes(start_drag,
              {ActionType::primary_down, ActionType::move});
  assert(start_drag[0].x == 100);
  assert(start_drag[0].y == 80);
  assert(start_drag[1].primary_is_down);

  const auto end_drag = controller.fingerUp(1, 130, 100, 80);
  expectTypes(end_drag, {ActionType::move, ActionType::primary_up});
}

void testSecondaryTap() {
  TouchMouseController controller;
  controller.fingerDown(10, 140, 90, 0);
  expectTypes(controller.fingerDown(11, 300, 180, 100), {});

  const auto actions = controller.fingerUp(11, 302, 181, 180);
  expectTypes(actions,
              {ActionType::secondary_down, ActionType::secondary_up});
  assert(actions[0].x == 140);
  assert(actions[0].y == 90);
  expectTypes(controller.fingerUp(10, 140, 90, 200), {});
}

void testSecondaryTapWhenPrimaryFingerLiftsFirst() {
  TouchMouseController controller;
  controller.fingerDown(10, 140, 90, 0);
  controller.fingerDown(11, 300, 180, 100);

  const auto actions = controller.fingerUp(10, 141, 91, 180);
  expectTypes(actions,
              {ActionType::secondary_down, ActionType::secondary_up});
  assert(actions[0].x == 141);
  assert(actions[0].y == 91);
  expectTypes(controller.fingerUp(11, 300, 180, 200), {});
}

void testMultiFingerMovementRemainsAGesture() {
  TouchMouseController controller;
  controller.fingerDown(1, 100, 80, 0);
  controller.fingerDown(2, 300, 180, 50);
  expectTypes(controller.fingerMove(1, 125, 80, 100), {});
  expectTypes(controller.fingerUp(2, 300, 180, 150), {});
  expectTypes(controller.fingerUp(1, 125, 80, 170), {});
}

void testSlowSecondFingerDoesNotClick() {
  TouchMouseController controller;
  controller.fingerDown(1, 100, 80, 0);
  controller.fingerDown(2, 300, 180, 100);
  expectTypes(controller.fingerUp(2, 300, 180, 700), {});
  expectTypes(controller.fingerUp(1, 100, 80, 720), {});
}

void testSecondFingerCancelsActivePrimaryDrag() {
  TouchMouseController controller;
  controller.fingerDown(1, 100, 80, 0);
  controller.fingerMove(1, 130, 80, 30);

  expectTypes(controller.fingerDown(2, 300, 180, 60),
              {ActionType::primary_up});
  expectTypes(controller.fingerUp(2, 300, 180, 100), {});
  expectTypes(controller.fingerUp(1, 130, 80, 120), {});
}

void testCancelReleasesActivePrimaryDrag() {
  TouchMouseController controller;
  controller.fingerDown(1, 100, 80, 0);
  controller.fingerMove(1, 130, 80, 30);
  expectTypes(controller.cancel(), {ActionType::primary_up});
  expectTypes(controller.fingerUp(1, 130, 80, 50), {});
}

}  // namespace

int main() {
  testPrimaryTap();
  testPrimaryDrag();
  testSecondaryTap();
  testSecondaryTapWhenPrimaryFingerLiftsFirst();
  testMultiFingerMovementRemainsAGesture();
  testSlowSecondFingerDoesNotClick();
  testSecondFingerCancelsActivePrimaryDrag();
  testCancelReleasesActivePrimaryDrag();
  return 0;
}
