#pragma once

#include "size.hpp"
#include "vec.hpp"

namespace gui {
namespace layout {

struct rect_t
{
    constexpr rect_t() : origin(), size() {}
    constexpr rect_t(float _x, float _y, float _width, float _height) 
        : origin(_x, _y), size(_width, _height) {}
    
    gui::layout::vec2_t origin;
    gui::layout::size_t size;

    bool contains(const gui::layout::vec2_t &point) const
    {
        return (point.x >= origin.x && point.x <= (origin.x + size.width) &&
                point.y >= origin.y && point.y <= (origin.y + size.height));
    }
};

} // layout
} // gui
