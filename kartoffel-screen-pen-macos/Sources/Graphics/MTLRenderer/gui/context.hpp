#pragma once

#include "layout/size.hpp"
#include "layout/vec.hpp"
#include <cstdint>

namespace gui {

using context_handle_t = std::uint64_t;

enum context_type_t
{
    context_type_display,
    context_type_texture
};

struct context_t
{
    context_type_t type;
    context_handle_t handle;
    
    gui::layout::size_t display_size;
    gui::layout::vec2_t display_scale;
};
    
} // gui
