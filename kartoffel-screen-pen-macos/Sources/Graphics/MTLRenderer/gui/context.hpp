#pragma once

#include "layout/size.hpp"
#include "layout/vec.hpp"
#include <cstdint>

namespace gui {

using surface_handle_t = std::uint64_t;

struct context_t
{
    surface_handle_t surface_handle;
    
    gui::layout::size_t display_size;
    gui::layout::vec2_t display_scale;
};
    
} // gui
