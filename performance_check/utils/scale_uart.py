import serial
import struct
from utils.bit_operation import *

class Scale_UART:
	def __init__(self, device):
		self.ser = serial.Serial(device, 921600)
		#self.ser = serial.Serial(device, 460800)
		self.ser.reset_input_buffer()
		self.ser.reset_output_buffer()

	def su_flush_buffer(self):
		self.ser.reset_input_buffer()
		self.ser.reset_output_buffer()
		return None

# write data with little endian
	def su_write_data_trans(self, addr, value):
		write_op = 0x4
		res = (write_op << 60) | (addr << 32) | (value)
		byte_num = struct.pack('>Q', res)
		for i in range(4):
			self.ser.write(bytearray([byte_num[i]]))
		for i in range(4):
			self.ser.write(bytearray([byte_num[7-i]]))
		return None

# write data with big endian
	def su_write_data(self, addr, value):
		write_op = 0x4
		res = (write_op << 60) | (addr << 32) | (value)
		byte_num = struct.pack('>Q', res)
		for i in range(8):
			self.ser.write(bytearray([byte_num[i]]))
		return None

# read data from address
	def su_read_data(self, addr):
		read_op = 0x5
		res = (read_op << 60) | (addr << 32)
		byte_num = struct.pack('>Q', res)
		for i in range(8):
			self.ser.write(bytearray([byte_num[i]]))
		packet = []
		for i in range(4):
			temp = self.ser.read(size=1)
			packet.append(ord(temp))
		return packet

# read image file
# write_data in little endian on base_addr + i * 4
	def su_set_image(self, image_info, f_name):
		base_addr = image_info['BASE_ADDR']
		img_data = np.load(f_name)
		count = 0
		d_str = ""
		for data_slice1 in img_data:
			for data_slice2 in data_slice1:
				for data_slice3 in data_slice2:
					for data_slice4 in data_slice3:
						count += 1
						bin_data = data_to_8bit_binary(data_slice4)
						d_str += f'{bin_data:02x}'
						if count % 4 == 0:
							d_str = "0x" + d_str
							val = int(d_str, 0)
							self.su_write_data_trans(base_addr + (count - 4), val)
							d_str = ""
		return None

	def su_set_image_one(self, image_info, f_name):
		base_addr = image_info['BASE_ADDR']
		img_data = np.load(f_name)
		count = 0
		d_str = ""
		for data_slice1 in img_data:
			for data_slice2 in data_slice1:
				for data_slice3 in data_slice2:
					count += 1
					bin_data = data_to_8bit_binary(data_slice3)
					d_str += f'{bin_data:02x}'
					if count % 4 == 0:
						d_str = "0x" + d_str
						val = int(d_str, 0)
						self.su_write_data_trans(base_addr + (count - 4), val)
						d_str = ""
		return None

# read network param file with idx
# write data in little endian on base_addr + i*4
	def su_set_conv_w(self, weight_info, f_name):
		base_addr = weight_info['BASE_ADDR']
		weight_data = np.load(f_name)
		count = 0
		d_str = ""
		for data_slice1 in weight_data:
			for data_slice2 in data_slice1:
				for data_slice3 in data_slice2:
					for data_slice4 in data_slice3:
						count += 1
						bin_data = data_to_8bit_binary(data_slice4)
						d_str += f'{bin_data:02x}'
						if count % 4 == 0:
							d_str = "0x" + d_str
							val = int(d_str, 0)
							self.su_write_data_trans(base_addr + (count - 4), val)
							d_str = ""
		return None

# read network param file with idx
# write data in little endian on base_addr + i*4
	def su_set_conv_b(self, bias_info, f_name):
		base_addr = bias_info['BASE_ADDR']
		bias_data = np.load(f_name)
		count = 0
		d_str = ""
		for data_slice1 in bias_data:
			count += 1
			bin_data = data_to_8bit_binary(data_slice1)
			d_str += f'{bin_data:02x}'
			if count % 4 == 0:
				d_str = "0x" + d_str
				val = int(d_str, 0)
				self.su_write_data_trans(base_addr + (count - 4), val)
				d_str = ""
		return None

# read network param file with idx
# write data in little endian on base_addr + i*4
	def su_set_fc_w(self, weight_info, f_name):
		base_addr = weight_info['BASE_ADDR']
		weight_data = np.load(f_name)
		count = 0
		d_str = ""
		for data_slice1 in weight_data:
			for data_slice2 in data_slice1:
				count += 1
				bin_data = data_to_8bit_binary(data_slice2)
				d_str += f'{bin_data:02x}'
				if count % 4 == 0:
					d_str = "0x" + d_str
					val = int(d_str, 0)
					self.su_write_data_trans(base_addr + (count - 4), val)
					d_str = ""
		return None

# read network param file with idx
# write data in little endian on base_addr + i*4
	def su_set_fc_b(self, bias_info, f_name):
		base_addr = bias_info['BASE_ADDR']
		bias_data = np.load(f_name)
		count = 0
		d_str = ""
		for data_slice1 in bias_data:
			count += 1
			bin_data = data_to_8bit_binary(data_slice1)
			d_str += f'{bin_data:02x}'
			if count % 4 == 0:
				d_str = "0x" + d_str
				val = int(d_str, 0)
				self.su_write_data_trans(base_addr + (count-4), val)
				d_str = ""
		if d_str:
			d_str = "0x" + "{:<08s}".format(d_str)
			val = int(d_str, 0)
			self.su_write_data_trans(base_addr + (count-2), val)
			d_str = ""
		return None

# Set the VDMA 0
# 1) Set result parameter to vdma0 (R)
# 2) Set feature parameter vdma0 (F)
# Feature receive
# 1) Send the commnad to start
# 2) Wait spin-lock (done-flag)
# 3) Send the respond signal
# Set bias parameter to vdma0 (B)
# Bias receive
# 1) Send the commnad to start
# 2) Wait spin-lock (done-flag)
# 3) Send the respond signal
# Set weight parameter to vdma0 (W)
# Weight receive
# 1) Send the commnad to start
# 2) Wait spin-lock (done-flag)
# 3) Send the respond signal
# FC computation
# 1) Send the command to start the computation
# 2) Spin-lock for waiting done-flag
# 3) If receive done flag, send respond signal
# 4) And write the finish sign

	def su_fc_control(self, F, W, B, R, vaddr, faddr):
		#######################################################################
		# You should revise below code
		# Your apb-register and FSM will not match below control flow
		#######################################################################
		# VDMA0 Setting
		# Set result param to vdma0
		self.su_write_data(vaddr + 0x30, 0x00010091)
		self.su_write_data(vaddr + 0xac, R['BASE_ADDR'])
		self.su_write_data(vaddr + 0xa8, R['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0xa4, R['HSIZE'])
		self.su_write_data(vaddr + 0xa0, R['VSIZE'])
		# Set feature param to vdma0
		self.su_write_data(vaddr + 0x00, 0x00010091)
		self.su_write_data(vaddr + 0x5c, F['BASE_ADDR'])
		self.su_write_data(vaddr + 0x58, F['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0x54, F['HSIZE'])
		self.su_write_data(vaddr + 0x50, F['VSIZE'])

		## Write size info to FC module
		self.su_write_data(faddr + 0x14, F['HSIZE']*F['VSIZE'])
		self.su_write_data(faddr + 0x18, B['HSIZE']*B['VSIZE'])

		## Start FC module, timer
		# if(PWDATA[2:0] != 3'b000) fc_start <= 1'b1;
		# COMMAND <= PWDATA[2:0];
		self.su_write_data(faddr + 0x00, 0x1) 

		
		# done = 0
		# while (True):
		#    done = self.su_read_data(faddr + 0x14)
		#    if (int.from_bytes(done, 'big', signed=True) == 1):
		#       break

		## feature receive
		while (True):
			status = self.su_read_data(faddr + 0x04)
			status_val = int.from_bytes(status, 'big', signed=False)
			if (status_val & 0x1): # Bit 0 is F_writedone
				break


		# Set bias param to vdma0
		self.su_write_data(vaddr + 0x00, 0x00010091)
		self.su_write_data(vaddr + 0x5c, B['BASE_ADDR'])
		self.su_write_data(vaddr + 0x58, B['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0x54, B['HSIZE'])
		self.su_write_data(vaddr + 0x50, B['VSIZE'])

		# TB: COMMAND = 3'b010
		self.su_write_data(faddr + 0x00, 0x2)   

		## bias receive
		while (True):
			status = self.su_read_data(faddr + 0x04)
			status_val = int.from_bytes(status, 'big', signed=False)
			if (status_val & 0x2): # Bit 1 is B_writedone
				break


		# Set weight param to vdma0
		self.su_write_data(vaddr + 0x00, 0x00010091)
		self.su_write_data(vaddr + 0x5c, W['BASE_ADDR'])
		self.su_write_data(vaddr + 0x58, W['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0x54, W['HSIZE'])
		self.su_write_data(vaddr + 0x50, W['VSIZE'])
		
		# TB: COMMAND = 3'b100
		self.su_write_data(faddr + 0x00, 0x4)   
		
		## weight receive
		while (True):
			status = self.su_read_data(faddr + 0x04)
			status_val = int.from_bytes(status, 'big', signed=False)
			if (status_val & 0x4): # Bit 2 is cal_done
				break


		# TB: COMMAND = 3'b101
		self.su_write_data(faddr + 0x00, 0x5)

		# wait for done signal
		done = 0
		while True:
			done = self.su_read_data(faddr + 0x0C) # poll fc_done
			if (int.from_bytes(done, 'big', signed=True) == 1):
				break

		# TB: fc_start = 0, COMMAND = 0
		self.su_write_data(faddr + 0x00, 0x0)


		self.check_timing("FC", faddr)
		self.su_write_data(vaddr + 0x00, 0x00010094)
		return 1

# Set the VDMA
# 1) Set result parameter to vdma1 (R)
# 2) Set input parameter vdma1 (I)
# 3) Set feature parameter to vdma2 (F)
# Feature receive
# 1) Send the commnad to start
# 2) Wait spin-lock (done-flag)
# 3) Send the respond signal
# Set bias parameter to vdma1 (B)
# Bias receive
# 1) Send the commnad to start
# 2) Wait spin-lock (done-flag)
# 3) Send the respond signal
# Set weight parameter to vdma1 (W)
# Weight receive
# 1) Send the commnad to start
# 2) Wait spin-lock (done-flag)
# 3) Send the respond signal
# Conv computation
# 1) Send the command to start the computation
# 2) Spin-lock for waiting done-flag
# 3) If receive done flag, send respond signal
# 4) And write the finish sign

	def su_conv_control(self, I, F, W, B, R, vaddr, caddr):
		#######################################################################
		# You should revise below code
		# Your apb-register and FSM will not match below control flow
		#######################################################################
		# I: Input 정보 (채널, 크기 등)
    	# F: Feature Map 주소 정보
    	# W: Weight 주소 정보
    	# B: Bias 주소 정보
    	# R: Result 저장할 주소 정보
		# vaddr: VDMA의 베이스 주소
    	# caddr: CONV 모듈(APB)의 베이스 주소 (예: 0x0D100000)
		
		# VDMA1 Setting
		# Set result param to vdma1
		self.su_write_data(vaddr + 0x30, 0x00010091)
		self.su_write_data(vaddr + 0xac, R['BASE_ADDR'])
		self.su_write_data(vaddr + 0xa8, R['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0xa4, R['HSIZE'])
		self.su_write_data(vaddr + 0xa0, R['VSIZE'])
		# Set input param to conv addr
		self.su_write_data(caddr + 0x24, I['IN_CH'])
		self.su_write_data(caddr + 0x28, I['OUT_CH'])
		self.su_write_data(caddr + 0x2c, I['FLEN'])
		
		## Start Conv module, timer
		self.su_write_data(caddr + 0x00, 1) 

		## Feature load (Command 1)
		# Set feature param to vdma1
		self.su_write_data(vaddr + 0x00, 0x00010091)
		self.su_write_data(vaddr + 0x5c, F['BASE_ADDR'])
		self.su_write_data(vaddr + 0x58, F['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0x54, F['HSIZE'])
		self.su_write_data(vaddr + 0x50, F['VSIZE'])

		self.su_write_data(caddr + 0x20, 0x1) # Command 1로 씀
		# 완료대기 (Polling): caddr + 0x10번지(f_writedone)를 계속 읽어서 1이 될 때까지 기다림
		done = 0
		while (True):
			done = self.su_read_data(caddr + 0x10)
			if (int.from_bytes(done, 'big', signed=True) == 1):
				break
		#self.su_write_data(caddr + 0x10, 0x1) #respond

		## Bias load (Command 2)
		# Set bias param to vdma1
		self.su_write_data(vaddr + 0x00, 0x00010091)
		self.su_write_data(vaddr + 0x5c, B['BASE_ADDR'])
		self.su_write_data(vaddr + 0x58, B['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0x54, B['HSIZE'])
		self.su_write_data(vaddr + 0x50, B['VSIZE'])

		self.su_write_data(caddr + 0x20, 2) # Command 2로 씀
		## 완료 대기: 0x14(b_writedone)
		done = 0
		while (True):
			done = self.su_read_data(caddr + 0x14)
			if (int.from_bytes(done, 'big', signed=True) == 1):
				break
		#self.su_write_data(caddr + 0x14, 0x1) #respond

		## Weight load & Calculate (Command 3)
		# Set weight param to vdma1
		self.su_write_data(vaddr + 0x00, 0x00010091)
		self.su_write_data(vaddr + 0x5c, W['BASE_ADDR'])
		self.su_write_data(vaddr + 0x58, W['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0x54, W['HSIZE'])
		self.su_write_data(vaddr + 0x50, W['VSIZE'])

		self.su_write_data(caddr + 0x20, 3) # Command 3으로 씀
		# 완료 대기: 0x18(cal_done)
		done = 0
		while (True):
			done = self.su_read_data(caddr + 0x18)
			if (int.from_bytes(done, 'big', signed=True) == 1):
				break
		#self.su_write_data(caddr + 0x18, 0x1) #respond

		## Send Result (Command 4)
		self.su_write_data(caddr + 0x20, 4) # Command 4로 씀
		# 완료 대기: 0x1C(transmit_done)
		done = 0
		while (True):
			done = self.su_read_data(caddr + 0x1c)
			if (int.from_bytes(done, 'big', signed=True) == 1):
				break

		'''if (I['IN_CH'] == 256):
			while (True):
				done = self.su_read_data(caddr + 0x2c)  # poll transmit_done
				if (int.from_bytes(done, 'big', signed=True) == 1):
					break
			done = 0
			self.su_write_data(caddr + 0x00, 0x3) #command: RECV W & CALCULATE
			while (True):
				done = self.su_read_data(caddr + 0x28)
				if (int.from_bytes(done, 'big', signed=True) == 1):
					break
			#self.su_write_data(caddr + 0x18, 0x1) #respond
			# Wait for done signal
			done = 0
			self.su_write_data(caddr + 0x00, 0x4) #command: SEND Y
		'''

		# 최종 완료 확인: 0x04(conv_done)
		while (True):
			done = self.su_read_data(caddr + 0x04)  # poll conv_done
			if (int.from_bytes(done, 'big', signed=True) == 1):
				break
		#self.check_timing("Conv", caddr)
		#self.su_write_data(caddr + 0x1c, 0x1) #respond
		
		# Finish & Reset
		self.su_write_data(caddr + 0x00, 0) # Start 신호 끄기
		self.su_write_data(caddr + 0x20, 0) # Command reset
		self.su_write_data(vaddr + 0x00, 0x00010094) # VDMA 초기화
		# print("Conv done.")
		return 1

# Set the VDMA2
# 1) Set the result parameter to vdma2 (R)
# 2) Set the feature parameter to vdma2 (F)
# 3) Set the input parameter to pool_base_addr
# Pool computation
# 1) Send the command to start the computation
# 2) Spin-lock for waiting done-flag
# 3) If receive the done flag, send respond signal
# 4) And write the finish sign
	def su_pool_control(self, I, F, R, vaddr, paddr):
		#######################################################################
		# You should revise below code
		# Your apb-register and FSM will not match below control flow
		#######################################################################

		# Set result param to vdma2
		self.su_write_data(vaddr + 0x30, 0x00010091)
		self.su_write_data(vaddr + 0xac, R['BASE_ADDR'])
		self.su_write_data(vaddr + 0xa8, R['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0xa4, R['HSIZE'])
		self.su_write_data(vaddr + 0xa0, R['VSIZE'])

		# Set input param, then start the max-pool proc
		self.su_write_data(paddr + 0x10, I['FLEN'])
		self.su_write_data(paddr + 0x14, I['IN_CH'])

		# Set feature param to vdma2
		self.su_write_data(vaddr + 0x00, 0x00010091)
		self.su_write_data(vaddr + 0x5c, F['BASE_ADDR'])
		self.su_write_data(vaddr + 0x58, F['STRIDE_SIZE'])
		self.su_write_data(vaddr + 0x54, F['HSIZE'])
		self.su_write_data(vaddr + 0x50, F['VSIZE'])

		## Start Pool module, timer
		self.su_write_data(paddr + 0x00, 1) 

		done = 0
		# 완료 대기 (Done: 0x04)
		while (True):
			done = self.su_read_data(paddr + 0x04)
			if (int.from_bytes(done, 'big', signed=True) == 1):
				break
		#self.check_timing("Pool", paddr)

		self.su_write_data(paddr + 0x00, 0x0) # Reset module
		self.su_write_data(vaddr + 0x00, 0x00010094)

		return 1


####################### RESULT CHECK
	def check_timing(self, name, module_addr):
		clk_cnt = self.su_read_data(module_addr+0x8)
		clk_cnt = int.from_bytes(clk_cnt, 'big', signed=True) 
