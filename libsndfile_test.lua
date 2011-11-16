local FILE = arg[1]

local general 				= require"general"
local current_script_dir 	= general.current_script_dir
local rel_dir = assert ( current_script_dir ( ) , "Current directory unknown" )
package.path = package.path .. ";" .. rel_dir .. "../?/init.lua"

local sndfile = require "libsndfile"

local ffi = require"ffi"

print ( "libsndfile version:" , sndfile.version ( ) )

print "\nOPENING FILE"

local sf , info = sndfile.openpath ( FILE )

print ( )
print ( "#Frames:     " , info.frames )
print ( "Sample Rate: " , info.samplerate )
print ( "Channels:    " , info.channels )
print ( "Format:      " , sndfile.format_info ( info.format ) )
print ( "Sections:    " , info.sections )
print ( "Seekable?    " , info.seekable ~= 0 )

print "\nDECODING TO FILE"

local out_fd = assert ( io.open ( "samples.raw" , "wb" ) )

local frames = 2^20
local buff = ffi.new ( "int16_t[?]" , frames * info.channels)
repeat
	local n = sf:read_short ( buff , frames )
	print(n,ffi.sizeof ( "int16_t" ),info.channels)
	out_fd:write ( ffi.string ( buff , n * ffi.sizeof ( "int16_t" ) * info.channels ) )
until n == 0

print "\nDONE"
