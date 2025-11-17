from utils.scale_uart import *
import time

def set_weight(SU):
	### Load network parameter
	
	# Conv1 
	print("conv1 parameter load")
	start = time.time()
	SU.su_set_conv_w({'BASE_ADDR': 0x0200_0000}, "./data/cifar10_network_quan_param/cifar10_conv1_weight_quan.npy")
	SU.su_set_conv_b({'BASE_ADDR': 0x0210_0000}, "./data/cifar10_network_quan_param/cifar10_conv1_bias_quan.npy")
	print("conv1 set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))

	# Conv2
	print("conv2 parameter load")
	start = time.time()
	SU.su_set_conv_w({'BASE_ADDR': 0x0220_0000}, "./data/cifar10_network_quan_param/cifar10_conv2_weight_quan.npy")
	SU.su_set_conv_b({'BASE_ADDR': 0x0270_0000}, "./data/cifar10_network_quan_param/cifar10_conv2_bias_quan.npy")
	print("conv2 set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))


	# Conv3
	print("conv3 parameter load")
	start = time.time()
	SU.su_set_conv_w({'BASE_ADDR': 0x0280_0000}, "./data/cifar10_network_quan_param/cifar10_conv3_weight_quan.npy")
	SU.su_set_conv_b({'BASE_ADDR': 0x02C0_0000}, "./data/cifar10_network_quan_param/cifar10_conv3_bias_quan.npy")
	print("conv3 set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))


	# Conv4 
	print("conv4 parameter load")
	start = time.time()
	SU.su_set_conv_w({'BASE_ADDR': 0x0300_0000}, "./data/cifar10_network_quan_param/cifar10_conv4_weight_quan.npy")
	SU.su_set_conv_b({'BASE_ADDR': 0x0390_0000}, "./data/cifar10_network_quan_param/cifar10_conv4_bias_quan.npy")
	print("conv4 set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))


	# Conv5 
	print("conv5 parameter load")
	start = time.time()
	SU.su_set_conv_w({'BASE_ADDR': 0x03A0_0000}, "./data/cifar10_network_quan_param/cifar10_conv5_weight_quan.npy")
	SU.su_set_conv_b({'BASE_ADDR': 0x03F0_0000}, "./data/cifar10_network_quan_param/cifar10_conv5_bias_quan.npy")
	print("conv5 set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))


	# Conv6
	print("conv6 parameter load")
	start = time.time()
	SU.su_set_conv_w({'BASE_ADDR': 0x0400_0000}, "./data/cifar10_network_quan_param/cifar10_conv6_weight_quan.npy")
	SU.su_set_conv_b({'BASE_ADDR': 0x0490_0000}, "./data/cifar10_network_quan_param/cifar10_conv6_bias_quan.npy")
	print("conv6 set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))


	# FC1 
	print("fc1 parameter load")
	start = time.time()
	SU.su_set_fc_w({'BASE_ADDR': 0x0500_0000}, "./data/cifar10_network_quan_param/cifar10_fc1_weight_quan.npy")
	SU.su_set_fc_b({'BASE_ADDR': 0x0530_0000}, "./data/cifar10_network_quan_param/cifar10_fc1_bias_quan.npy")
	print("fc1 set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))


	# FC2
	print("fc2 parameter load")
	start = time.time()
	SU.su_set_fc_w({'BASE_ADDR': 0x0540_0000}, "./data/cifar10_network_quan_param/cifar10_fc2_weight_quan.npy")
	SU.su_set_fc_b({'BASE_ADDR': 0x0550_0000}, "./data/cifar10_network_quan_param/cifar10_fc2_bias_quan.npy")
	print("fc2 set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))


	# FC3
	print("fc3 parameter load")
	start = time.time()
	SU.su_set_fc_w({'BASE_ADDR': 0x0560_0000}, "./data/cifar10_network_quan_param/cifar10_fc3_weight_quan.npy")
	SU.su_set_fc_b({'BASE_ADDR': 0x0570_0000}, "./data/cifar10_network_quan_param/cifar10_fc3_bias_quan.npy")
	print("fc3 set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))


# Load data X
def load_data(SU):
	# Image address memory map  
	start = time.time()
	SU.su_write_data(0x0000_0000, 3)
	data = SU.su_read_data(0x0000_0000)
	SU.su_set_image({'BASE_ADDR': 0x0000_0000}, "./data/cifar10_dataset_quan/images_100.npy")
	print("image set done")
	print("\tTotal time: {:.2f} sec".format(time.time() - start))

# ### INFERENCE
# ### Example code for one image step by step
# ### All Inference function
def inference(SU: Scale_UART, n_data: int):
	
	pred_list = []
	
	### Setting the VDMA
	## IT IS VDMA AND EACH MODULE'S BASE ADDRESS FOR CONTROL APB + AXI
	##### PARAMETER INFORMATION
	VDMA0_BASE_ADDR= 0x0c00_0000
	VDMA1_BASE_ADDR= 0x0c10_0000
	VDMA2_BASE_ADDR= 0x0c20_0000

	FC_BASE_ADDR   = 0x0d00_0000
	CONV_BASE_ADDR = 0x0d10_0000
	POOL_BASE_ADDR = 0x0d20_0000
	
	### Settings FOR OUR NETWORK
	OP_SIZE                        = 4
	ADDR_SIZE                      = 28
	DATA_SIZE                      = 32

	### Load data to inference
	load_data(SU)

	for image_idx in range(n_data):
		I = {'IN_CH': 3, 'OUT_CH': 32, 'FLEN': 32}
		F = {'BASE_ADDR': 0x0000_0000 + 3072*image_idx, 'STRIDE_SIZE': 3*32*32, 'HSIZE': 3*32*32, 'VSIZE': 1}
		W = {'BASE_ADDR': 0x0200_0000, 'STRIDE_SIZE': 3*32*9, 'HSIZE': 3*32*9, 'VSIZE': 1}
		B = {'BASE_ADDR': 0x0210_0000, 'STRIDE_SIZE': 32, 'HSIZE': 32, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0600_0000, 'STRIDE_SIZE': 32*32*32, 'HSIZE': 32*32*32, 'VSIZE': 1}
		SU.su_conv_control(I, F, W, B, R, VDMA1_BASE_ADDR, CONV_BASE_ADDR)
		I = {'IN_CH': 32, 'FLEN': 32}
		F = {'BASE_ADDR': 0x0600_0000, 'STRIDE_SIZE': 32*32*32, 'HSIZE': 32*32*32, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0610_0000, 'STRIDE_SIZE': 32*16*16, 'HSIZE': 32*16*16, 'VSIZE': 1}
		SU.su_pool_control(I, F, R, VDMA2_BASE_ADDR, POOL_BASE_ADDR)
		I = {'IN_CH': 32, 'OUT_CH': 64, 'FLEN': 16}
		F = {'BASE_ADDR': 0x0610_0000, 'STRIDE_SIZE': 32*16*16, 'HSIZE': 32*16*16, 'VSIZE': 1}
		W = {'BASE_ADDR': 0x0220_0000, 'STRIDE_SIZE': 32*64*9, 'HSIZE': 32*64*9, 'VSIZE': 1}
		B = {'BASE_ADDR': 0x0270_0000, 'STRIDE_SIZE': 64, 'HSIZE': 64, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0620_0000, 'STRIDE_SIZE': 64*16*16, 'HSIZE': 64*16*16, 'VSIZE': 1}
		SU.su_conv_control(I, F, W, B, R, VDMA1_BASE_ADDR, CONV_BASE_ADDR)
		I = {'IN_CH': 64, 'FLEN': 16}
		F = {'BASE_ADDR': 0x0620_0000, 'STRIDE_SIZE': 64*16*16, 'HSIZE': 64*16*16, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0630_0000, 'STRIDE_SIZE': 64*8*8, 'HSIZE': 64*8*8, 'VSIZE': 1}
		SU.su_pool_control(I, F, R, VDMA2_BASE_ADDR, POOL_BASE_ADDR)
		I = {'IN_CH': 64, 'OUT_CH': 128, 'FLEN': 8}
		F = {'BASE_ADDR': 0x0630_0000, 'STRIDE_SIZE': 64*8*8, 'HSIZE': 64*8*8, 'VSIZE': 1}
		W = {'BASE_ADDR': 0x0280_0000, 'STRIDE_SIZE': int(64*128*9/2), 'HSIZE': int(64*128*9/2), 'VSIZE': 2}
		B = {'BASE_ADDR': 0x02C0_0000, 'STRIDE_SIZE': 128, 'HSIZE': 128, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0640_0000, 'STRIDE_SIZE': 128*8*8, 'HSIZE': 128*8*8, 'VSIZE': 1}
		SU.su_conv_control(I, F, W, B, R, VDMA1_BASE_ADDR, CONV_BASE_ADDR)
		I = {'IN_CH': 128, 'OUT_CH': 128, 'FLEN': 8}
		F = {'BASE_ADDR': 0x0640_0000, 'STRIDE_SIZE': 128*8*8, 'HSIZE': 128*8*8, 'VSIZE': 1}
		W = {'BASE_ADDR': 0x0300_0000, 'STRIDE_SIZE': int(128*128*9/4), 'HSIZE': int(128*128*9/4), 'VSIZE': 4}
		B = {'BASE_ADDR': 0x0390_0000, 'STRIDE_SIZE': 128, 'HSIZE': 128, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0650_0000, 'STRIDE_SIZE': 128*8*8, 'HSIZE': 128*8*8, 'VSIZE': 1}
		SU.su_conv_control(I, F, W, B, R, VDMA1_BASE_ADDR, CONV_BASE_ADDR)
		I = {'IN_CH': 128, 'FLEN': 8}
		F = {'BASE_ADDR': 0x0650_0000, 'STRIDE_SIZE': 128*8*8, 'HSIZE': 128*8*8, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0660_0000, 'STRIDE_SIZE': 128*4*4, 'HSIZE': 128*4*4, 'VSIZE': 1}
		SU.su_pool_control(I, F, R, VDMA2_BASE_ADDR, POOL_BASE_ADDR)
		I = {'IN_CH': 128, 'OUT_CH': 256, 'FLEN': 4}
		F = {'BASE_ADDR': 0x0660_0000, 'STRIDE_SIZE': 128*4*4, 'HSIZE': 128*4*4, 'VSIZE': 1}
		W = {'BASE_ADDR': 0x03A0_0000, 'STRIDE_SIZE': int(128*256*9/8), 'HSIZE': int(128*256*9/8), 'VSIZE': 8}
		B = {'BASE_ADDR': 0x03F0_0000, 'STRIDE_SIZE': 256, 'HSIZE': 256, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0670_0000, 'STRIDE_SIZE': 256*4*4, 'HSIZE': 256*4*4, 'VSIZE': 1}
		SU.su_conv_control(I, F, W, B, R, VDMA1_BASE_ADDR, CONV_BASE_ADDR)
		I = {'IN_CH': 256, 'OUT_CH': 256, 'FLEN': 4}
		F = {'BASE_ADDR': 0x0670_0000, 'STRIDE_SIZE': 256*4*4, 'HSIZE': 256*4*4, 'VSIZE': 1}
		W = {'BASE_ADDR': 0x0400_0000, 'STRIDE_SIZE': int(256*256*9/16), 'HSIZE': int(256*256*9/16), 'VSIZE': 16}
		B = {'BASE_ADDR': 0x0490_0000, 'STRIDE_SIZE': 256, 'HSIZE': 256, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0680_0000, 'STRIDE_SIZE': 256*4*4, 'HSIZE': 256*4*4, 'VSIZE': 1}
		SU.su_conv_control(I, F, W, B, R, VDMA1_BASE_ADDR, CONV_BASE_ADDR)
		I = {'IN_CH': 256, 'FLEN': 4}
		F = {'BASE_ADDR': 0x0680_0000, 'STRIDE_SIZE': 256*4*4, 'HSIZE': 256*4*4, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x0690_0000, 'STRIDE_SIZE': 256*2*2, 'HSIZE': 256*2*2, 'VSIZE': 1}
		SU.su_pool_control(I, F, R, VDMA2_BASE_ADDR, POOL_BASE_ADDR)
		F = {'BASE_ADDR': 0x0690_0000, 'STRIDE_SIZE': 1024, 'HSIZE': 1024, 'VSIZE': 1}
		W = {'BASE_ADDR': 0x0500_0000, 'STRIDE_SIZE': int(1024*256/8), 'HSIZE': int(1024*256/8), 'VSIZE': 8}
		B = {'BASE_ADDR': 0x0530_0000, 'STRIDE_SIZE': 256, 'HSIZE': 256, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x06A0_0000, 'STRIDE_SIZE': 256, 'HSIZE': 256, 'VSIZE': 1}
		SU.su_fc_control(F, W, B, R, VDMA0_BASE_ADDR, FC_BASE_ADDR)
		F = {'BASE_ADDR': 0x06A0_0000, 'STRIDE_SIZE': 256, 'HSIZE': 256, 'VSIZE': 1}
		W = {'BASE_ADDR': 0x0540_0000, 'STRIDE_SIZE': 256*64, 'HSIZE': 256*64, 'VSIZE': 1}
		B = {'BASE_ADDR': 0x0550_0000, 'STRIDE_SIZE': 64, 'HSIZE': 64, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x06B0_0000, 'STRIDE_SIZE': 64, 'HSIZE': 64, 'VSIZE': 1}
		SU.su_fc_control(F, W, B, R, VDMA0_BASE_ADDR, FC_BASE_ADDR)
		F = {'BASE_ADDR': 0x06B0_0000, 'STRIDE_SIZE': 64, 'HSIZE': 64, 'VSIZE': 1}
		W = {'BASE_ADDR': 0x0560_0000, 'STRIDE_SIZE': 640, 'HSIZE': 640, 'VSIZE': 1}
		B = {'BASE_ADDR': 0x0570_0000, 'STRIDE_SIZE': 10, 'HSIZE': 10, 'VSIZE': 1}
		R = {'BASE_ADDR': 0x06C0_0000, 'STRIDE_SIZE': 10, 'HSIZE': 10, 'VSIZE': 1}
		SU.su_fc_control(F, W, B, R, VDMA0_BASE_ADDR, FC_BASE_ADDR)
	
		##############################################################################################
		# Below code can be revised according to your apb register setting
		##############################################################################################
		pred = SU.su_read_data(FC_BASE_ADDR + 0x20)
		pred = int.from_bytes(pred, 'big', signed=True)
		
		pred_list.append(pred - 1)

		print( "Progress: [{:03}/{:03}]".format(( image_idx + 1), n_data), end="\r", flush=True )

	return pred_list

