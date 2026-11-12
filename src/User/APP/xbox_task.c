/**
  *********************************************************************
  * @file      xbox_task.c/h
  * @brief     用于读取和处理Xbox手柄数据，
  *            将手柄数据转换为底盘速度、转向角度、翻滚角、腿长等控制量
  * @note       
  * @history
  *
  @verbatim
  ==============================================================================

  ==============================================================================
  @endverbatim
  *********************************************************************
  */
	
#include "xbox_task.h"
#include "cmsis_os.h"

#define M_PI        3.1415926f
#define DEAD_ZONE_JOY 5
#define RIGHT_JOY_DEADZONE 1500 // Ignore small right-stick offsets before target integration.

// 控制系数：保留原调参值和宏名；当前轴映射以 Xbox_data_process 中的字段为准。
// 速度直接赋值；转向、倾斜、腿长按每次调用累加，依赖下方 10 ms 任务周期。
#define RY_SPEED_COEFF  (-0.00002f)
#define RX_TURN_COEFF   (-0.000002f)
#define LX_ROLL_COEFF   (-0.0000003f)
#define LY_LEG_COEFF    (-0.00000008f)

// 限制值
#define ROLL_MIN    -0.40f
#define ROLL_MAX     0.40f
#define ROLL_LEVEL   (-0.03f) // Use the existing startup roll reference.
#define LEG_MIN      0.072f
#define LEG_MAX      0.21f
#define LEG_DEFAULT  0.08f

// 俯仰角限制
#define PITCH_LIMIT_NEG_HIGH (-M_PI/4.0f)
#define PITCH_LIMIT_NEG_LOW  (-M_PI/2.0f)
#define PITCH_LIMIT_POS_HIGH (M_PI/4.0f)
#define PITCH_LIMIT_POS_LOW  (M_PI/2.0f)

// 腿长变化阈值
#define LEG_CHANGE_THRESH 0.0001f
// 上一次的方向键上状态
uint8_t xbox_dirUp_last = 0;
static uint8_t xbox_dirDown_last = 0;

extern chassis_t chassis_move;
extern INS_t INS;
uint32_t XBOX_TIME=10; // 手柄控制周期，单位 ms；传入处理函数时换算为秒

extern vmc_leg_t right;			
extern vmc_leg_t left;	

void xbox_task(void)
{		
   while(1)
	 {
		 Xbox_data_process(&chassis_move, (float)XBOX_TIME/1000.0f);
	   osDelay(XBOX_TIME);
	 }
}

// 将 uart_bsp.c 已解码、去中心和死区处理的 xbox 数据转为底盘目标值。
// dt 单位为秒，仅用于速度到目标位移的积分；其余目标沿用原有每周期增量。
void Xbox_data_process(chassis_t *chassis, float dt)
{   
	if(xbox.btnStart_falling && chassis->start_flag == 0) 
	{
			// Start 松开时产生 falling 事件，启动；消费一次后清除事件
			chassis->start_flag = 1;
			xbox.btnStart_falling = 0; // 清除标志
	}
	else if(xbox.btnStart_falling && chassis->start_flag == 1) 
	{
			// 再次松开 Start 时停止，并退出恢复状态
			chassis->start_flag = 0;
			chassis->recover_flag = 0;
			xbox.btnStart_falling = 0; // 清除标志
	}

	// 检测摔倒并触发恢复
	if(chassis->recover_flag == 0
			&& ((chassis->myPithR < PITCH_LIMIT_NEG_HIGH && chassis->myPithR > PITCH_LIMIT_NEG_LOW)
			|| (chassis->myPithR > PITCH_LIMIT_POS_HIGH && chassis->myPithR < PITCH_LIMIT_POS_LOW)))
	{
			chassis->recover_flag = 1;
			chassis->leg_set = LEG_DEFAULT;
	}
	// 恢复状态：当角度恢复正常时退出恢复状态
	if(chassis->recover_flag == 1
			&& !((chassis->myPithR < PITCH_LIMIT_NEG_HIGH && chassis->myPithR > PITCH_LIMIT_NEG_LOW)
			|| (chassis->myPithR > PITCH_LIMIT_POS_HIGH && chassis->myPithR < PITCH_LIMIT_POS_LOW)))
	{
			chassis->recover_flag = 0;
	}


	// Select 松开事件切换预跳跃模式；退出时同时清除左右腿跳跃阶段。
	if(xbox.btnSelect_falling && chassis->start_flag == 1 && chassis->prejump_flag == 0) 
	{
			chassis->prejump_flag = 1;
			xbox.btnSelect_falling = 0;
	}
	else if(xbox.btnSelect_falling && chassis->prejump_flag == 1) 
	{
			chassis->prejump_flag = 0;
			// 清除跳跃标志
			chassis->jump_flag = 0;
			chassis->jump_flag2 = 0;
			xbox.btnSelect_falling = 0;
	}

	// 跳跃触发：方向键上
	uint8_t dirUp_rise = (xbox.btnDirUp == 1) && (xbox_dirUp_last == 0);
		if(dirUp_rise && chassis->prejump_flag == 1 && chassis->jump_flag == 0 && chassis->jump_flag2 == 0) 
		{
				chassis->jump_flag = 1;
				chassis->jump_flag2 = 1;
		}
		// 更新上一次的状态
		xbox_dirUp_last = xbox.btnDirUp;

	// Track Down in every state so an ignored press is not replayed later.
	uint8_t dirDown = xbox.btnDirDown;
	uint8_t dirDown_rise = (dirDown == 1) && (xbox_dirDown_last == 0);
	xbox_dirDown_last = dirDown;

	// ===================== 控制逻辑：Xbox手柄 =====================
	if(chassis->start_flag == 1)
	{
			int16_t roll_input = xbox.joyRHori;
			int16_t leg_input = xbox.joyRVert;

			if (roll_input >= -RIGHT_JOY_DEADZONE && roll_input <= RIGHT_JOY_DEADZONE)
			{
				roll_input = 0;
			}
			if (leg_input >= -RIGHT_JOY_DEADZONE && leg_input <= RIGHT_JOY_DEADZONE)
			{
				leg_input = 0;
			}

			// 左摇杆纵向：前后速度 v_set (m/s)，再积分为位置目标 x_set (m)
			chassis->v_set = -(float)xbox.joyLVert * RY_SPEED_COEFF;
			chassis->x_set += chassis->v_set * dt;

			// 左摇杆横向：累加偏航角目标 turn_set (rad)，由轮毂差动实现转向
			chassis->turn_set += (float)xbox.joyLHori * RX_TURN_COEFF;

			// Down restores roll only; keep leg_set and ignore this cycle's right-stick input.
			if (dirDown_rise && chassis->recover_flag == 0
					&& chassis->jump_flag == 0 && chassis->jump_flag2 == 0)
			{
				chassis->roll_set = ROLL_LEVEL;
			}
			else
			{
				// 右摇杆横向：累加横滚角目标 roll_set (rad)，两腿支撑力补偿实现倾斜
				chassis->roll_set += (float)roll_input * LX_ROLL_COEFF;
				mySaturate(&chassis->roll_set, ROLL_MIN, ROLL_MAX);

				// 右摇杆纵向：累加共同腿长目标 leg_set (m)，推前升高、拉后降低
				chassis->leg_set += -(float)leg_input * LY_LEG_COEFF;
				mySaturate(&chassis->leg_set, LEG_MIN, LEG_MAX);
			}

			// 检测腿长变化，触发腿标志
			if(fabsf(chassis->last_leg_set - chassis->leg_set) > LEG_CHANGE_THRESH)
			{
					right.leg_flag = 1;
					left.leg_flag = 1;
			}
			else
			{
					right.leg_flag = 0;
					left.leg_flag = 0;
			}
			chassis->last_leg_set = chassis->leg_set;
	} 
	// ===================== 停止状态 =====================
	else if(chassis->start_flag == 0)
	{
			// 停止时将位移、偏航目标对齐反馈，恢复默认腿长和横滚角。
			chassis->v_set = 0.0f;
			chassis->x_set = chassis->x_filter;
			chassis->turn_set = chassis->total_yaw;
			chassis->leg_set = LEG_DEFAULT;
			chassis->roll_set = ROLL_LEVEL;

			// 停止时，腿标志置0，这样腿不会持续运动
			right.leg_flag = 0;
			left.leg_flag = 0;

			// 清除跳跃标志
			chassis->jump_flag = 0;
			chassis->jump_flag2 = 0;
	}
}
