#include "lua_rnc.h"
#include "../../common/rnc.h"
#include "th_lua.h"

//! Provides lua function to decompress RNC data
/*!
    @param L Lua state where the function is called from.  In lua a call
        to this function has one parameter which is the RNC compressed data.
        The return value is the decompressed data.
*/
static int l_decompress(lua_State *L)
{
    size_t inlen;
    const uint8_t* in = reinterpret_cast<const uint8_t*>(luaL_checklstring(L, 1, &inlen));

    // Verify that the data contains an RNC signature, and that the input
    // size matches the size specified in the data header.
    if(inlen < rnc_header_size || inlen != rnc_input_size(in))
    {
        lua_pushnil(L);
        lua_pushliteral(L, "Input is not RNC compressed data");
        return 2;
    }
    uint32_t outlen = rnc_output_size(in); 

    // Allocate scratch area as Lua userdata so that if something horrible
    // happens, it'll be cleaned up by Lua's GC. Remember that most Lua API
    // calls can throw errors, so they all have to be wrapped with code to
    // detect errors and free the buffer if said buffer was not managed by Lua.
    void* outbuf = lua_newuserdata(L, outlen);

    lua_pushnil(L);
    switch(rnc_unpack(in, (uint8_t*)outbuf))
    {
    case rnc_status::ok:
        lua_pushlstring(L, (const char*)outbuf, outlen);
        return 1;

    case rnc_status::file_is_not_rnc:
        lua_pushliteral(L, "Input is not RNC compressed data");
        break;

    case rnc_status::huf_decode_error:
        lua_pushliteral(L, "Invalid Huffman coding");
        break;

    case rnc_status::file_size_mismatch:
        lua_pushliteral(L, "Size mismatch");
        break;

    case rnc_status::packed_crc_error:
        lua_pushliteral(L, "Incorrect packed CRC");
        break;

    case rnc_status::unpacked_crc_error:
        lua_pushliteral(L, "Incorrect unpacked CRC");
        break;

    default:
        lua_pushliteral(L, "Unknown error decompressing RNC data");
        break;
    }
    return 2;
}

static const std::vector<luaL_Reg> rnclib = {
    {"decompress", l_decompress},
    {nullptr, nullptr}
};

int luaopen_rnc(lua_State *L)
{
    luaT_register(L, "rnc", rnclib);
    return 1;
}
