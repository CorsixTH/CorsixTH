--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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
SOFTWARE. --]]

local L = require "lpeg"
need_lpeg_version(0, 9)

local C, P, R, S, V = L.C, L.P, L.R, L.S, L.V
local Carg, Cc, Cp, Ct, Cg, Cb, Cmt = L.Carg, L.Cc, L.Cp, L.Ct, L.Cg, L.Cb, L.Cmt

local identifier_type = {
  ["and"] = "operator",
  ["break"] = "keyword",
  ["do"] = "keyword",
  ["else"] = "keyword",
  ["elseif"] = "keyword",
  ["end"] = "keyword",
  ["false"] = "constant",
  ["for"] = "keyword",
  ["function"] = "keyword",
  ["if"] = "keyword",
  ["in"] = "keyword",
  ["local"] = "keyword",
  ["nil"] = "constant",
  ["not"] = "operator",
  ["or"] = "operator",
  ["repeat"] = "keyword",
  ["return"] = "keyword",
  ["then"] = "keyword",
  ["true"] = "constant",
  ["until"] = "keyword",
  ["while"] = "keyword",
  -- everything else is "identifer"
}

local tokens = P { "tokens";

  -- Comment of form --xyz or --[[ xyz ]] or #xyz (unix shebang)
  comment = Ct(C(P"--" * (V"long_string_body" + (1 - V"newline")^0))  * Cc"comment"),
  file_start = Ct(C(P"#" * (1 - S"\r\n")^0) * Cc"comment"),
  utf8_bom = P"\239\187\191",

  -- Single platform independant line break which increments line number
  newline = (P"\r\n" + P"\n\r" + S"\r\n") * (Cp() * Carg(1)) / function(pos, state)
    state.line = state.line + 1
    state.line_start = pos
  end,

  -- Whitespace of any length (includes newlines)
  whitespace = Ct(C((S" \t" + V"newline")^1) * Cc"whitespace"),

  -- Identifier of form [a-zA-Z_][a-zA-Z0-9_]*
  identifier = Ct((R("az","AZ","__") * R("09","az","AZ","__")^0) / function(id)
    return id, identifier_type[id] or "identifier"
  end),

  -- Single character in a string
  string_char = (1 - S[[\"']]) + (P"\\" * (S[[abfnrtv\"'0123456789]] + V"newline")),

  -- String literal
  string = Ct(C(P"'" * (V"string_char" + P'"')^0 * P"'" +
                P'"' * (V"string_char" + P"'")^0 * P'"' +
                V"long_string_body") * Cc"string"),
  long_string = Ct(C(V"long_string_body") * Cc"string"),
  long_string_body = "[" * Cg(P"="^0, "ls_init") * "[" * ((V"newline" + 1) - V"long_string_close")^0 * "]" * P"="^0 * "]",
  long_string_close = Cmt("]" * C(P"="^0) * "]" * Cb("ls_init"), function (s, i, a, b) return a == b end),

  -- Operator
  operator = Ct(C(P".." + P"<=" + P">=" + P"==" + P"~=" + S"+-*/^%<>#") * Cc"operator"),

  -- Vararg (...)
  vararg = Ct(C(P"...") * Cc"vararg"),

  -- Misc. char (token type is the character itself)
  char = Ct(C(S"[]{}();,=:.") / function(x) return x, x end),

  -- Hex or decimal number
  int = Ct(C((P"0x" * R("09","af","AF")^1) + R"09"^1) * Cc"integer"),

  -- Floating point number
  float = Ct(C(P"."^-1 * R"09" * R("09","..")^0)* Cc"float"),

  -- Any token
  token = ((V"comment" +
            V"identifier" +
            V"whitespace" +
            V"string" +
            V"long_string" +
            V"float" +
            V"vararg" +
            V"operator" +
            V"char" +
            V"int") * Carg(1)) / function(t, s) t.line = s.line return t end,

  -- Error for when nothing else matches
  error = (Cp() * C(P(1) ^ -8) * Carg(1)) / function(pos, where, state)
    error(("Tokenising error on line %i, position %i, near '%s'")
      :format(state.line, pos - state.line_start + 1, where))
  end,

  -- Match end of input or throw error
  finish = -P(1) + V"error",

  -- Match stream of tokens into a table
  tokens = V"utf8_bom"^-1 * Ct(V"file_start" ^ -1 * V"token" ^ 0) * V"finish",
}

function TokeniseLua(str)
  return tokens:match(str, 1, {line = 1, line_start = 1})
end

local escape_replacements = {
  ["<"] = "&lt;",
  [">"] = "&gt;",
  ["&"] = "&amp;",
}
local function escape(str)
  return str:gsub("[<>&]", escape_replacements)
end

local Lua_to_HTML_names = {
  comment = "c",
  identifier = "i",
  keyword = "k",
  string = "s",
  float = "n",
  integer = "n",
  vararg = "v"
}

function Lua_to_HTML(str)
  local tokens = TokeniseLua(str)
  local result = {}
  for i, token in ipairs(tokens) do
    local handler = Lua_to_HTML_names[token[2]]
    if handler then
      if type(handler) == "string" then
        token = '<span class="'.. handler ..'">'.. escape(token[1]) ..'</span>'
      else
        token = handler(token)
      end
    else
      token = escape(token[1])
    end
    result[#result + 1] = token
  end
  return table.concat(result)
end

--[=[
local d = io.open("lua_tokenise.lua","r")
local s = d:read("*a")
d:close()
d = io.open("lua_tokenise.html", "w")
d:write[[<style>
pre.lua span.c {color: #080;}
pre.lua span.k {color: #00f;}
pre.lua span.s {color: #888;}
pre.lua span.n {color: #f80;}
</style><pre class="lua">]]
d:write(Lua_to_HTML(s))
d:write[[</pre>]]
d:close()
--]=]
