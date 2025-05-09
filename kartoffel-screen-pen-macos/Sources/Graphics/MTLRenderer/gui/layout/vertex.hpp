#pragma once

#include "vec.hpp"
#include <cstdint>

namespace gui {
namespace layout {

struct vertex_t
{
    constexpr vertex_t(const gui::layout::vec2_t &_position,
                       const gui::layout::vec2_t &_uv,
                       const uint32_t &_color)
        : position(_position), 
          uv(_uv),
          color(_color) {};

    gui::layout::vec2_t position;
    gui::layout::vec2_t uv;
    uint32_t color;
};

} // layout
} // gui
