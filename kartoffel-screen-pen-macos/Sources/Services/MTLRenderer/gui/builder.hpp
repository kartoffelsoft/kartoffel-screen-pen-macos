#pragma once

#include "command.hpp"
#include "layout/color.hpp"
#include "layout/index.hpp"
#include "layout/rect.hpp"
#include "layout/vec.hpp"
#include "layout/vertex.hpp"

#include <vector>

namespace gui {

class builder_t
{
public:
    builder_t();
    ~builder_t();
    
    void add_rect(const gui::layout::vec2_t &p1,
                  const gui::layout::vec2_t &p2,
                  const gui::layout::color_t &color, 
                  float thickness);

    void add_polyline(const std::vector<gui::layout::vec2_t> &path,
                      const gui::layout::color_t &color,
                      float thickness);
    
    void push_clip_rect(const gui::layout::rect_t &rect);
    void pop_clip_rect();
    const gui::layout::rect_t & get_clip_rect_top() const;

    void reset();

    std::vector<gui::command_t> commands;
    std::vector<gui::layout::index_t> indices;
    std::vector<gui::layout::vertex_t> vertices;

private:
    std::vector<gui::layout::rect_t> _clip_rect_stack;
};

} // gui
