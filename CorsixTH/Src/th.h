/*
Copyright (c) 2009 Peter "Corsix" Cawley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#ifndef CORSIX_TH_TH_H_
#define CORSIX_TH_TH_H_
#include "config.h"
#include <vector>

//! Generic linked list class (for inheriting from)
class link_list
{
public:
    link_list() ;
    ~link_list();

    link_list* prev;
    link_list* next;

    void remove_from_list();

    // TODO: drawing layer doesn't belong in a generic link list.
    int get_drawing_layer() {return drawing_layer;}
    void set_drawing_layer(int layer) {drawing_layer = layer;}

private:
    int drawing_layer;
};

//! \brief Theme Hospital localised string list
//!
//! Presents Theme Hospital strings by section and index.
class th_string_list
{
public:
    //! Construct an instance of string_list from the given data
    //! from a Theme Hosptial string file. The format of the data is
    //! described at:
    //! https://github.com/alexandergitter/theme-hospital-spec/blob/master/format-specification.md#strings
    //!
    //! \param data A pointer to the raw data
    //! \param length The size of the data
    th_string_list(const uint8_t* data, size_t length);

    // Delete default constructors and assignment operators. They
    // can be implemented properly later if they are needed but
    // for now they are unneeded so it is safer to remove them.
    th_string_list() = delete;
    th_string_list(const th_string_list &) = delete;
    th_string_list(th_string_list &&) = delete;
    th_string_list& operator= (const th_string_list &) = delete;
    th_string_list&& operator= (th_string_list &&) = delete;
    ~th_string_list();

    //! Get the number of sections in the string list
    size_t get_section_count();

    //! Get the number of strings in a section of the string list
    size_t get_section_size(size_t section);

    //! Get a string from the string list
    /*!
        @param section Section index in range [0, getSectionCount() - 1]
        @param index String index in range [0, getSectionSize(iSection) - 1]
        @return nullptr if the index is invalid, otherwise a UTF-8 encoded string.
    */
    const char* get_string(size_t section, size_t index);

private:
    //! Section information
    std::vector<std::vector<const char *>> sections;

    //! Memory block containing all the actual strings utf-8 encoded
    std::vector<uint8_t> string_buffer;
};

#endif // CORSIX_TH_TH_H_
