#include "builder.hpp"
#include "math/normalize.hpp"

namespace gui {

builder_t::builder_t()
{
}

builder_t::~builder_t()
{
}

void builder_t::add_rect(const gui::layout::vec2_t &p1,
                         const gui::layout::vec2_t &p2,
                         const gui::layout::color_t &color,
                         float thickness)
{
    if(thickness <= 0) return;

    std::vector<gui::layout::vec2_t> path;
    path.push_back(p1);
    path.emplace_back(p1.x, p2.y);
    path.push_back(p2);
    path.emplace_back(p2.x, p1.x);

    add_polyline(path, color, thickness);
}

void builder_t::add_polyline(const std::vector<gui::layout::vec2_t> &path,
                             const gui::layout::color_t &color,
                             float thickness)
{
    size_t count = path.size();

    uint32_t index_buffer_offset = static_cast<int>(indices.size());
    uint32_t vertex_buffer_offset = static_cast<int>(vertices.size());
    commands.emplace_back(0, index_buffer_offset, vertex_buffer_offset, get_clip_rect_top());

    for (int i1 = 0; i1 < count - 1; i1++)
    {
        const int i2 = (i1 + 1) == count ? 0 : i1 + 1;
        const gui::layout::vec2_t &p1 = path[i1];
        const gui::layout::vec2_t &p2 = path[i2];

        float dx = p2.x - p1.x;
        float dy = p2.y - p1.y;
        gui::math::normalize_float_2(dx, dy);
        dx *= (thickness * 0.5f);
        dy *= (thickness * 0.5f);

        vertex_buffer_offset = static_cast<int>(vertices.size());

        vertices.emplace_back(gui::layout::vec2_t{p1.x + dy, p1.y - dx},
                              gui::layout::vec2_t{0, 0},
                               color);
        vertices.emplace_back(gui::layout::vec2_t{p2.x + dy, p2.y - dx},
                              gui::layout::vec2_t{0, 0},
                               color);
        vertices.emplace_back(gui::layout::vec2_t{p1.x - dy, p1.y + dx},
                              gui::layout::vec2_t{0, 0},
                               color);
        vertices.emplace_back(gui::layout::vec2_t{p2.x - dy, p2.y + dx},
                              gui::layout::vec2_t{0, 0},
                               color);
        
        indices.insert(indices.end(), { vertex_buffer_offset + 0, 
                                        vertex_buffer_offset + 1, 
                                        vertex_buffer_offset + 2 });                 
        indices.insert(indices.end(), { vertex_buffer_offset + 1, 
                                        vertex_buffer_offset + 2, 
                                        vertex_buffer_offset + 3 });    
    }

    commands.back().count = static_cast<uint32_t>(indices.size() - index_buffer_offset);
}

void builder_t::push_clip_rect(const gui::layout::rect_t &rect)
{
    _clip_rect_stack.push_back(rect);
}

void builder_t::pop_clip_rect()
{
    _clip_rect_stack.pop_back();
}

const gui::layout::rect_t & builder_t::get_clip_rect_top() const
{
    return _clip_rect_stack.back();
}

void builder_t::reset()
{
    commands.clear();
    vertices.clear();
    _clip_rect_stack.clear();
}

} // gui
