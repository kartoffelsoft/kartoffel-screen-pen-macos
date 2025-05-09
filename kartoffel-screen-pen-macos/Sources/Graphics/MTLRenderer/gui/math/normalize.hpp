#pragma once

#include <math.h>

namespace gui {
namespace math {

inline void normalize_float_2(float &x, float &y)
{
    float d2 = x * x + y * y;
    if(d2 > 0.0f)
    {
        float inv_len = 1.0f / sqrtf(d2);
        x *= inv_len;
        y *= inv_len;
    }
}

} // math
} // gui
