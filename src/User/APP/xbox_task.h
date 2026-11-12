#ifndef __XBOX_TASK_H
#define __XBOX_TASK_H

#include "main.h"
#include "chassisR_task.h"
#include "ins_task.h"
#include "uart_bsp.h"

extern void Xbox_data_process(chassis_t *chassis, float dt);
extern void xbox_task(void);

#endif
