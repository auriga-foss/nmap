---
-- A helper module for testing that zlib is available and working.
local stdnse = require "stdnse"
local unittest = require "unittest"

_ENV = stdnse.module("zlib", stdnse.seeall)

test_suite = unittest.TestSuite:new()

test_suite:add_test(unittest.equal(zlib.crc32(0, "penguin"), 0x0e5c1a120), "crc32")
test_suite:add_test(unittest.equal(zlib.crc32(1, "penguin"), 0x43b6aa94), "crc32")

local compr = zlib.compress("penguin")
local expected_compr = "x\x9c+H\xcdK/\xcd\xcc\x03\x00\x0b\xd6\x02\xf7"
test_suite:add_test(unittest.equal(compr, expected_compr), "compress")

local decompr = zlib.decompress(compr)
test_suite:add_test(unittest.equal(decompr, "penguin"), "compress")

return _ENV
