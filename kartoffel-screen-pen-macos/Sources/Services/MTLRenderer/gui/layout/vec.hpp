#pragma once

namespace gui {
namespace layout {

struct vec2_t
{
    constexpr vec2_t() : x(0.0f), y(0.0f) {}
    constexpr vec2_t(float _x, float _y) : x(_x), y(_y) {}
    float x, y;
};

struct vec4_t
{
    constexpr vec4_t() : x(0.0f), y(0.0f), z(0.0f), w(0.0f) {}
    constexpr vec4_t(float _x, float _y, float _z, float _w) : x(_x), y(_y), z(_z), w(_w) {}
    float x, y, z, w;
};

} // layout
} // gui
