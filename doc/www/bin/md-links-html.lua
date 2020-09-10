-- LumoSQL Pandoc Lua Functions
--
-- Copyright 2020 The LumoSQL Authors under the terms contained in the file LICENSES/MIT
--
-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors
-- SPDX-ArtifactOfProjectName: LumoSQL -->
-- SPDX-FileType: Code -->
-- SPDX-FileComment: Original by Dan Shearer, 2020 -->

function Link(el)
  el.target = string.gsub(el.target, "%.md", ".html")
  return el
end
