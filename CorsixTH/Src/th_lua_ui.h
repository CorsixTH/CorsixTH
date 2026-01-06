#ifndef CORSIX_TH_TH_LUA_UI_H_
#define CORSIX_TH_TH_LUA_UI_H_

#include "config.h"

#include <algorithm>
#include <cassert>

//! Remap a value between low and high to an output between start and end.
/*!
 * Perform linear scaling of a value from one range to another. This function
 * is primarily intended for mapping bytes to color channel values.
 *
 * @param low   Lower bound of input range. Must be less than high. [0-255]
 * @param high  Upper bound of input range. Must be greater than low. [0-255]
 * @param val   Value in [low, high] to scale.
 * @param start Lower bound of output range. May be greater than end. [0-255]
 * @param end   Upper bound of output range. May be less than start. [0-255]
 * @return Scaled value in [start, end]
 */
constexpr uint8_t map_color_channel(int low, int high, int val, int start,
                                    int end) {
  assert(low < high);
  assert(start >= 0 && start <= 0xFF);
  assert(end >= 0 && end <= 0xFF);

  if (val <= low) {
    return start;
  }
  if (val >= high) {
    return end;
  }

  return static_cast<uint8_t>(start +
                              (end - start) * (val - low) / (high - low));
}

#endif  // CORSIX_TH_TH_LUA_UI_H_
