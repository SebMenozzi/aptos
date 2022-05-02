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

/**
 * Create a core object allocated to the heap, will return a raw pointer
 */
struct Core *create_core(const char *aptos_rest_url, const char *aptos_faucet_url);

/**
 * Deallocate core object
 */
void free_core(struct Core *core);

/**
 * Call a synchronous request
 */
struct RustData rust_call_sync(struct Core *core, const uint8_t *data, uintptr_t len);

/**
 * Call an asynchronous request
 */
void rust_call_async(struct Core *core,
                     const uint8_t *data,
                     uintptr_t len,
                     struct RustCallback callback);

/**
 * Free rust data
 */
void rust_free_data(struct RustData data);
