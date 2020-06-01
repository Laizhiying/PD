/*
 * udp_transmission.c
 *
 *  Created on: 2019Äê11ÔÂ9ÈÕ
 *      Author: HP
 */
#include <stdio.h>
#include <string.h>

#include "lwip/err.h"
#include "lwip/udp.h"
#include "lwipopts.h"
#include "netif/xadapter.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "sleep.h"
#include "xgpio.h"

extern char num;
extern XGpio Gpio;
extern char stop_flag;
struct udp_pcb *connected_pcb = NULL;
static struct pbuf *pbuf_to_be_sent = NULL;

static unsigned local_port = 5010;	/* server port */
static unsigned remote_port = 8080;

void udp_printf(u32 *ctrl1,u16 length)
{
	struct pbuf *pbuf_to_be_sent = NULL;
	u32 * message;
	err_t err;
	struct udp_pcb *tpcb = connected_pcb;

	if (!tpcb)
	{
		xil_printf("error return\r\n");
		return;
	}

	message = ctrl1;

	pbuf_to_be_sent = pbuf_alloc(PBUF_TRANSPORT, length, PBUF_POOL);
	memset(pbuf_to_be_sent->payload, 0, length);
	memcpy(pbuf_to_be_sent->payload, (u32 *)message, length);

	err = udp_send(tpcb, pbuf_to_be_sent);
	if (err != ERR_OK)
	{
		xil_printf("Error on udp_send: %d\r\n", err);
		pbuf_free(pbuf_to_be_sent);
		return;
	}
	pbuf_free(pbuf_to_be_sent);

}

void udp_recv_callback(void *arg, struct udp_pcb *tpcb,
                               struct pbuf *p, struct ip_addr *addr, u16_t port)
{

	struct pbuf *q;
	struct pbuf *data_to_be_sent;

	err_t err;
	q = p;
	udp_printf("udp_recv_callback\r\n",19);
	xil_printf("udp_recv_callback!\r\n");
    if(!strcmp("0x20", (char *)q->payload))
    {
    	num = 0;
    	Xil_Out32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+16,0);
    	XGpio_DiscreteWrite(&Gpio, 1, 1);
    	udp_printf("sent\r\n",6);
    	printf("sent!\r\n");
    	data_to_be_sent = pbuf_alloc(PBUF_TRANSPORT, 4, PBUF_POOL);
    	memset(data_to_be_sent->payload, 0, 4);
    	err = udp_send(tpcb, data_to_be_sent);
		if (err != ERR_OK)
		{
			xil_printf("Error on udp_send: %d\r\n", err);
			pbuf_free(data_to_be_sent);
			return;
		}
    	pbuf_free(data_to_be_sent);
    }
    else if(!strcmp("0x33", (char *)q->payload))
    {
    	stop_flag = 1;
    	udp_printf("stop\r\n",6);
    	printf("stop!\r\n");
    	data_to_be_sent = pbuf_alloc(PBUF_TRANSPORT, 4, PBUF_POOL);
    	memset(data_to_be_sent->payload, 0, 4);
    	err = udp_send(tpcb, data_to_be_sent);
		if (err != ERR_OK)
		{
			xil_printf("Error on udp_send: %d\r\n", err);
			pbuf_free(data_to_be_sent);
			return;
		}
    	pbuf_free(data_to_be_sent);
    }
    else
    {
		/*if received ip fragment packets*/

		//xil_printf("udp data come in!%d, %d\r\n", p->tot_len, p->len);
    	xil_printf("Error creating PCB. Out of Memory\r\n");
    	udp_printf("not 0x20\r\n",10);
    	err = udp_sendto(tpcb, p, addr, port);
		pbuf_free(p);
    }

    return;
}


int udp_recv_init()
{
	struct udp_pcb *pcb;
	struct ip_addr ipaddr;
	err_t err;

	printf("start.\r\n");

	/* create new UDP PCB structure */
	pcb = udp_new();
	if (!pcb) {
		xil_printf("Error creating PCB. Out of Memory\r\n");
		return -1;
	}

	/* bind to local port */
	err = udp_bind(pcb, IP_ADDR_ANY, local_port);
	if (err != ERR_OK) {
		xil_printf("udp_recv_init: Unable to bind to port %d: err = %d\r\n", local_port, err);
		return -2;
	}


	IP4_ADDR(&ipaddr,  192, 168,  1, 100);
	err = udp_connect(pcb, &ipaddr, remote_port);
	if (err != ERR_OK)
		xil_printf("error on udp_connect: %x\n\r", err);

	udp_recv(pcb, udp_recv_callback, NULL);

	connected_pcb = pcb;
	udp_printf("start.\r\n",8);
	return 0;
}






