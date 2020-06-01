/*
 * udp_transmission.h
 *
 *  Created on: 2019Äê11ÔÂ9ÈÕ
 *      Author: HP
 */

#ifndef SRC_UDP_TRANSMISSION_H_
#define SRC_UDP_TRANSMISSION_H_

#include "lwip/err.h"
#include "lwip/udp.h"
#include "lwipopts.h"


void udp_recv_callback(void *arg, struct udp_pcb *tpcb,
                               struct pbuf *p, struct ip_addr *addr, u16_t port);
int udp_recv_init(void);
void udp_printf(u32 *ctrl1,u16 length);

#endif /* SRC_UDP_TRANSMISSION_H_ */
