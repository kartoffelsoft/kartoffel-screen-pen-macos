#pragma once

#include <memory>
#include <mutex>
#include <vector>
#include <Metal/Metal.hpp>

namespace gui {

struct mtl_buffer_t;
using mtl_buffer_ref_t = std::shared_ptr<gui::mtl_buffer_t>;

struct mtl_buffer_t
{
    mtl_buffer_t(MTL::Buffer *buffer)
        : _buffer{buffer},
          _last_reuse_time{0}
    {
    }
    
    ~mtl_buffer_t()
    {
        if(_buffer)
        {
            _buffer->release();
        }
    }
    
    MTL::Buffer * get_buffer() const
    {
        return _buffer;
    }
    
    uint64_t get_last_reuse_time() const
    {
        return _last_reuse_time;
    }
    
    void set_last_reuse_time(uint64_t time)
    {
        _last_reuse_time = time;
    }

private:
    MTL::Buffer *_buffer;
    uint64_t _last_reuse_time;
};

class mtl_buffer_manager_t
{
public:
    mtl_buffer_manager_t();
    ~mtl_buffer_manager_t();
    
    mtl_buffer_ref_t dequeueReusableBuffer(MTL::Device *device,
                                           uint64_t length);
    
    void queueReusableBuffer(mtl_buffer_ref_t buffer);

private:
    std::vector<mtl_buffer_ref_t> _cache;
    std::mutex _cache_mutex;
    
    uint64_t _last_purge_time;
};

} // gui
