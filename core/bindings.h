#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct Core Core;

typedef struct RustData {
  const uint8_t *ptr;
  uintptr_t len;
  uintptr_t cap;
  const char *err;
} RustData;

typedef struct RustCallback {
  const void *swift_callback_ptr;
  void (*callback)(const void*, struct RustData);
} RustCallback;

struct Core *create_core(const char *aptos_url);

void free_core(struct Core *core);

struct RustData rust_call(struct Core *core, const uint8_t *data, uintptr_t len);

void rust_call_async(struct Core *core,
                     const uint8_t *data,
                     uintptr_t len,
                     struct RustCallback callback);

void rust_free_data(struct RustData data);
