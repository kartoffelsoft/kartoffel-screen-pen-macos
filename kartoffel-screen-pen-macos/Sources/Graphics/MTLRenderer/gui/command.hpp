#pragma once

#include "asset/texture_id.hpp"
#include "layout/rect.hpp"
#include <cstdint>

namespace gui {

struct command_t
{
    constexpr command_t(uint32_t _count,
                        uint32_t _index_buffer_offset,
                        uint32_t _vertex_buffer_offset,
                        const gui::layout::rect_t &_clip_rect,
                        gui::asset::texture_id_t _texture_id = 0)
        : count{_count},
          index_buffer_offset{_index_buffer_offset},
          vertex_buffer_offset{_vertex_buffer_offset},
          clip_rect{_clip_rect},
          texture_id{_texture_id} {}

    uint32_t count;
    uint32_t index_buffer_offset;
    uint32_t vertex_buffer_offset;

    gui::layout::rect_t clip_rect;
    gui::asset::texture_id_t texture_id;
};

} // gui
