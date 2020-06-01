/*
 * Lwip_main.c
 *
 *  Created on: 2019年11月8日
 *      Author: HP
 */


#include <stdio.h>
#include "sleep.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "sys_intr.h"
#include "lwip/err.h"
#include "lwipopts.h"
#include "netif/xadapter.h"
#include "lwipopts.h"
#include "xil_cache.h"
#include "udp_transmission.h"
#include "xgpio.h"
#include "xtime_l.h"
#include "xpm_counter.h"

u32 data[12];
u32 i;
int num;
char stop_flag;//停止处理

#define INT_CFG0_OFFSET 		0x00000C00
#define COUNTS_PER_SECOND 	 	(XPAR_CPU_CORTEXA9_CORE_CLOCK_FREQ_HZ / 64)
// Parameter definitions
#define SW1_INT_ID              61
#define EX_INTC_DEVICE_ID       XPAR_PS7_SCUGIC_0_DEVICE_ID
#define INT_TYPE_RISING_EDGE    0x03
#define INT_TYPE_HIGHLEVEL      0x01
#define INT_TYPE_MASK           0x03

#define AXI_GPIO_DEV_ID     XPAR_AXI_GPIO_0_DEVICE_ID
//#define BTN_CHANNEL         2
//#define LED_CHANNEL         1

XGpio   Gpio;
static XScuGic INTCInst;

static  XScuGic Intc; //GIC

extern struct udp_pcb *connected_pcb;

extern void lwip_init(void);



static void SW_intr_Handler(void *param);
static int IntcInitFunction(u16 DeviceId);

void init_intr_sys(void)
{
	Init_Intr_System(&Intc); // initial interrupt system
	Setup_Intr_Exception(&Intc);
}
static void SW_intr_Handler(void *param)
{
    int sw_id = (int)param;
    printf("SW%d int\n\r", sw_id);
    XGpio_DiscreteWrite(&Gpio, 2, 0);
    for(i=0;i<14;i++)
    {

	   data[i]=Xil_In32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+i*4);
	   udp_printf(&data[i],4);
	   xil_printf("%d=%d, ",i,data[i]);
    }
    XGpio_DiscreteWrite(&Gpio, 2, 1);
//   xemacif_input(netif);//将MAC队列里的packets传输到你的LwIP/IP stack里
   xil_printf("\r\n");
}

void IntcTypeSetup(XScuGic *InstancePtr, int intId, int intType)
{
    int mask;

    intType &= INT_TYPE_MASK;
    mask = XScuGic_DistReadReg(InstancePtr, INT_CFG0_OFFSET + (intId/16)*4);
    mask &= ~(INT_TYPE_MASK << (intId%16)*2);
    mask |= intType << ((intId%16)*2);
    XScuGic_DistWriteReg(InstancePtr, INT_CFG0_OFFSET + (intId/16)*4, mask);
}

int IntcInitFunction(u16 DeviceId)
{
    XScuGic_Config *IntcConfig;
    int status;

    // Interrupt controller initialisation
    IntcConfig = XScuGic_LookupConfig(DeviceId);
    status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
    if(status != XST_SUCCESS) return XST_FAILURE;


//    // Call to interrupt setup
//    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
//                                 (Xil_ExceptionHandler)XScuGic_InterruptHandler,
//                                 &INTCInst);
//    Xil_ExceptionEnable();

    // Connect SW1~SW3 interrupt to handler
    status = XScuGic_Connect(&INTCInst,
                             SW1_INT_ID,
                             (Xil_ExceptionHandler)SW_intr_Handler,
                             (void *)1);
    if(status != XST_SUCCESS) return XST_FAILURE;


    // Set interrupt type of SW1~SW2 to rising edge
    IntcTypeSetup(&INTCInst, SW1_INT_ID, INT_TYPE_RISING_EDGE);

    // Enable SW1~SW2 interrupts in the controller
    XScuGic_Enable(&INTCInst, SW1_INT_ID);


    return XST_SUCCESS;
}
int main()
{
    char ReadFlag=0;
    char ReadFlag1=0;
    char ARM_read=0;//没用上
    char ProcessOver=0;
    char ff = 1;//没用上
    char and = 0;
    u32 MonopulseExThreshould;//单脉冲提取的阈值
    u32 MonopulseExHold;//下降沿时小于单脉冲提取的阈值前的点数
    u32 MonopulseMultiThreshould;//下降沿后又出现大于单脉冲提取的阈值，这之间的点数小于这个值
    u32 MonopulseEndHold;
    u32 GentalThreshould;//稳定值
    u32 GentalThreshouldNum;//小于稳定值的数量
    XTime tEnd,tCur;
    u32 tUsed;
    u32 Processnum;
    struct pbuf *pbuf_to_be_sent;
    struct udp_pcb *pcb=connected_pcb;
	struct ip_addr ipaddr, netmask, gw;
	struct netif *netif, server_netif;
	/* the mac address of the board. this should be unique per board */
	unsigned char mac_ethernet_address[] = { 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };

	num = 0;
    stop_flag = 0;
    Processnum = 0;
	MonopulseExThreshould = 160;
	MonopulseExHold = 6;
	MonopulseMultiThreshould = 10;
	MonopulseEndHold = 20;
	GentalThreshould = 105;
	GentalThreshouldNum = 3;
	XGpio_Initialize(&Gpio, AXI_GPIO_DEV_ID);
	XGpio_SetDataDirection(&Gpio, 1, 0);
	XGpio_SetDataDirection(&Gpio, 2, 0);
	init_intr_sys();
	XGpio_DiscreteWrite(&Gpio, 1, 0);
	XGpio_DiscreteWrite(&Gpio, 2, 0);

	netif = &server_netif;

	IP4_ADDR(&ipaddr,  192, 168,   1,  10);
	IP4_ADDR(&netmask, 255, 255, 255,  0);
	IP4_ADDR(&gw,      192, 168,   1,  1);

	/*lwip library init*/
	lwip_init();
	/* Add network interface to the netif_list, and set it as default */
	if (!xemac_add(netif, &ipaddr, &netmask, &gw, mac_ethernet_address, XPAR_XEMACPS_0_BASEADDR)) {
		xil_printf("Error adding N/W interface\r\n");
		return -1;
	}
	netif_set_default(netif);

	/* specify that the network if is up */
	netif_set_up(netif);

	/* initialize tcp pcb */
	udp_recv_init();
//	sleep(2);

//	 IntcInitFunction(EX_INTC_DEVICE_ID);
	while(1)
	{
		Xil_Out32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR,MonopulseExThreshould);
		Xil_Out32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+4,MonopulseExHold);
		Xil_Out32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+8,MonopulseMultiThreshould);
		Xil_Out32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+12,MonopulseEndHold);
		Xil_Out32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+20,GentalThreshould);
		Xil_Out32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+24,GentalThreshouldNum);
//
	    xemacif_input(netif);//将MAC队列里的packets传输到你的LwIP/IP stack里
        ReadFlag = Xil_In32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+64);//SENDOVER一个单脉冲处理结束表示可以开始读取数据
        ARM_read = 1;
        ProcessOver = Xil_In32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+68);//ProcessOver25个工频周期处理结束标志位
        and = ReadFlag&ff&ARM_read;
        // if(XGpio_DiscreteRead(&Gpio, BTN_CHANNEL))
        if(and)
        {
        	num = num + 1;
        	XGpio_DiscreteWrite(&Gpio, 2, 0);
            for(i=0;i<17;i++)
            {
//            	XTime_GetTime(&tCur);
                data[i]=Xil_In32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+i*4);
//                XTime_GetTime(&tEnd);
//				tUsed = ((tEnd - tCur)*1000000)/(COUNTS_PER_SECOND);
//				xil_printf("time elapsed is %d us\r\n",tUsed);
//                udp_printf(&data[i],4);
//               xil_printf("%d=%d, ",i,data[i]);

            }
//             xil_printf("%d, ",data[1]);
//             xil_printf("%d",data[5]);
            xil_printf("%d,",data[1]);
			xil_printf("%d,",0);
			xil_printf("%d,",data[2]);
			xil_printf("%d,",data[3]);
			xil_printf("%d,",data[4]);
			xil_printf("%d,",data[5]);
			xil_printf("%d,",data[6]);
			xil_printf("%d,",data[7]);
			xil_printf("%d,",data[8]);
			xil_printf("%d,",data[9]);
			xil_printf("%d,",data[10]);
			xil_printf("%d,",data[11]);
			xil_printf("%d,",data[12]);
			xil_printf("%d,",data[13]);
			xil_printf("%d",data[14]);
            XGpio_DiscreteWrite(&Gpio, 2, 1);
            ARM_read = 0;
            //Xil_Out32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR,1);
//            XTime_GetTime(&tCur);
            xil_printf("\r\n");
        }
        if(stop_flag)
        {
        	XGpio_DiscreteWrite(&Gpio, 1, 0);//收到上位机停止采样指令后指示灯1灭
            Xil_Out32(XPAR_EMC_0_S_AXI_MEM0_BASEADDR+16,1);//停止采样标志置1
            stop_flag = 0;
            Processnum = 0;
        }
        if(ProcessOver)
        {

        	XGpio_DiscreteWrite(&Gpio, 1, 0);//25个工频周期处理结束后指示灯1灭
//        	xil_printf("Processnum = %d\r\n",Processnum);
        	Processnum = Processnum + 1;
//        	if(num!=0)
//        		xil_printf("num = %d\r\n",num);
//        	num = 0;
        }
	}
    return 0;
}







