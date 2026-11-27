// wcp-import: see wcp_untar.h. liblzma is declared the way itch_7z.c does, so no lzma.h is needed.
#include "wcp_untar.h"
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

typedef struct {
    const uint8_t *next_in; size_t avail_in; uint64_t total_in;
    uint8_t *next_out; size_t avail_out; uint64_t total_out;
    const void *allocator; void *internal;
    void *r1, *r2, *r3, *r4; uint64_t ri1, ri2; size_t ri3, ri4; int re1, re2;
} wcp_lzma_stream;
extern int lzma_stream_decoder(wcp_lzma_stream *strm, uint64_t memlimit, uint32_t flags);
extern int lzma_code(wcp_lzma_stream *strm, int action);
extern void lzma_end(wcp_lzma_stream *strm);

enum { ST_HEADER, ST_BODY, ST_SKIP, ST_LONGNAME, ST_DONE };

typedef struct {
    const char *dest; uint32_t max_files; uint64_t max_bytes;
    int state, err, fd, zero_blocks;
    uint8_t hdr[512]; size_t hdr_have;
    uint64_t remain, pad;      /* data left in this entry, padding to the next 512 */
    char type;
    char name[1100]; size_t name_len; char longname[1100]; int have_long;
    uint32_t files; uint64_t bytes;
} untar;

static int safe_name(const char *n)
{
    size_t l = strlen(n);
    if (!l || l > 1000 || n[0] == '/') return 0;
    if (strchr(n, '\\') || strchr(n, ':')) return 0;
    for (const char *p = n; *p;) {
        const char *e = strchr(p, '/');
        size_t seg = e ? (size_t)(e - p) : strlen(p);
        if (seg == 2 && p[0] == '.' && p[1] == '.') return 0;
        if (!e) break;
        p = e + 1;
    }
    return 1;
}

static uint64_t octal(const uint8_t *p, size_t n)
{
    uint64_t v = 0;
    if (p[0] & 0x80) { for (size_t i = 1; i < n; i++) v = (v << 8) | p[i]; return v; }   /* base-256 */
    for (size_t i = 0; i < n && p[i] >= '0' && p[i] <= '7'; i++) v = (v << 3) | (uint64_t)(p[i] - '0');
    return v;
}

static int make_dirs(const char *dest, const char *rel)
{
    char path[2200]; snprintf(path, sizeof path, "%s/%s", dest, rel);
    for (char *p = path + strlen(dest) + 1; *p; p++)
        if (*p == '/') { *p = 0; if (mkdir(path, 0755) && errno != EEXIST) return -1; *p = '/'; }
    return 0;
}

static void begin_entry(untar *u)
{
    const uint8_t *h = u->hdr;
    int blank = 1;
    for (int i = 0; i < 512; i++) if (h[i]) { blank = 0; break; }
    if (blank) { if (++u->zero_blocks >= 2) u->state = ST_DONE; return; }
    u->zero_blocks = 0;
    uint64_t sum = 0, want = octal(h + 148, 8);
    for (int i = 0; i < 512; i++) sum += (i >= 148 && i < 156) ? ' ' : h[i];
    if (sum != want) { u->err = WCP_DAMAGED; return; }
    u->type = (char)h[156];
    u->remain = octal(h + 124, 12);
    u->pad = (512 - (u->remain % 512)) % 512;
    char name[1100]; size_t n = 0;
    if (!memcmp(h + 257, "ustar", 5) && h[345]) {      /* prefix + "/" + name */
        size_t pl = strnlen((const char *)h + 345, 155);
        memcpy(name, h + 345, pl); n = pl; name[n++] = '/';
    }
    size_t nl = strnlen((const char *)h, 100); memcpy(name + n, h, nl); name[n + nl] = 0;
    if (u->have_long) { snprintf(name, sizeof name, "%s", u->longname); u->have_long = 0; }
    if (u->type == 'L') { u->state = ST_LONGNAME; u->name_len = 0; if (u->remain > 1000) u->err = WCP_UNSAFE; return; }
    if (u->type == 'x' || u->type == 'g') { u->state = u->remain ? ST_SKIP : ST_HEADER; if (u->state == ST_SKIP) u->type = 'x'; return; }
    if (u->type == '5' || (u->type == 0 && name[strlen(name) - 1] == '/')) {
        size_t l = strlen(name); while (l && name[l - 1] == '/') name[--l] = 0;
        if (l && !safe_name(name)) { u->err = WCP_UNSAFE; return; }
        if (l && make_dirs(u->dest, name) == 0) { char p[2200]; snprintf(p, sizeof p, "%s/%s", u->dest, name); if (mkdir(p, 0755) && errno != EEXIST) u->err = WCP_IO; }
        u->state = u->remain ? ST_SKIP : ST_HEADER; return;
    }
    if (u->type == '0' || u->type == 0) {
        if (!safe_name(name)) { u->err = WCP_UNSAFE; return; }
        if (++u->files > u->max_files || u->bytes + u->remain > u->max_bytes) { u->err = WCP_TOO_BIG; return; }
        u->bytes += u->remain;
        char p[2200]; snprintf(p, sizeof p, "%s/%s", u->dest, name);
        if (make_dirs(u->dest, name)) { u->err = WCP_IO; return; }
        u->fd = open(p, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW, 0644);   /* never overwrites or follows */
        if (u->fd < 0) { u->err = WCP_UNSAFE; return; }
        u->state = ST_BODY; if (!u->remain) { close(u->fd); u->fd = -1; u->state = ST_HEADER; }
        return;
    }
    u->err = WCP_UNSAFE;   /* symlink, hardlink, device, fifo */
}

static void feed(untar *u, const uint8_t *p, size_t n)
{
    while (n && !u->err && u->state != ST_DONE) {
        if (u->state == ST_HEADER) {
            size_t t = 512 - u->hdr_have; if (t > n) t = n;
            memcpy(u->hdr + u->hdr_have, p, t); u->hdr_have += t; p += t; n -= t;
            if (u->hdr_have == 512) { u->hdr_have = 0; begin_entry(u); }
        } else {
            size_t t = n > u->remain ? (size_t)u->remain : n;
            if (u->state == ST_BODY && t && write(u->fd, p, t) != (ssize_t)t) { u->err = WCP_IO; return; }
            if (u->state == ST_LONGNAME) { memcpy(u->longname + u->name_len, p, t); u->name_len += t; }
            u->remain -= t; p += t; n -= t;
            if (!u->remain) {
                if (u->state == ST_BODY) { close(u->fd); u->fd = -1; }
                if (u->state == ST_LONGNAME) { u->longname[u->name_len] = 0; u->have_long = 1; }
                /* the padding up to 512: counted as skipped bytes */
                size_t pad = (size_t)u->pad; u->pad = 0;
                size_t s = pad > n ? n : pad; p += s; n -= s;
                if (s < pad) { u->remain = pad - s; u->state = ST_SKIP; u->type = 'p'; }
                else u->state = ST_HEADER;
            }
            if (u->state == ST_SKIP && u->type == 'p' && !u->remain) u->state = ST_HEADER;
        }
    }
}

int wcp_untar_xz(const char *archive, const char *dest, uint32_t max_files, uint64_t max_bytes)
{
    FILE *f = fopen(archive, "rb"); if (!f) return WCP_IO;
    uint8_t magic[6]; if (fread(magic, 1, 6, f) != 6 || memcmp(magic, "\xFD" "7zXZ\0", 6)) { fclose(f); return WCP_NOT_XZ; }
    rewind(f);
    untar *u = calloc(1, sizeof *u); uint8_t *in = malloc(1 << 16), *out = malloc(1 << 18);
    wcp_lzma_stream z; memset(&z, 0, sizeof z);
    int rc = WCP_MEMORY;
    if (!u || !in || !out) goto done;
    u->dest = dest; u->max_files = max_files; u->max_bytes = max_bytes; u->fd = -1;
    if (lzma_stream_decoder(&z, 256ULL << 20, 0)) { rc = WCP_DAMAGED; goto done; }
    int ret = 0, eof = 0;
    while (!u->err && ret == 0) {
        if (!z.avail_in && !eof) { z.avail_in = fread(in, 1, 1 << 16, f); z.next_in = in; if (!z.avail_in) eof = 1; }
        z.next_out = out; z.avail_out = 1 << 18;
        ret = lzma_code(&z, eof ? 3 : 0);
        feed(u, out, (1 << 18) - z.avail_out);
        if (ret == 10 && eof) { ret = 9; }
    }
    lzma_end(&z);
    rc = u->err ? u->err : (ret == 1 && u->state == ST_DONE ? WCP_OK : (ret == 1 && u->state == ST_HEADER ? WCP_OK : WCP_DAMAGED));
done:
    if (u && u->fd >= 0) close(u->fd);
    free(u); free(in); free(out); fclose(f);
    return rc;
}

int wcp_pe_kind(const char *path)
{
    FILE *f = fopen(path, "rb"); if (!f) return WCP_PE_NONE;
    uint8_t *d = malloc(1 << 20); if (!d) { fclose(f); return WCP_PE_NONE; }
    size_t got = fread(d, 1, 1 << 20, f); fclose(f);
    int kind = WCP_PE_NONE;
    #define U16(o) ((o) + 2 <= got ? (uint32_t)(d[o] | d[(o) + 1] << 8) : 0)
    #define U32(o) ((o) + 4 <= got ? (uint32_t)(d[o] | d[(o) + 1] << 8 | d[(o) + 2] << 16 | (uint32_t)d[(o) + 3] << 24) : 0)
    if (got > 0x40 && d[0] == 'M' && d[1] == 'Z') {
        uint32_t pe = U32(0x3c);
        if (pe + 0x18 < got && !memcmp(d + pe, "PE\0\0", 4)) {
            uint32_t machine = U16(pe + 4), nsec = U16(pe + 6), optsz = U16(pe + 20), opt = pe + 24, magic = U16(opt);
            if (machine == 0x14c) kind = WCP_PE_X86;
            else if (machine == 0xAA64) kind = WCP_PE_ARM64;
            else if (machine == 0x8664) {
                kind = WCP_PE_X64;
                if (magic == 0x20b) {
                    uint32_t lc_rva = U32(opt + 112 + 10 * 8), sec = opt + optsz;
                    for (uint32_t i = 0; lc_rva && i < nsec; i++) {
                        uint32_t s = sec + i * 40, vs = U32(s + 8), va = U32(s + 12), rs = U32(s + 16), ra = U32(s + 20);
                        if (lc_rva >= va && lc_rva < va + (vs > rs ? vs : rs)) {
                            uint32_t lo = lc_rva - va + ra;
                            /* the load config may lie past the 1 MB read: read it again where it is */
                            uint8_t lc[0xD8]; memset(lc, 0, sizeof lc);
                            FILE *g = fopen(path, "rb");
                            if (g && fseek(g, lo, SEEK_SET) == 0) { size_t r = fread(lc, 1, sizeof lc, g); (void)r; }
                            if (g) fclose(g);
                            uint32_t size = lc[0] | lc[1] << 8 | lc[2] << 16 | (uint32_t)lc[3] << 24;
                            if (size >= 0xD0) { uint64_t chpe = 0; for (int k = 7; k >= 0; k--) chpe = (chpe << 8) | lc[0xC8 + k]; if (chpe) kind = WCP_PE_ARM64EC; }
                            break;
                        }
                    }
                }
            } else kind = WCP_PE_OTHER;
        }
    }
    free(d);
    return kind;
}
