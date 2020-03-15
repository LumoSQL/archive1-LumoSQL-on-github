-- LumoSQL Pandoc Lua Functions
--
-- SPDX-License-Identifier: Apache-2.0
-- SPDX-FileCopyrightText: 2019 The LumoSQL Authors

function Link(el)
  el.target = string.gsub(el.target, "%.md", ".html")
  return el
end
