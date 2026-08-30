OBK_DIR = $(TOP_DIR)/apps/$(APP_BIN_NAME)/

BERRY_MODULEPATH = $(OBK_DIR)/src/berry/modules
BERRY_SRCPATH = $(OBK_DIR)/libraries/berry/src/

include $(OBK_DIR)/libraries/berry.mk

SRC_C += $(BERRY_SRC_C)

CPPDEFINES += -DOBK_VARIANT=$(OBK_VARIANT)
CPPDEFINES += -D__FILE__=\"\" -Wno-builtin-macro-redefined

# The SDK's lwip-2.1.3 mqtt.c is the older 2.1.2-era code that corrupts
# incoming PUBLISH messages spanning several TCP segments; swap it for the
# app's fixed copy (see libraries/mqtt_patched_beken.c). This runs after the
# SDK's application.mk has already added its mqtt.c, so filter-out works.
ifneq ($(filter $(TARGET_PLATFORM),bk7231n bk7231t),)
ifeq ($(CFG_LWIP_2_1_3),1)
SRC_C := $(filter-out ./beken378/func/lwip_intf/lwip-2.1.3/src/apps/mqtt/mqtt.c,$(SRC_C))
SRC_C += $(OBK_DIR)/libraries/mqtt_patched_beken.c
endif
endif

ifeq ($(TARGET_PLATFORM),bk7231n)

CFG_USE_MQTT_TLS ?= 0

ifeq ($(CFG_USE_MQTT_TLS),1)

MBEDTLS_DIR = $(TOP_DIR)/apps/$(APP_BIN_NAME)/output/mbedtls-2.28.5
INCLUDES := -I$(MBEDTLS_DIR)/include -I$(TOP_DIR)/apps/$(APP_BIN_NAME)/src $(INCLUDES)
MQTT_TLS_DEFS += -DMQTT_USE_TLS=1
MQTT_TLS_DEFS += -DLWIP_ALTCP=1
MQTT_TLS_DEFS += -DLWIP_ALTCP_TLS=1
MQTT_TLS_DEFS += -DLWIP_ALTCP_TLS_MBEDTLS=1
MQTT_TLS_DEFS += -DMEMP_NUM_ALTCP_PCB=4
MQTT_TLS_DEFS += -DMBEDTLS_CONFIG_FILE='"user_mbedtls_config.h"'
CPPDEFINES += $(MQTT_TLS_DEFS) -Wno-misleading-indentation
OSFLAGS += $(MQTT_TLS_DEFS)

SRC_C += ./beken378/func/lwip_intf/lwip-2.1.3/src/apps/altcp_tls/altcp_tls_mbedtls.c
SRC_C += ./beken378/func/lwip_intf/lwip-2.1.3/src/apps/altcp_tls/altcp_tls_mbedtls_mem.c
SRC_C += ${MBEDTLS_DIR}/library/ssl_tls.c
SRC_C += ${MBEDTLS_DIR}/library/x509_crt.c
SRC_C += ${MBEDTLS_DIR}/library/entropy.c
SRC_C += ${MBEDTLS_DIR}/library/chachapoly.c
SRC_C += ${MBEDTLS_DIR}/library/ctr_drbg.c
SRC_C += ${MBEDTLS_DIR}/library/ssl_msg.c
SRC_C += ${MBEDTLS_DIR}/library/debug.c
SRC_C += ${MBEDTLS_DIR}/library/md.c
SRC_C += ${MBEDTLS_DIR}/library/sha512.c
SRC_C += ${MBEDTLS_DIR}/library/platform_util.c
SRC_C += ${MBEDTLS_DIR}/library/sha256.c
SRC_C += ${MBEDTLS_DIR}/library/sha1.c
SRC_C += ${MBEDTLS_DIR}/library/ripemd160.c
SRC_C += ${MBEDTLS_DIR}/library/md5.c
SRC_C += ${MBEDTLS_DIR}/library/cipher.c
SRC_C += ${MBEDTLS_DIR}/library/gcm.c
SRC_C += ${MBEDTLS_DIR}/library/chacha20.c
SRC_C += ${MBEDTLS_DIR}/library/ccm.c
SRC_C += ${MBEDTLS_DIR}/library/constant_time.c
SRC_C += ${MBEDTLS_DIR}/library/aes.c
SRC_C += ${MBEDTLS_DIR}/library/poly1305.c
SRC_C += ${MBEDTLS_DIR}/library/pem.c
SRC_C += ${MBEDTLS_DIR}/library/des.c
SRC_C += ${MBEDTLS_DIR}/library/asn1parse.c
SRC_C += ${MBEDTLS_DIR}/library/base64_mbedtls.c
SRC_C += ${MBEDTLS_DIR}/library/x509.c
SRC_C += ${MBEDTLS_DIR}/library/oid.c
SRC_C += ${MBEDTLS_DIR}/library/pkparse.c
SRC_C += ${MBEDTLS_DIR}/library/ecp.c
SRC_C += ${MBEDTLS_DIR}/library/bignum.c
SRC_C += ${MBEDTLS_DIR}/library/pk.c
SRC_C += ${MBEDTLS_DIR}/library/pk_wrap.c
SRC_C += ${MBEDTLS_DIR}/library/ecdsa.c
SRC_C += ${MBEDTLS_DIR}/library/asn1write.c
SRC_C += ${MBEDTLS_DIR}/library/hmac_drbg.c
SRC_C += ${MBEDTLS_DIR}/library/rsa.c
SRC_C += ${MBEDTLS_DIR}/library/rsa_internal.c
SRC_C += ${MBEDTLS_DIR}/library/ecp_curves.c
SRC_C += ${MBEDTLS_DIR}/library/ssl_ciphersuites.c
SRC_C += ${MBEDTLS_DIR}/library/ecdh.c
SRC_C += ${MBEDTLS_DIR}/library/dhm.c
SRC_C += ${MBEDTLS_DIR}/library/ssl_srv.c
SRC_C += ${MBEDTLS_DIR}/library/cipher_wrap.c
SRC_C += ${MBEDTLS_DIR}/library/arc4.c
SRC_C += ${MBEDTLS_DIR}/library/blowfish.c
SRC_C += ${MBEDTLS_DIR}/library/camellia.c
SRC_C += ${MBEDTLS_DIR}/library/ssl_cli.c

endif   #ifeq ($(CFG_USE_MQTT_TLS),1)
endif   #ifeq ($(TARGET_PLATFORM),bk7231n)

SRC_C += $(OBK_DIR)/libraries/easyflash/ports/ef_port.c
SRC_C += $(OBK_DIR)/libraries/easyflash/src/easyflash.c
SRC_C += $(OBK_DIR)/libraries/easyflash/src/ef_env.c
SRC_C += $(OBK_DIR)/libraries/easyflash/src/ef_utils.c
INCLUDES += -I$(OBK_DIR)/libraries/easyflash/inc
