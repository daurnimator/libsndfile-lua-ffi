
local getenv = os.getenv

local bit = require"bit"
local band = bit.band

local general 				= require"general"
local current_script_dir 	= general.current_script_dir
local reverse_lookup 		= general.reverse_lookup

local rel_dir = assert ( current_script_dir ( ) , "Current directory unknown" )

local ffi 					= require"ffi"
local ffi_util 				= require"ffi_util"
local ffi_add_include_dir 	= ffi_util.ffi_add_include_dir
local ffi_defs 				= ffi_util.ffi_defs
local ffi_process_defines 	= ffi_util.ffi_process_defines


assert ( jit , "jit table unavailable" )
local libsndfile_lib
if jit.os == "Windows" then
	local basedir = getenv ( [[ProgramFiles(x86)]] ) or getenv ( [[ProgramFiles]] )
	basedir = basedir .. [[\Mega-Nerd\libsndfile\]]

	ffi_add_include_dir ( basedir .. [[include\]] )
	libsndfile_lib = ffi.load ( basedir .. [[\bin\libsndfile-1.dll]] )
elseif jit.os == "Linux" or jit.os == "OSX" or jit.os == "POSIX" or jit.os == "BSD" then
	ffi_add_include_dir [[/usr/include/]]
	libsndfile_lib = ffi.load ( [[sndfile-1]] )
else
	error ( "Unknown platform" )
end

ffi_defs ( rel_dir .. [[defs.h]] , {
		[[sndfile.h]] ;
	} )

local majformats = { -- Major formats
	WAV       = libsndfile_lib.SF_FORMAT_WAV ;   -- Microsoft WAV format (little endian).
	AIFF      = libsndfile_lib.SF_FORMAT_AIFF ;  -- Apple/SGI AIFF format (big endian).
	AU        = libsndfile_lib.SF_FORMAT_AU ;    -- Sun/NeXT AU format (big endian).
	RAW       = libsndfile_lib.SF_FORMAT_RAW ;   -- RAW PCM data.
	PAF       = libsndfile_lib.SF_FORMAT_PAF ;   -- Ensoniq PARIS file format.
	SVX       = libsndfile_lib.SF_FORMAT_SVX ;   -- Amiga IFF / SVX8 / SV16 format.
	NIST      = libsndfile_lib.SF_FORMAT_NIST ;  -- Sphere NIST format.
	VOC       = libsndfile_lib.SF_FORMAT_VOC ;   -- VOC files.
	IRCAM     = libsndfile_lib.SF_FORMAT_IRCAM ; -- Berkeley/IRCAM/CARL
	W64       = libsndfile_lib.SF_FORMAT_W64 ;   -- Sonic Foundry's 64 bit RIFF/WAV
	MAT4      = libsndfile_lib.SF_FORMAT_MAT4 ;  -- Matlab (tm) V4.2 / GNU Octave 2.0
	MAT5      = libsndfile_lib.SF_FORMAT_MAT5 ;  -- Matlab (tm) V5.0 / GNU Octave 2.1
	PVF       = libsndfile_lib.SF_FORMAT_PVF ;   -- Portable Voice Format
	XI        = libsndfile_lib.SF_FORMAT_XI ;    -- Fasttracker 2 Extended Instrument
	HTK       = libsndfile_lib.SF_FORMAT_HTK ;   -- HMM Tool Kit format
	SDS       = libsndfile_lib.SF_FORMAT_SDS ;   -- Midi Sample Dump Standard
	AVR       = libsndfile_lib.SF_FORMAT_AVR ;   -- Audio Visual Research
	WAVEX     = libsndfile_lib.SF_FORMAT_WAVEX ; -- MS WAVE with WAVEFORMATEX
	SD2       = libsndfile_lib.SF_FORMAT_SD2 ;   -- Sound Designer 2
	FLAC      = libsndfile_lib.SF_FORMAT_FLAC ;  -- FLAC lossless file format
	CAF       = libsndfile_lib.SF_FORMAT_CAF ;   -- Core Audio File format
	WVE       = libsndfile_lib.SF_FORMAT_WVE ;   -- Psion WVE format
	OGG       = libsndfile_lib.SF_FORMAT_OGG ;   -- Xiph OGG container
	MPC2K     = libsndfile_lib.SF_FORMAT_MPC2K ; -- Akai MPC 2000 sampler
	RF64      = libsndfile_lib.SF_FORMAT_RF64 ;  -- RF64 WAV file
}
local subformats = { -- Subtypes
	PCM_S8    = libsndfile_lib.SF_FORMAT_PCM_S8 ;    -- Signed 8 bit data
	PCM_16    = libsndfile_lib.SF_FORMAT_PCM_16 ;    -- Signed 16 bit data
	PCM_24    = libsndfile_lib.SF_FORMAT_PCM_24 ;    -- Signed 24 bit data
	PCM_32    = libsndfile_lib.SF_FORMAT_PCM_32 ;    -- Signed 32 bit data
	PCM_U8    = libsndfile_lib.SF_FORMAT_PCM_U8 ;    -- Unsigned 8 bit data (WAV and RAW only)
	FLOAT     = libsndfile_lib.SF_FORMAT_FLOAT ;     -- 32 bit float data
	DOUBLE    = libsndfile_lib.SF_FORMAT_DOUBLE ;    -- 64 bit float data
	ULAW      = libsndfile_lib.SF_FORMAT_ULAW ;      -- U-Law encoded.
	ALAW      = libsndfile_lib.SF_FORMAT_ALAW ;      -- A-Law encoded.
	IMA_ADPCM = libsndfile_lib.SF_FORMAT_IMA_ADPCM ; -- IMA ADPCM.
	MS_ADPCM  = libsndfile_lib.SF_FORMAT_MS_ADPCM ;  -- Microsoft ADPCM.
	GSM610    = libsndfile_lib.SF_FORMAT_GSM610 ;    -- GSM 6.10 encoding.
	VOX_ADPCM = libsndfile_lib.SF_FORMAT_VOX_ADPCM ; -- Oki Dialogic ADPCM encoding.
	G721_32   = libsndfile_lib.SF_FORMAT_G721_32 ;   -- 32kbs G721 ADPCM encoding.
	G723_24   = libsndfile_lib.SF_FORMAT_G723_24 ;   -- 24kbs G723 ADPCM encoding.
	G723_40   = libsndfile_lib.SF_FORMAT_G723_40 ;   -- 40kbs G723 ADPCM encoding.
	DWVW_12   = libsndfile_lib.SF_FORMAT_DWVW_12 ;   -- 12 bit Delta Width Variable Word encoding.
	DWVW_16   = libsndfile_lib.SF_FORMAT_DWVW_16 ;   -- 16 bit Delta Width Variable Word encoding.
	DWVW_24   = libsndfile_lib.SF_FORMAT_DWVW_24 ;   -- 24 bit Delta Width Variable Word encoding.
	DWVW_N    = libsndfile_lib.SF_FORMAT_DWVW_N ;    -- N bit Delta Width Variable Word encoding.
	DPCM_8    = libsndfile_lib.SF_FORMAT_DPCM_8 ;    -- 8 bit differential PCM (XI only)
	DPCM_16   = libsndfile_lib.SF_FORMAT_DPCM_16 ;   -- 16 bit differential PCM (XI only)
	VORBIS    = libsndfile_lib.SF_FORMAT_VORBIS ;    -- Xiph Vorbis encoding.
}
local endianess = {
	FILE      = libsndfile_lib.SF_ENDIAN_FILE ;   -- Default file endian-ness.
	LITTLE    = libsndfile_lib.SF_ENDIAN_LITTLE ; -- Force little endian-ness.
	BIG       = libsndfile_lib.SF_ENDIAN_BIG ;    -- Force big endian-ness.
	CPU       = libsndfile_lib.SF_ENDIAN_CPU ;    -- Force CPU endian-ness.
}
local masks = {
	SUB    = libsndfile_lib.SF_FORMAT_SUBMASK ;
	TYPE   = libsndfile_lib.SF_FORMAT_TYPEMASK ;
    ENDIAN = libsndfile_lib.SF_FORMAT_ENDMASK ;
}
reverse_lookup ( majformats , majformats )
reverse_lookup ( subformats , subformats )
reverse_lookup ( endianess , endianess )
reverse_lookup ( masks , masks )

local sf_assert = function ( err )
	if err ~= 0 then
		error ( ffi.string ( libsndfile_lib.sf_error_number ( err ) ) , 2 )
	end
end

local function version ( )
	local data = ffi.new ( "char[128]" )
	libsndfile_lib.sf_command ( nil , libsndfile_lib.SFC_GET_LIB_VERSION , data , ffi.sizeof ( data ) )
	local str = ffi.string ( data )
	local maj , min , inc = str:match ( "(%d+).(%d+).(%d+)" )
	return str , tonumber ( maj ) , tonumber ( min ) , tonumber ( inc )
end

local function mask_format ( f )
	local major = majformats [ band ( masks.TYPE , f ) ]
	local minor = subformats [ band ( masks.SUB , f ) ]
	local endianess = endianess [ band ( masks.ENDIAN , f ) ]
	return major , minor , endianess
end

local function format_info ( f )
	local data = ffi.new ( "SF_FORMAT_INFO[1]" )

	data[0].format = f
	sf_assert ( libsndfile_lib.sf_command ( nil , libsndfile_lib.SFC_GET_FORMAT_INFO , data , ffi.sizeof ( "SF_FORMAT_INFO" ) ) )

	local typename = ffi.string ( data[0].name )
	local extension = ffi.string ( data[0].extension )

	data[0].format = band ( f , masks.SUB )
	sf_assert ( libsndfile_lib.sf_command ( nil , libsndfile_lib.SFC_GET_FORMAT_INFO , data , ffi.sizeof ( "SF_FORMAT_INFO" ) ) )
	local subname = ffi.string ( data[0].name )

	return typename , subname , extension
end

-- For info, sample_rate , channels , format are required when the input file is a RAW file
local function openpath ( path , mode , info )
	assert ( path , "No path provided" )

	if mode == nil or mode == "r" then
		mode = libsndfile_lib.SFM_READ
	elseif mode == "w" then
		mode = libsndfile_lib.SFM_WRITE
	elseif mode == "rw" then
		mode = libsndfile_lib.SFM_RDWR
	end

	info = info or { }
	info = ffi.new ( "SF_INFO[1]" , info )

	local sndfile = libsndfile_lib.sf_open ( path , mode , info )
	if sndfile == nil then
		error ( ffi.string ( libsndfile_lib.sf_strerror ( sndfile ) ) )
	end

	return sndfile , info[0]
end


local sndfile_methods = { }
local sndfile_mt = { __index = sndfile_methods }

--[[
function sndfile_methods:seek ( frames , whence )
	whence = whence or libsndfile_lib.SEEK_SET

	res = libsndfile_lib.sf_seek ( self , frames , whence )

	if res == -1 then error ( "Unable to seek" )
	return res
end--]]

function sndfile_methods:close ( )
	sf_assert ( libsndfile_lib.sf_close ( self ) )
end
sndfile_mt.__gc = sndfile_methods.close


sndfile_methods.read_short 	= libsndfile_lib.sf_readf_short
sndfile_methods.read_int 	= libsndfile_lib.sf_readf_int
sndfile_methods.read_float 	= libsndfile_lib.sf_readf_float
sndfile_methods.read_double	= libsndfile_lib.sf_readf_double

sndfile_methods.write_short 	= libsndfile_lib.sf_writef_short
sndfile_methods.write_int   	= libsndfile_lib.sf_writef_int
sndfile_methods.write_float 	= libsndfile_lib.sf_writef_float
sndfile_methods.write_double	= libsndfile_lib.sf_writef_double


ffi.metatype ( "SNDFILE" , sndfile_mt )

return {
	majformats = majformats ;
	subformats = subformats ;
	endianess = endianess ;
	masks = masks ;
	mask_format = mask_format ;
	format_info = format_info ;

	version = version ;
	openpath = openpath ;
}
