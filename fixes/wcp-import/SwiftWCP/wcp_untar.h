// wcp-import: unpack a Winlator-style .wcp (an xz-compressed tar) and tell a DLL's kind. DRAFT, host-tested only.
#ifndef wcp_untar_h
#define wcp_untar_h
#include <stdint.h>

enum { WCP_OK = 0, WCP_NOT_XZ = 1, WCP_DAMAGED = 2, WCP_UNSAFE = 3, WCP_TOO_BIG = 4, WCP_IO = 5, WCP_MEMORY = 6 };

/// Streams `archive` (xz) as a tar into the EXISTING empty folder `dest`. Only regular files and folders are made:
/// links, devices, absolute names, "..", backslashes and names with a ":" or NUL are refused (WCP_UNSAFE).
/// More than max_files files or max_bytes of file data is refused (WCP_TOO_BIG).
int wcp_untar_xz(const char *archive, const char *dest, uint32_t max_files, uint64_t max_bytes);

enum { WCP_PE_NONE = 0, WCP_PE_X64 = 1, WCP_PE_ARM64EC = 2, WCP_PE_ARM64 = 3, WCP_PE_X86 = 4, WCP_PE_OTHER = 5 };

/// What kind of PE image `path` is. ARM64EC images say machine 0x8664 like x64 ones; they are told apart by the
/// load config's CHPE metadata pointer (non-zero), checked on a real DXVK ARM64EC package and a plain x64 one.
int wcp_pe_kind(const char *path);
#endif
