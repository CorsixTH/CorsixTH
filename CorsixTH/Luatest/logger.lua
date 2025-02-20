local l = function(m)
  print(m)
end

local logger = {
  trace = l,
  debug = l,
  info = l,
  warn = l,
  error = l
}

return logger;
