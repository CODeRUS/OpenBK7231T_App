// The Beken FreeRTOS SDKs (sdk/beken_freertos_sdk, sdk/OpenBK7231T,
// sdk/OpenBK7231N - their lwip-2.1.3 mqtt.c is byte-identical) ship the older
// 2.1.2-era implementation with the known incoming-fragmentation bug: a PUBLISH
// spanning several TCP segments is delivered to the data callback only when
// rx_buffer happens to be exactly full, and the undelivered tail of the previous
// segment is overwritten by the next one. A ~2.4KB payload (e.g. SendIR2 raw:...)
// arrives as 1460+1003 byte segments, so bytes are lost: with a small buffer the
// command reaches the app corrupted, with a 4KB buffer the leftover garbage is
// parsed as a new "first frame" and the client disconnects.
//
// This wrapper compiles the app's fixed copy (libraries/mqtt_patched.c,
// upstream lwip 2.1.3+ logic) instead of the SDK's mqtt.c. On BK723x the
// linker then never pulls mqtt.o from liblwip.a; on the old BK7231T/N SDKs
// components.mk also filter-outs the SDK's mqtt.c from SRC_C.
//
// The SDK's mqtt_priv.h uses SemaphoreHandle_t but only includes FreeRTOS.h;
// the SDK's own mqtt.c gets away with it via sys_rtos.h, so include the RTOS
// headers before it.
#include <FreeRTOS.h>
#include <semphr.h>

#include "mqtt_patched.c"

// Beken extension declared in the SDK's mqtt.h and called by new_mqtt.c before
// reconnecting. The patched mqtt_client_connect() wipes the client itself, so
// only reset the state here, keeping the registered callbacks (there is no
// output ringbuf mutex in the patched implementation, nothing else to free).
void mqtt_client_cleanup(mqtt_client_t *client)
{
	mqtt_incoming_data_cb_t data_cb;
	mqtt_incoming_publish_cb_t pub_cb;
	void *inpub_arg;

	if (client == NULL) {
		return;
	}
	data_cb = client->data_cb;
	pub_cb = client->pub_cb;
	inpub_arg = client->inpub_arg;
	memset(client, 0, sizeof(mqtt_client_t));
	client->data_cb = data_cb;
	client->pub_cb = pub_cb;
	client->inpub_arg = inpub_arg;
}
