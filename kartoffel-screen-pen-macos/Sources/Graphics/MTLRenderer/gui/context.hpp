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

enum context_load_action_t
{
    context_load_action_dont_care = 0,
    context_load_action_load,
    context_load_action_clear
};

struct context_t
{
    context_type_t type;
    context_handle_t handle;
    context_load_action_t load_action;
    
    gui::layout::size_t display_size;
    gui::layout::vec2_t display_scale;
};
    
} // gui
